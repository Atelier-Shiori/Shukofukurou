//
//  AuthWebView.m
//  Shukofukurou
//
//  Created by 小鳥遊六花 on 4/24/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "AuthWebView.h"
#import "ClientConstants.h"

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
    [self loadAuthorization];
}

- (NSURL *)authURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/api/v2/oauth/authorize?client_id=%@&response_type=code",kanilistclient]];
}

- (void)loadAuthorization {
    [_webView loadRequest:[NSURLRequest requestWithURL:[self authURL]]];
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([navigationAction.request.URL.absoluteString containsString:@"shukofukurouauth://anilistauth/?code="]) {
        // Save Pin
        decisionHandler(WKNavigationActionPolicyCancel);
        [self resetWebView];
        _completion([navigationAction.request.URL.absoluteString stringByReplacingOccurrencesOfString:@"shukofukurouauth://anilistauth/?code=" withString:@""]);
    }
    else if ([navigationAction.request.URL.absoluteString containsString:@"http://"]) {
        NSLog(@"Insecure URL, changing to HTTPS");
        NSString *newURL = [navigationAction.request.URL.absoluteString stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
        decisionHandler(WKNavigationActionPolicyCancel);
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:newURL]]];
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
