//
//  InfoView.h
//  Shukofukurou
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import <Cocoa/Cocoa.h>
#import "CharactersBrowser.h"

@class MainWindow;

@interface InfoView : NSViewController
typedef NS_ENUM(unsigned int, InfoType) {
    AnimeType = 0,
    MangaType = 1
};
@property (strong) IBOutlet MainWindow *mw;
@property bool forcerefresh;
@property (getter=getSelectedId, setter=setSelectedId:) int selectedid;
@property (getter=getSelectedInfo) NSDictionary *selectedinfo;
@property (getter=getType, setter=setType:) int type;
@property (strong) IBOutlet NSPopover *othertitlepopover;

@property (strong) IBOutlet NSTextView *infoviewbackgroundtextview;
@property (strong) IBOutlet NSTextView *infoviewdetailstextview;
@property (strong) IBOutlet NSTextView *infoviewsynopsistextview;

// Search Menus
@property (strong) IBOutlet NSMenuItem *anidbmenuitem;
@property (strong) IBOutlet NSMenuItem *bakaupdatesmenuitem;

@property (strong) CharactersBrowser *cbrowser;

- (void)populateAnimeInfoView:(id)object;
- (void)populateMangaInfoView:(id)object;
- (IBAction)viewonmal:(id)sender;
- (IBAction)viewreviews:(id)sender;
- (IBAction)openpeoplebrowser:(id)sender;
- (IBAction)searchsite:(id)sender;
- (void)infoPopulationDidAbort;
@end
