//
//  LoginPref.h
//  Shukofukuro
//
//  Created by Nanoha Takamachi on 2014/10/18.
//  Copyright 2014 MAL Updater OS X Group. All rights reserved. Code licensed under New BSD License
//

#import <Cocoa/Cocoa.h>
#import <MASPreferences/MASPreferences.h>
#import "Keychain.h"

@class AppDelegate;
@class MainWindow;
@class AniListAuthWindow;

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

// Login Preference AniList
@property (strong) IBOutlet NSButton *anilistclearbut;
@property (strong) IBOutlet NSTextField *anilistloggedinuser;
@property (strong) IBOutlet NSView *anilistloginview;
@property (strong) IBOutlet NSView *anilistloggedinview;
@property (strong) IBOutlet AniListAuthWindow *anilistauthw;
@property (strong) IBOutlet NSButton *anilistauthorizebtn;

- (id)initwithAppDelegate:(AppDelegate *)adelegate;
- (IBAction)startlogin:(id)sender;
- (IBAction)clearlogin:(id)sender;
- (IBAction)registermal:(id)sender;
- (void)login:(NSString *)username password:(NSString *)password withServiceID:(int)serviceid;
- (void)loadlogin;
@end
