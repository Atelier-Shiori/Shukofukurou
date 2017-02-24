using System;

using Foundation;
using AppKit;
using CoreGraphics;
using RestSharp;
using System.Threading;

namespace MALLibrary
{
	public partial class MainWindowController : NSWindowController
	{
		RestClient client;
		int aniinfoid = 0;
		NSDictionary currentaniinfo;
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
			sourcelist.ExpandItem(null, true);

			// Retrieve last used main view
			if (NSUserDefaults.StandardUserDefaults.ValueForKey(new NSString("selectedmainview")) != null)
			{
				NSNumber selected = (NSNumber)NSUserDefaults.StandardUserDefaults.ValueForKey(new NSString("selectedmainview"));
				sourcelist.SelectRow(selected.NIntValue, false);
			}
			else
			{
				sourcelist.SelectRow(1, true);
			}
			this.loadmainview();
			// Initalize RestClient
			client = new RestClient("https://malapi.ateliershiori.moe/2.1/");
			client.UserAgent = new UserAgent().getUserAgent();

		}
		private void loadmainview()
		{
			
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
						toolbar.InsertItem("Share", 1);
					}
					break;
				case "Seasons":
					break;
			}
		}
		public new MainWindow Window
		{
			get { return (MainWindow)base.Window; }
		}
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
			NSAlert a = new NSAlert();
			a.MessageText = "Implement Share Menu";
			long l = a.RunModal();
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
			NSAlert a = new NSAlert();
			a.MessageText = "Implement View on MAL";
			long l = a.RunModal();
		}
		partial void performsearch(Foundation.NSObject sender)
		{
			string term = searchbox.StringValue;
			// Create Thread
			Thread thread = new Thread(() => performsearch(term));
			// Perform Search
			thread.Start();
		}
		private void performsearch(string term)
		{
			RestRequest request = new RestRequest("anime/search", Method.GET);
			request.AddParameter("q", term);

			IRestResponse response = client.Execute(request);
			if (response.StatusCode.GetHashCode() == 200)
			{
				InvokeOnMainThread(() =>
				{
					this.loadsearchdata(response.Content);
				});
			}
		}
		private void loadsearchdata(String content)
		{
			NSMutableArray a = (NSMutableArray)this.searcharraycontroller.Content;
			a.RemoveAllObjects();
			NSData data = NSData.FromString(content);
			NSError e;
			NSArray searchdata = (NSArray)NSJsonSerialization.Deserialize(data, 0, out e);
			this.searcharraycontroller.AddObjects(searchdata);
			this.stb.ReloadData();
			this.stb.DeselectAll(Self);
		}
		partial void searchtbdoubleclick(Foundation.NSObject sender)
		{
			if (stb.ClickedRow > 0)
			{
				if ((System.nuint)searcharraycontroller.SelectionIndex >= 1)
				{
					this.searchtableclick();
				}
			}
		}
		public void searchtableclick()
		{
			NSArray data = (NSArray)searcharraycontroller.Content;
			NSDictionary d = data.GetItem<NSDictionary>((System.nuint)searcharraycontroller.SelectionIndex);
			NSNumber idnum = (NSNumber)d.ValueForKey(new NSString("id"));

			Thread t = new Thread((obj) => loadAnimeInfo(idnum.Int32Value));
			t.Start();
		}
		private void loadAnimeInfo(int id)
		{
			// Change page to Anime Info
			int tmpid = aniinfoid;
			aniinfoid = 0;
			InvokeOnMainThread(() =>
				{
					sourcelist.SelectRow(4, true);

					this.loadmainview();
					noinfo.Hidden = true;
					loadingwheel.Hidden = false;
					loadingwheel.StartAnimation(null);
				});
			RestRequest request = new RestRequest("anime/"+ id, Method.GET);

			IRestResponse response = client.Execute(request);
			if (response.StatusCode.GetHashCode() == 200)
			{
				NSData data = NSData.FromString(response.Content);
				NSError e;
				NSDictionary animedata = (NSDictionary)NSJsonSerialization.Deserialize(data, 0, out e);
				InvokeOnMainThread(() =>
				{
					// Populate Anime Information
					animeinfotitle.StringValue = (NSString)animedata.ValueForKey(new NSString("title")).ToString();
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
					int favoritedcount;
					string detail = "Type: " + type + System.Environment.NewLine +
					                                        "Episodes: " + episodes.Int32Value + " (" + duration.Int32Value +" mins long per episode)" + System.Environment.NewLine +
									 "Status: " + status + System.Environment.NewLine +
					                                        "Classification: " + classification + System.Environment.NewLine+
					                                        "Score: " + memberscore.FloatValue + "(" + memberscount.Int32Value + " users, ranked " + rank.Int32Value +")" + System.Environment.NewLine +
					                                        "Popularity: " + popularityrank.Int32Value + System.Environment.NewLine  ;
					detailstextview.Value = detail;
					if (animedata.ValueForKey(new NSString("background")) != null){
						backgroundtextview.Value = (NSString)animedata.ValueForKey(new NSString("background")).ToString();
					}
					else {
						backgroundtextview.Value = "None available.";
					}
					synopsistextview.Value = (NSString)animedata.ValueForKey(new NSString("synopsis")).ToString();
					loadingwheel.StopAnimation(null);
					aniinfoid = id;
					this.loadmainview();
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
	}
	public class MainWindowDelegate : NSWindowDelegate
	{
		public override void WillClose(NSNotification notification)
		{
			System.Environment.Exit(0);
		}
	}
}
