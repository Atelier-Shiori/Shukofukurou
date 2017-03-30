//
//  SeasonView.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindow;

@interface SeasonView : NSViewController <NSTableViewDelegate>{
    IBOutlet MainWindow * mw;
    bool selected;
}
@property (strong) IBOutlet NSTableView *seasontableview;
@property (strong) IBOutlet NSArrayController *seasonarraycontroller;
@property (strong) IBOutlet NSToolbarItem *addtitleitem;

- (IBAction)seasondoubleclick:(id)sender;
- (IBAction)yearchange:(id)sender;
- (IBAction)seasonchange:(id)sender;
-(void)populateseasonpopup;
-(void)populateyearpopup;
-(void)populateseasonpopups;
-(void)performseasonindexretrieval;
@end
