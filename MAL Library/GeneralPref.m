//
//  GeneralPref.m
//  Nekomata
//
//  Created by 桐間紗路 on 2017/03/01.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import "GeneralPref.h"
#import "MainWindow.h"
#import "Utility.h"
@interface GeneralPref ()

@end

@implementation GeneralPref
- (id)init
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
    [mainwindowcontroller setAppearence];
}
-(void)setMainWindowController:(MainWindow*)mw{
    mainwindowcontroller = mw;
}

- (IBAction)performtoggletimer:(id)sender {
    NSNumber * autorefreshlist = [[NSUserDefaults standardUserDefaults] valueForKey:@"refreshautomatically"];
    if (autorefreshlist.boolValue){
        [mainwindowcontroller startTimer];
    }
    else{
        [mainwindowcontroller stopTimer];
    }
}

- (IBAction)clearimages:(id)sender {
    NSAlert * alert = [[NSAlert alloc] init] ;
    [alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
    [alert setMessageText:NSLocalizedString(@"Do you really want to clear the image cache?",nil)];
    [alert setInformativeText:NSLocalizedString(@"Once done, this action cannot be undone.",nil)];
    // Set Message type to Warning
    alert.alertStyle = NSAlertStyleInformational;
    [alert beginSheetModalForWindow:[[self view] window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode== NSAlertFirstButtonReturn) {
            NSFileManager * fm = [NSFileManager defaultManager];
            NSString * path = [Utility retrieveApplicationSupportDirectory:@"imgcache"];
            NSDirectoryEnumerator * en = [fm enumeratorAtPath:path];
            NSError * error = nil;
            bool success;
            NSString * file;
            while (file = [en nextObject]){
                success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@",path,file] error:&error];
                if (!success && error){
                    NSLog(@"%@", error);
                }
            }
        }
    }];
}
@end
