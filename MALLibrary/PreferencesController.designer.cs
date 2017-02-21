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
	[Register ("PreferencesController")]
	partial class PreferencesController
	{
		[Outlet]
		AppKit.NSButton loginbut { get; set; }

		[Outlet]
		AppKit.NSView loginview { get; set; }

		[Outlet]
		AppKit.NSView logoutview { get; set; }

		[Outlet]
		AppKit.NSSecureTextField passwordfield { get; set; }

		[Outlet]
		AppKit.NSTextField usernamefield { get; set; }

		[Outlet]
		AppKit.NSTextField usernamelabel { get; set; }

		[Outlet]
		AppKit.NSWindow w { get; set; }

		[Action ("gettingstarted:")]
		partial void gettingstarted (Foundation.NSObject sender);

		[Action ("login:")]
		partial void login (Foundation.NSObject sender);

		[Action ("logout:")]
		partial void logout (Foundation.NSObject sender);

		[Action ("reauthorize:")]
		partial void reauthorize (Foundation.NSObject sender);

		[Action ("registeraccount:")]
		partial void registeraccount (Foundation.NSObject sender);

		[Action ("registerpassword:")]
		partial void registerpassword (Foundation.NSObject sender);
		
		void ReleaseDesignerOutlets ()
		{
			if (loginview != null) {
				loginview.Dispose ();
				loginview = null;
			}

			if (logoutview != null) {
				logoutview.Dispose ();
				logoutview = null;
			}

			if (passwordfield != null) {
				passwordfield.Dispose ();
				passwordfield = null;
			}

			if (usernamefield != null) {
				usernamefield.Dispose ();
				usernamefield = null;
			}

			if (usernamelabel != null) {
				usernamelabel.Dispose ();
				usernamelabel = null;
			}

			if (w != null) {
				w.Dispose ();
				w = null;
			}

			if (loginbut != null) {
				loginbut.Dispose ();
				loginbut = null;
			}
		}
	}
}
