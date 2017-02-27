using System;
using Security;
using AppKit;
using Foundation;

namespace MALLibrary
{
	public class Keychain
	{
		public static bool saveaccount(string username, string password)
		{
			// Saves the account to the user's keychain
			var rec = new SecRecord(SecKind.GenericPassword);
			rec.Account = username;
			rec.Service = NSBundle.MainBundle.InfoDictionary.ObjectForKey(new NSString("CFBundleName")).ToString();
			rec.Generic = NSData.FromString(password);
			var err = SecKeyChain.Add(rec);
			if (err != SecStatusCode.Success && err != SecStatusCode.DuplicateItem)
			{
				return false;
			}
			else {
				return true;
			}
		}
		public static SecRecord retrieveaccount()
		{
			// Retrieves account from user's keychain
			var rec = new SecRecord(SecKind.GenericPassword);
			rec.Service = NSBundle.MainBundle.InfoDictionary.ObjectForKey(new NSString("CFBundleName")).ToString();
			SecStatusCode res;
			var match = SecKeyChain.QueryAsRecord(rec, out res);
			if (res == SecStatusCode.Success)
			{
				return match;
			}
			return null;
		}
		public static bool removeaccount()
		{
			// Removes account from user's keychain
			var rec = Keychain.retrieveaccount();
			var rec2 = new SecRecord(SecKind.GenericPassword);
			rec2.Account = rec.Account;
			rec2.Service = NSBundle.MainBundle.InfoDictionary.ObjectForKey(new NSString("CFBundleName")).ToString();
			var err = SecKeyChain.Remove(rec2);
			if (err != SecStatusCode.Success)
			{
				return false;
			}
			else {
				return true;
			}
		}
		public static bool checkacountexists()
		{
			var rec = retrieveaccount();
			if (rec == null)
			{
				return false;
			}
			return true;
		}
	}
}
