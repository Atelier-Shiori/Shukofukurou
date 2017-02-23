// WARNING
//
// This file has been generated automatically by Xamarin Studio to store outlets and
// actions made in the UI designer. If it is removed, they will be lost.
// Manual changes to this file may not be handled correctly.
//
using Foundation;
using System.CodeDom.Compiler;

namespace MALLibrary
{
	[Register ("MainWindowController")]
	partial class MainWindowController
	{
		[Outlet]
		AppKit.NSView animeinfoview { get; set; }

		[Outlet]
		AppKit.NSSearchField Filter { get; set; }

		[Outlet]
		AppKit.NSView listview { get; set; }

		[Outlet]
		AppKit.NSView mainview { get; set; }

		[Outlet]
		AppKit.NSSearchField searchbox { get; set; }

		[Outlet]
		AppKit.NSView searchview { get; set; }

		[Outlet]
		AppKit.NSView seasonsview { get; set; }

		[Outlet]
		MALLibrary.SourceListView sourcelist { get; set; }

		[Outlet]
		AppKit.NSScrollView tableview { get; set; }

		[Outlet]
		AppKit.NSToolbar toolbar { get; set; }

		[Action ("addtitle:")]
		partial void addtitle (Foundation.NSObject sender);

		[Action ("opensharemenu:")]
		partial void opensharemenu (Foundation.NSObject sender);

		[Action ("performfilter:")]
		partial void performfilter (Foundation.NSObject sender);

		[Action ("performrefresh:")]
		partial void performrefresh (Foundation.NSObject sender);

		[Action ("performsearch:")]
		partial void performsearch (Foundation.NSObject sender);

		[Action ("removetitle:")]
		partial void removetitle (Foundation.NSObject sender);

		[Action ("selectmainview:")]
		partial void selectmainview (Foundation.NSObject sender);
		
		void ReleaseDesignerOutlets ()
		{
			if (animeinfoview != null) {
				animeinfoview.Dispose ();
				animeinfoview = null;
			}

			if (Filter != null) {
				Filter.Dispose ();
				Filter = null;
			}

			if (listview != null) {
				listview.Dispose ();
				listview = null;
			}

			if (mainview != null) {
				mainview.Dispose ();
				mainview = null;
			}

			if (searchbox != null) {
				searchbox.Dispose ();
				searchbox = null;
			}

			if (searchview != null) {
				searchview.Dispose ();
				searchview = null;
			}

			if (seasonsview != null) {
				seasonsview.Dispose ();
				seasonsview = null;
			}

			if (sourcelist != null) {
				sourcelist.Dispose ();
				sourcelist = null;
			}

			if (tableview != null) {
				tableview.Dispose ();
				tableview = null;
			}

			if (toolbar != null) {
				toolbar.Dispose ();
				toolbar = null;
			}
		}
	}
}
