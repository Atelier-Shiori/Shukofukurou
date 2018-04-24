const command_menu = "open_in_mal_library_menu_cmd";
const command_btn = "open_in_mal_library_toolbar_btn_cmd";

var eventHandler = function(event) {
  if (event.command == command_menu || event.command == command_btn) {
    	var tab = safari.application.activeBrowserWindow.activeTab;
    	var active_url = tab.url;
    	if (active_url) {
			var urlcheck = /(myanimelist.net|kitsu.io|anilist.co)/;
			if (active_url.search(urlcheck) > 0){
				var animepagecheck = /((myanimelist.net|kitsu.io|anilist.co)\/anime\/\d+)/;
				var mangapagecheck = /((myanimelist.net|kitsu.io|anilist.co)\/manga\/\d+)/;
				var profilepagecheck = /((myanimelist.net|kitsu.io|anilist.co)\/(profile|user|users)\/.*)/;
				var replacestring = /((myanimelist.net|kitsu.io|anilist.co)\/)/;
				var sitename = active_url.match(/(myanimelist|kitsu|anilist)/)[1];
				if (active_url.search(animepagecheck) > 0) {
					var matchurl = active_url.match(animepagecheck);
					var firstmatch = matchurl[1];
					tab.url = "shukofukurou://" + sitename + "/" + firstmatch.replace(replacestring,"");
				}
				else if (active_url.search(mangapagecheck) > 0) {
					var matchurl = active_url.match(mangapagecheck);
					var firstmatch = matchurl[1];
					tab.url = "shukofukurou://" + sitename + "/" + firstmatch.replace(replacestring,"");
				}
				else if (active_url.search(profilepagecheck) > 0) {
					var matchurl = active_url.match(profilepagecheck);
					var firstmatch = matchurl[1];
					tab.url = "shukofukurou://" + sitename + "/" + firstmatch.replace(replacestring,"");
				}
			}
		}
	}
};
safari.application.addEventListener("command", eventHandler, false);