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
#import "MainWindow.h"
#import "Utility.h"
//#import "MyAnimeList.h"
#import "listservice.h"
@implementation LoginPref

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
    if ([Kitsu getFirstAccount]) {
        [_kitsuclearbut setEnabled: YES];
        [_kitsusavebut setEnabled: NO];
        [_kitsuloggedinview setHidden:NO];
        [_kitsuloginview setHidden:YES];
        _kitsuloggedinuser.stringValue = [NSUserDefaults.standardUserDefaults valueForKey:@"hachidori-username"];
    }
    else {
        //Disable Clearbut
        [_kitsuclearbut setEnabled: NO];
        [_kitsusavebut setEnabled: YES];
    }
}
- (IBAction)startlogin:(id)sender
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
            [self login:_fieldusername.stringValue password:_fieldpassword.stringValue withServiceID:1];
        }
    }
}
- (IBAction)startKitsuLogin:(id)sender {
    //Start Login Process
    //Disable Login Button
    [_kitsusavebut setEnabled: NO];
    [_kitsusavebut displayIfNeeded];
    if (_kitsufieldusername.stringValue.length == 0) {
        //No Username Entered! Show error message
        [Utility showsheetmessage:@"MAL Library was unable to log you in since you didn't enter a username" explaination:@"Enter a valid username and try logging in again" window:self.view.window];
        [_kitsusavebut setEnabled: YES];
    }
    else {
        if (_kitsufieldpassword.stringValue.length == 0 ) {
            //No Password Entered! Show error message.
            [Utility showsheetmessage:@"MAL Library was unable to log you in since you didn't enter a password" explaination:@"Enter a valid password and try logging in again." window:self.view.window];
            [_kitsusavebut setEnabled: YES];
        }
        else {
            [_kitsusavebut setEnabled:NO];
            [self login:_kitsufieldusername.stringValue password:_kitsufieldpassword.stringValue withServiceID:2];
        }
    }
}
- (void)login:(NSString *)username password:(NSString *)password withServiceID:(int)serviceid{
    [_savebut setEnabled:NO];
    [listservice verifyAccountWithUsername:username password:password withServiceID:serviceid completion:^(id responseObject){
        //Login successful
        [Utility showsheetmessage:@"Login Successful" explaination: @"Login is successful." window:self.view.window];
        // Store account in login keychain
        switch (serviceid) {
            case 1:
                [Keychain storeaccount:_fieldusername.stringValue password:_fieldpassword.stringValue];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:60*60*24] forKey:@"credentialscheckdate"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"credentialsvalid"];
                [_clearbut setEnabled: YES];
                _loggedinuser.stringValue = username;
                [_loggedinview setHidden:NO];
                [_loginview setHidden:YES];
                [_savebut setEnabled:YES];
                break;
            case 2:
                [_kitsuclearbut setEnabled: YES];
                _kitsuloggedinuser.stringValue = username;
                [_kitsuloggedinview setHidden:NO];
                [_kitsuloginview setHidden:YES];
                [_kitsusavebut setEnabled:YES];
                break;
            default:
                break;
        }
        if ([listservice getCurrentServiceID] == serviceid) {
            [_mw loadlist:@(1) type:0];
            [_mw loadlist:@(1) type:1];
            [_mw loadlist:@(1) type:2];
            [_mw loadmainview];
            [_mw refreshloginlabel];
        }
    }error:^(NSError *error) {
        NSLog(@"%@",error);
        if ([[error.userInfo valueForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: unauthorized (401)"]) {
            //Login Failed, show error message
            [Utility showsheetmessage:[NSString stringWithFormat:@"MAL Library was unable to log you into your %@ account since you don't have the correct username and/or password.", [self serviceidtoservicename:serviceid]] explaination:@"Check your username and password and try logging in again. If you recently changed your password, enter your new password and try again." window:self.view.window];
            [_savebut setEnabled: YES];
            _savebut.keyEquivalent = @"\r";
        }
        else if ([[error.userInfo valueForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: forbidden (403)"]) {
            // Too many login attempts
            //Login Failed, show error message
            if (serviceid == 1) {
                [Utility showsheetmessage:@"MAL Library was unable to log you into your MyAnimeList account since there is too many login attempts." explaination:@"Check your username and password and try logging in again after several hours." window:self.view.window];
            }
            else {
                [Utility showsheetmessage:[NSString stringWithFormat:@"MAL Library was unable to log you into your %@ account since you don't have the correct username and/or password.", [self serviceidtoservicename:serviceid]] explaination:@"Check your username and password and try logging in again. If you recently changed your password, enter your new password and try again." window:self.view.window];
            }
        }
        else{
            NSString *errormessage = @"Error Unkown.";
            if ([error.userInfo valueForKey:@"NSLocalizedDescription"]) {
                errormessage = [error.userInfo valueForKey:@"NSLocalizedDescription"];
            }
            [Utility showsheetmessage:[NSString stringWithFormat:@"MAL Library was unable to log you into your %@ account", [self serviceidtoservicename:serviceid]] explaination:errormessage window:self.view.window];
        }
        switch ([listservice getCurrentServiceID]) {
            case 1:
                [_savebut setEnabled: YES];
                _savebut.keyEquivalent = @"\r";
                break;
            case 2:
                [_kitsusavebut setEnabled: YES];
                _kitsusavebut.keyEquivalent = @"\r";
                break;
            default:
                break;
        }
    }];
}
- (IBAction)registermal:(id)sender {
	//Show MAL Registration Page
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://myanimelist.net/register.php"]];
}
- (IBAction)registerKitsu:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://kitsu.io/"]];
}
- (IBAction) showgettingstartedpage:(id)sender
{
    //Show Getting Started help page
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/Atelier-Shiori/MALLibrary/wiki/Getting-Started"]];
}
- (IBAction)clearlogin:(id)sender
{
    [self performClearLogin:1];
}
- (IBAction)clearkitsulogin:(id)sender {
    [self performClearLogin:2];
}
- (void)performClearLogin:(int)service {
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
            if ([listservice getCurrentServiceID] == service) {
                [_mw clearlist];
                [_mw loadmainview];
                [_mw refreshloginlabel];
                if (service == 1) {
                    [_appdelegate clearMessages];
                }
            }
            //Remove account from keychain
            switch ([listservice getCurrentServiceID]) {
                case 1:
                    [Keychain removeaccount];
                    break;
                case 2:
                    [Kitsu removeAccount];
                    break;
                default:
                    break;
            }
            //Disable Clearbut
            switch (service) {
                case 1:
                    [_clearbut setEnabled: NO];
                    [_savebut setEnabled: YES];
                    _loggedinuser.stringValue = @"";
                    [_loggedinview setHidden:YES];
                    [_loginview setHidden:NO];
                    _fieldusername.stringValue = @"";
                    _fieldpassword.stringValue = @"";
                    break;
                case 2:
                    [_kitsuclearbut setEnabled: NO];
                    [_kitsusavebut setEnabled: YES];
                    _kitsuloggedinuser.stringValue = @"";
                    [_kitsuloggedinview setHidden:YES];
                    [_kitsuloginview setHidden:NO];
                    _kitsufieldusername.stringValue = @"";
                    _kitsufieldpassword.stringValue = @"";
                    break;
                default:
                    break;
            }

            
        }
    }];
}
- (NSString *)serviceidtoservicename:(int)serviceid {
    switch (serviceid) {
        case 1:
            return @"MyAnimeList";
        case 2:
            return @"Kitsu";
        case 3:
            return @"AniList";
        default:
            break;
    }
    return @"";
}
@end
