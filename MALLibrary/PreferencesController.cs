using System;

using Foundation;
using AppKit;
using Sparkle;
using RestSharp;
using RestSharp.Authenticators;
using Security;
using CoreGraphics;

namespace MALLibrary
{
	public partial class PreferencesController : NSWindowController
	{
		SUUpdater updater;
		public void setUpdater(SUUpdater u)
		{
			// Point sparkle updater from app delegate so it can access the updater functions.
			updater = u;
		}
		public PreferencesController(IntPtr handle) : base(handle)
		{
			
		}
		public NSWindow getWindow()
		{
			return this.w;
		}
		[Export("initWithCoder:")]
		public PreferencesController(NSCoder coder) : base(coder)
		{
		}

		public PreferencesController() : base("Preferences")
		{
		}

		public override void AwakeFromNib()
		{
			base.AwakeFromNib();
			this.showpreferenceview();
		}
		public void showpreferenceview()
		{
			prefview.AddSubview(new NSView());
			string selectedpref;
			// Retrieve last used preference pane
			if (NSUserDefaults.StandardUserDefaults.ValueForKey(new NSString("selectedpref")) != null)
			{
				selectedpref = NSUserDefaults.StandardUserDefaults.ValueForKey(new NSString("selectedpref")).ToString();
			}
			else
			{
				selectedpref = "General";
			}
			toolbar.SelectedItemIdentifier = selectedpref;
			this.changepreferenceview();
			//w.SetContentSize(generalpref.IntrinsicContentSize);
		}
		partial void changePref(Foundation.NSObject sender)
		{
			this.changepreferenceview();
			NSUserDefaults.StandardUserDefaults.SetValueForKey(new NSString(toolbar.SelectedItemIdentifier), new NSString("selectedpref"));
		}
		private void changepreferenceview()
		{
			//this.showMessage(toolbar.SelectedItemIdentifier, "");
			CGSize vsize = new CGSize();
			CGPoint origin = new CGPoint();
			origin.X = 0;
			origin.Y = 0;
			switch (toolbar.SelectedItemIdentifier)
			{
				case "General":
					w.Title = "General";
					prefview.ReplaceSubviewWith(prefview.Subviews[0], new NSView());
					vsize.Height = 120;
					vsize.Width = 419;
					this.resizeWindowToView(generalpref.Frame.Size);
					prefview.ReplaceSubviewWith(prefview.Subviews[0], generalpref);
					generalpref.SetFrameOrigin(origin);
					break;
				case "Login":
					w.Title = "Login";
					prefview.ReplaceSubviewWith(prefview.Subviews[0], new NSView());
					vsize.Height = 198;
					vsize.Width = 419;
					this.resizeWindowToView(vsize);
					prefview.ReplaceSubviewWith(prefview.Subviews[0], loginpref);
					loginpref.SetFrameOrigin(origin);
					break;
				case "updates":
					w.Title = "Software Updates";
					prefview.ReplaceSubviewWith(prefview.Subviews[0], new NSView());
					vsize.Height = 185;
					vsize.Width = 419;
					this.resizeWindowToView(vsize);
					prefview.ReplaceSubviewWith(prefview.Subviews[0], updatepref);
					loginpref.SetFrameOrigin(origin);
					break;
			}
		}
		private void resizeWindowToView(CGSize size)
		{
			nfloat titlebarheight = w.Frame.Size.Height - w.ContentView.Frame.Size.Height;
			CGSize windowsize = new CGSize();
			windowsize.Width = size.Width;
			windowsize.Height = size.Height + titlebarheight;
			nfloat originX = w.Frame.Location.X + (w.Frame.Size.Width - windowsize.Width) / 2;

			nfloat originY = w.Frame.Location.Y + (w.Frame.Size.Height - windowsize.Height) / 2;
			CGRect WindowFrame = new CGRect(originX,originY, windowsize.Width, windowsize.Height);
			w.SetFrame(WindowFrame, true, true);
		}
		partial void gettingstarted(Foundation.NSObject sender)
		{
			this.OpenURL("https://github.com/chikorita157/mal-library/wiki/Getting-Started");
		}

		partial void login(Foundation.NSObject sender)
		{
			if (usernamefield.StringValue.Length == 0 || passwordfield.StringValue.Length == 0)
			{
				this.showMessage("Username or Password missing.", "Please enter your username and password and try again.");
			}
			else {
				RestClient client = new RestClient("https://malapi.ateliershiori.moe/2.1/");
				client.UserAgent = new UserAgent().getUserAgent();
				RestRequest request = new RestRequest("account/verify_credentials", Method.GET);
				client.Authenticator = new HttpBasicAuthenticator(usernamefield.StringValue, passwordfield.StringValue);
				IRestResponse response = client.Execute(request);
				var content = response.Content; // raw content as string
				if (response.StatusCode.GetHashCode() == 200)
				{
					this.showMessage("Login Successful", "Login is successful");

				}
				else
				{
					this.showMessage("MAL Library was unable to log you in since you don't have the correct username and/or password.", "Check your username and password and try logging in again. If you recently changed your password, enter your new password and try again.");
				}

			}
		}

		partial void logout(Foundation.NSObject sender)
		{
		}

		partial void reauthorize(Foundation.NSObject sender)
		{
		}

		partial void registeraccount(Foundation.NSObject sender)
		{
			this.OpenURL("https://myanimelist.net/register.php");
		}

		private void showMessage(string message, string explaination)
		{
			NSAlert msgbox = new NSAlert();
			msgbox.MessageText = message;
			msgbox.InformativeText = explaination;
			msgbox.AlertStyle = NSAlertStyle.Warning;
			msgbox.RunSheetModal(this.w);

		}
		private void OpenURL(string URL)
		{
			NSUrl link = new NSUrl(URL);
			NSWorkspace.SharedWorkspace.OpenUrl(link);
		}
		partial void checkforupdates(Foundation.NSObject sender)
		{
			updater.CheckForUpdates(sender);
		}
	}
}
