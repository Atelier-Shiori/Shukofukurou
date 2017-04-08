//
//  AppDelegate.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/02/28.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
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

@interface AppDelegate ()
@property (strong, nonatomic) dispatch_queue_t privateQueue;
@property PFAboutWindowController *aboutWindowController;
@property (strong) DonationWindowController * donationwincontroller;
@end

@implementation AppDelegate
+ (void)initialize{
    
    //Create a Dictionary
    NSMutableDictionary * defaultValues = [NSMutableDictionary dictionary];
    
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
    
    //Register Dictionary
    [[NSUserDefaults standardUserDefaults]
     registerDefaults:defaultValues];
    
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
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
    mainwindowcontroller = [MainWindow new];
    [mainwindowcontroller setDelegate:self];
    [mainwindowcontroller.window makeKeyAndOrderFront:self];
    [self showloginnotice];
    [Fabric with:@[[Crashlytics class]]];
    [[NSAppleEventManager sharedAppleEventManager]
     setEventHandler:self
     andSelector:@selector(handleURLEvent:withReplyEvent:)
     forEventClass:kInternetEventClass
     andEventID:kAEGetURL];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (MainWindow *)getMainWindowController{
    return mainwindowcontroller;
}
- (NSWindowController *)preferencesWindowController
{
    if (_preferencesWindowController == nil)
    {
        GeneralPref * genview =[[GeneralPref alloc] init];
        [genview setMainWindowController:mainwindowcontroller];
        NSViewController *loginViewController = [[LoginPref alloc] initwithAppDelegate:self];
        NSViewController *advancedviewController = [AdvancedPref new];
        #if defined(AppStore)
        NSArray *controllers = @[genview,loginViewController,advancedviewController];
        #else
        NSViewController *suViewController = [[SoftwareUpdatesPref alloc] init];
        NSArray *controllers = @[genview,loginViewController,suViewController,advancedviewController];
        #endif
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers];
    }
    return _preferencesWindowController;
}

- (IBAction)showpreferences:(id)sender {
        [self.preferencesWindowController showWindow:nil];
}
- (void)showloginnotice{
    if (![Keychain checkaccount]) {
        // First time prompt
        NSAlert * alert = [[NSAlert alloc] init] ;
        [alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
        [alert setMessageText:NSLocalizedString(@"Welcome to MAL Library",nil)];
        [alert setInformativeText:NSLocalizedString(@"Before you can use this program, you need to add an account. Do you want to open Preferences to authenticate an account now? \r\rNote that there is limited functionality if you don't add an account.",nil)];
        // Set Message type to Warning
        alert.alertStyle = NSAlertStyleInformational;
        [alert beginSheetModalForWindow:mainwindowcontroller.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode== NSAlertFirstButtonReturn) {
            // Show Preference Window and go to Login Preference Pane
            [self showloginpref];
        }
            }];
    }

}
- (void)showloginpref{
    [self.preferencesWindowController showWindow:nil];
    [(MASPreferencesWindowController *)self.preferencesWindowController selectControllerAtIndex:1];
}

- (IBAction)enterDonationKey:(id)sender {
    if (!_donationwincontroller){
        _donationwincontroller = [DonationWindowController new];
    }
    [[_donationwincontroller window] makeKeyAndOrderFront:nil];
}

- (IBAction)showaboutwindow:(id)sender{
    if (!_aboutWindowController){
        _aboutWindowController = [PFAboutWindowController new];
    }
    [self.aboutWindowController setAppURL:[[NSURL alloc] initWithString:@"https://malupdaterosx.ateliershiori.moe/mallibrary/"]];
    NSMutableString * copyrightstr = [NSMutableString new];
    NSDictionary *bundleDict = [[NSBundle mainBundle] infoDictionary];
    [copyrightstr appendFormat:@"%@ \r\r",[bundleDict objectForKey:@"NSHumanReadableCopyright"]];
    #if defined(AppStore)
    [copyrightstr appendString:@"Mac App Store version."];
    #else
    if ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"donated"] boolValue]){
        [copyrightstr appendFormat:@"This copy is registered to: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"donor"]];
    }
    else {
        [copyrightstr appendString:@"UNREGISTERED COPY"];
    }
    #endif
    [self.aboutWindowController setAppCopyright:[[NSAttributedString alloc] initWithString:copyrightstr
                                                                                attributes:@{
                                                                                             NSForegroundColorAttributeName:[NSColor labelColor],
                                                                                             NSFontAttributeName:[NSFont fontWithName:[[NSFont systemFontOfSize:12.0f] familyName] size:11]}]];

    [self.aboutWindowController showWindow:nil];
    
}
- (IBAction)getHelp:(id)sender{
    //Show Help
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/Atelier-Shiori/MALLibrary/wiki/Getting-Started"]];
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event
        withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject]
                     stringValue];
    NSLog(@"%@", url);
    url = [url stringByReplacingOccurrencesOfString:@"mallibrary://" withString:@""];
    if ([url containsString:@"anime/"]){
        // Loads Anime Information with specified id.
        url = [url stringByReplacingOccurrencesOfString:@"anime/" withString:@""];
        [mainwindowcontroller loadinfo:@(url.intValue) type:0];
    }
    if ([url containsString:@"manga/"]){
        if ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"donated"] boolValue]){
            // Loads Manga Information with specified id.
            url = [url stringByReplacingOccurrencesOfString:@"manga/" withString:@""];
            [mainwindowcontroller loadinfo:@(url.intValue) type:0];
        }
    }
}
@end
