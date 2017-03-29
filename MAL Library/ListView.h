//
//  ListView.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainWindow;
@interface ListView : NSViewController{
    IBOutlet MainWindow * mw;
}
// Anime List View
@property (strong) IBOutlet NSArrayController *animelistarraycontroller;
@property (strong) IBOutlet NSTableView *animelisttb;
@property (strong) IBOutlet NSButton *watchingfilter;
@property (strong) IBOutlet NSButton *completedfilter;
@property (strong) IBOutlet NSButton *onholdfilter;
@property (strong) IBOutlet NSButton *droppedfilter;
@property (strong) IBOutlet NSButton *plantowatchfilter;
@property (strong) IBOutlet NSSearchField *animelistfilter;
@property (strong) IBOutlet NSVisualEffectView *filterbarview;
- (IBAction)deletetitle:(id)sender;
- (IBAction)filterperform:(id)sender;
- (void)populateList:(id)object;
// Not logged in
@end
