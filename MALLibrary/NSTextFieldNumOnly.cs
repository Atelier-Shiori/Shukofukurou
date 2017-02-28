using System;
using Foundation;
using AppKit;
using System.Text.RegularExpressions;
namespace MALLibrary
{
	[Register("NSTextFieldNumOnlyDel")]
	public class NSTextFieldNumOnly : NSTextFieldDelegate
	{
		Regex digitsOnly = new Regex(@"[^\d]");
		public NSTextFieldNumOnly()
		{
		}
		public override void Changed(NSNotification notification)
		{
			// Return only numbers
			NSTextField field = (AppKit.NSTextField)notification.Object;
			field.StringValue = digitsOnly.Replace(field.StringValue,"");
		}
	}
}
