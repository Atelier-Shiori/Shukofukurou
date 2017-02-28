using System;

using Foundation;
using AppKit;
using RestSharp;
using RestSharp.Authenticators;
using System.Threading;
using System.IO;
namespace MALLibrary
{
	public class MyAnimeList
	{
		RestClient client;
		public MyAnimeList()
		{
			// Initalize RestClient
			client = new RestClient("https://malapi.ateliershiori.moe/2.1/");
			client.UserAgent = UserAgent.getUserAgent();
		}
		public IRestResponse login(string username, string password)
		{
			RestRequest request = new RestRequest("account/verify_credentials", Method.GET);
			client.Authenticator = new HttpBasicAuthenticator(username, password);
			IRestResponse response = client.Execute(request);
			return response;
		}
		public IRestResponse search(string term)
		{
			// Retrieves Search Data from Atarashii-API
			RestRequest request = new RestRequest("anime/search", Method.GET);
			request.AddParameter("q", term);

			IRestResponse response = client.Execute(request);
			return response;
		}
		public IRestResponse loadanimeinfo(int i)
		{
			// Loads Anime Information from Atarashii-API
			RestRequest request = new RestRequest("anime/" + i, Method.GET);
			IRestResponse response = client.Execute(request);
			return response;
		}
		public string loadanimeList(string username, bool refreshlist)
		{
			string path = SupportFiles.retrieveApplicationSupportDirectory();
			if (refreshlist == true || File.Exists(path + "/list-" + username + ".json") == false)
			{
				return retrievelist(username);
			}
			return System.IO.File.ReadAllText(path + "/list-" + username + ".json");
		}
		public string retrievelist(string username)
		{
			RestRequest request = new RestRequest("animelist/"+username, Method.GET);

			IRestResponse response = client.Execute(request);
			if (response.StatusCode.GetHashCode() == 200)
			{
				string directory = SupportFiles.retrieveApplicationSupportDirectory("/");
				System.IO.File.WriteAllText(directory + "list-"+ username + ".json", response.Content);
				return System.IO.File.ReadAllText(directory + "list-" + username + ".json");
			}
			return "";

		}
	}
}
