using System;
using AppKit;
using Foundation;
namespace MALLibrary
{
	public class UserAgent 
	{
		public static string getUserAgent()
		{
			// Set default user agent
			string bundlename = NSBundle.MainBundle.InfoDictionary.ObjectForKey(new NSString("CFBundleName")).ToString();
			string bundleversion = NSBundle.MainBundle.InfoDictionary.ObjectForKey(new NSString("CFBundleShortVersionString")).ToString();
			string osversion = NSDictionary.FromFile("/System/Library/CoreServices/SystemVersion.plist").ObjectForKey(new NSString("ProductVersion")).ToString();
			string locale = NSLocale.CurrentLocale.LocaleIdentifier;
			return bundlename + " " + bundleversion + " (Macintosh; Mac OS X " + osversion + "; " + locale + ")";
		}
	}
}
