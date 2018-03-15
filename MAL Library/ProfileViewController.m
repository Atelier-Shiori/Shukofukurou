//
//  ProfileViewController.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/10/07.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "ProfileViewController.h"
//#import "MyAnimeList.h"
#import "listservice.h"
#import "AppDelegate.h"
#import "messageswindow.h"
#import "messagecomposer.h"
#import "Keychain.h"
#import "Utility.h"

@interface ProfileViewController ()
@property (strong) NSString *homepageurl;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (instancetype)init {
    return [super initWithNibName:@"ProfileViewController" bundle:nil];
}

- (void)loadprofilewithUsername:(NSString *)username completion:(void (^)(bool))completion {
    [listservice retrieveProfile:username completion:^(id responseObject) {
        [self populateProfile:responseObject withUsername:username];
        if ([_usernamelabel.stringValue isEqualToString:@"Username"]) {
            [self populateProfile:responseObject withUsername:username];
        }
        completion(true);
    } error:^(NSError *error) {
        NSLog(@"%@",error);
        completion(false);
    }];
}
- (void)populateProfile:(id)responseobject withUsername:(NSString *)username {
    _usernamelabel.stringValue = [username lowercaseString];
    if (responseobject[@"avatar_url"] && responseobject[@"avatar_url"] != [NSNull null]) {
        _profileimage.image = [Utility loadImage:[NSString stringWithFormat:@"%@.jpg",[[responseobject[@"avatar_url"] stringByReplacingOccurrencesOfString:@"https://" withString:@""]stringByReplacingOccurrencesOfString:@"/" withString:@"-"]] withAppendPath:@"imgcache" fromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",responseobject[@"avatar_url"]]]];
    }
    else {
        _profileimage.image = [NSImage new];
    }
    NSMutableString *details = [NSMutableString new];
    if (responseobject[@"details"][@"extra"][@"about"]) {
        if (((NSString *)responseobject[@"details"][@"extra"][@"about"]).length > 0) {
            [details appendFormat:@"%@\n\n", responseobject[@"details"][@"extra"][@"about"]];
        }
    }
    [details appendString:@"General Details:\n"];
    if (responseobject[@"details"][@"gender"] && responseobject[@"details"][@"gender"] != [NSNull null]) {
        [details appendFormat:@"Gender: %@\n", responseobject[@"details"][@"gender"]];
    }
    if (responseobject[@"details"][@"birthday"] && responseobject[@"details"][@"birthday"] != [NSNull null]) {
        [details appendFormat:@"Birthday: %@\n", responseobject[@"details"][@"birthday"]];
    }
    if (responseobject[@"details"][@"location"] && ![NSNull null]) {
        [details appendFormat:@"Location: %@\n", responseobject[@"details"][@"location"]];
    }
    [details appendFormat:@"Join Date: %@\n", responseobject[@"details"][@"join_date"]];
    [details appendFormat:@"Access Rank: %@\n\n", responseobject[@"details"][@"access_rank"]];
    [details appendString:@"Member Statistics:\n"];
    [details appendFormat:@"Forum Posts: %@\n", responseobject[@"details"][@"forum_posts"]];
    switch ([listservice getCurrentServiceID]) {
        case 1: {
            [details appendFormat:@"Reviews: %@\n", responseobject[@"details"][@"reviews"]];
            [details appendFormat:@"Recommendations: %@\n", responseobject[@"details"][@"recommendations"]];
            [details appendFormat:@"Blog Posts: %@\n", responseobject[@"details"][@"blog_posts"]];
            [details appendFormat:@"Clubs Joined: %@\n", responseobject[@"details"][@"clubs"]];
            [details appendFormat:@"Comments: %@\n", responseobject[@"details"][@"comments"]];
            _sendmessagebtn.hidden = false;
            break;
        }
        case 2: {
            [details appendFormat:@"Reactions: %@\n", responseobject[@"details"][@"reviews"]];
            [details appendFormat:@"Likes Given: %@\n", responseobject[@"details"][@"extra"][@"likes_given"]];
            [details appendFormat:@"Liked: %@\n", responseobject[@"details"][@"extra"][@"likes_recieved"]];
            [details appendFormat:@"Comments: %@\n", responseobject[@"details"][@"comments"]];
            _sendmessagebtn.hidden = true;
            break;
        }
        default:
            break;
    }

    if (responseobject[@"details"][@"website"] && responseobject[@"details"][@"website"] != [NSNull null] && ![(NSString *)responseobject[@"details"][@"website"] containsString:@"myanimelist.net/rss.php"]) {
        _homepageurl = responseobject[@"details"][@"website"];
        _homepagebtn.hidden = false;
    }
    else {
        _homepageurl = @"";
        _homepagebtn.hidden = true;
    }
    _profiledetails.string = details;
    _profiledetails.textColor = NSColor.controlTextColor;
}
- (IBAction)sendprivatemessage:(id)sender {
    if ([Keychain checkaccount]){
        messagecomposer *mc = [[(AppDelegate *)NSApplication.sharedApplication.delegate getMessagesWindow] getMessageComposerWindow];
        [mc.window makeKeyAndOrderFront:self];
        [mc setToUsername:_usernamelabel.stringValue];
    }
}
- (IBAction)viewuserhomepage:(id)sender {
    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:_homepageurl]];
}

- (void)resetprofileview {
    _profileimage.image = [NSImage new];
    _homepageurl = nil;
    _profiledetails.string = @"";
    _usernamelabel.stringValue = @"";
}

@end
