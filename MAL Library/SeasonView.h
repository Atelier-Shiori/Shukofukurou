//
//  SeasonView.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import <Cocoa/Cocoa.h>

@class MainWindow;

@interface SeasonView : NSViewController <NSTableViewDelegate>{
    IBOutlet MainWindow * mw;
}
@property (strong) IBOutlet NSTableView *seasontableview;
@property (strong) IBOutlet NSArrayController *seasonarraycontroller;
@property (strong) IBOutlet NSToolbarItem *addtitleitem;

- (IBAction)seasondoubleclick:(id)sender;
- (IBAction)yearchange:(id)sender;
- (IBAction)seasonchange:(id)sender;
- (void)populateseasonpopup;
- (void)populateyearpopup;
- (void)populateseasonpopups;
- (void)performseasonindexretrieval;
@end
