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
		AppKit.NSPopover addpopover { get; set; }

		[Outlet]
		AppKit.NSTextField addpopoverepifield { get; set; }

		[Outlet]
		AppKit.NSPopUpButton addpopoverscore { get; set; }

		[Outlet]
		AppKit.NSPopUpButton addpopoverstatus { get; set; }

		[Outlet]
		AppKit.NSTextField alternativetitlelbl { get; set; }

		[Outlet]
		AppKit.NSTextField animeinfotitle { get; set; }

		[Outlet]
		AppKit.NSView animeinfoview { get; set; }

		[Outlet]
		AppKit.NSTextView backgroundtextview { get; set; }

		[Outlet]
		AppKit.NSTextView detailstextview { get; set; }

		[Outlet]
		AppKit.NSSearchField Filter { get; set; }

		[Outlet]
		AppKit.NSView listview { get; set; }

		[Outlet]
		AppKit.NSProgressIndicator loadingwheel { get; set; }

		[Outlet]
		AppKit.NSView mainview { get; set; }

		[Outlet]
		AppKit.NSView noinfo { get; set; }

		[Outlet]
		AppKit.NSImageView posterimage { get; set; }

		[Outlet]
		AppKit.NSView progressview { get; set; }

		[Outlet]
		AppKit.NSArrayController searcharraycontroller { get; set; }

		[Outlet]
		AppKit.NSSearchField searchbox { get; set; }

		[Outlet]
		AppKit.NSView searchview { get; set; }

		[Outlet]
		AppKit.NSArrayController seasonarraycontroller { get; set; }

		[Outlet]
		AppKit.NSPopUpButton seasonselect { get; set; }

		[Outlet]
		AppKit.NSView seasonsview { get; set; }

		[Outlet]
		AppKit.NSTableView seasontb { get; set; }

		[Outlet]
		AppKit.NSPopUpButton seasonyrselect { get; set; }

		[Outlet]
		MALLibrary.SourceListView sourcelist { get; set; }

		[Outlet]
		AppKit.NSTableView stb { get; set; }

		[Outlet]
		AppKit.NSTextView synopsistextview { get; set; }

		[Outlet]
		AppKit.NSScrollView tableview { get; set; }

		[Outlet]
		AppKit.NSToolbar toolbar { get; set; }

		[Outlet]
		AppKit.NSWindow w { get; set; }

		[Action ("addpopoveraddtitle:")]
		partial void addpopoveraddtitle (Foundation.NSObject sender);

		[Action ("addtitle:")]
		partial void addtitle (Foundation.NSObject sender);

		[Action ("edittitle:")]
		partial void edittitle (Foundation.NSObject sender);

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

		[Action ("returnpreviousview:")]
		partial void returnpreviousview (Foundation.NSObject sender);

		[Action ("searchtbdoubleclick:")]
		partial void searchtbdoubleclick (Foundation.NSObject sender);

		[Action ("seasonchanged:")]
		partial void seasonchanged (Foundation.NSObject sender);

		[Action ("seasontbdoubleclicked:")]
		partial void seasontbdoubleclicked (Foundation.NSObject sender);

		[Action ("selectmainview:")]
		partial void selectmainview (Foundation.NSObject sender);

		[Action ("viewonmal:")]
		partial void viewonmal (Foundation.NSObject sender);

		[Action ("yearchanged:")]
		partial void yearchanged (Foundation.NSObject sender);
		
		void ReleaseDesignerOutlets ()
		{
			if (addpopover != null) {
				addpopover.Dispose ();
				addpopover = null;
			}

			if (addpopoverepifield != null) {
				addpopoverepifield.Dispose ();
				addpopoverepifield = null;
			}

			if (addpopoverscore != null) {
				addpopoverscore.Dispose ();
				addpopoverscore = null;
			}

			if (addpopoverstatus != null) {
				addpopoverstatus.Dispose ();
				addpopoverstatus = null;
			}

			if (alternativetitlelbl != null) {
				alternativetitlelbl.Dispose ();
				alternativetitlelbl = null;
			}

			if (animeinfotitle != null) {
				animeinfotitle.Dispose ();
				animeinfotitle = null;
			}

			if (animeinfoview != null) {
				animeinfoview.Dispose ();
				animeinfoview = null;
			}

			if (backgroundtextview != null) {
				backgroundtextview.Dispose ();
				backgroundtextview = null;
			}

			if (detailstextview != null) {
				detailstextview.Dispose ();
				detailstextview = null;
			}

			if (Filter != null) {
				Filter.Dispose ();
				Filter = null;
			}

			if (listview != null) {
				listview.Dispose ();
				listview = null;
			}

			if (loadingwheel != null) {
				loadingwheel.Dispose ();
				loadingwheel = null;
			}

			if (mainview != null) {
				mainview.Dispose ();
				mainview = null;
			}

			if (noinfo != null) {
				noinfo.Dispose ();
				noinfo = null;
			}

			if (posterimage != null) {
				posterimage.Dispose ();
				posterimage = null;
			}

			if (progressview != null) {
				progressview.Dispose ();
				progressview = null;
			}

			if (searcharraycontroller != null) {
				searcharraycontroller.Dispose ();
				searcharraycontroller = null;
			}

			if (searchbox != null) {
				searchbox.Dispose ();
				searchbox = null;
			}

			if (searchview != null) {
				searchview.Dispose ();
				searchview = null;
			}

			if (seasonarraycontroller != null) {
				seasonarraycontroller.Dispose ();
				seasonarraycontroller = null;
			}

			if (seasonselect != null) {
				seasonselect.Dispose ();
				seasonselect = null;
			}

			if (seasonsview != null) {
				seasonsview.Dispose ();
				seasonsview = null;
			}

			if (seasontb != null) {
				seasontb.Dispose ();
				seasontb = null;
			}

			if (seasonyrselect != null) {
				seasonyrselect.Dispose ();
				seasonyrselect = null;
			}

			if (sourcelist != null) {
				sourcelist.Dispose ();
				sourcelist = null;
			}

			if (stb != null) {
				stb.Dispose ();
				stb = null;
			}

			if (synopsistextview != null) {
				synopsistextview.Dispose ();
				synopsistextview = null;
			}

			if (tableview != null) {
				tableview.Dispose ();
				tableview = null;
			}

			if (toolbar != null) {
				toolbar.Dispose ();
				toolbar = null;
			}

			if (w != null) {
				w.Dispose ();
				w = null;
			}
		}
	}
}
