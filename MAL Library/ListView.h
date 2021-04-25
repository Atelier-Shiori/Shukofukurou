//
//  ListView.h
//  Shukofukurou
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import <Cocoa/Cocoa.h>
#import "CustomListsPopover.h"
#import "CustomListModify.h"

@interface ListView : NSViewController <NSTableViewDelegate, NSMenuDelegate>

@property int currentlist;

// Anime List View
@property (strong) IBOutlet NSArrayController *animelistarraycontroller;
@property (strong) IBOutlet NSTableView *animelisttb;
@property (strong) IBOutlet NSButton *watchingfilter;
@property (strong) IBOutlet NSButton *completedfilter;
@property (strong) IBOutlet NSButton *onholdfilter;
@property (strong) IBOutlet NSButton *droppedfilter;
@property (strong) IBOutlet NSButton *plantowatchfilter;
@property (strong) IBOutlet NSSearchToolbarItem *animelistfilter;
@property (strong) IBOutlet NSVisualEffectView *filterbarview;
@property (strong) IBOutlet NSView *animelistview;
@property (strong) IBOutlet NSVisualEffectView *filterbarview2;
@property (strong) IBOutlet NSTableColumn *animescorecol;

// Manga List View
@property (strong) IBOutlet NSArrayController *mangalistarraycontroller;
@property (strong) IBOutlet NSTableView *mangalisttb;
@property (strong) IBOutlet NSButton *readingfilter;
@property (strong) IBOutlet NSButton *mangacompletedfilter;
@property (strong) IBOutlet NSButton *mangaonholdfilter;
@property (strong) IBOutlet NSButton *mangadroppedfilter;
@property (strong) IBOutlet NSButton *plantoreadfilter;
@property (strong) IBOutlet NSView *mangalistview;
@property (strong) IBOutlet NSTableColumn *mangascorecol;

// Filter Save
@property (strong) NSString * animelisttitlefilterstring;
@property (strong) NSString * mangalisttitlefilterstring;

// Custom Lists
@property (strong) NSArray *animecustomlists;
@property (strong) NSArray *mangacustomlists;
@property (strong) IBOutlet NSPopover *customlistpopover;
@property (strong) IBOutlet CustomListsPopover *customlistpopoverviewcontroller;
@property (strong) NSString *currentcustomlistanime;
@property (strong) NSString *currentcustomlistmanga;
@property (strong) IBOutlet NSButton *mangacustomlistbtn;
@property (strong) IBOutlet NSButton *animecustomlistbtn;
@property (strong) IBOutlet NSPopover *customlistmodifypopover;
@property (strong) IBOutlet CustomListModify *customlistmodifyviewcontroller;

- (void)loadList:(int)list;
- (IBAction)filterperform:(id)sender;
- (void)populateList:(id)object type:(int)type;
- (void)removeAllFilterBindings;
- (void)clearalllists;
- (void)setToolTipForType:(int)type shouldReset:(bool)reset;
- (void)resetcustomlists;
@end
