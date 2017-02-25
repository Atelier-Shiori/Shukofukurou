using System;
using Foundation;
using AppKit;
namespace MALLibrary
{
	[Register("MainWindowDelegate")]
	public class MainWindowDelegate : NSWindowDelegate
	{
		public override void WillClose(NSNotification notification)
		{
			System.Environment.Exit(0);
		}
	}
}
