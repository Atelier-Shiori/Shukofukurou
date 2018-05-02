//
//  LoginPref.m
//  Shukofukurou
//
//  Created by Nanoha Takamachi on 2014/10/18.
//  Copyright 2014 MAL Updater OS X Group. All rights reserved.
//

#import "LoginPref.h"
#import "Base64Category.h"
#import "AppDelegate.h"
#import "MainWindow.h"
#import "Utility.h"
#import "listservice.h"
#import "AniListAuthWindow.h"

@implementation LoginPref

- (instancetype)init {
    return [super initWithNibName:@"LoginView" bundle:nil];
}
- (id)initwithAppDelegate:(AppDelegate *)adelegate {
    _appdelegate = adelegate;
    return [super initWithNibName:@"LoginView" bundle:nil];
}

- (void)loadView{
    [super loadView];
    // Retrieve MyAnimeList Engine instance from app delegate
    _mw = _appdelegate.mainwindowcontroller;
    // Set Logo
    _logo.image = NSApp.applicationIconImage;
    // Load Login State
    [self loadlogin];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier {
    return @"LoginPreferences";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:NSImageNameUserAccounts];
}

- (NSString *)toolbarItemLabel {
    return NSLocalizedString(@"Accounts", @"Toolbar item name for the Accounts preference pane");
}

#pragma mark Login Preferences Functions
- (void)loadlogin
{
    // Load Username
    if ([Keychain checkaccount]) {
        _clearbut.enabled = YES;
        _savebut.enabled = NO;
        _loggedinview.hidden = NO;
        _loginview.hidden = YES;
        _loggedinuser.stringValue = [Keychain getusername];
    }
    else {
        //Disable Clearbut
        _clearbut.enabled = NO;
        _savebut.enabled = YES;
    }
    if ([Kitsu getFirstAccount]) {
        _kitsuclearbut.enabled = YES;
        _kitsusavebut.enabled = NO;
        _kitsuloggedinview.hidden = NO;
        _kitsuloginview.hidden = YES;
        _kitsuloggedinuser.stringValue = [NSUserDefaults.standardUserDefaults valueForKey:@"kitsu-username"];
    }
    else {
        //Disable Clearbut
        _kitsuclearbut.enabled = NO;
        _kitsusavebut.enabled = YES;
    }
    if ([AniList getFirstAccount]) {
        _anilistclearbut.enabled =YES;
        _anilistloggedinview.hidden = NO;
        _anilistloginview.hidden = YES;
        _anilistloggedinuser.stringValue = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-username"];
    }
    else {
        //Disable Clearbut
        _anilistclearbut.enabled = NO;
    }
}

- (IBAction)startlogin:(id)sender {
    //Start Login Process
    //Disable Login Button
    _savebut.enabled = NO;
    [_savebut displayIfNeeded];
    if (_fieldusername.stringValue.length == 0) {
        [self showloginfailurenousername];
        _savebut.enabled = YES;
    }
    else {
        if (_fieldpassword.stringValue.length == 0 ) {
            [self showloginfailurenopassword];
            _savebut.enabled = YES;
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
    _kitsusavebut.enabled = NO;
    [_kitsusavebut displayIfNeeded];
    if (_kitsufieldusername.stringValue.length == 0) {
        [self showloginfailurenousername];
        _kitsusavebut.enabled = YES;
    }
    else {
        if (_kitsufieldpassword.stringValue.length == 0 ) {
            //No Password Entered! Show error message.
            [self showloginfailurenopassword];
            _kitsusavebut.enabled = YES;
        }
        else {
            [_kitsusavebut setEnabled:NO];
            [self login:_kitsufieldusername.stringValue password:_kitsufieldpassword.stringValue withServiceID:2];
        }
    }
}

- (IBAction)authorize:(id)sender {
    if (!_anilistauthw) {
        _anilistauthw = [AniListAuthWindow new];
    }
    else {
        [_anilistauthw.window makeKeyAndOrderFront:self];
        [_anilistauthw loadAuthorization];
        [_anilistauthw close];
    }
    _anilistauthorizebtn.enabled = NO;
    [self.view.window beginSheet:_anilistauthw.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            NSString *pin = _anilistauthw.pin.copy;
            _anilistauthw.pin = nil;
            [self login:@"" password:pin withServiceID:3];
        }
        else {
            _anilistauthorizebtn.enabled = YES;
        }
    }];
}

