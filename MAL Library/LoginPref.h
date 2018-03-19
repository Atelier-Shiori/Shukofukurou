//
//  LoginPref.h
//  MAL Library
//
//  Created by Nanoha Takamachi on 2014/10/18.
//  Copyright 2014 Atelier Shiori. All rights reserved. Code licensed under New BSD License
//

#import <Cocoa/Cocoa.h>
#import <MASPreferences/MASPreferences.h>
#import "Keychain.h"

@class AppDelegate;
@class MainWindow;

@interface LoginPref : NSViewController <MASPreferencesViewController>
@property (strong) IBOutlet NSImageView *logo;
@property (strong) AppDelegate* appdelegate;
@property (strong) MainWindow* mw;

//Login Preferences
@property (strong) IBOutlet NSTextField *fieldusername;
@property (strong) IBOutlet NSTextField *fieldpassword;
@property (strong) IBOutlet NSButton *savebut;
@property (strong) IBOutlet NSButton *clearbut;
@property (strong) IBOutlet NSTextField *loggedinuser;
@property (strong) IBOutlet NSView *loginview;
@property (strong) IBOutlet NSView *loggedinview;
//Login Preferences Kitsu
@property (strong) IBOutlet NSTextField *kitsufieldusername;
@property (strong) IBOutlet NSTextField *kitsufieldpassword;
@property (strong) IBOutlet NSButton *kitsusavebut;
@property (strong) IBOutlet NSButton *kitsuclearbut;
@property (strong) IBOutlet NSTextField *kitsuloggedinuser;
@property (strong) IBOutlet NSView *kitsuloginview;
@property (strong) IBOutlet NSView *kitsuloggedinview;

- (id)initwithAppDelegate:(AppDelegate *)adelegate;
- (IBAction)startlogin:(id)sender;
- (IBAction)clearlogin:(id)sender;
- (IBAction)registermal:(id)sender;
- (void)login:(NSString *)username password:(NSString *)password withServiceID:(int)serviceid;
- (void)loadlogin;
@end
