//
//  SafariExtensionHandler.m
//  hachidorilite
//
//  Created by 千代田桃 on 6/26/21.
//  Copyright © 2021 Atelier Shiori. All rights reserved.
//

#import "SafariExtensionHandler.h"

#import "ezregex.h"
#import "MediaStreamParse.h"

@interface SafariExtensionHandler ()
@property (strong) NSString *pagesite;
@property (strong) NSString *pageurl;
@property (strong) NSString *pagetitle;
@property (strong) NSString *pagedom;
@property (strong) NSArray *detected;
@end

@implementation SafariExtensionHandler

NSString *const supportedSites = @"(crunchyroll|funimation|hidive)";

- (void)messageReceivedWithName:(NSString *)messageName fromPage:(SFSafariPage *)page userInfo:(NSDictionary *)userInfo {
    // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
    [page getPagePropertiesWithCompletionHandler:^(SFSafariPageProperties *properties) {
        //NSLog(@"The extension received a message (%@) from a script injected into (%@) with userInfo (%@)", messageName, properties.url, userInfo);
        if ([messageName isEqualToString: @"DomReceived"]) {
            if (userInfo[@"DOM"]) {
                self.pagedom = userInfo[@"DOM"];
                [self performparsing:page];
            }
        }
    }];
}

- (void)toolbarItemClickedInWindow:(SFSafariWindow *)window {
    // This method will be called when your toolbar item is clicked.
    NSLog(@"Starting detection");
    [window getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTab) {
        if (activeTab) {
            [activeTab getActivePageWithCompletionHandler:^(SFSafariPage * _Nullable activePage) {
                if (activePage) {
                    [activePage getPagePropertiesWithCompletionHandler:^(SFSafariPageProperties * _Nullable properties) {
                        if (properties) {
                            self.pageurl = properties.url.absoluteString;
                            self.pagetitle = properties.title;
                            [self performDetectionwithPage:activePage];
                        }
                    }];
                }
            }];
        }
    }];
}

- (void)performDetectionwithPage: (SFSafariPage *)page {
    _pagesite = [self checkURL:_pageurl];
    if (_pagesite.length > 0) {
        if ([_pagesite isEqualToString:@"crunchyroll"] && [_pageurl containsString:@"beta"]){
            if ([_pageurl containsString:@"history"]) {
                [page dispatchMessageToScriptWithName:@"CrunchyrollHistory" userInfo:nil];
            }
            else {
                [page dispatchMessageToScriptWithName:@"CrunchyrollDetection" userInfo:nil];
            }
        }
        else if ([_pagesite isEqualToString:@"funimation"] && [[ezregex alloc] findMatches:_pageurl pattern:@"account"].count > 0) {
            [page dispatchMessageToScriptWithName:@"FunimationHistory" userInfo:nil];
        }
        else {
            _pagedom = @"";
            [self performparsing:page];
        }
    }
    else {
        [page dispatchMessageToScriptWithName:@"DetectNotFound" userInfo:nil];
    }
}

- (void)performparsing:(SFSafariPage *)page {
    NSArray *final = @[ @{@"title": _pagetitle, @"url": _pageurl, @"browser": @"Safari", @"site": _pagesite, @"DOM": _pagedom}];
    _detected = [MediaStreamParse parse:final];
    NSLog(@"%@",_detected);
    if (_detected.count > 0) {
        [page dispatchMessageToScriptWithName:@"ShowResults" userInfo:_detected[0]];
    }
}

- (void)showNotFoundMessage: (SFSafariPage *)page {
    [page dispatchMessageToScriptWithName:@"DetectNotFound" userInfo:nil];
}

- (void)validateToolbarItemInWindow:(SFSafariWindow *)window validationHandler:(void (^)(BOOL enabled, NSString *badgeText))validationHandler {
    // This method will be called whenever some state changes in the passed in window. You should use this as a chance to enable or disable your toolbar item and set badge text.
    validationHandler(YES, nil);
}

- (NSString *)checkURL:(NSString *)url {
    NSString * site = [[[ezregex alloc] init] findMatch:url pattern:supportedSites rangeatindex:0];
    return site;
}


@end
