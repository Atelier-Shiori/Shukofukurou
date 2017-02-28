using AppKit;
using Foundation;
using Sparkle;

using System.Threading;
using System;

namespace MALLibrary
{
	[Register("AppDelegate")]
	public partial class AppDelegate : NSApplicationDelegate
	{
		MainWindowController mainWindowController;
		DonationWindowController donationWindowController;
		SUUpdater updater;
		PreferencesController prefcontroller;
		MyAnimeList malengine;
		public AppDelegate()
		{
		}
		public MainWindowController getMainWindowController(){
			return mainWindowController;
		}
		public override void DidFinishLaunching(NSNotification notification)
		{
			this.setdefaults();
			malengine = new MyAnimeList();
			this.performNoticeCheck();
			mainWindowController = new MainWindowController();
			mainWindowController.malengine = malengine;
			mainWindowController.appdel = this;
			mainWindowController.Window.MakeKeyAndOrderFront(this);
			updater = new SUUpdater();
			//Fix Icons to use as templates
			string[] images = new string[6] { "library", "search", "animeinfo", "seasons", "Info", "Edit" };
			for (int i = 0; i < 6; i++)
			{
				NSImage.ImageNamed(images[i]).Template = true;
			}
			this.checkaccount();
		}
		public override void WillTerminate(NSNotification notification)
		{
			// Insert code here to tear down your application
		}
		partial void checkforupdates(Foundation.NSObject sender)
		{
			updater.CheckForUpdates(sender);	
		}
		partial void showpreferences(Foundation.NSObject sender)
		{
			this.showpreferences();
		}
		private void showpreferences()
		{
			if (prefcontroller == null)
			{
				prefcontroller = new PreferencesController();
				prefcontroller.setUpdater(updater);
			}
			if (prefcontroller.malengine == null)
			{
				prefcontroller.malengine = this.malengine;
			}
			if (prefcontroller.mainwindowcontrol== null)
			{
				prefcontroller.mainwindowcontrol = this.mainWindowController;
			}
			prefcontroller.Window.MakeKeyAndOrderFront(prefcontroller.getWindow());
		}
		partial void showdonationkeywin(Foundation.NSObject sender)
		{
			this.openDonationKeyEnterWindow();
		}
		partial void viewhelp(Foundation.NSObject sender)
		{
			NSUrl link = new NSUrl("https://github.com/Atelier-Shiori/MALLibrary/wiki");
			NSWorkspace.SharedWorkspace.OpenUrl(link);
		}
		private void performNoticeCheck()
		{
			Thread t = new Thread(new ThreadStart(checknotice));
			t.Start();
		}
		private void checknotice(){
			int check = Donation.shouldshowDonationReminder();
			InvokeOnMainThread(() =>
			{
				switch (check)
				{
					case 0:
						break;
					case 1:
						//Show Message
						this.showDonationNotice();
						break;
					case 2:
						this.showInvalidKeyNotice();
						break;
				}
				});
		}
		private void showDonationNotice()
		{
			NSAlert a = new NSAlert();
			a.AddButton("Donate");
			a.AddButton("Enter Key");
			a.AddButton("Remind Me Later");
			a.MessageText = "Please Support MAL Library";
			a.InformativeText = "We noticed that you have been using MAL Library for a while. Although MAL Library is free and open source software, it cost us money and time to develop this program." + System.Environment.NewLine + "If you find this program helpful, please consider making a donation. You will recieve a key to remove this message and enable new features.";
			a.AlertStyle = NSAlertStyle.Informational;
			long choice = a.RunModal();
			if (choice == (long)NSAlertButtonReturn.First)
			{
				NSUrl link = new NSUrl("https://mallibrary.ateliershiori.moe/donate");
				NSWorkspace.SharedWorkspace.OpenUrl(link);
				Donation.setReminderDate();
			}
			else if (choice == (long)NSAlertButtonReturn.Second)
			{
				this.openDonationKeyEnterWindow();
				Donation.setReminderDate();
			}
			else {
				Donation.setReminderDate();
			}
		}
		private void showInvalidKeyNotice()
		{
			NSAlert a = new NSAlert();
			a.AddButton("Quit");
			a.MessageText = "Donation Key Error";
			a.InformativeText = "This key has been revoked. Please contact the author of this program or enter a valid key. MAL Library will now quit.";
			a.AlertStyle = NSAlertStyle.Critical;
			long choice = a.RunModal();
			if (choice == (long)NSAlertButtonReturn.First)
			{
				System.Environment.Exit(0);
			}
		}
		private void openDonationKeyEnterWindow()
		{
			if (donationWindowController == null)
			{
				donationWindowController = new DonationWindowController();
			}
			donationWindowController.Window.MakeKeyAndOrderFront(this);
		}
		private void checkaccount()
		{
			if (Keychain.checkacountexists() == false)
			{
				NSAlert a = new NSAlert();
				a.AddButton("Yes");
				a.AddButton("No");
				a.MessageText = "Welcome to MAL Library";
				a.InformativeText = "To take full advantage of MAL Library you need to login. Do you want to open Preferences to log in now?" + System.Environment.NewLine + System.Environment.NewLine +
					"Note that you do not need to login to use the explore features.";
				a.AlertStyle = NSAlertStyle.Informational;
				long choice = a.RunSheetModal(mainWindowController.Window);
				if (choice == (long)NSAlertButtonReturn.First)
				{
					this.showloginprefs();

				}
			}
		}
		public void showloginprefs()
		{
			this.showpreferences();
			prefcontroller.gotopreference("Login");
		}
		private void setdefaults()
		{
			// Sets default settings
			NSMutableDictionary defaultvalues = new NSMutableDictionary();
			defaultvalues.Add((NSString)"doubeclickaction", (NSString)"Edit Title");
			defaultvalues.Add((NSString)"windowappearence", (NSString)"Light");
			defaultvalues.Add((NSString)"filterwatching", new NSNumber(1));
			defaultvalues.Add((NSString)"filtercompleted", new NSNumber(1));
			defaultvalues.Add((NSString)"filteronhold", new NSNumber(1));
			defaultvalues.Add((NSString)"filterdropped", new NSNumber(1));
			defaultvalues.Add((NSString)"filterplantowatch", new NSNumber(1));
			NSUserDefaults.StandardUserDefaults.RegisterDefaults(defaultvalues);
		}
	}
}
