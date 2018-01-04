//
//  loginviewcontrolelr.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/12/19.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "loginviewcontroller.h"

@interface loginviewcontrolelr ()

@end

@implementation loginviewcontrolelr

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setCurrentservice:(int)service {
    switch (service) {
        case MyAnimeListService:
        case KitsuService:
            // Show regular login
            _usernamelbl.hidden = false;
            _passwordlbl.hidden = false;
            _usernamefield.hidden = false;
            _passwordfield.hidden = false;
            _loginbtn.hidden = false;
            _authorizebtn.hidden = true;
            break;
        case AniListService:
            _usernamelbl.hidden = true;
            _passwordlbl.hidden = true;
            _usernamefield.hidden = true;
            _passwordfield.hidden = true;
            _loginbtn.hidden = true;
            _authorizebtn.hidden = false;
            break;
        default:
            break;
    }
    _currentservice = service;
}

- (void)checklogin {
    switch (_currentservice) {
        case MyAnimeListService:
            break;
        case KitsuService:
            break;
        case AniListService:
            break;
        default:
            break;
    }
    _currentservice = service;
}

- (IBAction)login:(id)sender {
}

- (IBAction)registersite:(id)sender {
}

@end
