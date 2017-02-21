using System;

using Foundation;
using AppKit;
using Sparkle;
using RestSharp;
using RestSharp.Authenticators;
using Security;

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
					mo

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
	}
}
