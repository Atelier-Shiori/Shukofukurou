using System;

using Foundation;
using AppKit;
using System.Threading;

namespace MALLibrary
{
	public partial class DonationWindowController : NSWindowController
	{
		public DonationWindowController(IntPtr handle) : base(handle)
		{
		}

		[Export("initWithCoder:")]
		public DonationWindowController(NSCoder coder) : base(coder)
		{
		}

		public DonationWindowController() : base("DonationWindow")
		{
		}

		public override void AwakeFromNib()
		{
			base.AwakeFromNib();
		}

		public new NSWindow Window
		{
			get { return base.Window; }
		}
		partial void cancel(Foundation.NSObject sender)
		{
			this.w.Close();
		}
		partial void opendonationpage(Foundation.NSObject sender)
		{
			NSUrl link = new NSUrl("https://mallibrary.ateliershiori.moe/donate/");
			NSWorkspace.SharedWorkspace.OpenUrl(link);
		}
		partial void performregistration(Foundation.NSObject sender)
		{
			registerbtn.Enabled = false;
			string name = namefield.StringValue;
			string key = donationkeyfield.StringValue;
			Thread t = new Thread(() => validatekey(name, key));
			t.Start();
		}
		private void validatekey(string name, string key)
		{
			int valid = Donation.performKeyValidation(name, key);
			InvokeOnMainThread(() =>
			{
				switch (valid)
				{
					case 0:
						this.showMessage("Invalid Key", "Please make sure you copied the name and key exactly from the email.");
						break;
					case 1:
						this.showsuccess(name, key);
						break;
					case 2:
						this.showMessage("No Internet", "Make sure you are connected to the internet and try again.");
						break;
						
				}
				registerbtn.Enabled = true;
			});
		}
		private void showMessage(string message, string explaination)
		{
			NSAlert msgbox = new NSAlert();
			msgbox.MessageText = message;
			msgbox.InformativeText = explaination;
			msgbox.AlertStyle = NSAlertStyle.Warning;
			msgbox.RunSheetModal(this.w);

		}
		private void showsuccess(string name, string key)
		{
			NSAlert a = new NSAlert();
			a.AddButton("OK");
			a.MessageText = "Registered";
			a.InformativeText = "Thank you for donating. The donation reminder will no longer appear and donation exclusive features are now unlocked.";
			a.AlertStyle = NSAlertStyle.Critical;
			long choice = a.RunModal();
			if (choice == (long)NSAlertButtonReturn.First)
			{
				NSUserDefaults.StandardUserDefaults.SetValueForKey(new NSNumber(true), (NSString)"donated");
				NSUserDefaults.StandardUserDefaults.SetValueForKey((NSString)name, (NSString)"donor");
				NSUserDefaults.StandardUserDefaults.SetValueForKey((NSString)key, (NSString)"key");
				this.w.Close();
			}
		}
	}
}
