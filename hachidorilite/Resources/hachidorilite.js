document.addEventListener("DOMContentLoaded", function(event) {
    safari.extension.dispatchMessage("Hello World!");
    console.log("Hachidori Lite loaded");
});
function notSupported(event) {
    alert("Hachidori Lite does not support this website. Sites Supported are Crunchyroll, Hidive, and Funimation.");
}

function getDOM(event) {
    var dom = document.documentElement.innerHTML;
    console.log(dom);
    if (dom.length > 0) {
        safari.extension.dispatchMessage("DomReceived", {"DOM" : dom});
    }
}

function detectCrunchyroll(event) {
    var mediainfo = document.querySelector('.erc-current-media-info').innerHTML;
    console.log(mediainfo);
    if (mediainfo.length > 0) {
        safari.extension.dispatchMessage("DomReceived", {"DOM" : mediainfo});
    }
}
function detectCrunchyrollHistory(event) {
    var history = document.querySelector('.history-collection').innerHTML;
    console.log(history);
    if (history.length > 0) {
        safari.extension.dispatchMessage("DomReceived", {"DOM" : history});
    }
}

function detectFunimationHistory(event) {
    var history = document.querySelector('.history-item').innerHTML;
    console.log(history);
    if (history.length > 0) {
        safari.extension.dispatchMessage("DomReceived", {"DOM" : history});
    }
}

function showResults(event) {
    console.log(event.message);
}

document.addEventListener("DetectNotFound", function(event) {
    alert("Hachidori Lite does not support this website. Sites Supported are Crunchyroll, Hidive, and Funimation.");
    console.log("Unsupported Site");
});
document.addEventListener("CrunchyrollHistory", detectCrunchyrollHistory);
document.addEventListener("CrunchyrollDetection", detectCrunchyroll);
document.addEventListener("FunimationHistory", detectFunimationHistory);
document.addEventListener("GetDOM", getDOM);
document.addEventListener("ShowResults", showResults);
