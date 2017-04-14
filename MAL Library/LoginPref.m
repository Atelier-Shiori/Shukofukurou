//
//  LoginPref.m
//  MAL Library
//
//  Created by Nanoha Takamachi on 2014/10/18.
//  Copyright 2014 Atelier Shiori. All rights reserved.
//

#import "LoginPref.h"
#import "Base64Category.h"
#import "AppDelegate.h"
#import "MainWindow.H"
#import "Utility.h"
#import "MyAnimeList.h"

@implementation LoginPref
@synthesize loginpanel;

- (instancetype)init
{
	return [super initWithNibName:@"LoginView" bundle:nil];
}
- (id)initwithAppDelegate:(AppDelegate *)adelegate{
    _appdelegate = adelegate;
    return [super initWithNibName:@"LoginView" bundle:nil];
}
- (void)loadView{
    [super loadView];
    // Retrieve MyAnimeList Engine instance from app delegate
    _mw = [_appdelegate getMainWindowController];
    // Set Logo
    _logo.image = NSApp.applicationIconImage;
    // Load Login State
	[self loadlogin];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"LoginPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameUser];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Login", @"Toolbar item name for the Login preference pane");
}
#pragma mark Login Preferences Functions
- (void)loadlogin
{
	// Load Username
	if ([Keychain checkaccount]) {
		[_clearbut setEnabled: YES];
		[_savebut setEnabled: NO];
        [_loggedinview setHidden:NO];
        [_loginview setHidden:YES];
        _loggedinuser.stringValue = [Keychain getusername];
	}
	else {
		//Disable Clearbut
		[_clearbut setEnabled: NO];
		[_savebut setEnabled: YES];
	}
}
- (IBAction)startlogin:(id)sender
{
	{
		//Start Login Process
		//Disable Login Button
		[_savebut setEnabled: NO];
		[_savebut displayIfNeeded];
		if (_fieldusername.stringValue.length == 0) {
			//No Username Entered! Show error message
			[Utility showsheetmessage:@"MAL Library was unable to log you in since you didn't enter a username" explaination:@"Enter a valid username and try logging in again" window:self.view.window];
			[_savebut setEnabled: YES];
		}
		else {
			if (_fieldpassword.stringValue.length == 0 ) {
				//No Password Entered! Show error message.
				[Utility showsheetmessage:@"MAL Library was unable to log you in since you didn't enter a password" explaination:@"Enter a valid password and try logging in again." window:self.view.window];
				[_savebut setEnabled: YES];
			}
			else {
                [_savebut setEnabled:NO];
                dispatch_queue_t queue = dispatch_get_global_queue(
                                                                   DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                
                dispatch_async(queue, ^{
                    [self login:_fieldusername.stringValue password:_fieldpassword.stringValue];
                });
                }
		}
	}
}
- (void)login:(NSString *)username password:(NSString *)password{
    [_savebut setEnabled:NO];
    [MyAnimeList verifyAccountWithUsername:username password:password completion:^(id responseObject){
        //Login successful
        [Utility showsheetmessage:@"Login Successful" explaination: @"Login is successful." window:self.view.window];
        // Store account in login keychain
        [Keychain storeaccount:_fieldusername.stringValue password:_fieldpassword.stringValue];
        [_clearbut setEnabled: YES];
        _loggedinuser.stringValue = username;
        [_loggedinview setHidden:NO];
        [_loginview setHidden:YES];
        [_savebut setEnabled:YES];
        [_mw loadlist:@(1) type:0];
        [_mw loadlist:@(1) type:1];
        [_mw loadlist:@(1) type:2];
        [_mw loadmainview];
        [_mw refreshloginlabel];
    }error:^(NSError *error) {
        NSLog(@"%@",error);
        if([[error.userInfo valueForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: unauthorized (401)"]){
            //Login Failed, show error message
            [Utility showsheetmessage:@"MAL Library was unable to log you into your MyAnimeList account since you don't have the correct username and/or password." explaination:@"Check your username and password and try logging in again. If you recently changed your password, enter your new password and try again." window:self.view.window];
            [_savebut setEnabled: YES];
            _savebut.keyEquivalent = @"\r";
        }
        else{
            [Utility showsheetmessage:@"MAL Library was unable to log you into your MyAnimeList account since you are not connected to the internet" explaination:@"Check your internet connection and try again." window:self.view.window];
            [_savebut setEnabled: YES];
            _savebut.keyEquivalent = @"\r";
        }

    }];


}
- (IBAction)registermal:(id)sender
{
	//Show MAL Registration Page
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://myanimelist.net/register.php"]];
}
- (IBAction) showgettingstartedpage:(id)sender
{
    //Show Getting Started help page
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/Atelier-Shiori/MALLibrary/wiki/Getting-Started"]];
}
- (IBAction)clearlogin:(id)sender
{
    // Set Up Prompt Message Window
    NSAlert *alert = [[NSAlert alloc] init] ;
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    alert.messageText = @"Do you want to log out?";
    alert.informativeText = @"Once you logged out, you need to log back in before you can use this application.";
    // Set Message type to Warning
    alert.alertStyle = NSAlertStyleWarning;
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [_mw clearlist];
            //Remove account from keychain
            [Keychain removeaccount];
            //Disable Clearbut
            [_clearbut setEnabled: NO];
            [_savebut setEnabled: YES];
            _loggedinuser.stringValue = @"";
            [_loggedinview setHidden:YES];
            [_loginview setHidden:NO];
            _fieldusername.stringValue = @"";
            _fieldpassword.stringValue = @"";
            [_mw loadmainview];
            [_mw refreshloginlabel];
        }
    }];
}
/*
 Reauthorization Panel
 */
- (IBAction)reauthorize:(id)sender {
    [NSApp beginSheet:self.loginpanel
       modalForWindow:self.view.window modalDelegate:self
       didEndSelector:@selector(reAuthPanelDidEnd:returnCode:contextInfo:)
          contextInfo:(void *)nil];
}
- (void)reAuthPanelDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == 1) {
        dispatch_queue_t queue = dispatch_get_global_queue(
                                                           DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(queue, ^{
        [self login: [Keychain getusername] password:_passwordinput.stringValue];
        });
    }
    //Reset and Close
    _passwordinput.stringValue = @"";
    [_invalidinput setHidden:YES];
    [self.loginpanel close];
}
- (IBAction)cancelreauthorization:(id)sender{
    [self.loginpanel orderOut:self];
    [NSApp endSheet:self.loginpanel returnCode:0];
    
}
- (IBAction)performreauthorization:(id)sender{
    if (_passwordinput.stringValue.length == 0) {
        // No password, indicate it
        NSBeep();
        [_invalidinput setHidden:NO];
    }
    else{
        [_invalidinput setHidden:YES];
        [self.loginpanel orderOut:self];
        [NSApp endSheet:self.loginpanel returnCode:1];
    }
}
@end
