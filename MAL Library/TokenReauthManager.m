//
//  TokenReauthManager.m
//  Shukofukurou
//
//  Created by 香風智乃 on 8/2/20.
//  Copyright © 2020 Atelier Shiori. All rights reserved.
//

#import "TokenReauthManager.h"
#import "listservice.h"
#import "AppDelegate.h"

@implementation TokenReauthManager
+ (void)checkRefreshOrReauth {
    if ([listservice.sharedInstance checkAccountForCurrentService]) {
        int current = listservice.sharedInstance.getCurrentServiceID;
        switch (current) {
            case 1: {
                if (listservice.sharedInstance.myanimelistManager.tokenexpired) {
                    [listservice.sharedInstance.myanimelistManager refreshToken:^(bool success) {
                        if (!success) {
                            [TokenReauthManager showReAuthMessage];
                        }
                    }];
                }
                break;
            }
            case 3: {
                if (listservice.sharedInstance.anilistManager.tokenexpired) {
                    [TokenReauthManager showReAuthMessage];
                }
                break;
            }
            default:
                break;
        }
    }
}
+ (void)showReAuthMessage {
    [(AppDelegate *)NSApplication.sharedApplication.delegate reauthorizeAccount:nil];
}
@end
