using System;

using Foundation;
using AppKit;
using CoreGraphics;
using RestSharp;
using System.Threading;
using System.Text.RegularExpressions;

namespace MALLibrary
{
	public partial class MainWindowController : NSWindowController
	{
		
		int aniinfoid = 0;
		NSDictionary currentaniinfo;
		NSArray seasonindex;
		public MyAnimeList malengine { get; set; }
		public MainWindowController(IntPtr handle) : base(handle)
		{
		}


		[Export("initWithCoder:")]
		public MainWindowController(NSCoder coder) : base(coder)
		{
		}

		public MainWindowController() : base("MainWindow")
		{
		}

		public override void AwakeFromNib()
		{
			base.AwakeFromNib();
			// Use Unified Toolbar Title Bar
			base.Window.TitleVisibility = NSWindowTitleVisibility.Hidden;
			base.Window.SetFrame(base.Window.Frame, true);
			// Fix TextView text color
			backgroundtextview.TextColor = NSColor.ControlText;
			detailstextview.TextColor = NSColor.ControlText;
			synopsistextview.TextColor = NSColor.ControlText;
			// Set Main Views to be resizable
			searchview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			listview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			animeinfoview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			progressview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			seasonsview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			//Set up list view
			sourcelist.Initialize();
			generatesourcelist();
			performappearencechange();
		}
		private void generatesourcelist()
		{
			var library = new SourceListItem("LIBRARY");
			library.AddItem("Anime List", NSImage.ImageNamed("library"), this.loadmainview);
			sourcelist.AddItem(library);
			var discover = new SourceListItem("DISCOVER");
			discover.AddItem("Search", NSImage.ImageNamed("search"), this.loadmainview);
			discover.AddItem("Title Info", NSImage.ImageNamed("animeinfo"), this.loadmainview);
			discover.AddItem("Seasons", NSImage.ImageNamed("seasons"), this.loadmainview);
			sourcelist.AddItem(discover);

			// Display side list
			sourcelist.ReloadData();
			sourcelist.ExpandItem(null, true);

			// Retrieve last used main view
			if (NSUserDefaults.StandardUserDefaults.ValueForKey(new NSString("selectedmainview")) != null)
			{
				NSNumber selected = (NSNumber)NSUserDefaults.StandardUserDefaults.ValueForKey(new NSString("selectedmainview"));
				sourcelist.SelectRow(selected.NIntValue, false);
			}
			else
			{
				sourcelist.SelectRow(1, false);
			}
		}

		private void loadmainview()
		{
			// Loads the view based on the selection from the source list
			CGRect mainviewframe = mainview.Frame;
			mainview.AddSubview(new NSView());
			nint selectedrow = sourcelist.SelectedRow;
			CGPoint origin = new CGPoint();
			origin.X = 0;
			origin.Y = 0;
			var selecteditem = (SourceListItem)sourcelist.ItemAtRow(sourcelist.SelectedRow);
			switch (selecteditem.Title)
			{
				case "Anime List":
					mainview.ReplaceSubviewWith(mainview.Subviews[0], listview);
					listview.Frame = mainviewframe;
					listview.SetFrameOrigin(origin);
					//toolbar.InsertItem("filter", 2);
				break;
				case "Search":
					mainview.ReplaceSubviewWith(mainview.Subviews[0], searchview);
					searchview.Frame = mainviewframe;
					searchview.SetFrameOrigin(origin);
					listview.SetFrameOrigin(origin);
					break;
				case "Title Info":
					if (aniinfoid != 0)
					{
						mainview.ReplaceSubviewWith(mainview.Subviews[0], animeinfoview);
						animeinfoview.Frame = mainviewframe;
						animeinfoview.SetFrameOrigin(origin);
					}
					else {
						mainview.ReplaceSubviewWith(mainview.Subviews[0], progressview);
						progressview.Frame = mainviewframe;
						progressview.SetFrameOrigin(origin);
						noinfo.Hidden = false;
						loadingwheel.Hidden = true;
					}
					break;
				case "Seasons":
					mainview.ReplaceSubviewWith(mainview.Subviews[0], seasonsview);
					seasonsview.Frame = mainviewframe;
					seasonsview.SetFrameOrigin(origin);
					break;
			}
			this.createtoolbar();
			// Save Current Main View
			NSUserDefaults.StandardUserDefaults.SetValueForKey(new NSNumber(sourcelist.SelectedRow), new NSString("selectedmainview"));
		}
		public void createtoolbar()
		{
			// Shows toolbar items based on current main view.
			NSToolbarItem[] items = toolbar.Items;
			if (items != null)
			{
				for (nint i = 0; i < items.Length; i++)
				{
					toolbar.RemoveItem(0);
				}
			}
			// Create toolbar
			var selecteditem = (SourceListItem)sourcelist.ItemAtRow(sourcelist.SelectedRow);
			switch (selecteditem.Title)
			{
				case "Anime List":
					toolbar.InsertItem("refresh", 0);
					toolbar.InsertItem("Share", 1);
					toolbar.InsertItem("NSToolbarFlexibleSpaceItem", 2);
					toolbar.InsertItem("filter", 3);
					break;
				case "Search":
					toolbar.InsertItem("AddTitle", 0);
					toolbar.InsertItem("NSToolbarFlexibleSpaceItem", 1);
					toolbar.InsertItem("search", 2);
					break;
				case "Title Info":
					if (aniinfoid != 0)
					{
						
							toolbar.InsertItem("AddTitle", 0);
							toolbar.InsertItem("viewonmal", 1);
						toolbar.InsertItem("Share", 2);
					}
					break;
				case "Seasons":
					toolbar.InsertItem("AddTitle", 0);
					toolbar.InsertItem("yearselect", 1);
					toolbar.InsertItem("seasonselect",2);
					toolbar.InsertItem("refresh", 3);
					if (seasonindex == null)
					{
						this.retrieveseasonindex(false);
					}
					break;
			}
		}