- (void)login:(NSString *)username password:(NSString *)password withServiceID:(int)serviceid {
    [listservice verifyAccountWithUsername:username password:password withServiceID:serviceid completion:^(id responseObject){
        [self showLoginSuccess:username withServiceID:serviceid];
    } error:^(NSError *error) {
        [self showLoginFailure:error withServiceID:serviceid];
    }];
}

- (void)showLoginSuccess:(NSString *)username withServiceID:(int)serviceid {
    //Login successful
    [Utility showsheetmessage:@"Login Successful" explaination: @"Login is successful." window:self.view.window];
    // Store account in login keychain
    switch (serviceid) {
        case 1:
            [Keychain storeaccount:_fieldusername.stringValue password:_fieldpassword.stringValue];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:60*60*24] forKey:@"credentialscheckdate"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"credentialsvalid"];
            _clearbut.enabled = YES;
            _loggedinuser.stringValue = username;
            _loggedinview.hidden = NO;
            _loginview.hidden = YES;
            [_savebut setEnabled:YES];
            break;
        case 2:
            _kitsuclearbut.enabled = YES;
            _kitsuloggedinuser.stringValue = username;
            _kitsuloggedinview.hidden = NO;
            _kitsuloginview.hidden = YES;
            [_kitsusavebut setEnabled:YES];
            [NSUserDefaults.standardUserDefaults setObject:[NSDate dateWithTimeIntervalSinceNow:259200] forKey:@"kitsu-userinformationrefresh"];
            break;
        case 3:
            _anilistclearbut.enabled = YES;
            _anilistloggedinuser.stringValue = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-username"];
            _anilistloggedinview.hidden = NO;
            _anilistloginview.hidden = YES;
            _anilistauthorizebtn.enabled = YES;
            [NSUserDefaults.standardUserDefaults setObject:[NSDate dateWithTimeIntervalSinceNow:259200] forKey:@"anilist-userinformationrefresh"];
            break;
        default:
            break;
    }
    if ([listservice getCurrentServiceID] == serviceid) {
        if (serviceid == 2) {
            [Kitsu getUserRatingType:^(int scoretype) {
                [NSUserDefaults.standardUserDefaults setInteger:scoretype forKey:@"kitsu-ratingsystem"];
                [self performlistloading];
            } error:^(NSError *error) {
                NSLog(@"Error loading list: %@", error.localizedDescription);
            }];
        }
        else {
            [self performlistloading];
        }
        [_mw loadmainview];
        [_mw refreshloginlabel];
    }
}

