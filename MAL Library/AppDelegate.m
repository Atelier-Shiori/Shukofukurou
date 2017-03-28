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

@interface AppDelegate ()
@property (strong, nonatomic) dispatch_queue_t privateQueue;
@property PFAboutWindowController *aboutWindowController;
@property (strong) DonationWindowController * donationwincontroller;
@end

@implementation AppDelegate
+(void)initialize{
    
    //Create a Dictionary
    NSMutableDictionary * defaultValues = [NSMutableDictionary dictionary];
    
    // Defaults
    defaultValues[@"watchingfilter"] = @(1);
    defaultValues[@"listdoubleclickaction"] = @"Modify Title";
    defaultValues[@"refreshlistonstart"] = @(0);
    defaultValues[@"appearence"] = @"Light";
    defaultValues[@"refreshautomatically"] = @(1);
    defaultValues[@"donated"] = @(0);
    
    //Register Dictionary
    [[NSUserDefaults standardUserDefaults]
     registerDefaults:defaultValues];

    
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Ask to move application
#ifdef DEBUG
#else
    PFMoveToApplicationsFolderIfNecessary();
    #endif
    // Load main window
    mainwindowcontroller = [MainWindow new];
    [mainwindowcontroller setDelegate:self];
    [mainwindowcontroller.window makeKeyAndOrderFront:self];
    [self showloginnotice];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
-(MainWindow *)getMainWindowController{
    return mainwindowcontroller;
}
- (NSWindowController *)preferencesWindowController
{
    if (_preferencesWindowController == nil)
    {
        GeneralPref * genview =[[GeneralPref alloc] init];
        [genview setMainWindowController:mainwindowcontroller];
        NSViewController *loginViewController = [[LoginPref alloc] initwithAppDelegate:self];
        NSViewController *suViewController = [[SoftwareUpdatesPref alloc] init];
        NSArray *controllers = @[genview,loginViewController,suViewController];
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers];
    }
    return _preferencesWindowController;
}

- (IBAction)showpreferences:(id)sender {
        [self.preferencesWindowController showWindow:nil];
}
-(void)showloginnotice{
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
-(void)showloginpref{
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
    [self.aboutWindowController setAppURL:[[NSURL alloc] initWithString:@"https://mallibrary.ateliershiori.moe"]];
    NSMutableString * copyrightstr = [NSMutableString new];
    NSDictionary *bundleDict = [[NSBundle mainBundle] infoDictionary];
    [copyrightstr appendFormat:@"%@ \r\r",[bundleDict objectForKey:@"NSHumanReadableCopyright"]];
    if ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"donated"] boolValue]){
        [copyrightstr appendFormat:@"This copy is registered to: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"donor"]];
    }
    else {
        [copyrightstr appendString:@"UNREGISTERED COPY"];
    }
    [self.aboutWindowController setAppCopyright:[[NSAttributedString alloc] initWithString:copyrightstr
                                                                                attributes:@{
                                                                                             NSForegroundColorAttributeName:[NSColor labelColor],
                                                                                             NSFontAttributeName:[NSFont fontWithName:@"HelveticaNeue" size:11]}]];

    [self.aboutWindowController showWindow:nil];
    
}
@end
