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
		RestClient client;
		int aniinfoid = 0;
		NSDictionary currentaniinfo;
		NSArray seasonindex;
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
			base.Window.SetFrame(base.Window.Frame,true);
			// Set Main Views to be resizable
			searchview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			listview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			animeinfoview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			progressview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			seasonsview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			//Set up list view
			sourcelist.Initialize();

			var library = new SourceListItem("LIBRARY");
			library.AddItem("Anime List", NSImage.ImageNamed("library"),this.loadmainview);
			sourcelist.AddItem(library);
			var discover = new SourceListItem("DISCOVER");
			discover.AddItem("Search", NSImage.ImageNamed("search"), this.loadmainview);
			discover.AddItem("Title Info", NSImage.ImageNamed("animeinfo"),this.loadmainview);
			discover.AddItem("Seasons", NSImage.ImageNamed("seasons"),this.loadmainview);
			sourcelist.AddItem(discover);

			// Display side list
			sourcelist.ReloadData();
			sourcelist.ExpandItem(null,true);

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
			// Initalize RestClient
			client = new RestClient("https://malapi.ateliershiori.moe/2.1/");
			client.UserAgent = UserAgent.getUserAgent();

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
					if (seasonindex == null)
					{
						this.retrieveseasonindex();
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
			NSAlert a = new NSAlert();
			a.MessageText = "Implement Refresh";
			long l = a.RunModal();
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
			NSAlert a = new NSAlert();
			a.MessageText = "Implement Add Title";
			long l = a.RunModal();
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
			// Retrieves Search Data from Atarashii-API
			RestRequest request = new RestRequest("anime/search", Method.GET);
			request.AddParameter("q", term);

			IRestResponse response = client.Execute(request);
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
			RestRequest request = new RestRequest("anime/"+ id, Method.GET);

			IRestResponse response = client.Execute(request);
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
			NSImage img = new NSImage(new NSUrl((NSString)animedata.ValueForKey(new NSString("image_url"))));
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
			detail = detail + "Episodes: " + episodes.Int32Value + " (" + duration.Int32Value + " mins long per episode)" + System.Environment.NewLine;
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
		private void performseasonindexretrieval()
		{
			// Create Thread
			Thread thread = new Thread(new ThreadStart(retrieveseasonindex));
			// Perform Search
			thread.Start();
		}
		private void retrieveseasonindex()
		{
			// Retrieves Season Data from Repo
			RestClient seasonclient = new RestClient("https://raw.githubusercontent.com/Atelier-Shiori/anime-season-json/master/");
			seasonclient.UserAgent = UserAgent.getUserAgent();
			RestRequest request = new RestRequest("index.json", Method.GET);

			IRestResponse response = seasonclient.Execute(request);
			if (response.StatusCode.GetHashCode() == 200)
			{
				InvokeOnMainThread(() =>
				{
					// Populate data in Search Table View
					this.populateyearpopup(response.Content);
					seasonyrselect.SelectItem(seasonyrselect.ItemCount - 1); //Select current year;
					this.populateseasonpopup((nuint)seasonyrselect.IndexOfSelectedItem);
					if (seasonselect.ItemCount - 1 >= 0)
					{
						seasonselect.SelectItem(seasonselect.ItemCount - 1); //Select most recent season, only if it has more than two seasons;
					}
					this.performseasondata();
				});
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
			NSArray a1 = (NSArray)d.ValueForKey((NSString)"seasons");
			d = a1.GetItem<NSDictionary>((System.nuint)seasonselect.IndexOfSelectedItem);
			string url = d.ValueForKey((NSString)"url").ToString();
			// Create Thread
			Thread thread = new Thread(() => this.loadseasondata(url));
			// Perform Search
			thread.Start();
		}
		private void loadseasondata(string URL)
		{
			// Retrieves Season Data from Repo
			RestClient seasonclient = new RestClient(URL);
			seasonclient.UserAgent = UserAgent.getUserAgent();
			RestRequest request = new RestRequest(Method.GET);

			IRestResponse response = seasonclient.Execute(request);
			if (response.StatusCode.GetHashCode() == 200)
			{
				InvokeOnMainThread(() =>
				{
					// Populate data in Search Table View
					this.performseasondatapop(response.Content);
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

	}
}
