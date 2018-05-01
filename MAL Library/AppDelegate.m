//
//  AppDelegate.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/02/28.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "AppDelegate.h"
#import "Preferences.h"
#import "Keychain.h"
#import "PFAboutWindowController.h"
#if defined(OSS)
#else
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#endif
#import "Utility.h"
#import "StreamDataRetriever.h"
#import "ProfileWindowController.h"
#import "servicemenucontroller.h"
#import "listservice.h"
#import "InfoView.h"
#if defined(AppStore)
#if defined(OSS)
#else
#import "TipJar.h"
#endif
#else
#import "PFMoveApplication.h"
#import "DonationLicenseManager.h"
#endif

@interface AppDelegate ()
@property (strong, nonatomic) dispatch_queue_t privateQueue;
@property PFAboutWindowController *aboutWindowController;
@property (strong) IBOutlet NSMenuItem *malexportmenu;
#if defined(AppStore)
#if defined(OSS)
#else
@property (strong) TipJar *tipjar;
#endif
#else
@property (strong) DonationLicenseManager *dlmanager;
#endif
- (IBAction)saveAction:(id)sender;
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
#if defined(OSS)
    defaultValues[@"malapiurl"] = @"http://localhost:8000";
#else
    defaultValues[@"malapiurl"] = @"https://malapi.malupdaterosx.moe";
