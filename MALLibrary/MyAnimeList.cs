using RestSharp;
using RestSharp.Authenticators;
using System.IO;
using Security;
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
		public IRestResponse addtitle(int id, string episode, string status, int score)
		{
			RestRequest request = new RestRequest("animelist/anime", Method.POST);
			SecRecord account = Keychain.retrieveaccount();
			client.Authenticator = new HttpBasicAuthenticator(account.Account, account.Generic.ToString());
			request.AddParameter("anime_id", id);
			request.AddParameter("episodes", episode);
			request.AddParameter("status", status);
			request.AddParameter("score", score);
			IRestResponse response = client.Execute(request);
			return response;
		}
		public IRestResponse updatetitle(int id, string episode, string status, int score)
		{
			RestRequest request = new RestRequest("animelist/anime/"+id, Method.PUT);
			SecRecord account = Keychain.retrieveaccount();
			client.Authenticator = new HttpBasicAuthenticator(account.Account, account.Generic.ToString());
			request.AddParameter("episodes", episode);
			request.AddParameter("status", status);
			request.AddParameter("score", score);
			IRestResponse response = client.Execute(request);
			return response;
		}
		public IRestResponse deletetitle(int id)
		{
			RestRequest request = new RestRequest("animelist/anime/" + id, Method.DELETE);
			SecRecord account = Keychain.retrieveaccount();
			client.Authenticator = new HttpBasicAuthenticator(account.Account, account.Generic.ToString());
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
			return File.ReadAllText(path + "/list-" + username + ".json");
		}
		public string retrievelist(string username)
		{
			RestRequest request = new RestRequest("animelist/"+username, Method.GET);

			IRestResponse response = client.Execute(request);
			string directory = SupportFiles.retrieveApplicationSupportDirectory("/");
			if (response.StatusCode.GetHashCode() == 200)
			{
				File.WriteAllText(directory + "list-"+ username + ".json", response.Content);
				return File.ReadAllText(directory + "list-" + username + ".json");
			}
			if (File.Exists(directory + "list-" + username + ".json") == true)
			{
				return File.ReadAllText(directory + "list-" + username + ".json");
			}
			return "";

		}
	}
}
