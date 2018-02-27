//
//  AppDelegate.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/02/28.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import <Cocoa/Cocoa.h>
#import "MainWindow.h"
#import "MSWeakTimer.h"
#import "MainWindow.h"
#import "messageswindow.h"
#import "ListStatistics.h"

@class ProfileWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong,getter=getMainWindowController) MainWindow *mainwindowcontroller;
@property (strong) NSWindowController *_preferencesWindowController;
@property (strong) messageswindow *messageswindow;
@property (strong) ListStatistics *liststatswindow;
@property (strong) ProfileWindowController *pwc;

// Menus
@property (strong) IBOutlet NSMenuItem *messagesmenuitem;
@property (strong) IBOutlet NSMenuItem *importkitsumenu;


// Preference Window
@property (nonatomic, readonly) NSWindowController *preferencesWindowController;
- (IBAction)showpreferences:(id)sender;
- (void)showloginnotice;
- (void)showloginpref;
- (void)clearMessages;
- (messageswindow *)getMessagesWindow;
- (ProfileWindowController *)getProfileWindow;
@end
