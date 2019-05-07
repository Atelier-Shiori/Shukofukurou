//
//  SearchView.h
//  Shukofukurou
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import <Cocoa/Cocoa.h>

@class MainWindow;
@interface SearchView : NSViewController <NSTableViewDelegate, NSMenuDelegate>
typedef NS_ENUM(unsigned int, SearchType) {
    AnimeSearch = 0,
    MangaSearch = 1
};
@property (strong) IBOutlet MainWindow *mw;
@property int currentsearch;
@property (strong) NSString *AnimeSearchTerm;
@property (strong) NSString *MangaSearchTerm;

@property (strong) IBOutlet NSSearchField *searchtitlefield;

// Anime Search
@property (strong) IBOutlet NSView *animesearch;
@property (strong) IBOutlet NSTableView *searchtb;
@property (strong) IBOutlet NSArrayController *searcharraycontroller;

//Manga Search
@property (strong) IBOutlet NSView *mangasearch;
@property (strong) IBOutlet NSTableView *mangasearchtb;
@property (strong) IBOutlet NSArrayController *mangasearcharraycontroller;

// Toolbar Items
@property (strong) IBOutlet NSToolbarItem *addtitleitem;
@property (strong) IBOutlet NSToolbarItem *moresearchitem;

- (void)loadsearchView:(int)type;
- (IBAction)performsearch:(id)sender;
- (IBAction)performsearch:(id)sender;
- (IBAction)searchtbdoubleclick:(id)sender;
- (void)clearsearchtb;
- (void)clearallsearch;
@end
