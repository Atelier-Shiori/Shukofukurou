// WARNING
//
// This file has been generated automatically by Visual Studio to store outlets and
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
		AppKit.NSSearchField Filter { get; set; }

		[Outlet]
		AppKit.NSScrollView tableview { get; set; }

		[Action ("performfilter:")]
		partial void performfilter (Foundation.NSObject sender);

		[Action ("performrefresh:")]
		partial void performrefresh (Foundation.NSObject sender);
		
		void ReleaseDesignerOutlets ()
		{
			if (tableview != null) {
				tableview.Dispose ();
				tableview = null;
			}

			if (Filter != null) {
				Filter.Dispose ();
				Filter = null;
			}
		}
	}
}
