//
//  GeneralPref.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/03/01.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "GeneralPref.h"
#import "AppDelegate.h"
#import "MainWindow.h"
#import "ProfileWindowController.h"
#import "Utility.h"
#import "StreamDataRetriever.h"

@interface GeneralPref ()

@end

@implementation GeneralPref
- (instancetype)init
{
    return [super initWithNibName:@"GeneralPref" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}
- (IBAction)changeappearence:(id)sender {
    [_mainwindowcontroller setAppearance];
    AppDelegate *del = (AppDelegate *)NSApplication.sharedApplication.delegate;
    [[del getProfileWindow] setAppearance];
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
        if (returnCode== NSAlertFirstButtonReturn) {
            [Utility clearImageCache];
        }
    }];
}
- (IBAction)refreshstreamdata:(id)sender {
    [StreamDataRetriever performrestrieveStreamData];
}
@end
