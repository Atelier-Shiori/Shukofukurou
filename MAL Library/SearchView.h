//
//  SearchView.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindow;
@interface SearchView : NSViewController <NSTableViewDelegate> {
    IBOutlet MainWindow *mw;
}
typedef enum  {
    AnimeSearch = 0,
    MangaSearch = 1
} SearchType;
@property (strong) IBOutlet NSSearchField *searchtitlefield;
@property (strong) IBOutlet NSTableView *searchtb;
@property (strong) IBOutlet NSArrayController *searcharraycontroller;
// Toolbar Items
@property (strong) IBOutlet NSToolbarItem * addtitleitem;
- (IBAction)performsearch:(id)sender;
- (IBAction)searchtbdoubleclick:(id)sender;
-(void)clearsearchtb;
@end
