using System;
using Foundation;
using AppKit;
using RestSharp;
using System.Threading;
using System.Collections.Generic;
namespace MALLibrary
{
	public class Donation
	{
		public static int performKeyValidation(string name, string key)
		{
				// Checks donation key
				RestClient seasonclient = new RestClient("https://updates.ateliershiori.moe/keycheck/");
				seasonclient.UserAgent = UserAgent.getUserAgent();
				RestRequest request = new RestRequest("check.php", Method.POST);
			NSMutableDictionary d = new NSMutableDictionary();
			d.Add((NSString)"name", (NSString)name);
			d.Add((NSString)"key", (NSString)key);
			NSError error;
			NSData jsondata = NSJsonSerialization.Serialize(d, 0, out error);
			string body = new NSString(jsondata, NSStringEncoding.UTF8);
			request.AddParameter("application/json", body, ParameterType.RequestBody);
				IRestResponse response = seasonclient.Execute(request);
			if (response.StatusCode.GetHashCode() == 200)
			{
				NSData data = NSData.FromString(response.Content);
				NSError e;
				NSDictionary json = (NSDictionary)NSJsonSerialization.Deserialize(data, 0, out e);
				NSNumber valid = (NSNumber)json.ValueForKey((NSString)"valid");
				if (valid.Int32Value == 1)
				{
					return 1; // Valid Key
				}
				else if (valid.Int32Value == 0)
				{
					return 0; // Invalid Key
				}
			}
			return 2; // No internet
		}
		public static void setReminderDate()
		{
			NSDate date = NSDate.Now;
			NSDate reminderdate = date.AddSeconds(60 * 60 * 24 * 14);
			NSUserDefaults.StandardUserDefaults.SetValueForKey(reminderdate, (NSString)"donatereminderdate");
		}
		public static int shouldshowDonationReminder()
		{
			if (NSUserDefaults.StandardUserDefaults.ValueForKey((NSString)"donatereminderdate") == null)
			{
				Donation.setReminderDate();
				return 0;
			}
			NSDate date = (NSDate)NSUserDefaults.StandardUserDefaults.ValueForKey((NSString)"donatereminderdate");

			if (date.SecondsSinceReferenceDate - NSDate.Now.SecondsSinceReferenceDate < 0)
			{
				NSNumber donated = (NSNumber)NSUserDefaults.StandardUserDefaults.ValueForKey((NSString)"donated");
				if (donated.BoolValue)
				{
					string donor = (NSString)NSUserDefaults.StandardUserDefaults.ValueForKey((NSString)"donor").ToString();
					string key = (NSString)NSUserDefaults.StandardUserDefaults.ValueForKey((NSString)"key").ToString();
					int validkey = Donation.performKeyValidation(donor, key);
					switch (validkey)
					{
						case 0:
							NSUserDefaults.StandardUserDefaults.SetValueForKey(new NSNumber(false), (NSString)"donated");
							NSUserDefaults.StandardUserDefaults.SetValueForKey(new NSString(), (NSString)"donor");
							NSUserDefaults.StandardUserDefaults.SetValueForKey(new NSString(), (NSString)"key");
							return 2;
						case 1:
							Donation.setReminderDate();
							return 0;
						case 2:
							return 0;
					}
				}
				else {
					return 1;
				}
			}
			return 0;
		}
	}
}
