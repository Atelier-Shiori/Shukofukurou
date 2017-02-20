using System;

using Foundation;
using AppKit;

namespace MALLibrary
{
	public partial class MainWindowController : NSWindowController
	{
		
		public MainWindowController(IntPtr handle) : base(handle)
		{
		}

		[Export("initWithCoder:")]
		public MainWindowController(NSCoder coder) : base(coder)
		{
		}

		public MainWindowController() : base("MainWindow")
		{
		}

		public override void AwakeFromNib()
		{
			base.AwakeFromNib();
			base.Window.Delegate = new MainWindowDelegate();
		}

		public new MainWindow Window
		{
			get { return (MainWindow)base.Window; }
		}
		partial void performfilter(Foundation.NSObject sender)
		{
		}
		partial void performrefresh(Foundation.NSObject sender)
		{
			NSAlert a = new NSAlert();
			a.MessageText = "Test";
			long l = a.RunModal();
		}
	}
	public class MainWindowDelegate : NSWindowDelegate
	{
		public override void WillClose(NSNotification notification)
		{
			System.Environment.Exit(0);
		}
	}
}
