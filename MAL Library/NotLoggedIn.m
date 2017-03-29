//
//  NotLoggedIn.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "NotLoggedIn.h"
#import "AppDelegate.h"
#import "MainWindow.h"
@interface NotLoggedIn ()

@end

@implementation NotLoggedIn

- (id)init
{
    return [super initWithNibName:@"NotLoggedIn" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self view];
}

#pragma mark Not Logged in View
- (IBAction)performlogin:(id)sender {
    [[mw app] showloginpref];
}
@end
