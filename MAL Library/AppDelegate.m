//
//  AppDelegate.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/02/28.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import "AppDelegate.h"
#import "Preferences.h"
#import "PFMoveApplication.h"
#import "Keychain.h"
#import "PFAboutWindowController.h"
#import "DonationWindowController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Utility.h"
#import "StreamDataRetriever.h"
#import "ProfileWindowController.h"

@interface AppDelegate ()
@property (strong, nonatomic) dispatch_queue_t privateQueue;
@property PFAboutWindowController *aboutWindowController;
@property (strong) DonationWindowController *donationwincontroller;
@end

@implementation AppDelegate
@synthesize pwc;

+ (void)initialize {
    
    //Create a Dictionary
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
    // Defaults
    defaultValues[@"watchingfilter"] = @(1);
    defaultValues[@"listdoubleclickaction"] = @"Modify Title";
    defaultValues[@"refreshlistonstart"] = @(0);
    defaultValues[@"appearance"] = @"Light";
    defaultValues[@"refreshautomatically"] = @(1);
    #if defined(AppStore)
    defaultValues[@"donated"] = @(1);
    #else
    defaultValues[@"donated"] = @(0);
    #endif
    defaultValues[@"NSApplicationCrashOnExceptions"] = @YES;
    defaultValues[@"readingfilter"] = @(1);
    defaultValues[@"malapiurl"] = @"https://malapi.ateliershiori.moe";
    defaultValues[@"filtersastabs"] = @(1);
    defaultValues[@"stream_region"] = @(0);
    
    //Register Dictionary
    [[NSUserDefaults standardUserDefaults]
     registerDefaults:defaultValues];
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [Fabric with:@[[Crashlytics class]]];
    [Utility checkandclearimagecache];
    // Ask to move application
    #if defined(AppStore)
    #else
    #ifdef DEBUG
    #else
    PFMoveToApplicationsFolderIfNecessary();
    #endif
    [Utility donateCheck:self];
    #endif
    // Load main window
    _mainwindowcontroller = [MainWindow new];
    [_mainwindowcontroller setDelegate:self];
    [_mainwindowcontroller.window makeKeyAndOrderFront:self];
    [self showloginnotice];
    [[NSAppleEventManager sharedAppleEventManager]
     setEventHandler:self
     andSelector:@selector(handleURLEvent:withReplyEvent:)
     forEventClass:kInternetEventClass
     andEventID:kAEGetURL];
    [StreamDataRetriever retrieveStreamData];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (NSWindowController *)preferencesWindowController {
    if (__preferencesWindowController == nil)
    {
        GeneralPref *genview =[[GeneralPref alloc] init];
        [genview setMainWindowController:_mainwindowcontroller];
        NSViewController *loginViewController = [[LoginPref alloc] initwithAppDelegate:self];
        NSViewController *advancedviewController = [AdvancedPref new];
        #if defined(AppStore)
        NSArray *controllers = @[genview,loginViewController,advancedviewController];
        #else
        NSViewController *suViewController = [[SoftwareUpdatesPref alloc] init];
        NSArray *controllers = @[genview,loginViewController,suViewController,advancedviewController];
        #endif
        __preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers];
    }
    return __preferencesWindowController;
}

- (IBAction)showpreferences:(id)sender {
        [self.preferencesWindowController showWindow:nil];
}
- (void)showloginnotice {
    if (![Keychain checkaccount]) {
        // First time prompt
        NSAlert *alert = [[NSAlert alloc] init] ;
        [alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
        [alert setMessageText:NSLocalizedString(@"Welcome to MAL Library",nil)];
        [alert setInformativeText:NSLocalizedString(@"Before you can use this program, you need to add an account. Do you want to open Preferences to authenticate an account now? \r\rNote that there is limited functionality if you don't add an account.",nil)];
        // Set Message type to Warning
        alert.alertStyle = NSAlertStyleInformational;
        [alert beginSheetModalForWindow:_mainwindowcontroller.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode== NSAlertFirstButtonReturn) {
            // Show Preference Window and go to Login Preference Pane
            [self showloginpref];
        }
            }];
    }
    else {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"credentialscheckdate"]){
            // Check credentials now if user has an account and these values are not set
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"credentialscheckdate"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"credentialsvalid"];
        }
    }

}
- (void)showloginpref{
    [self.preferencesWindowController showWindow:nil];
    [(MASPreferencesWindowController *)self.preferencesWindowController selectControllerAtIndex:1];
}

