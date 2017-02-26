using System;

using Foundation;
using AppKit;
using CoreGraphics;
using RestSharp;
using System.Threading;
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
		public IRestResponse search(string term)
		{
			// Retrieves Search Data from Atarashii-API
			RestRequest request = new RestRequest("anime/search", Method.GET);
			request.AddParameter("q", term);

			IRestResponse response = client.Execute(request);
			return response;
		}
		public IRestResponse loadanimeinfo(int i){
			// Loads Anime Information from Atarashii-API
			RestRequest request = new RestRequest("anime/" + i, Method.GET);

			IRestResponse response = client.Execute(request);
			return response;
		}
	}
}
