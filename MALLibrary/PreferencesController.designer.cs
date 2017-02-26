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
	[Register ("PreferencesController")]
	partial class PreferencesController
	{
		[Outlet]
		AppKit.NSImageView appicon { get; set; }

		[Outlet]
		AppKit.NSView generalpref { get; set; }

		[Outlet]
		AppKit.NSButton loginbut { get; set; }

		[Outlet]
		AppKit.NSView loginpref { get; set; }

		[Outlet]
		AppKit.NSView loginview { get; set; }

		[Outlet]
		AppKit.NSView logoutview { get; set; }

		[Outlet]
		AppKit.NSSecureTextField passwordfield { get; set; }

		[Outlet]
		AppKit.NSView prefview { get; set; }

		[Outlet]
		AppKit.NSWindow reauthorizepanel { get; set; }

		[Outlet]
		AppKit.NSSecureTextField reauthpassword { get; set; }

		[Outlet]
		AppKit.NSToolbar toolbar { get; set; }

		[Outlet]
		AppKit.NSView updatepref { get; set; }

		[Outlet]
		AppKit.NSTextField usernamefield { get; set; }

		[Outlet]
		AppKit.NSTextField usernamelabel { get; set; }

		[Outlet]
		AppKit.NSWindow w { get; set; }

		[Outlet]
		AppKit.NSImageView warningicon { get; set; }

		[Action ("cancelreauth:")]
		partial void cancelreauth (Foundation.NSObject sender);

		[Action ("changePref:")]
		partial void changePref (Foundation.NSObject sender);

		[Action ("checkforupdates:")]
		partial void checkforupdates (Foundation.NSObject sender);

		[Action ("gettingstarted:")]
		partial void gettingstarted (Foundation.NSObject sender);

		[Action ("login:")]
		partial void login (Foundation.NSObject sender);

		[Action ("logout:")]
		partial void logout (Foundation.NSObject sender);

		[Action ("performreauth:")]
		partial void performreauth (Foundation.NSObject sender);

		[Action ("reauthorize:")]
		partial void reauthorize (Foundation.NSObject sender);

		[Action ("registeraccount:")]
		partial void registeraccount (Foundation.NSObject sender);

		[Action ("registerpassword:")]
		partial void registerpassword (Foundation.NSObject sender);
		
		void ReleaseDesignerOutlets ()
		{
			if (reauthorizepanel != null) {
				reauthorizepanel.Dispose ();
				reauthorizepanel = null;
			}

			if (reauthpassword != null) {
				reauthpassword.Dispose ();
				reauthpassword = null;
			}

			if (warningicon != null) {
				warningicon.Dispose ();
				warningicon = null;
			}

			if (appicon != null) {
				appicon.Dispose ();
				appicon = null;
			}

			if (generalpref != null) {
				generalpref.Dispose ();
				generalpref = null;
			}

			if (loginbut != null) {
				loginbut.Dispose ();
				loginbut = null;
			}

			if (loginpref != null) {
				loginpref.Dispose ();
				loginpref = null;
			}

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

			if (prefview != null) {
				prefview.Dispose ();
				prefview = null;
			}

			if (toolbar != null) {
				toolbar.Dispose ();
				toolbar = null;
			}

			if (updatepref != null) {
				updatepref.Dispose ();
				updatepref = null;
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
		}
	}
}
