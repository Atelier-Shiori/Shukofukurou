//
//  SearchView.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import <Cocoa/Cocoa.h>

@class MainWindow;
@interface SearchView : NSViewController <NSTableViewDelegate> {
    IBOutlet MainWindow *mw;
    int currentsearch;
    NSString *AnimeSearchTerm;
    NSString *MangaSearchTerm;
}
typedef NS_ENUM(unsigned int, SearchType) {
    AnimeSearch = 0,
    MangaSearch = 1
};
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

- (void)loadsearchView:(int)type;
- (IBAction)performsearch:(id)sender;
- (IBAction)searchtbdoubleclick:(id)sender;
- (void)clearsearchtb;
@end
