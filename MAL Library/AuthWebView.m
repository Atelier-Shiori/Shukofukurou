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
@property (strong) WKWebView *webView;
@end

@implementation AuthWebView
- (void)loadView {
    WKWebViewConfiguration *webConfiguration = [WKWebViewConfiguration new];
    _webView = [[WKWebView alloc] initWithFrame:NSZeroRect configuration:webConfiguration];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    self.view = _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self loadAuthorization:_service];
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
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
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
