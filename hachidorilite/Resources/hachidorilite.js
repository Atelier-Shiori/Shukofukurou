            document.addEventListener("DOMContentLoaded", function(event) {
                safari.extension.dispatchMessage("Hello World!");
                console.log("Hachidori Lite loaded");
                console.log("Detecting");
                setTimeout(function(){
                    var url = window.location.href;
                    if (url.includes("crunchyroll")) {
                        if (url.includes("history")) {
                            detectCrunchyrollHistory();
                        }
                        else {
                            detectCrunchyroll();
                        }
                    }
                    else if (url.includes("funimation")) {
                        if (url.includes("account")) {
                            detectFunimationHistory()
                        }
                    }
                    else {
                          getDOM();
                    }
                }, 15000);
        });

function getDOM() {
    var dom = document.documentElement.innerHTML;
    console.log(dom);
    if (dom.length > 0) {
        safari.extension.dispatchMessage("DomReceived", {"DOM" : dom});
    }
}

function detectCrunchyroll() {
    var mediainfo = document.querySelector('.erc-current-media-info').innerHTML;
    console.log(mediainfo);
    if (mediainfo.length > 0) {
        safari.extension.dispatchMessage("DomReceived", {"DOM" : mediainfo});
    }
}
function detectCrunchyrollHistory() {
    var history = document.querySelector('.history-collection').innerHTML;
    console.log(history);
    if (history.length > 0) {
        safari.extension.dispatchMessage("DomReceived", {"DOM" : history});
    }
}

function detectFunimationHistory() {
    var history = document.querySelector('.history-item').innerHTML;
    console.log(history);
    if (history.length > 0) {
        safari.extension.dispatchMessage("DomReceived", {"DOM" : history});
    }
}

function showResults(event) {
    console.log(event.message);
}
