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

@interface GeneralPref ()

@end

@implementation GeneralPref
- (instancetype)init {
    return [super initWithNibName:@"GeneralPref" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController
- (NSString *)identifier {
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel {
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}

- (IBAction)changeappearence:(id)sender {
    [_mainwindowcontroller setAppearance];
    AppDelegate *del = (AppDelegate *)NSApplication.sharedApplication.delegate;
    if (del.pwc) {
        [[del getProfileWindow] setAppearance];
    }
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
    NSManagedObjectContext *moc = ((AppDelegate *)[NSApplication sharedApplication].delegate).managedObjectContext;
    NSFetchRequest *fetch = [NSFetchRequest new];
    fetch.entity = [NSEntityDescription entityForName:@"Titleidmappings" inManagedObjectContext:moc];
    NSError *error = nil;
    NSArray *mappings = [moc executeFetchRequest:fetch error:&error];
    if (!error && mappings.count > 0) {
        for (NSManagedObject *obj in mappings) {
            [moc deleteObject:obj];
        }
        [moc save:&error];
    }
    [moc reset];
}
@end
