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
			Environment.Exit(0);
		}
	}
}
