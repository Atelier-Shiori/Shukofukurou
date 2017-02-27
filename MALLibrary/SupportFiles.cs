using System;
using Foundation;
using AppKit;
using System.IO;
using RestSharp;
namespace MALLibrary
{
	public class SupportFiles
	{
		public static NSImage retrieveImage(string url, int id)
		{
			string path = SupportFiles.retrieveApplicationSupportDirectory("/imgcache/");
			if (path.Length > 0)
			{
				string filepath = path + id + ".jpg";
				if (File.Exists(filepath))
				{
					return new NSImage(filepath);
				}
				return SupportFiles.downloadImage(url,id);
			}
			return new NSImage();
		}
		public static NSImage downloadImage(string url, int id)
		{
			string path = SupportFiles.retrieveApplicationSupportDirectory("/imgcache/");
			Uri uri = new Uri(url);
			string filename = System.IO.Path.GetFileName(uri.AbsolutePath);
			if (filename.Length > 0)
			{
				string imgfile = path + id + ".jpg";
				using (var writer = File.OpenWrite(imgfile))
				{
					var client = new RestClient(url.Replace(filename,""));
					client.UserAgent = UserAgent.getUserAgent();
					var request = new RestRequest(filename);
					request.ResponseWriter = (responseStream) => responseStream.CopyTo(writer);
					var response = client.DownloadData(request);
					if (File.Exists(imgfile))
					{
						return new NSImage(imgfile);
					}
				}
			}
			return new NSImage();
		}
		public static string retrieveSeasonIndex(bool replaceexisting)
		{
			if (replaceexisting == false)
			{
				string path = SupportFiles.retrieveApplicationSupportDirectory("/seasondata/");
				if (path.Length > 0)
				{
					string filepath = path + "index.json";
					if (File.Exists(filepath))
					{
						return System.IO.File.ReadAllText(filepath);
					}
					return SupportFiles.downloadseasonindex();;
				}
			}
			return SupportFiles.downloadseasonindex();
		}
		public static string downloadseasonindex()
		{
			// Retrieves Season Data from Repo
			RestClient seasonclient = new RestClient("https://raw.githubusercontent.com/Atelier-Shiori/anime-season-json/master/");
			seasonclient.UserAgent = UserAgent.getUserAgent();
			RestRequest request = new RestRequest("index.json", Method.GET);

			IRestResponse response = seasonclient.Execute(request);
			if (response.StatusCode.GetHashCode() == 200)
			{
				string directory = SupportFiles.retrieveApplicationSupportDirectory("/seasondata/");
				System.IO.File.WriteAllText(directory + "index.json", response.Content);
				return System.IO.File.ReadAllText(directory + "index.json");
			}
			return "";
		}
		public static string retrievedataforyrseason(string year, string season, bool replaceexisting)
		{
			string path = SupportFiles.retrieveApplicationSupportDirectory("/seasondata/");
			if (File.Exists(path + year + "-" + season + ".json") == false || replaceexisting == true)
			{
				string content = SupportFiles.downloadseasondata(year, season);
				if (content.Length == 0)
				{
					// Download error, fail
					return "";
				}
				return content;
			}
			return System.IO.File.ReadAllText(path + year + "-" + season + ".json");
		}
		public static bool retrieveallseasondata(bool replaceexisting)
		{
			string path = SupportFiles.retrieveApplicationSupportDirectory("/seasondata/");
			NSData data = NSData.FromString(SupportFiles.retrieveSeasonIndex(false));
			NSError e;
			NSDictionary d = (NSDictionary)NSJsonSerialization.Deserialize(data, 0, out e);
			NSArray seasonindex = (NSArray)d.ValueForKey(new NSString("years"));
			for (int i = 0; i < (int)seasonindex.Count; i++)
			{
				NSDictionary yr = seasonindex.GetItem<NSDictionary>((nuint)i);
				string year = (NSString)yr.ValueForKey(new NSString("year")).ToString();
				NSArray seasons = (NSArray)yr.ValueForKey(new NSString("seasons"));
				for (nuint s = 0; s < seasons.Count; s++)
				{
					NSDictionary sd = seasons.GetItem<NSDictionary>(s);
					string seasonname = (NSString)sd.ValueForKey(new NSString("season")).ToString();
					if (File.Exists(path + year + "-" + seasonname + ".json") == false || replaceexisting == true){
						string content = SupportFiles.downloadseasondata(year, seasonname);
						if (content.Length == 0)
						{
							// Download error, fail
							return false;
						}
					}
				}
			}
			return true;
		}
		public static string downloadseasondata(string year, string season)
		{
			// Retrieves Season Data from Repo
			RestClient seasonclient = new RestClient("https://raw.githubusercontent.com/Atelier-Shiori/anime-season-json/master/data/");
			seasonclient.UserAgent = UserAgent.getUserAgent();
			RestRequest request = new RestRequest(year + "-" + season + ".json", Method.GET);

			IRestResponse response = seasonclient.Execute(request);
			if (response.StatusCode.GetHashCode() == 200)
			{
				string directory = SupportFiles.retrieveApplicationSupportDirectory("/seasondata/");
				System.IO.File.WriteAllText(directory + year + "-" + season + ".json", response.Content);
				return System.IO.File.ReadAllText(directory + year + "-" + season + ".json");
			}
			return "";
		}
		// Support Methods
		public static string retrieveApplicationSupportDirectory()
		{
			return retrieveApplicationSupportDirectory("");
		}
		public static string retrieveApplicationSupportDirectory(string appenddirectory)
		{
			NSFileManager filemanager = NSFileManager.DefaultManager;
			NSError error;
			string bundlename = NSBundle.MainBundle.InfoDictionary.ObjectForKey(new NSString("CFBundleName")).ToString();
			NSUrl directory = filemanager.GetUrl(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomain.User,null,true,out error);
			string basepath = directory.Path + "/" + bundlename + appenddirectory;
			if (Directory.Exists(basepath) == false)
			{
				bool success = filemanager.CreateDirectory(basepath, true, new NSDictionary(), out error);
				if (error != null || success == false)
				{
					return "";
				}
				return basepath;
			}
			return basepath;
		}
	}
}
