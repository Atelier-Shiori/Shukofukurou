//
//  GeneralPref.h
//  Nekomata
//
//  Created by 桐間紗路 on 2017/03/01.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MASPreferences/MASPreferences.h>
@class MainWindow;
@interface GeneralPref : NSViewController <MASPreferencesViewController>{
    MainWindow * mainwindowcontroller;
}
- (IBAction)changeappearence:(id)sender;
-(void)setMainWindowController:(MainWindow*)mw;
- (IBAction)performtoggletimer:(id)sender;
- (IBAction)clearimages:(id)sender;

@end
