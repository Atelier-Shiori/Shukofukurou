//
//  GeneralPref.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/03/01.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "GeneralPref.h"
#import "AppDelegate.h"
#import "MainWindow.h"
#import "ProfileWindowController.h"
#import "Utility.h"
#import "StreamDataRetriever.h"
#import "TitleIDMapper.h"
#import "TitleInfoCache.h"
#import <SDWebImage/SDWebImage.h>
#import <SDWebImage/UIImageView+WebCache.h>

#if defined(OSS)
#else
@import AppCenterAnalytics;
@import AppCenterCrashes;
#endif

@interface GeneralPref ()
@property (strong) IBOutlet NSButton *showadultoption;
@property (strong) IBOutlet NSPopUpButton *appearencepopupbtn;

@end

@implementation GeneralPref
- (instancetype)init {
    return [super initWithNibName:@"GeneralPref" bundle:nil];
}
- (void)viewDidLoad {
#if defined(AppStore)
#if defined(OSS)
#else
    // Do not show adult content in the Mac App Store version
    _showadultoption.hidden = YES;
#endif
#endif
    if (@available(macOS 10.14, *)) {
        _appearencepopupbtn.enabled = NO;
    }
}

#pragma mark -
#pragma mark MASPreferencesViewController
- (NSString *)viewIdentifier {
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel {
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}

- (IBAction)changeappearence:(id)sender {
    [NSNotificationCenter.defaultCenter postNotificationName:@"AppAppearenceChanged" object:nil];
}
- (void)setMainWindowController:(MainWindow*)mw{
    _mainwindowcontroller = mw;
}

- (IBAction)performtoggletimer:(id)sender {
    NSNumber *autorefreshlist = [[NSUserDefaults standardUserDefaults] valueForKey:@"refreshautomatically"];
    if (autorefreshlist.boolValue){
        [_mainwindowcontroller startTimer];
    }
    else{
        [_mainwindowcontroller stopTimer];
    }
}

- (IBAction)clearimages:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init] ;
    [alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
    [alert setMessageText:NSLocalizedString(@"Do you really want to clear the image cache?",nil)];
    [alert setInformativeText:NSLocalizedString(@"Once done, this action cannot be undone.",nil)];
    // Set Message type to Warning
    alert.alertStyle = NSAlertStyleInformational;
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [Utility clearImageCache];
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{}];
        }
    }];
}

- (IBAction)refreshstreamdata:(id)sender {
    //[StreamDataRetriever performrestrieveStreamData];
}

- (IBAction)resetmappings:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init] ;
    [alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
    [alert setMessageText:NSLocalizedString(@"Do you really want to reset the Title ID mappings?",nil)];
    [alert setInformativeText:NSLocalizedString(@"Once done, this action cannot be undone.",nil)];
    // Set Message type to Warning
    alert.alertStyle = NSAlertStyleInformational;
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode== NSAlertFirstButtonReturn) {
            [self performmappingsreset];
        }
    }];
}

- (void)performmappingsreset {
    // Resets the Titleidmappings entity
    [[TitleIDMapper sharedInstance] clearAllMappings];
}
- (IBAction)cachetitletoggle:(id)sender {
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"cachetitleinfo"]) {
        [TitleInfoCache cleanupcacheShouldRemoveAll:YES];
    }
    [NSNotificationCenter.defaultCenter postNotificationName:@"TitleCacheToggled" object:nil];
}

- (IBAction)sendstatstoggle:(id)sender {
#if defined(OSS)
#else
    [MSACCrashes setEnabled:[NSUserDefaults.standardUserDefaults boolForKey:@"sendanalytics"]];
    [MSACAnalytics setEnabled:[NSUserDefaults.standardUserDefaults boolForKey:@"sendanalytics"]];
#endif
}
- (IBAction)viewprivacypolicy:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://malupdaterosx.moe/shukofukurou/privacy-policy/"]];
}
@end