		public new MainWindow Window
		{
			get { return (MainWindow)base.Window; }
		}
		// Toolbar Functions
		partial void performfilter(Foundation.NSObject sender)
		{

		}
		partial void performrefresh(Foundation.NSObject sender)
		{
			var selecteditem = (SourceListItem)sourcelist.ItemAtRow(sourcelist.SelectedRow);
			switch (selecteditem.Title)
			{
				case "Anime List":
					return;
				case "Seasons":
					this.performseasondatarefresh();
					break;
			}
		}
		partial void opensharemenu(Foundation.NSObject sender)
		{
			// Share Menu
			var selecteditem = (SourceListItem)sourcelist.ItemAtRow(sourcelist.SelectedRow);
			NSObject[] shareitems = new NSObject[2];
			// Generate share items based on which view the Share button has been pressed.
			switch (selecteditem.Title)
			{
				case "Anime List":
					return;
				case "Title Info":
					shareitems[0] = new NSString("Check " + animeinfotitle.StringValue + " out - ");
					shareitems[1] = new NSUrl("https://myanimelist.net/anime/" + aniinfoid);
					break;
			}
			NSSharingServicePicker picker = new NSSharingServicePicker(shareitems);
			NSButton btn = (NSButton)sender;
			picker.ShowRelativeToRect(btn.Bounds, btn, NSRectEdge.MinYEdge);
		}
		partial void addtitle(Foundation.NSObject sender)
		{
			NSButton btn = (NSButton)sender;
			addpopover.Show(btn.Bounds, btn, NSRectEdge.MinYEdge);
		}
		partial void removetitle(Foundation.NSObject sender)
		{
			NSAlert a = new NSAlert();
			a.MessageText = "Implement Remove Title";
			long l = a.RunModal();
		}
		partial void edittitle(Foundation.NSObject sender)
		{
			NSAlert a = new NSAlert();
			a.MessageText = "Implement Edit Title";
			long l = a.RunModal();
		}
		partial void viewonmal(Foundation.NSObject sender)
		{
			// Opens the anime title's page on MyAnimeList
			NSUrl link = new NSUrl("https://myanimelist.net/anime/" + aniinfoid);
			NSWorkspace.SharedWorkspace.OpenUrl(link);
		}
		// Searchview
		partial void performsearch(Foundation.NSObject sender)
		{
			// Performs Search
			string term = searchbox.StringValue;
			// Create Thread
			Thread thread = new Thread(() => performsearch(term));
			// Perform Search
			thread.Start();
		}
		private void performsearch(string term)
		{
			IRestResponse response = malengine.search(term);
			if (response.StatusCode.GetHashCode() == 200)
			{
				InvokeOnMainThread(() =>
				{
					// Populate data in Search Table View
					this.loadsearchdata(response.Content);
				});
			}
		}
		private void loadsearchdata(String content)
		{
			// Populates search data from JSON
			NSMutableArray a = (NSMutableArray)this.searcharraycontroller.Content;
			a.RemoveAllObjects();
			// Deserialize JSON
			NSData data = NSData.FromString(content);
			NSError e;
			NSArray searchdata = (NSArray)NSJsonSerialization.Deserialize(data, 0, out e);
			// Populate Table View
			this.searcharraycontroller.AddObjects(searchdata);
			this.stb.ReloadData();
			this.stb.DeselectAll(Self);
		}
		partial void searchtbdoubleclick(Foundation.NSObject sender)
		{
			if (stb.ClickedRow >= 0)
			{
				if ((int)searcharraycontroller.SelectionIndex >= -1)
				{
					// Loads Anime Information
					this.searchtableclick();
				}
			}
		}
		public void searchtableclick()
		{
			NSDictionary d = (NSDictionary)searcharraycontroller.SelectedObjects[0];
			NSNumber idnum = (NSNumber)d.ValueForKey(new NSString("id"));

			Thread t = new Thread((obj) => loadAnimeInfo(idnum.Int32Value));
			t.Start();
		}
		// Anime Information View
		private void loadAnimeInfo(int id)
		{
			// Change page to Anime Info
			int tmpid = aniinfoid;
			aniinfoid = 0;
			InvokeOnMainThread(() =>
				{
					// Change Source List selection to Anime Info
					sourcelist.SelectRow(4,false);
					noinfo.Hidden = true;
					loadingwheel.Hidden = false;
					loadingwheel.StartAnimation(null);
				});
			IRestResponse response = malengine.loadanimeinfo(id);
			if (response.StatusCode.GetHashCode() == 200)
			{
				// Deserialize data
				NSData data = NSData.FromString(response.Content);
				NSError e;
				NSDictionary animedata = (NSDictionary)NSJsonSerialization.Deserialize(data, 0, out e);
				currentaniinfo = animedata;
				InvokeOnMainThread(() =>
				{
					populateanimeinfo(id, animedata);
				});
			}
			else {
				aniinfoid = tmpid;
				InvokeOnMainThread(() =>
				{
					loadingwheel.StopAnimation(null);
					this.loadmainview();
				});
			}
		}

