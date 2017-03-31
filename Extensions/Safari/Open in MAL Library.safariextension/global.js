const command_menu = "open_in_mal_library_menu_cmd"
const command_btn = "open_in_mal_library_toolbar_btn_cmd" 

var eventHandler = function(event) {
  if (event.command == command_menu || event.command == command_btn) {
    	var tab = safari.application.activeBrowserWindow.activeTab
    	var active_url = tab.url
    	if (active_url) {
			var urlcheck = /(myanimelist.net)/
			if (active_url.search(urlcheck)>0){
				var animepagecheck = /(myanimelist.net\/anime\/\d+)/
				var mangapagecheck = /(myanimelist.net\/manga\/\d+)/
				if (active_url.search(animepagecheck) > 0){
					var matchurl = active_url.match(animepagecheck)
					var firstmatch = matchurl[1]
					var replacestring = /(myanimelist.net\/)/
					var url = "mallibrary://" + firstmatch.replace(replacestring,"")
					tab.url = url
				}
				if (active_url.search(mangapagecheck) > 0){
					var matchurl = active_url.match(mangapagecheck)
					var firstmatch = matchurl[1]
					var replacestring = /(myanimelist.net\/)/
					var url = "mallibrary://" + firstmatch.replace(replacestring,"")
					tab.url = url
				}
			}
		}
	}
}
safari.application.addEventListener("command", eventHandler, false)