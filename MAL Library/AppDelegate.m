//
//  AppDelegate.m
//  Nekomata
//
//  Created by 桐間紗路 on 2017/02/28.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import "AppDelegate.h"
#import "Preferences.h"
#import "PFMoveApplication.h"
#import "Keychain.h"

@interface AppDelegate ()
@property (strong, nonatomic) dispatch_queue_t privateQueue;
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
@end