- (void)showLoginFailure:(NSError *)error withServiceID:(int)serviceid {
    if ([[error.userInfo valueForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: unauthorized (401)"]) {
        //Login Failed, show error message
        [Utility showsheetmessage:[NSString stringWithFormat:@"Shukofukurou was unable to log you into your %@ account since the username and/or password are incorrect.", [self serviceidtoservicename:serviceid]] explaination:@"Check your username and password and try logging in again. If you recently changed your password, enter your new password and try again." window:self.view.window];
    }
    else if ([[error.userInfo valueForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: forbidden (403)"]) {
        // Too many login attempts
        //Login Failed, show error message
        if (serviceid == 1) {
            [Utility showsheetmessage:@"Shukofukurou was unable to log you into your MyAnimeList account since there is too many login attempts." explaination:@"Check your username and password and try logging in again after several hours." window:self.view.window];
        }
        else {
            [Utility showsheetmessage:[NSString stringWithFormat:@"Shukofukurou was unable to log you into your %@ account since the username and/or password are incorrect.", [self serviceidtoservicename:serviceid]] explaination:@"Check your username and password and try logging in again. If you recently changed your password, enter your new password and try again." window:self.view.window];
        }
    }
    else{
        NSString *errormessage = @"Error Unkown.";
        if ([error.userInfo valueForKey:@"NSLocalizedDescription"]) {
            errormessage = [error.userInfo valueForKey:@"NSLocalizedDescription"];
        }
        [Utility showsheetmessage:[NSString stringWithFormat:@"Shukofukurou was unable to log you into your %@ account", [self serviceidtoservicename:serviceid]] explaination:errormessage window:self.view.window];
    }
    switch (serviceid) {
        case 1:
            _savebut.enabled = YES;
            _savebut.keyEquivalent = @"\r";
            break;
        case 2:
            _kitsusavebut.enabled = YES;
            _kitsusavebut.keyEquivalent = @"\r";
            break;
        case 3:
            _anilistauthorizebtn.enabled = YES;
            break;
        default:
            break;
    }
}

- (IBAction)registermal:(id)sender {
    //Show MAL Registration Page
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://myanimelist.net/register.php"]];
}

- (IBAction)registerKitsu:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://kitsu.io/"]];
}

- (IBAction)registerAnilist:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://anilist.co/register"]];
}

- (IBAction) showgettingstartedpage:(id)sender
{
    //Show Getting Started help page
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/Atelier-Shiori/MALLibrary/wiki/Getting-Started"]];
}

- (IBAction)clearlogin:(id)sender {
    [self performClearLogin:1];
}

- (IBAction)clearkitsulogin:(id)sender {
    [self performClearLogin:2];
}

- (IBAction)clearanilistlogin:(id)sender {
    [self performClearLogin:3];
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
            [self removeaccount:service];
        }
    }];
}

- (void)removeaccount:(int)service {
    //Remove account from keychain
    switch (service) {
        case 1:
            [Keychain removeaccount];
            break;
        case 2:
            [Kitsu removeAccount];
            break;
        case 3:
            [AniList removeAccount];
        default:
            break;
    }
    [_mw clearlist:service];
    if (service == 1) {
        [_appdelegate clearMessages];
    }
    if ([listservice getCurrentServiceID] == service) {
        [_mw loadmainview];
        [_mw refreshloginlabel];
    }
    //Disable Clearbut
    switch (service) {
        case 1:
            _clearbut.enabled = NO;
            _savebut.enabled = YES;
            _loggedinuser.stringValue = @"";
            _loggedinview.hidden = YES;
            _loginview.hidden = NO;
            _fieldusername.stringValue = @"";
            _fieldpassword.stringValue = @"";
            break;
        case 2:
            _kitsuclearbut.enabled = NO;
            _kitsusavebut.enabled = YES;
            _kitsuloggedinuser.stringValue = @"";
            _kitsuloggedinview.hidden = YES;
            _kitsuloginview.hidden = NO;
            _kitsufieldusername.stringValue = @"";
            _kitsufieldpassword.stringValue = @"";
            break;
        case 3:
            _anilistclearbut.enabled = NO;
            _anilistloggedinuser.stringValue = @"";
            _anilistloggedinview.hidden = YES;
            _anilistloginview.hidden = NO;
            break;
        default:
            break;
    }
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

- (void)showloginfailurenousername {
    //No Username Entered! Show error message
    [Utility showsheetmessage:@"Shukofukurou was unable to log you in since you didn't enter a username" explaination:@"Enter a valid username and try logging in again" window:self.view.window];
}

- (void)showloginfailurenopassword {
    //No Password Entered! Show error message.
    [Utility showsheetmessage:@"Shukofukurou was unable to log you in since you didn't enter a password" explaination:@"Enter a valid password and try logging in again." window:self.view.window];
}

- (void)performlistloading {
    [_mw loadlist:@(1) type:0];
    [_mw loadlist:@(1) type:1];
    [_mw loadlist:@(1) type:2];
}
@end
