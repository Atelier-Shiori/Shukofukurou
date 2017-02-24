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
			//Fix Source List Icons to use as templates
			string[] images = new string[4] { "library", "search", "animeinfo", "seasons"};
			for (int i = 0; i < 4; i++){
				NSImage.ImageNamed(images[i]).Template = true;
			}
			// Set Main Views to be resizable
			searchview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			listview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
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
					mainview.ReplaceSubviewWith(mainview.Subviews[0], animeinfoview);
					animeinfoview.Frame = mainviewframe;
					animeinfoview.SetFrameOrigin(origin);
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
					toolbar.InsertItem("AddTitle", 0);
					toolbar.InsertItem("Share", 1);
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
		partial void performsearch(Foundation.NSObject sender)
		{
			string term = searchbox.StringValue;
			// Create Thread
			Thread thread = new Thread(() => performsearch(term));
			// Perform Search
			thread.Start();
		}
		public void performsearch(string term)
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
		public void loadsearchdata(String content)
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
	}
	public class MainWindowDelegate : NSWindowDelegate
	{
		public override void WillClose(NSNotification notification)
		{
			System.Environment.Exit(0);
		}
	}
}
