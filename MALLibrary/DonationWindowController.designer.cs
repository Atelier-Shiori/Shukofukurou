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
	[Register ("DonationWindowController")]
	partial class DonationWindowController
	{
		[Outlet]
		AppKit.NSTextField donationkeyfield { get; set; }

		[Outlet]
		AppKit.NSTextField namefield { get; set; }

		[Outlet]
		AppKit.NSButton registerbtn { get; set; }

		[Outlet]
		AppKit.NSWindow w { get; set; }

		[Action ("cancel:")]
		partial void cancel (Foundation.NSObject sender);

		[Action ("opendonationpage:")]
		partial void opendonationpage (Foundation.NSObject sender);

		[Action ("performregistration:")]
		partial void performregistration (Foundation.NSObject sender);
		
		void ReleaseDesignerOutlets ()
		{
			if (donationkeyfield != null) {
				donationkeyfield.Dispose ();
				donationkeyfield = null;
			}

			if (namefield != null) {
				namefield.Dispose ();
				namefield = null;
			}

			if (registerbtn != null) {
				registerbtn.Dispose ();
				registerbtn = null;
			}

			if (w != null) {
				w.Dispose ();
				w = null;
			}
		}
	}
}
