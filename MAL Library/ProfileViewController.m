//
//  ProfileViewController.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/10/07.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "ProfileViewController.h"
#import "listservice.h"
#import "AppDelegate.h"
#import "Keychain.h"
#import "Utility.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSTextView+SetHTMLAttributedText.h"

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
    _usernamelabel.stringValue = username.lowercaseString;
    if (responseobject[@"avatar_url"] && responseobject[@"avatar_url"] != [NSNull null]) {
        [_profileimage sd_setImageWithURL:responseobject[@"avatar_url"]];
    }
    else {
        _profileimage.image = [NSImage new];
    }
    NSMutableString *details = [NSMutableString new];
    if (responseobject[@"details"][@"extra"][@"about"] && responseobject[@"details"][@"extra"][@"about"] != [NSNull null]) {
        if (((NSString *)responseobject[@"details"][@"extra"][@"about"]).length > 0) {
            [details appendFormat:@"%@\n\n", responseobject[@"details"][@"extra"][@"about"]];
        }
    }
    if ([listservice getCurrentServiceID] != 3) {
        [details appendString:@"General Details:<br />"];
        if (responseobject[@"details"][@"gender"] && responseobject[@"details"][@"gender"] != [NSNull null]) {
            [details appendFormat:@"Gender: %@<br />", responseobject[@"details"][@"gender"]];
        }
        if (responseobject[@"details"][@"birthday"] && responseobject[@"details"][@"birthday"] != [NSNull null]) {
            [details appendFormat:@"Birthday: %@<br />", responseobject[@"details"][@"birthday"]];
        }
        if (responseobject[@"details"][@"location"] && ![NSNull null]) {
            [details appendFormat:@"Location: %@<br />", responseobject[@"details"][@"location"]];
        }
        [details appendFormat:@"Join Date: %@<br />", responseobject[@"details"][@"join_date"]];
        [details appendFormat:@"Access Rank: %@<br /><br />", responseobject[@"details"][@"access_rank"]];
        [details appendString:@"Member Statistics:<br />"];
        [details appendFormat:@"Forum Posts: %@<br />", responseobject[@"details"][@"forum_posts"]];
        switch ([listservice getCurrentServiceID]) {
            case 1: {
                [details appendFormat:@"Reviews: %@<br />", responseobject[@"details"][@"reviews"]];
                [details appendFormat:@"Recommendations: %@<br />", responseobject[@"details"][@"recommendations"]];
                [details appendFormat:@"Blog Posts: %@<br />", responseobject[@"details"][@"blog_posts"]];
                [details appendFormat:@"Clubs Joined: %@<br />", responseobject[@"details"][@"clubs"]];
                [details appendFormat:@"Comments: %@<br />", responseobject[@"details"][@"comments"]];
                _sendmessagebtn.hidden = false;
                break;
            }
            case 2: {
                [details appendFormat:@"Reactions: %@<br />", responseobject[@"details"][@"reviews"]];
                [details appendFormat:@"Likes Given: %@<br />", responseobject[@"details"][@"extra"][@"likes_given"]];
                [details appendFormat:@"Liked: %@<br />", responseobject[@"details"][@"extra"][@"likes_recieved"]];
                [details appendFormat:@"Comments: %@<br />", responseobject[@"details"][@"comments"]];
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
    }
    else {
        _homepageurl = @"";
        _homepagebtn.hidden = true;
        _sendmessagebtn.hidden = true;
        [NSUserDefaults.standardUserDefaults setObject:responseobject[@"details"][@"extra"][@"scoreFormat"] forKey:@"anilist-otheruser-scoreformat"];
    }
    __weak ProfileViewController *weakself = self;
    [_profiledetails setTextToHTML:details withLoadingText:@"Loading" completion:^(NSAttributedString * _Nonnull astr) {
        [weakself.profiledetails.textStorage setAttributedString:astr];
        weakself.profiledetails.textColor = NSColor.controlTextColor;
    }];
}
- (IBAction)viewuserhomepage:(id)sender {
    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:_homepageurl]];
}

- (void)resetprofileview {
    _profileimage.image = nil;
    _homepageurl = nil;
    _profiledetails.string = @"";
    _usernamelabel.stringValue = @"";
}

@end
