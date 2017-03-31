//
//  ListView.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainWindow;
@interface ListView : NSViewController <NSTableViewDelegate>{
    IBOutlet MainWindow * mw;
    int currentlist;
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
@property (strong) IBOutlet NSView *animelistview;

// Manga List View
@property (strong) IBOutlet NSArrayController *mangalistarraycontroller;
@property (strong) IBOutlet NSTableView *mangalisttb;
@property (strong) IBOutlet NSButton *readingfilter;
@property (strong) IBOutlet NSButton *mangacompletedfilter;
@property (strong) IBOutlet NSButton *mangaonholdfilter;
@property (strong) IBOutlet NSButton *mangadroppedfilter;
@property (strong) IBOutlet NSButton *plantoreadfilter;
@property (strong) IBOutlet NSView *mangalistview;

// Toolbar Items
@property (strong) IBOutlet NSToolbarItem *edittitleitem;
@property (strong) IBOutlet NSToolbarItem *deletetitleitem;
@property (strong) IBOutlet NSToolbarItem *shareitem;

-(void)loadList:(int)list;
- (IBAction)deletetitle:(id)sender;
- (IBAction)filterperform:(id)sender;
- (void)populateList:(id)object type:(int)type;
@end
