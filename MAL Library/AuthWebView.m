//
//  AuthWebView.m
//  Shukofukurou
//
//  Created by 小鳥遊六花 on 4/24/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "AuthWebView.h"
#import "ClientConstants.h"
#import "listservice.h"
#import <Hakuchou/Hakuchou.h>

@interface AuthWebView ()
@end

@implementation AuthWebView
- (void)loadView {
    WKWebViewConfiguration *webConfiguration = [WKWebViewConfiguration new];
    _webView = [[WKWebView alloc] initWithFrame:NSZeroRect configuration:webConfiguration];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    _webView.customUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15";
    self.view = _webView;
    _webView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(oauthredirectreceived:) name:@"shukofukurou_auth" object:nil];
    // Do view setup here.
    [self loadAuthorization:_service];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)reloadAuth {
    [self loadAuthorization:_service];
}

- (void)oauthredirectreceived: (NSNotification *)notification {
    NSString *redirectURL;
    switch (_service) {
            case 1:
                redirectURL = @"shukofukurouauth://malauth/?code=";
                break;
            case 3:
                redirectURL = @"shukofukurouauth://anilistauth/?code=";
                break;
            default:
                break;
    }
    if ([(NSString *)notification.object containsString:redirectURL]) {
        // Save Pin
        [self resetWebView];
        _completion([(NSString *)notification.object stringByReplacingOccurrencesOfString:redirectURL withString:@""]);
    }
}

- (NSURL *)authURL {
    NSString *authurl;
    switch (_service) {
        case 3:
            authurl = [NSString stringWithFormat:@"https://anilist.co/api/v2/oauth/authorize?client_id=%@&response_type=code",kanilistclient];
            break;
        case 1:
            return [listservice.sharedInstance.myanimelistManager retrieveAuthorizeURL];
        default:
            break;
    }
    return [NSURL URLWithString:authurl];
}

- (void)loadAuthorization:(int)nservice {
    _service = nservice;
    [_webView loadRequest:[NSURLRequest requestWithURL:[self authURL]]];
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *redirectURL;
    switch (_service) {
        case 1:
            redirectURL = @"shukofukurouauth://malauth/?code=";
            break;
        case 3:
            redirectURL = @"shukofukurouauth://anilistauth/?code=";
            break;
        default:
            break;
    }
    if ([navigationAction.request.URL.absoluteString containsString:redirectURL]) {
        // Save Pin
        decisionHandler(WKNavigationActionPolicyCancel);
        [self resetWebView];
        _completion([navigationAction.request.URL.absoluteString stringByReplacingOccurrencesOfString:redirectURL withString:@""]);
    }
    else if ([navigationAction.request.URL.absoluteString isEqualToString:@"https://myanimelist.net/"]) {
        // Redirect to OAuth URL for MyAnimeList
        decisionHandler(WKNavigationActionPolicyCancel);
        [_webView loadRequest:[NSURLRequest requestWithURL:[self authURL]]];
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    self.state(webView.canGoBack, webView.canGoForward, webView.title);
}


- (void)resetWebView {
    // Clears WebView cookies and cache
    NSSet *websiteDataTypes;
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_12) {
        websiteDataTypes = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache,WKWebsiteDataTypeOfflineWebApplicationCache,WKWebsiteDataTypeMemoryCache,WKWebsiteDataTypeLocalStorage,WKWebsiteDataTypeCookies,WKWebsiteDataTypeSessionStorage,WKWebsiteDataTypeIndexedDBDatabases, WKWebsiteDataTypeWebSQLDatabases]];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        }];
    }
    else {
        return;
    }
}



@end
