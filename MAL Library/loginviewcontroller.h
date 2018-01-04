//
//  loginviewcontrolelr.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/12/19.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface loginviewcontrolelr : NSViewController
typedef NS_ENUM(int, list_service) {
    MyAnimeListService = 0,
    KitsuService = 1,
    AniListService = 2
};
@property int currentservice;
@property (strong) IBOutlet NSView *loggedinview;
@property (strong) IBOutlet NSTextField *loggedinuser;
@property (strong) IBOutlet NSView *loggedoutview;
@property (strong) IBOutlet NSTextField *usernamefield;
@property (strong) IBOutlet NSSecureTextField *passwordfield;
@property (strong) IBOutlet NSButton *authorizebtn;
@property (strong) IBOutlet NSTextField *passwordlbl;
@property (strong) IBOutlet NSTextField *usernamelbl;
@property (strong) IBOutlet NSButton *loginbtn;
- (IBAction)login:(id)sender;
- (IBAction)registersite:(id)sender;

@end
