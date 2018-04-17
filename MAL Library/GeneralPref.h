//
//  GeneralPref.h
//  Shukofukuro
//
//  Created by 桐間紗路 on 2017/03/01.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import <Cocoa/Cocoa.h>
#import <MASPreferences/MASPreferences.h>
@class MainWindow;
@interface GeneralPref : NSViewController <MASPreferencesViewController>
@property (strong) MainWindow *mainwindowcontroller;
- (IBAction)changeappearence:(id)sender;
- (void)setMainWindowController:(MainWindow*)mw;
- (IBAction)performtoggletimer:(id)sender;
- (IBAction)clearimages:(id)sender;

@end
