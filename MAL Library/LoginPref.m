//
//  LoginPref.m
//  MAL Updater OS X
//
//  Created by Nanoha Takamachi on 2014/10/18.
//  Copyright 2014 Atelier Shiori. All rights reserved.
//

#import "LoginPref.h"
#import "Base64Category.h"
#import "AppDelegate.h"
#import "MainWindow.H"
#import "Utility.h"
#import <AFNetworking/AFNetworking.h>

@implementation LoginPref
@synthesize loginpanel;

- (id)init
{
	return [super initWithNibName:@"LoginView" bundle:nil];
}
- (id)initwithAppDelegate:(AppDelegate *)adelegate{
    appdelegate = adelegate;
    return [super initWithNibName:@"LoginView" bundle:nil];
}
- (void)loadView{
    [super loadView];
    // Retrieve MyAnimeList Engine instance from app delegate
    mw = [appdelegate getMainWindowController];
    // Set Logo
    [logo setImage:[NSApp applicationIconImage]];
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
		[clearbut setEnabled: YES];
		[savebut setEnabled: NO];
        [loggedinview setHidden:NO];
        [loginview setHidden:YES];
        [loggedinuser setStringValue:[Keychain getusername]];
	}
	else {
		//Disable Clearbut
		[clearbut setEnabled: NO];
		[savebut setEnabled: YES];
	}
}
- (IBAction)startlogin:(id)sender
{
	{
		//Start Login Process
		//Disable Login Button
		[savebut setEnabled: NO];
		[savebut displayIfNeeded];
		if ( [[fieldusername stringValue] length] == 0) {
			//No Username Entered! Show error message
			[Utility showsheetmessage:@"MAL Library was unable to log you in since you didn't enter a username" explaination:@"Enter a valid username and try logging in again" window:[[self view] window]];
			[savebut setEnabled: YES];
		}
		else {
			if ( [[fieldpassword stringValue] length] == 0 ) {
				//No Password Entered! Show error message.
				[Utility showsheetmessage:@"MAL Library was unable to log you in since you didn't enter a password" explaination:@"Enter a valid password and try logging in again." window:[[self view] window]];
				[savebut setEnabled: YES];
			}
			else {
                [savebut setEnabled:NO];
                dispatch_queue_t queue = dispatch_get_global_queue(
                                                                   DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                
                dispatch_async(queue, ^{
                    [self login:[fieldusername stringValue] password:[fieldpassword stringValue]];
                });
                }
		}
	}
}
- (void)login:(NSString *)username password:(NSString *)password{
    [savebut setEnabled:NO];
    //Set Login URL
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [[NSString stringWithFormat:@"%@:%@", username, password] base64Encoding]] forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"%@/1/account/verify_credentials",[[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //Login successful
        [Utility showsheetmessage:@"Login Successful" explaination: @"Login is successful." window:self.view.window];
        // Store account in login keychain
        [Keychain storeaccount:fieldusername.stringValue password:fieldpassword.stringValue];
        [clearbut setEnabled: YES];
        loggedinuser.stringValue = username;
        [loggedinview setHidden:NO];
        [loginview setHidden:YES];
        [savebut setEnabled:YES];
        [mw loadlist:@(1) type:0];
        [mw loadlist:@(1) type:1];
        [mw loadmainview];
        [mw refreshloginlabel];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"%@",error);
        if([[error.userInfo valueForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: unauthorized (401)"]){
            //Login Failed, show error message
            [Utility showsheetmessage:@"MAL Library was unable to log you into your MyAnimeList account since you don't have the correct username and/or password." explaination:@"Check your username and password and try logging in again. If you recently changed your password, enter your new password and try again." window:self.view.window];
            [savebut setEnabled: YES];
            savebut.keyEquivalent = @"\r";
        }
        else{
            [Utility showsheetmessage:@"MAL Library was unable to log you into your MyAnimeList account since you are not connected to the internet" explaination:@"Check your internet connection and try again." window:self.view.window];
            [savebut setEnabled: YES];
            savebut.keyEquivalent = @"\r";
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
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/chikorita157/malupdaterosx-cocoa/wiki/Getting-Started"]];
}
- (IBAction)clearlogin:(id)sender
{
    // Set Up Prompt Message Window
    NSAlert * alert = [[NSAlert alloc] init] ;
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert setMessageText:@"Do you want to log out?"];
    [alert setInformativeText:@"Once you logged out, you need to log back in before you can use this application."];
    // Set Message type to Warning
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:[[self view] window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode== NSAlertFirstButtonReturn) {
            [mw clearlist];
            //Remove account from keychain
            [Keychain removeaccount];
            //Disable Clearbut
            [clearbut setEnabled: NO];
            [savebut setEnabled: YES];
            [loggedinuser setStringValue:@""];
            [loggedinview setHidden:YES];
            [loginview setHidden:NO];
            [fieldusername setStringValue:@""];
            [fieldpassword setStringValue:@""];
            [mw loadmainview];
            [mw refreshloginlabel];
        }
    }];
}
/*
 Reauthorization Panel
 */
- (IBAction)reauthorize:(id)sender{
    [NSApp beginSheet:self.loginpanel
       modalForWindow:[[self view] window] modalDelegate:self
       didEndSelector:@selector(reAuthPanelDidEnd:returnCode:contextInfo:)
          contextInfo:(void *)nil];
}
- (void)reAuthPanelDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == 1) {
        dispatch_queue_t queue = dispatch_get_global_queue(
                                                           DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(queue, ^{
        [self login: (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"] password:[passwordinput stringValue]];
        });
    }
    //Reset and Close
    [passwordinput setStringValue:@""];
    [invalidinput setHidden:YES];
    [self.loginpanel close];
}
- (IBAction)cancelreauthorization:(id)sender{
    [self.loginpanel orderOut:self];
    [NSApp endSheet:self.loginpanel returnCode:0];
    
}
- (IBAction)performreauthorization:(id)sender{
    if ([[passwordinput stringValue] length] == 0) {
        // No password, indicate it
        NSBeep();
        [invalidinput setHidden:NO];
    }
    else{
        [invalidinput setHidden:YES];
        [self.loginpanel orderOut:self];
        [NSApp endSheet:self.loginpanel returnCode:1];
    }
}
@end