		private void populateanimeinfo(int id, NSDictionary animedata)
		{
			// Populate Anime Information
			animeinfotitle.StringValue = (NSString)animedata.ValueForKey(new NSString("title")).ToString();
			alternativetitlelbl.StringValue = this.generatetitleslist(animedata);
			NSImage img = SupportFiles.retrieveImage((NSString)animedata.ValueForKey(new NSString("image_url")),id);
			posterimage.Image = img;
			NSNumber rank = (NSNumber)animedata.ValueForKey(new NSString("rank"));
			NSNumber popularityrank = (NSNumber)animedata.ValueForKey(new NSString("popularity_rank"));
			string type = (NSString)animedata.ValueForKey(new NSString("type")).ToString();
			NSNumber episodes = (NSNumber)animedata.ValueForKey(new NSString("episodes"));
			string status = (NSString)animedata.ValueForKey(new NSString("status")).ToString();
			NSNumber duration = (NSNumber)animedata.ValueForKey(new NSString("duration"));
			string classification = (NSString)animedata.ValueForKey(new NSString("classification")).ToString();
			NSNumber memberscore = (NSNumber)animedata.ValueForKey(new NSString("members_score"));
			NSNumber memberscount = (NSNumber)animedata.ValueForKey(new NSString("members_count"));
			NSArray genrelist = (NSArray)animedata.ValueForKey(new NSString("genres"));
			string genres = "None";
			//Populate Genres
			if (genrelist != null){
				for (nuint i = 0; i <  genrelist.Count; i++)
				{
					if (i == 0)
					{
						genres = genrelist.GetItem<NSString>(i).ToString();
					}
					else {
						genres = genres + ", " + genrelist.GetItem<NSString>(i).ToString();
					}
				}
			}
			NSNumber favoritedcount = (NSNumber)animedata.ValueForKey(new NSString("favorited_count"));
			string detail = "Type: " + type + System.Environment.NewLine;
			if (episodes == null)
			{
				if (duration == null)
				{
					detail = detail + "Episodes: Unknown" + System.Environment.NewLine;

				}
				else {
					detail = detail + "Episodes: Unknown (" + duration.Int32Value + " mins long per episode)" + System.Environment.NewLine;
				}
			}
			else {
				if (duration == null)
				{
					detail = detail + "Episodes: " + episodes.Int32Value + System.Environment.NewLine;

				}
				else {
					detail = detail + "Episodes: " + episodes.Int32Value + " (" + duration.Int32Value + " mins long per episode)" + System.Environment.NewLine;

				}
			}
			detail = detail + "Status: " + status + System.Environment.NewLine;
			detail = detail + "Genres: " + genres + System.Environment.NewLine;
			detail = detail + "Classification: " + classification + System.Environment.NewLine;
			detail = detail + "Score: " + memberscore.FloatValue + " (" + memberscount.Int32Value + " users, ranked " + rank.Int32Value + ")" + System.Environment.NewLine;
			detail = detail + "Popularity: " + popularityrank.Int32Value + System.Environment.NewLine;
			detail = detail + "Favorites: " + favoritedcount.Int32Value;
			detailstextview.Value = detail;
			if (animedata.ValueForKey(new NSString("background")) != null)
			{
				backgroundtextview.Value = StripHTML((NSString)animedata.ValueForKey(new NSString("background")).ToString());
			}
			else {
				backgroundtextview.Value = "None available.";
			}
			synopsistextview.Value = StripHTML((NSString)animedata.ValueForKey(new NSString("synopsis")).ToString());
			loadingwheel.StopAnimation(null);
			aniinfoid = id;
			this.loadmainview();
		}
		private string generatetitleslist(NSDictionary d)
		{
			NSMutableArray a = new NSMutableArray();
			NSDictionary titles = (NSDictionary)d.ValueForKey(new NSString("other_titles"));
			for (int i = 0; i < 3; i++)
			{
				NSArray titleslist = new NSArray();
				switch (i)
				{
					
					case 0:
						if ((NSArray)titles.ValueForKey(new NSString("english")) != null)
						{
							titleslist = (NSArray)titles.ValueForKey(new NSString("english"));
						}
						break;
					case 1:
						if ((NSArray)titles.ValueForKey(new NSString("japanese")) != null)
						{
							titleslist = (NSArray)titles.ValueForKey(new NSString("japanese"));
						}
						break;
					case 2:
						if ((NSArray)titles.ValueForKey(new NSString("synonyms")) != null)
						{
							titleslist = (NSArray)titles.ValueForKey(new NSString("synonyms"));
						}
						break;
				}

				for (nuint s = 0; s < titleslist.Count; s++){
					a.Add(titleslist.GetItem<NSString>(s));
				}
			}
			string strtitles = "";
			for (nuint i = 0; i < a.Count; i++)
			{
				if (i == 0)
				{
					strtitles = (NSString)a.GetItem<NSString>(i).ToString();
				}
				else {
					strtitles = strtitles + ", " + (NSString)a.GetItem<NSString>(i).ToString();
				}
			}
			return strtitles;
		}
		// Season View
		private void performseasondatarefresh()
		{
			// Create Thread
			Thread thread = new Thread(new ThreadStart(refreshseasondata));
			// Perform Search
			thread.Start();
		}
		private void refreshseasondata()
		{
			string content = SupportFiles.retrieveSeasonIndex(true);
			if (content.Length > 0)
			{
				bool success = SupportFiles.retrieveallseasondata(true);
				InvokeOnMainThread(() =>
				{
					// Refresh popup menus and populate season data
					retrieveseasonindex(false);
				});
			}
		}
		private void performseasonindexretrieval()
		{
			// Create Thread
			Thread thread = new Thread(() => retrieveseasonindex(false));
			// Perform Search
			thread.Start();
		}
		private void retrieveseasonindex(bool refreshindex)
		{
			// Retrieves Season Data 
			string content = SupportFiles.retrieveSeasonIndex(refreshindex);
			if (content.Length > 0)
			{
				InvokeOnMainThread(() =>
				{
					// Populate data in Search Table View
					this.populateyearpopup(content);
					seasonyrselect.SelectItem(seasonyrselect.ItemCount - 1); //Select current year;
					this.populateseasonpopup((nuint)seasonyrselect.IndexOfSelectedItem);
					if (seasonselect.ItemCount - 1 >= 0)
					{
						seasonselect.SelectItem(seasonselect.ItemCount - 1); //Select most recent season, only if it has more than two seasons;
					}
					this.performseasondata();
				});
			}
			else
			{
				seasonyrselect.RemoveAllItems();
				seasonselect.RemoveAllItems();
			}
		}
		private void populateyearpopup(string content)
		{
			seasonyrselect.RemoveAllItems();
			if (seasonindex != null)
			{
				seasonindex = new NSArray();
			}
			// Deserialize JSON
			NSData data = NSData.FromString(content);
			NSError e;
			NSDictionary d = (NSDictionary)NSJsonSerialization.Deserialize(data, 0, out e);
			seasonindex = (NSArray)d.ValueForKey(new NSString("years"));
			for (int i = 0; i < (int)seasonindex.Count; i++)
			{
				NSDictionary yr = seasonindex.GetItem<NSDictionary>((nuint)i);
				seasonyrselect.AddItem((NSString)yr.ValueForKey(new NSString("year")).ToString());
			}
		}
		private void populateseasonpopup(nuint selected)
		{
			seasonselect.RemoveAllItems();
			NSDictionary d = seasonindex.GetItem<NSDictionary>(selected);
			NSArray seasons = (NSArray)d.ValueForKey(new NSString("seasons"));
			for (nuint i = 0; i < seasons.Count; i++)
			{
				NSDictionary s = seasons.GetItem<NSDictionary>(i);
				seasonselect.AddItem((NSString)s.ValueForKey(new NSString("season")).ToString());
			}
		}
		partial void yearchanged(Foundation.NSObject sender)
		{
			this.populateseasonpopup((nuint)seasonyrselect.IndexOfSelectedItem);
			this.performseasondata();
		}
		partial void seasonchanged(Foundation.NSObject sender)
		{
			this.performseasondata();
		}
		private void performseasondata()
		{
			// Retrieve JSON Season URL
			NSDictionary d = seasonindex.GetItem<NSDictionary>((System.nuint)seasonyrselect.IndexOfSelectedItem);
			string year = d.ValueForKey((NSString)"year").ToString();
			NSArray a1 = (NSArray)d.ValueForKey((NSString)"seasons");
			d = a1.GetItem<NSDictionary>((System.nuint)seasonselect.IndexOfSelectedItem);
			string season = d.ValueForKey((NSString)"season").ToString();
			// Create Thread
			Thread thread = new Thread(() => this.loadseasondata(season,year));
			// Perform Search
			thread.Start();
		}
		private void loadseasondata(string season, string year)
		{
			// Retrieves Season Data 
			string content = SupportFiles.retrievedataforyrseason(year, season, false);
			if (content.Length > 0)
			{
				InvokeOnMainThread(() =>
				{
					// Populate data in Search Table View
					this.performseasondatapop(content);
				});
			}
		}
		private void performseasondatapop(string Content)
		{
			// Populates search data from JSON
			NSMutableArray a = (NSMutableArray)this.seasonarraycontroller.Content;
			a.RemoveAllObjects();
			// Deserialize JSON
			NSData data = NSData.FromString(Content);
			NSError e;
			NSDictionary json = (NSDictionary)NSJsonSerialization.Deserialize(data, 0, out e);
			NSArray seasondataarray = (NSArray)json.ValueForKey((NSString)"anime");
			// Populate Table View
			this.seasonarraycontroller.AddObjects(seasondataarray);
			this.seasontb.ReloadData();
			this.seasontb.DeselectAll(Self);
		}

		partial void seasontbdoubleclicked(Foundation.NSObject sender)
		{
			NSDictionary d = (NSDictionary)seasonarraycontroller.SelectedObjects[0];
			d = (NSDictionary)d.ValueForKey((NSString)"id");

			Thread t = new Thread((obj) => loadAnimeInfo(Convert.ToInt32((NSString)d.ValueForKey((NSString)"id").ToString())));
			t.Start();
		}
		// Other
		public static string StripHTML(string input)
		{
			return Regex.Replace(input, "<.*?>", String.Empty);
		}
		public void performappearencechange()
		{
			string appearence = (NSString)NSUserDefaults.StandardUserDefaults.ValueForKey((NSString)"windowappearence").ToString();
			NSString appearencename = new NSString();
			switch (appearence)
			{
				case "Light":
					appearencename = NSAppearance.NameVibrantLight;
					break;
				case "Dark":
					appearencename = NSAppearance.NameVibrantDark;
					break;

			}
			w.Appearance = NSAppearance.GetAppearance(appearencename);
			progressview.Appearance = NSAppearance.GetAppearance(appearencename);
			animeinfoview.Appearance = NSAppearance.GetAppearance(appearencename);
			base.Window.SetFrame(base.Window.Frame, true);
		}
	}
}
