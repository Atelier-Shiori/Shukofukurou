using System;

using Foundation;
using AppKit;

namespace MALLibrary
{
	public partial class Preferences : NSWindow
	{
		public Preferences(IntPtr handle) : base(handle)
		{
		}

		[Export("initWithCoder:")]
		public Preferences(NSCoder coder) : base(coder)
		{
		}

		public override void AwakeFromNib()
		{
			base.AwakeFromNib();
		}
	}
}
