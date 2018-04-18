//
//  ProfileViewController.h
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/10/07.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProfileViewController : NSViewController
@property (strong) IBOutlet NSTextField *usernamelabel;
@property (strong) IBOutlet NSTextView *profiledetails;
@property (strong) IBOutlet NSButton *homepagebtn;
@property (strong) IBOutlet NSImageView *profileimage;
@property (strong) IBOutlet NSButton *sendmessagebtn;
- (void)loadprofilewithUsername:(NSString *)username completion:(void (^)(bool))completion;
- (void)resetprofileview;
@end