#endif
    defaultValues[@"stream_region"] = @(0);
    defaultValues[@"currentservice"] = @(1);
    defaultValues[@"kitsu-profilebrowserratingsystem"] = @(0);
    defaultValues[@"showadult"] = @NO;
    //Register Dictionary
    [[NSUserDefaults standardUserDefaults]
     registerDefaults:defaultValues];
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    #if defined(OSS)
    #else
    [Fabric with:@[[Crashlytics class]]];
    #endif
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
    __weak AppDelegate *weakself = self;
    _servicemenucontrol.actionblock = ^(int selected, int previousservice) {
        if (weakself.liststatswindow) {
            [weakself.liststatswindow.window close];
        }
        [weakself refreshUIServiceChange:selected];
        [weakself.mainwindowcontroller changeservice:previousservice];
        if (weakself.pwc) {
            [weakself.pwc.window close];
            [weakself.pwc generateSourceList];
            [weakself.pwc resetprofilewindow];
        }
    };
    [_servicemenucontrol setmenuitemvaluefromdefaults];
    [self checkaccountinformation];
    [self refreshUIServiceChange:[listservice getCurrentServiceID]];
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
    if (![listservice checkAccountForCurrentService]) {
        // First time prompt
        NSAlert *alert = [[NSAlert alloc] init] ;
        [alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
        [alert setMessageText:NSLocalizedString(@"Welcome to Shukofukurou",nil)];
        alert.informativeText = [NSString stringWithFormat:NSLocalizedString(@"Before you can use this program, you need to add an account for %@. Do you want to open Preferences to authenticate an account now? \r\rNote that there is limited functionality if you don't add an account.\r\rYou can change the current service by clicking on the service menu and selecting a list service.",nil),[listservice currentservicename]];
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
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"credentialscheckdate"] && [listservice getCurrentServiceID] == 1){
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

- (IBAction)showaboutwindow:(id)sender{
    if (!_aboutWindowController) {
        _aboutWindowController = [PFAboutWindowController new];
    }
    (self.aboutWindowController).appURL = [[NSURL alloc] initWithString:@"https://malupdaterosx.moe/shukofukurou/"];
    NSMutableString *copyrightstr = [NSMutableString new];
    NSDictionary *bundleDict = [NSBundle mainBundle].infoDictionary;
    [copyrightstr appendFormat:@"%@ \r\r",bundleDict[@"NSHumanReadableCopyright"]];
#if defined(AppStore)
#if defined(OSS)
    [copyrightstr appendString:@"Community version. No support will be provided."];
#else
    [copyrightstr appendString:@"Mac App Store version."];
#endif
#else
    if (((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"donated"]).boolValue) {
        [copyrightstr appendString:@"Pro version. Thank you for supporting Shukofukurou's development!¥"];
        [copyrightstr appendFormat:@"\rThis copy is registered to: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"donation_name"]];
    }
    else {
        [copyrightstr appendString:@"Free Version."];
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
    url = [url stringByReplacingOccurrencesOfString:@"shukofukurou://" withString:@""];
    int service = 0;
    if ([url containsString:@"myanimelist/"]) {
        service = 1;
        url = [url stringByReplacingOccurrencesOfString:@"myanimelist/" withString:@""];
    }
    else if ([url containsString:@"kitsu/"]) {
        service = 2;
        url = [url stringByReplacingOccurrencesOfString:@"kitsu/" withString:@""];
    }
    else if ([url containsString:@"anilist/"]) {
        service = 3;
        url = [url stringByReplacingOccurrencesOfString:@"anilist/" withString:@""];
    }
    bool surpressidconversion = (service != [listservice getCurrentServiceID]);
    if ([url containsString:@"anime/"]) {
        // Loads Anime Information with specified id.
        [self clearInfoView:surpressidconversion];
        url = [url stringByReplacingOccurrencesOfString:@"anime/" withString:@""];
        [_servicemenucontrol setServiceWithServiceId:service];
        [_mainwindowcontroller loadinfo:@(url.intValue) type:0 changeView:YES];
    }
    else if ([url containsString:@"manga/"]) {
        if (((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"donated"]).boolValue) {
            // Loads Manga Information with specified id.
            [self clearInfoView:surpressidconversion];
            [_servicemenucontrol setServiceWithServiceId:service];
            url = [url stringByReplacingOccurrencesOfString:@"manga/" withString:@""];
            [_mainwindowcontroller loadinfo:@(url.intValue) type:1 changeView:YES];
        }
    }
    else if ([url containsString:@"profile/"]||[url containsString:@"user/"]||[url containsString:@"users/"]) {
        if (((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"donated"]).boolValue) {
            [_servicemenucontrol setServiceWithServiceId:service];
            // Loads Manga Information with specified id.
            url = [url stringByReplacingOccurrencesOfString:@"profile/" withString:@""];
            url = [url stringByReplacingOccurrencesOfString:@"user/" withString:@""];
            url = [url stringByReplacingOccurrencesOfString:@"users/" withString:@""];
            if ([self getProfileWindow]) {
                [pwc.window makeKeyAndOrderFront:self];
                [pwc loadProfileWithUsername:url];
            }
        }
    }
    
}

- (void)clearInfoView:(bool)doclear {
    if (doclear) {
        [_mainwindowcontroller.infoview infoPopulationDidAbort];
    }
}

- (IBAction)showmessagewindow:(id)sender {
    if ([listservice getCurrentServiceID] == 1) {
        if ([Keychain checkaccount]) {
            if (!_messageswindow){
                _messageswindow = [messageswindow new];
            }
            [_messageswindow.window makeKeyAndOrderFront:self];
            [_messageswindow loadmessagelist:1 refresh:false inital:true];
        }
        else {
            [self showloginnotice];
        }
    }
}

- (IBAction)viewListStats:(id)sender {
    switch ([listservice getCurrentServiceID]) {
        case 1: {
            if (![Keychain checkaccount]) {
                [self showloginnotice];
                return;
            }
            break;
        }
        case 2: {
            if (![Kitsu getFirstAccount]) {
                [self showloginnotice];
                return;
            }
            break;
        }
        case 3: {
            if (![AniList getFirstAccount]) {
                [self showloginnotice];
                return;
            }
            break;
        }
        default:
            return;
    }
    if (!_liststatswindow){
        _liststatswindow = [ListStatistics new];
    }
    [_liststatswindow.window makeKeyAndOrderFront:self];
    [_liststatswindow populateValues];
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
- (messageswindow *)getMessagesWindow {
    if (!_messageswindow){
        _messageswindow = [messageswindow new];
    }
    return _messageswindow;
}
- (IBAction)reportbugs:(id)sender {
    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"https://github.com/Atelier-Shiori/shukofukurou/issues"]];
}

- (void)refreshUIServiceChange:(int)selected {
    if (selected != 1) {
        if (_messageswindow) {
            [_messageswindow cleartableview];
        }
        _messagesmenuitem.hidden = true;
        _malexportmenu.hidden = true;
    }
    else {
        _messagesmenuitem.hidden = false;
        _malexportmenu.hidden = false;
    }
    switch (selected) {
        case 1:
            _importkitsumenu.hidden = false;
            _importanilist.hidden = false;
            break;
        case 2:
            _importkitsumenu.hidden = true;
            _importanilist.hidden = false;
            break;
        case 3:
            _importkitsumenu.hidden = false;
            _importanilist.hidden = true;
            break;
        default:
            break;
    }
}
- (IBAction)unlockprofeatures:(id)sender {
#if defined(AppStore)
#else
    if (!_dlmanager) {
        _dlmanager = [DonationLicenseManager new];
    }
    [_dlmanager.window makeKeyAndOrderFront:self];
#endif
}


- (IBAction)getfromAppStore:(id)sender {
#if defined(AppStore)
#else
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/mal-library/id1226620085?ls=1&mt=12"]];
#endif
}

- (void)checkaccountinformation {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if ([Kitsu getFirstAccount]) {
        bool refreshKitsu = (![defaults valueForKey:@"kitsu-userinformationrefresh"] || ((NSDate *)[defaults objectForKey:@"kitsu-userinformationrefresh"]).timeIntervalSinceNow < 0);
        if ((![defaults valueForKey:@"kitsu-username"] && ![defaults valueForKey:@"kitsu-userid"]) || ((NSString *)[defaults valueForKey:@"kitsu-username"]).length == 0 || refreshKitsu) {
            [Kitsu saveuserinfoforcurrenttoken];
            [NSUserDefaults.standardUserDefaults setObject:[NSDate dateWithTimeIntervalSinceNow:259200] forKey:@"kitsu-userinformationrefresh"];
        }
    }
    if ([AniList getFirstAccount]) {
        bool refreshAniList = (![defaults valueForKey:@"anilist-userinformationrefresh"] || ((NSDate *)[defaults objectForKey:@"anilist-userinformationrefresh"]).timeIntervalSinceNow < 0);
        if ((![defaults valueForKey:@"anilist-username"] || ![defaults valueForKey:@"anilist-userid"]) || ((NSString *)[defaults valueForKey:@"anilist-username"]).length == 0 || refreshAniList) {
            [AniList saveuserinfoforcurrenttoken];
            [NSUserDefaults.standardUserDefaults setObject:[NSDate dateWithTimeIntervalSinceNow:259200] forKey:@"anilist-userinformationrefresh"];
        }
    }
}
- (IBAction)tipjar:(id)sender {
#if defined(AppStore)
#if defined(OSS)
#else
    if (!_tipjar) {
        _tipjar = [TipJar new];
    }
    [_tipjar.window makeKeyAndOrderFront:self];
#endif
#else
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://ko-fi.com/N4N0B153"]];
#endif
}

#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "moe.ateliershiori.test" in the user's Application Support directory.
    NSURL *appSupportURL = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].lastObject;
    return [appSupportURL URLByAppendingPathComponent:@"Shukofukurou"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"datamodel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
    BOOL shouldFail = NO;
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    // Make sure the application files directory is there
    NSDictionary *properties = [applicationDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    if (properties) {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", applicationDocumentsDirectory.path];
            shouldFail = YES;
        }
    } else if (error.code == NSFileReadNoSuchFileError) {
        error = nil;
        [fileManager createDirectoryAtPath:applicationDocumentsDirectory.path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (!shouldFail && !error) {
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        NSURL *url = [applicationDocumentsDirectory URLByAppendingPathComponent:@"Library Data.storedata"];
        if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            
            /*
             Typical reasons for an error here include:
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            coordinator = nil;
        }
        _persistentStoreCoordinator = coordinator;
    }
    
    if (shouldFail || error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        if (error) {
            dict[NSUnderlyingErrorKey] = error;
        }
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator = coordinator;
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    NSManagedObjectContext *context = self.managedObjectContext;
    
    if (![context commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if (context.hasChanges && ![context save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return self.managedObjectContext.undoManager;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    NSManagedObjectContext *context = _managedObjectContext;
    
    if (!context) {
        return NSTerminateNow;
    }
    
    if (![context commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (!context.hasChanges) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![context save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = question;
        alert.informativeText = info;
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertSecondButtonReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

@end