- (IBAction)enterDonationKey:(id)sender {
    if (!_donationwincontroller) {
        _donationwincontroller = [DonationWindowController new];
    }
    [_donationwincontroller.window makeKeyAndOrderFront:nil];
}

- (IBAction)showaboutwindow:(id)sender{
    if (!_aboutWindowController) {
        _aboutWindowController = [PFAboutWindowController new];
    }
    (self.aboutWindowController).appURL = [[NSURL alloc] initWithString:@"https://malupdaterosx.ateliershiori.moe/mallibrary/"];
    NSMutableString *copyrightstr = [NSMutableString new];
    NSDictionary *bundleDict = [NSBundle mainBundle].infoDictionary;
    [copyrightstr appendFormat:@"%@ \r\r",bundleDict[@"NSHumanReadableCopyright"]];
    #if defined(AppStore)
    [copyrightstr appendString:@"Mac App Store version."];
    #else
    if (((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"donated"]).boolValue) {
        [copyrightstr appendFormat:@"This copy is registered to: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"donor"]];
    }
    else {
        [copyrightstr appendString:@"UNREGISTERED COPY"];
    }
    #endif
    (self.aboutWindowController).appCopyright = [[NSAttributedString alloc] initWithString:copyrightstr
                                                                                attributes:@{
                                                                                             NSForegroundColorAttributeName:[NSColor labelColor],
                                                                                             NSFontAttributeName:[NSFont fontWithName:[NSFont systemFontOfSize:12.0f].familyName size:11]}];

    [self.aboutWindowController showWindow:nil];
    
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event
        withReplyEvent:(NSAppleEventDescriptor*)replyEvent {
    NSString* url = [event paramDescriptorForKeyword:keyDirectObject].stringValue;
    NSLog(@"%@", url);
    url = [url stringByReplacingOccurrencesOfString:@"mallibrary://" withString:@""];
    if ([url containsString:@"anime/"]) {
        // Loads Anime Information with specified id.
        url = [url stringByReplacingOccurrencesOfString:@"anime/" withString:@""];
        [_mainwindowcontroller loadinfo:@(url.intValue) type:0];
    }
    if ([url containsString:@"manga/"]) {
        if (((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"donated"]).boolValue) {
            // Loads Manga Information with specified id.
            url = [url stringByReplacingOccurrencesOfString:@"manga/" withString:@""];
            [_mainwindowcontroller loadinfo:@(url.intValue) type:0];
        }
    }
}

- (IBAction)showmessagewindow:(id)sender {
    if ([Keychain checkaccount]) {
        if (!_messageswindow){
            _messageswindow = [messageswindow new];
        }
        [_messageswindow.window makeKeyAndOrderFront:self];
    }
    else {
        [self showloginnotice];
    }
}

- (IBAction)viewListStats:(id)sender {
    if ([Keychain checkaccount]) {
        if (!_liststatswindow){
            _liststatswindow = [ListStatistics new];
        }
        [_liststatswindow.window makeKeyAndOrderFront:self];
        [_liststatswindow populateValues];
    }
    else {
        [self showloginnotice];
    }
}


- (void)clearMessages {
    // Clears user messages
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [Utility retrieveApplicationSupportDirectory:@"Messages"];
    NSDirectoryEnumerator *en = [fm enumeratorAtPath:path];
    NSError *error = nil;
    bool success;
    NSString *file;
    while (file = [en nextObject]){
        success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@",path,file] error:&error];
        if (!success && error){
            NSLog(@"%@", error);
        }
    }
    if ([Utility checkifFileExists:@"messages.json" appendPath:@""]) {
        [Utility deleteFile:@"messages.json" appendpath:@""];
    }
    if (_messageswindow){
        [_messageswindow.window close];
        [_messageswindow cleartableview];
    }
    if (_liststatswindow){
        [_liststatswindow.window close];
    }
}

- (IBAction)viewProfileWindow:(id)sender {
    if (!pwc) {
        pwc = [ProfileWindowController new];
    }
    [pwc.window makeKeyAndOrderFront:self];
}
- (ProfileWindowController *)getProfileWindow {
    if (!pwc) {
        pwc = [ProfileWindowController new];
    }
    return pwc;
}
@end
