//
//  NotLoggedIn.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "NotLoggedIn.h"
#import "AppDelegate.h"
#import "MainWindow.h"
@interface NotLoggedIn ()

@end

@implementation NotLoggedIn

- (instancetype)init {
    return [super initWithNibName:@"NotLoggedIn" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self view];
}

#pragma mark Not Logged in View
- (IBAction)performlogin:(id)sender {
    AppDelegate * del = _mw.appdel;
    [del showloginpref];
}
@end
