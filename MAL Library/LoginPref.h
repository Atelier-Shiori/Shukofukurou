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

@interface LoginPref : NSViewController <MASPreferencesViewController> {
    IBOutlet NSImageView *logo;
	//Login Preferences
	IBOutlet NSTextField *fieldusername;
	IBOutlet NSTextField *fieldpassword;
	IBOutlet NSButton *savebut;
	IBOutlet NSButton *clearbut;
    IBOutlet NSTextField *loggedinuser;
    AppDelegate* appdelegate;
    MainWindow* mw;
    IBOutlet NSView *loginview;
    IBOutlet NSView *loggedinview;
    //Reauthorize Panel
    IBOutlet NSTextField *passwordinput;
    IBOutlet NSImageView *invalidinput;
}
@property (weak) IBOutlet NSWindow *loginpanel;
- (id)initwithAppDelegate:(AppDelegate *)adelegate;
- (IBAction)startlogin:(id)sender;
- (IBAction)clearlogin:(id)sender;
- (IBAction)registermal:(id)sender;
- (void)login:(NSString *)username password:(NSString *)password;
- (void)loadlogin;
@end
