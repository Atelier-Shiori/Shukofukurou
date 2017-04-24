//
//  AppDelegate.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/02/28.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import <Cocoa/Cocoa.h>
#import "MainWindow.h"
#import "MSWeakTimer.h"
#import "MainWindow.h"
#import "messageswindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong,getter=getMainWindowController) MainWindow *mainwindowcontroller;
@property (strong) NSWindowController *_preferencesWindowController;
@property (strong) messageswindow *messageswindow;
// Preference Window
@property (nonatomic, readonly) NSWindowController *preferencesWindowController;
- (IBAction)showpreferences:(id)sender;
- (void)showloginpref;
- (IBAction)enterDonationKey:(id)sender;
- (void)clearMessages;
@end
