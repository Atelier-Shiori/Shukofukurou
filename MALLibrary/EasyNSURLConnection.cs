using System;
using AppKit;
using Foundation;

namespace MALLibrary
{
	public class EasyNSURLConnection
	{
		String useragent;
		String postmethod;
		NSMutableArray headers;
		NSMutableArray formdata;
		NSHttpUrlResponse response;
		NSData responsedata;
		NSError error;
		NSUrl URL;
		bool usecookies;
		public EasyNSURLConnection(String address)
		{
			URL = new NSUrl(address);
			// Set default user agent
			string bundlename = NSBundle.MainBundle.InfoDictionary.ObjectForKey(new NSString("CFBundleName")).ToString();
			string bundleversion = NSBundle.MainBundle.InfoDictionary.ObjectForKey(new NSString("CFBundleShortVersionString")).ToString();
			string osversion = NSDictionary.FromFile("/System/Library/CoreServices/SystemVersion.plist").ObjectForKey(new NSString("ProductVersion")).ToString();
			string locale = NSLocale.CurrentLocale.LocaleIdentifier;
			useragent = bundlename + " " + bundleversion + " (Macintosh; Mac OS X " + osversion + "; " + locale;
		}
		public NSData getResponseData()
		{
			return responsedata;
		}
		public string getResponseDataString()
		{
			String datastring = NSString.FromData(responsedata, NSStringEncoding.UTF8).ToString();
			return datastring;
		}
		public long getStatusCode()
		{
			return response.StatusCode;
		}
		public NSError getError() 
		{
			return error;
		}
		public void addHeader(object value, String key)
		{
			NSLock nlock = new NSLock();
			nlock.Lock();
			if (headers == null)
			{
				headers = new NSMutableArray();
			}
			headers.Add(NSDictionary.FromObjectAndKey(NSObject.FromObject(value), new NSString(key)));
		}
		public void addFormData(object value, string key)
		{
			NSLock nlock = new NSLock();
			nlock.Lock();
			if (formdata == null)
			{
				formdata = new NSMutableArray();
			}
			formdata.Add(NSDictionary.FromObjectAndKey(NSObject.FromObject(value), new NSString(key)));
		}
		public void setUserAgent(string agent)
		{
			useragent = agent;
		}
		public void setUseCookies(bool choice)
		{
			usecookies = choice;
		}
		public void setPostMethod(string method)
		{
			postmethod = method;
		}
		public void startRequest()
		{
			
			// Send a synchronous request
			NSMutableUrlRequest request = new NSMutableUrlRequest();
			request.Url = URL;
			NSHttpUrlResponse rresponse = null;
			//Set Method
			if (postmethod.Length != 0)
			{
				request.HttpMethod = postmethod;
			}
			else
			{
				request.HttpMethod = "POST";
			}
			// Set content type to form data
			request.SetValueForKey(NSObject.FromObject("application/x-www-form-urlencoded"), new NSString("Content-Type"));
			// Set cookies
			request.ShouldHandleCookies = usecookies;
			// Set User Agent
			request.SetValueForKey(NSObject.FromObject(useragent), new NSString("User-Agent"));
			// Set Timeout
			request.TimeoutInterval = 15;
			NSLock nlock = new NSLock();
			nlock.Lock();
			//Set Form Data
			request.Body = this.encodeArray(formdata);
			// Set Other Headers, if any
			if (headers != null)
			{
				for (nuint i = 0; i > headers.Count; i++)
				{
					NSDictionary h = headers.GetItem<NSDictionary>(i);
					// Set an headers
					request.SetValueForKey(h.Values[0], (NSString)h.Keys[0]);
				}
			}
			nlock.Unlock();
			NSError rerror;
			responsedata = NSUrlConnection.SendSynchronousRequest(request,out rresponse, out rerror);
			error = rerror;
			response = rresponse;
		}
		public void startFormRequest()
		{
		}
		private NSData encodeArray(NSArray a)
		{
		}

	}
}
