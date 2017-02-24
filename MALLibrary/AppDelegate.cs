using AppKit;
using Foundation;
using Sparkle;

namespace MALLibrary
{
	[Register("AppDelegate")]
	public partial class AppDelegate : NSApplicationDelegate
	{
		MainWindowController mainWindowController;
		SUUpdater updater;
		PreferencesController prefcontroller;
		public AppDelegate()
		{
		}

		public MainWindowController getMainWindowController(){
			return mainWindowController;
		}
		public override void DidFinishLaunching(NSNotification notification)
		{
			mainWindowController = new MainWindowController();
			mainWindowController.Window.MakeKeyAndOrderFront(this);
			updater = new SUUpdater();
			//Fix Icons to use as templates
			string[] images = new string[6] { "library", "search", "animeinfo", "seasons", "Info", "Edit" };
			for (int i = 0; i < 4; i++)
			{
				NSImage.ImageNamed(images[i]).Template = true;
			}
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
			if (prefcontroller == null)
			{
				prefcontroller = new PreferencesController();
				prefcontroller.setUpdater(updater);
			}
			prefcontroller.Window.MakeKeyAndOrderFront(prefcontroller.getWindow());

		}
	}
}
