//
//  AniListAuthWindow.m
//  MAL Library
//
//  Created by 小鳥遊六花 on 4/3/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "AniListAuthWindow.h"
#import <WebKit/WebKit.h>
#import "ClientConstants.h"

@interface AniListAuthWindow ()
@property (strong, nonatomic) WKWebView *webView;
@property (strong) IBOutlet NSView *containerview;
@end

@implementation AniListAuthWindow

- (instancetype)init{
    self = [super initWithWindowNibName:@"AniListAuthWindow"];
    if (!self)
        return nil;
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    WKWebViewConfiguration *webConfiguration = [WKWebViewConfiguration new];
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, _containerview.frame.size.width, _containerview.frame.size.height) configuration:webConfiguration];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [_containerview  addSubview:_webView];
}

- (NSURL *)authURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/api/v2/oauth/authorize?client_id=%@&response_type=code",kanilistclient]];
}

- (void)loadAuthorization {
    [_webView loadRequest:[NSURLRequest requestWithURL:[self authURL]]];
}

- (IBAction)cancel:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}

#pragma mark WKWebView Delegate
- (void)webViewDidClose:(WKWebView *)webView {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([webView.URL.absoluteString containsString:@"mallibraryauth://anilistauth/?code="]) {
        // Save Pin
        _pin = [webView.URL.absoluteString stringByReplacingOccurrencesOfString:@"mallibraryauth://anilistauth/?code=" withString:@""];
        decisionHandler(WKNavigationActionPolicyCancel);
        [self resetWebView];
        [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
- (void)resetWebView {
    // Clears WebView cookies and cache
    NSSet *websiteDataTypes
    = [NSSet setWithArray:@[
                            WKWebsiteDataTypeDiskCache,
                            WKWebsiteDataTypeOfflineWebApplicationCache,
                            WKWebsiteDataTypeMemoryCache,
                            WKWebsiteDataTypeLocalStorage,
                            WKWebsiteDataTypeCookies,
                            WKWebsiteDataTypeSessionStorage,
                            WKWebsiteDataTypeIndexedDBDatabases,
                            WKWebsiteDataTypeWebSQLDatabases
                            ]];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
    }];
}

@end
