using System;

using Foundation;
using AppKit;
using CoreGraphics;

namespace MALLibrary
{
	public partial class MainWindowController : NSWindowController
	{
		
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
			library.AddItem("Anime List", NSImage.ImageNamed("library"));
			sourcelist.AddItem(library);
			var discover = new SourceListItem("DISCOVER");
			discover.AddItem("Search", NSImage.ImageNamed("search"));
			discover.AddItem("Title Info", NSImage.ImageNamed("animeinfo"));
			discover.AddItem("Seasons", NSImage.ImageNamed("seasons"));
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

		}
		partial void selectmainview(Foundation.NSObject sender)
		{
			this.loadmainview();
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
					mainview.ReplaceSubviewWith(mainview.Subviews[0], searchview);
					searchview.Frame = mainviewframe;
					searchview.SetFrameOrigin(origin);
					break;
				case "Seasons":
					mainview.ReplaceSubviewWith(mainview.Subviews[0], searchview);
					searchview.Frame = mainviewframe;
					searchview.SetFrameOrigin(origin);
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
					toolbar.InsertItem("NSToolbarFlexibleSpaceItem", 1);
					toolbar.InsertItem("filter", 2);
					break;
				case "Search":
					toolbar.InsertItem("NSToolbarFlexibleSpaceItem", 0);
					toolbar.InsertItem("search", 1);
					break;
				case "Title Info":
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
			a.MessageText = "Test";
			long l = a.RunModal();
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
