//
//  MainWindow.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/02/28.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "MainWindow.h"
#import "listservice.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "NSTextFieldNumber.h"
#import "MSWeakTimer.h"
#import "Keychain.h"
#import "AddTitle.h"
#import "EditTitle.h"
#import "MyListView.h"
#import "NotLoggedIn.h"
#import "SearchView.h"
#import "InfoView.h"
#import "SeasonView.h"
#import "AdvancedSearch.h"
#import "HistoryView.h"
#import "AiringView.h"
#import "NSTableViewAction.h"
#import "servicemenucontroller.h"

@interface MainWindow ()
@property (strong, nonatomic) NSMutableArray *sourceListItems;
@property (strong) IBOutlet NSSplitView *splitview;
@property bool refreshanime;
@property bool refreshmanga;
@end

@implementation MainWindow

- (instancetype)init{
    self = [super initWithWindowNibName:@"MainWindow"];
    if (!self)
        return nil;
    return self;
}
- (void)awakeFromNib
{
    // Register queue
    _privateQueue = dispatch_queue_create("moe.ateliershiori.MAL Library", DISPATCH_QUEUE_CONCURRENT);
    // Add blank subview to mainview
    [_mainview addSubview:[NSView new]];
    // Insert code here to initialize your application
    // Fix template images
    // There is a bug where template images are not made even if they are set in XCAssets
    NSArray *images = @[@"animeinfo", @"delete", @"Edit", @"Info", @"library", @"search", @"seasons", @"anime", @"manga", @"history", @"airing", @"reviews", @"newmessage", @"reply", @"cast", @"person", @"stats", @"safari"];
    NSImage * image;
    for (NSString *imagename in images){
        image = [NSImage imageNamed:imagename];
        [image setTemplate:YES];
    }
    // Generate Source List
    [self generateSourceList];
    
    // Set Resizing mask
    (_infoview.view).autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    (_listview.view).autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    (_historyview.view).autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    _progressview.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    (_searchview.view).autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    (_seasonview.view).autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    (_notloggedin.view).autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    (_airingview.view).autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    self.window.titleVisibility = NSWindowTitleHidden;
    
    // Fix window size
    NSRect frame = (self.window).frame;
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_11){
        frame.size.height = frame.size.height - 44;
    }
    else{
        frame.size.height = frame.size.height - 22;
    }
    [self.window setFrame:frame display:NO];
    [self setAppearance];
    
    // Set logged in user
    [self refreshloginlabel];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    _infoview.selectedid = 0;
    // Set Mainview
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"selectedmainview"]){
        NSNumber *selected = (NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedmainview"];
        [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex: selected.unsignedIntegerValue]byExtendingSelection:false];
    }
    else{
         [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:1]byExtendingSelection:false];
    }
    // Load Touchbar
    //if (NSClassFromString(@"NSTouchBar") != nil) {
    //    [[NSBundle mainBundle] loadNibNamed:@"MainWindow_Touch_Bar" owner:self topLevelObjects:nil];
    //}
    
    [self initallistload];
    
    NSNumber * autorefreshlist = [[NSUserDefaults standardUserDefaults] valueForKey:@"refreshautomatically"];
    if (autorefreshlist.boolValue){
        [self startTimer];
    }
    
}

- (void)generateSourceList {
    self.sourceListItems = [[NSMutableArray alloc] init];
    int currentservice = [listservice getCurrentServiceID];
    //Library Group
    PXSourceListItem *libraryItem = [PXSourceListItem itemWithTitle:@"LIBRARY" identifier:@"library"];
    PXSourceListItem *animelistItem = [PXSourceListItem itemWithTitle:@"Anime List" identifier:@"animelist"];
    animelistItem.icon = [NSImage imageNamed:@"library"];
    PXSourceListItem *historyItem = [PXSourceListItem itemWithTitle:@"History" identifier:@"history"];
    historyItem.icon = [NSImage imageNamed:@"history"];
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"donated"]) {
        PXSourceListItem *mangalistItem = [PXSourceListItem itemWithTitle:@"Manga List" identifier:@"mangalist"];
        mangalistItem.icon = [NSImage imageNamed:@"library"];
        if (currentservice == 1) {
            libraryItem.children = @[animelistItem, mangalistItem, historyItem];
        }
        else {
            libraryItem.children = @[animelistItem, mangalistItem];
        }
    }
    else {
        if (currentservice == 1) {
            libraryItem.children = @[animelistItem, historyItem];
        }
        else {
            libraryItem.children = @[animelistItem];
        }
    }
    // Search
    PXSourceListItem *searchgroupItem = [PXSourceListItem itemWithTitle:@"SEARCH" identifier:@"searchgroup"];
    PXSourceListItem *searchItem = [PXSourceListItem itemWithTitle:@"Anime" identifier:@"search"];
    searchItem.icon = [NSImage imageNamed:@"anime"];
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"donated"]) {
        PXSourceListItem *mangasearchItem = [PXSourceListItem itemWithTitle:@"Manga" identifier:@"mangasearch"];
        mangasearchItem.icon = [NSImage imageNamed:@"manga"];
        searchgroupItem.children = @[searchItem, mangasearchItem];
    }
    else {
        searchgroupItem.children = @[searchItem];
    }
    // Discover Group
    PXSourceListItem *discoverItem = [PXSourceListItem itemWithTitle:@"DISCOVER" identifier:@"discover"];
    PXSourceListItem *titleinfoItem = [PXSourceListItem itemWithTitle:@"Title Info" identifier:@"titleinfo"];
    titleinfoItem.icon = [NSImage imageNamed:@"animeinfo"];
    PXSourceListItem *seasonsItem = [PXSourceListItem itemWithTitle:@"Seasons" identifier:@"seasons"];
    seasonsItem.icon = [NSImage imageNamed:@"seasons"];
    PXSourceListItem *airingItem = [PXSourceListItem itemWithTitle:@"Airing" identifier:@"airing"];
    airingItem.icon = [NSImage imageNamed:@"airing"];
    discoverItem.children = @[titleinfoItem,seasonsItem, airingItem];
    
    // Populate Source List
    [self.sourceListItems addObject:libraryItem];
    [self.sourceListItems addObject:searchgroupItem];
    [self.sourceListItems addObject:discoverItem];
    [_sourceList reloadData];

}

- (void)setDelegate:(AppDelegate*) adelegate{
    _appdel = adelegate;
}


- (IBAction)sharetitle:(id)sender {
    NSDictionary * d;
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    NSString *identifier = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];
    int type = 0;
    if ([identifier isEqualToString:@"animelist"]){
        d = (_listview.animelistarraycontroller).selectedObjects[0];
        type = AnimeType;
    }
    if ([identifier isEqualToString:@"mangalist"]){
        d = (_listview.mangalistarraycontroller).selectedObjects[0];
        type = MangaType;
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        d = _infoview.selectedinfo;
        type = _infoview.type;
    }

    //Generate Items to Share
    NSArray *shareItems = @[];;
    switch ([listservice getCurrentServiceID]) {
        case 1: {
            if (type == AnimeType){
                shareItems = @[[NSString stringWithFormat:@"Check out %@ out on MyAnimeList ", d[@"title"]], [NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/anime/%@", d[@"id"]]]];
            }
            else {
                shareItems = @[[NSString stringWithFormat:@"Check out %@ out on MyAnimeList ", d[@"title"]], [NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/manga/%@", d[@"id"]]]];
            }
            break;
        }
        case 2: {
            if (type == AnimeType){
                shareItems = @[[NSString stringWithFormat:@"Check out %@ out on Kitsu", d[@"title"]], [NSURL URLWithString:[NSString stringWithFormat:@"https://kitsu.io/anime/%@", d[@"id"]]]];
            }
            else {
                shareItems = @[[NSString stringWithFormat:@"Check out %@ out on Kitsu", d[@"title"]], [NSURL URLWithString:[NSString stringWithFormat:@"https://kitsu.io/manga/%@", d[@"id"]]]];
            }
            break;
        }
        default:
            break;
    }
    //Get Share Picker
    NSSharingServicePicker *sharePicker = [[NSSharingServicePicker alloc] initWithItems:shareItems];
    sharePicker.delegate = nil;
    NSButton * btn = (NSButton *)sender;
    // Show Share Box
    [sharePicker showRelativeToRect:btn.bounds ofView:btn preferredEdge:NSMinYEdge];
}

- (void)startTimer{
    _refreshtimer =  [MSWeakTimer scheduledTimerWithTimeInterval:900
                                                          target:self
                                                        selector:@selector(fireTimer)
                                                        userInfo:nil
                                                         repeats:YES
                                                   dispatchQueue:_privateQueue];
}

- (void)stopTimer{
    [_refreshtimer invalidate];
}

- (void)fireTimer{
    if ([listservice checkAccountForCurrentService]) {
        switch ([listservice getCurrentServiceID]) {
            case 1: {
                [self performtimerlistrefresh];
                break;
            }
            case 2: {
                [Kitsu getUserRatingType:^(int scoretype) {
                    [NSUserDefaults.standardUserDefaults setInteger:scoretype forKey:@"kitsu-ratingsystem"];
                    [self performtimerlistrefresh];
                } error:^(NSError *error) {
                    NSLog(@"Error loading list: %@", error.localizedDescription);
                }];
            }
            case 3: {
                [AniList getUserRatingType:^(NSString *scoretype) {
                    [NSUserDefaults.standardUserDefaults setValue:scoretype forKey:@"anilist-scoreformat"];
                    [self performtimerlistrefresh];
                } error:^(NSError *error) {
                     NSLog(@"Error loading list: %@", error.localizedDescription);
                }];
            }
            default: {
                break;
            }
        }
    }
}
- (void)performtimerlistrefresh {
    [_appdel.servicemenucontrol enableservicemenuitems:NO];
    [self showProgressWheel:NO];
    [self loadlist:@(true) type:0];
    [self loadlist:@(true) type:1];
    [self loadlist:@(true) type:2];
}
- (void)windowWillClose:(NSNotification *)notification{
    [[NSApplication sharedApplication] terminate:0];
}

- (void)setAppearance {
    NSString * appearence = [[NSUserDefaults standardUserDefaults] valueForKey:@"appearance"];
    NSString *appearancename;
    if ([appearence isEqualToString:@"Light"]){
        appearancename = NSAppearanceNameVibrantLight;
        _w.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
    }
    else{
        appearancename = NSAppearanceNameVibrantDark;
        _w.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    }
    _progressview.appearance = [NSAppearance appearanceNamed:appearancename];
    _infoview.view.appearance = [NSAppearance appearanceNamed:appearancename];
    [_infoview.cbrowser setAppearance];
    _notloggedin.view.appearance = [NSAppearance appearanceNamed:appearancename];
    _listview.filterbarview.appearance = [NSAppearance appearanceNamed:appearancename];
    _listview.filterbarview2.appearance = [NSAppearance appearanceNamed:appearancename];
    _advsearchpopover.appearance = [NSAppearance appearanceNamed:appearancename];
    _minieditpopover.appearance = [NSAppearance appearanceNamed:appearancename];
    _addpopover.appearance = [NSAppearance appearanceNamed:appearancename];
    _infoview.othertitlepopover.appearance = [NSAppearance appearanceNamed:appearancename];
    [_w setFrame:_w.frame display:false];
}

- (void)refreshloginlabel{
    if ([listservice checkAccountForCurrentService]) {
        _loggedinuser.stringValue = [NSString stringWithFormat:@"Logged in as %@",[listservice getCurrentServiceUsername]];
    }
    else {
        _loggedinuser.stringValue = @"Not logged in.";
    }
}

#pragma mark -
#pragma mark Source List Data Source Methods
- (NSUInteger)sourceList:(PXSourceList*)sourceList numberOfChildrenOfItem:(id)item
{
    if (!item)
        return self.sourceListItems.count;
    
    return [item children].count;
}

- (id)sourceList:(PXSourceList*)aSourceList child:(NSUInteger)index ofItem:(id)item
{
    if (!item)
        return self.sourceListItems[index];
    
    return [item children][index];
}

- (BOOL)sourceList:(PXSourceList*)aSourceList isItemExpandable:(id)item
{
    return [item hasChildren];
}


#pragma mark Source List Delegate Methods
- (NSView *)sourceList:(PXSourceList *)aSourceList viewForItem:(id)item
{
    PXSourceListTableCellView *cellView = nil;
    if ([aSourceList levelForItem:item] == 0)
        cellView = [aSourceList makeViewWithIdentifier:@"HeaderCell" owner:nil];
    else
        cellView = [aSourceList makeViewWithIdentifier:@"MainCell" owner:nil];
    
    PXSourceListItem *sourceListItem = item;
    
    // Only allow us to edit the user created photo collection titles.
    cellView.textField.editable = false;
    cellView.textField.selectable = false;
    
    cellView.textField.stringValue = sourceListItem.title ? sourceListItem.title : [sourceListItem.representedObject title];
    cellView.imageView.image = [item icon];
    
    return cellView;
}


- (BOOL)sourceList:(PXSourceList*)aSourceList isGroupAlwaysExpanded:(id)group
{
    if([[group identifier] isEqualToString:@"library"])
        return YES;
    else if([[group identifier] isEqualToString:@"searchgroup"])
        return YES;
    else if([[group identifier] isEqualToString:@"discover"])
        return YES;
    return NO;
}
- (void)sourceListSelectionDidChange:(NSNotification *)notification
{
    [self loadmainview];
}

#pragma mark -
#pragma mark SplitView Delegate

- (void) splitView:(NSSplitView*) splitView resizeSubviewsWithOldSize:(NSSize) oldSize
{
    if (splitView == _splitview)
    {
        CGFloat dividerPos = NSWidth([[splitView subviews][0] frame]);
        CGFloat width = NSWidth([splitView frame]);
        
        if (dividerPos < 0)
            dividerPos = 0;
        if (width - dividerPos < 558 + [splitView dividerThickness])
            dividerPos = width - (558 + [splitView dividerThickness]);
        
        [splitView adjustSubviews];
        [splitView setPosition:dividerPos ofDividerAtIndex:0];
    }
}

- (CGFloat) splitView:(NSSplitView*) splitView constrainSplitPosition:(CGFloat) proposedPosition ofSubviewAt:(NSInteger) dividerIndex
{
    if (splitView == _splitview)
    {
        CGFloat width = NSWidth([splitView frame]);
        
        if (ABS(137 - proposedPosition) <= 8)
            proposedPosition = 150;
        if (proposedPosition < 0)
            proposedPosition = 0;
        if (width - proposedPosition < 558 + [splitView dividerThickness])
            proposedPosition = width - (558 + [splitView dividerThickness]);
    }
    
    return proposedPosition;
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification{
    [_w setFrame:_w.frame display:false];
}

#pragma mark -
#pragma mark Main View Control
- (void)loadmainview {
    NSRect mainviewframe = _mainview.frame;
    long selectedrow = _sourceList.selectedRow;
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    NSString *identifier = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];
    NSPoint origin = NSMakePoint(0, 0);
        if ([identifier isEqualToString:@"animelist"]){
            if ([listservice checkAccountForCurrentService]) {
                [self replaceMainViewWithView:_listview.view];
                [_listview loadList:0];
                _listview.animelistview.frame = mainviewframe;
                [_listview.animelistview setFrameOrigin:origin];
            }
            else {
                [self loadNotLoggedIn];
            }
        }
        else if ([identifier isEqualToString:@"mangalist"]){
            if (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"]).boolValue){
                if ([listservice checkAccountForCurrentService]) {
                    [self replaceMainViewWithView:_listview.view];
                    [_listview loadList:1];
                    _listview.mangalistview.frame = mainviewframe;
                    [_listview.mangalistview setFrameOrigin:origin];
                }
                else {
                     [self loadNotLoggedIn];
                }
            }
        }
        else if ([identifier isEqualToString:@"history"]){
            if ([listservice checkAccountForCurrentService]) {
                [self replaceMainViewWithView:_historyview.view];
            }
            else{
                [self loadNotLoggedIn];
            }
        }
        else if ([identifier isEqualToString:@"search"]){
            [self replaceMainViewWithView:_searchview.view];
            [_searchview loadsearchView:AnimeSearch];
            _searchview.animesearch.frame = mainviewframe;
            [_searchview.animesearch setFrameOrigin:origin];
        }
        else if ([identifier isEqualToString:@"mangasearch"]){
            if (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"]).boolValue){
                [self replaceMainViewWithView:_searchview.view];
                [_searchview loadsearchView:MangaSearch];
                _searchview.mangasearch.frame = mainviewframe;
                [_searchview.mangasearch setFrameOrigin:origin];
            }
        }
        else if ([identifier isEqualToString:@"titleinfo"]){
            if (_infoview.selectedid > 0){
                [self replaceMainViewWithView:_infoview.view];
            }
            else{
                [self replaceMainViewWithView:_progressview];
            }
        }
        else if ([identifier isEqualToString:@"seasons"]){
            [self replaceMainViewWithView:_seasonview.view];
        }
        else if ([identifier isEqualToString:@"airing"]){
            [self replaceMainViewWithView:_airingview.view];
            if ([_airingview.airingarraycontroller.arrangedObjects count] == 0){
                // Load Airing List
                [_airingview loadAiring:@(false)];
            }
        }
        else{
            // Fallback
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:1]byExtendingSelection:false];
            [self loadmainview];
            return;
        }
    // Save current view
    [[NSUserDefaults standardUserDefaults] setValue:@(selectedrow) forKey:@"selectedmainview"];
    [self createToolbar];
}
- (void)replaceMainViewWithView:(NSView *)view {
    NSRect mainviewframe = _mainview.frame;
    NSPoint origin = NSMakePoint(0, 0);
    [_mainview replaceSubview:(_mainview.subviews)[0] with:view];
    view.frame = mainviewframe;
    [view setFrameOrigin:origin];
}
- (void)loadNotLoggedIn {
    [self replaceMainViewWithView:_notloggedin.view];
}
- (void)createToolbar{
    NSArray *toolbaritems = _toolbar.items;
    // Remove Toolbar Items
    for (int i = 0; i < toolbaritems.count; i++) {
        [_toolbar removeItemAtIndex:0];
    }
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    NSString *identifier = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];
    int indexoffset = 0;
    if ([identifier isEqualToString:@"animelist"]){
        if ([listservice checkAccountForCurrentService]) {
            [_toolbar insertItemWithItemIdentifier:@"editList" atIndex:0];
            [_toolbar insertItemWithItemIdentifier:@"DeleteTitle" atIndex:1];
            [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:2];
            [_toolbar insertItemWithItemIdentifier:@"viewtitleinfo" atIndex:3];
            [_toolbar insertItemWithItemIdentifier:@"ShareList" atIndex:4];
            [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:5];
            [_toolbar insertItemWithItemIdentifier:@"filter" atIndex:6];
        }
    }
    else if ([identifier isEqualToString:@"mangalist"]){
        if (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"]).boolValue) {
            if ([listservice checkAccountForCurrentService]) {
                [_toolbar insertItemWithItemIdentifier:@"editList" atIndex:0];
                [_toolbar insertItemWithItemIdentifier:@"DeleteTitle" atIndex:1];
                [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:2];
                [_toolbar insertItemWithItemIdentifier:@"viewtitleinfo" atIndex:3];
                [_toolbar insertItemWithItemIdentifier:@"ShareList" atIndex:4];
                [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:5];
                [_toolbar insertItemWithItemIdentifier:@"filter" atIndex:6];
            }
        }
    }
    else if ([identifier isEqualToString:@"history"]){
        if ([listservice checkAccountForCurrentService]) {
            [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:0];
        }
        
    }
    else if ([identifier isEqualToString:@"search"]){
        if ([listservice checkAccountForCurrentService]) {
            [_toolbar insertItemWithItemIdentifier:@"AddTitleSearch" atIndex:0];
        }
        else {
            indexoffset = -1;
        }
        [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:1+indexoffset];
        if ([listservice getCurrentServiceID] == 1) {
            [_toolbar insertItemWithItemIdentifier:@"advsearch" atIndex:2+indexoffset];
            [_toolbar insertItemWithItemIdentifier:@"search" atIndex:3+indexoffset];
        }
        else {
            [_toolbar insertItemWithItemIdentifier:@"search" atIndex:2+indexoffset];
        }
    }
    else if ([identifier isEqualToString:@"mangasearch"]){
        if (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"]).boolValue) {
            if ([listservice checkAccountForCurrentService]) {
                [_toolbar insertItemWithItemIdentifier:@"AddTitleSearch" atIndex:0];
            }
            else {
                indexoffset = -1;
            }
            [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:1+indexoffset];
            if ([listservice getCurrentServiceID] == 1) {
                [_toolbar insertItemWithItemIdentifier:@"advsearch" atIndex:2+indexoffset];
                [_toolbar insertItemWithItemIdentifier:@"search" atIndex:3+indexoffset];
            }
            else {
                [_toolbar insertItemWithItemIdentifier:@"search" atIndex:2+indexoffset];
            }
        }
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        if (_infoview.selectedid > 0){
            if ([listservice checkAccountForCurrentService]) {
                if ([self checkiftitleisonlist:_infoview.selectedid type:_infoview.type]){
                     [_toolbar insertItemWithItemIdentifier:@"editInfo" atIndex:0];
                }
                else{
                    [_toolbar insertItemWithItemIdentifier:@"AddTitleInfo" atIndex:0];
                }
            }
            else{
                indexoffset = -1;
            }
            [_toolbar insertItemWithItemIdentifier:@"viewonmal" atIndex:1+indexoffset];
            [_toolbar insertItemWithItemIdentifier:@"viewreviews" atIndex:2+indexoffset];
            if (_infoview.type == MALAnime && [[NSUserDefaults standardUserDefaults] boolForKey:@"donated"]) {
                [_toolbar insertItemWithItemIdentifier:@"viewpeople" atIndex:3+indexoffset];
                [_toolbar insertItemWithItemIdentifier:@"ShareInfo" atIndex:4+indexoffset];
                [_toolbar insertItemWithItemIdentifier:@"web" atIndex:5+indexoffset];
            }
            else {
                [_toolbar insertItemWithItemIdentifier:@"ShareInfo" atIndex:3+indexoffset];
                [_toolbar insertItemWithItemIdentifier:@"web" atIndex:4+indexoffset];
            }
        }
    }
    else if ([identifier isEqualToString:@"seasons"]){
        if ([listservice checkAccountForCurrentService]) {
            [_toolbar insertItemWithItemIdentifier:@"AddTitleSeason" atIndex:0+indexoffset];
        }
        else {
            indexoffset = -1;
        }
        [_toolbar insertItemWithItemIdentifier:@"yearselect" atIndex:1+indexoffset];
        [_toolbar insertItemWithItemIdentifier:@"seasonselect" atIndex:2+indexoffset];
        [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:3+indexoffset];
        if (((NSArray *)_seasonview.seasonarraycontroller.content).count == 0) {
            [_seasonview populateseasonpopups];
        }
    }
    else if ([identifier isEqualToString:@"airing"]){
        if ([listservice checkAccountForCurrentService]) {
            [_toolbar insertItemWithItemIdentifier:@"AddTitleAiring" atIndex:0+indexoffset];
        }
        else {
            indexoffset = -1;
        }
        [_toolbar insertItemWithItemIdentifier:@"airingdayselect" atIndex:1+indexoffset];
        [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:2+indexoffset];
    }
}
#pragma mark -
#pragma mark Search View
- (void)populatesearchtb:(id)json type:(int)type{
    if (type == 0){
        NSMutableArray * a = (_searchview.searcharraycontroller).content;
        [a removeAllObjects];
        if ([json isKindOfClass:[NSArray class]]){
           // Valid Search Results, populate
            [_searchview.searcharraycontroller addObjects:json];
        }
        [_searchview.searchtb reloadData];
        [_searchview.searchtb deselectAll:self];
    }
    else {
        NSMutableArray * a = (_searchview.mangasearcharraycontroller).content;
        [a removeAllObjects];
        if ([json isKindOfClass:[NSArray class]]){
            // Valid Search Results, populate
            [_searchview.mangasearcharraycontroller addObjects:json];
        }
        [_searchview.mangasearchtb reloadData];
        [_searchview.mangasearchtb deselectAll:self];
    }
}

- (void)clearsearchtb{
    [_searchview clearsearchtb];
}

- (IBAction)showadvancedpopover:(id)sender {
    NSButton * btn = (NSButton *)sender;
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    NSString *identifier = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];
    if ([identifier isEqualToString:@"search"]){
        [_advancedsearchcontroller setSearchType:0];
    }
    else if ([identifier isEqualToString:@"mangasearch"]){
        [_advancedsearchcontroller setSearchType:1];
    }
    // Show Share Box
    [_advsearchpopover showRelativeToRect:btn.bounds ofView:btn preferredEdge:NSMaxYEdge];
}
#pragma mark Anime List
- (IBAction)refreshlist:(id)sender {
    [_appdel.servicemenucontrol enableservicemenuitems:NO];
    switch ([listservice getCurrentServiceID]) {
        case 1: {
            [self performlistRefresh];
            break;
        }
        case 2: {
            [Kitsu getUserRatingType:^(int scoretype) {
                [NSUserDefaults.standardUserDefaults setInteger:scoretype forKey:@"kitsu-ratingsystem"];
                [self performlistRefresh];
            } error:^(NSError *error) {
                NSLog(@"Error loading list: %@", error.localizedDescription);
                [_appdel.servicemenucontrol enableservicemenuitems:YES];
            }];
        }
        case 3: {
            [AniList getUserRatingType:^(NSString *scoretype) {
                [NSUserDefaults.standardUserDefaults setValue:scoretype forKey:@"anilist-scoreformat"];
                [self performlistRefresh];
            } error:^(NSError *error) {
                NSLog(@"Error loading list: %@", error.localizedDescription);
            }];
        }
        default: {
            break;
        }
    }
}
- (void)performlistRefresh {
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    NSString *identifier = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];
    if ([identifier isEqualToString:@"animelist"]){
        _refreshanime = true;
        [self showProgressWheel:false];
        [self loadlist:@(true) type:0];
    }
    else if ([identifier isEqualToString:@"mangalist"]){
        _refreshmanga = true;
        [self showProgressWheel:false];
        [self loadlist:@(true) type:1];
    }
    else if ([identifier isEqualToString:@"history"]){
        [self loadlist:@(true) type:2];
        [_appdel.servicemenucontrol enableservicemenuitems:YES];
    }
    else if ([identifier isEqualToString:@"seasons"]){
        [_seasonview performseasonindexretrieval];
        [_appdel.servicemenucontrol enableservicemenuitems:YES];
    }
    else if ([identifier isEqualToString:@"airing"]){
        [_airingview loadAiring:@(true)];
        [_appdel.servicemenucontrol enableservicemenuitems:YES];
    }
}
- (void)loadlist:(NSNumber *)refresh type:(int)type {
    if ([listservice checkAccountForCurrentService]) {
        id list;
        bool refreshlist = refresh.boolValue;
        bool exists = false;
        switch (type) {
            case 0:
                exists = [Utility checkifFileExists:[listservice retrieveListFileName:0] appendPath:@""];
                if (exists && !refreshlist){
                    list = [Utility loadJSON:[listservice retrieveListFileName:0] appendpath:@""];
                    [_listview populateList:list type:0];
                    [self refreshStatistics];
                    _refreshanime = false;
                    [self enableservicemenuitems];
                    return;
                }
                else if (!exists || refreshlist){
                    [listservice retrieveList:[listservice getCurrentServiceUsername] listType:MALAnime completion:^(id responseObject){
                        [_listview populateList:[Utility saveJSON:responseObject withFilename:[listservice retrieveListFileName:0] appendpath:@"" replace:TRUE] type:0];
                        [self refreshStatistics];
                        _refreshanime = false;
                        [self enableservicemenuitems];
                    }error:^(NSError *error){
                        NSLog(@"%@", error.userInfo);
                        _refreshanime = false;
                        [self enableservicemenuitems];
                    }];
                }
                break;
            case 1:
                exists = [Utility checkifFileExists:[listservice retrieveListFileName:1] appendPath:@""];
                list = [Utility loadJSON:[listservice retrieveListFileName:1] appendpath:@""];
                if (exists && !refreshlist){
                    [_listview populateList:list type:1];
                    [self refreshStatistics];
                    _refreshmanga = false;
                    [self enableservicemenuitems];
                    return;
                }
                else if (!exists || refreshlist){
                    [listservice retrieveList:[listservice getCurrentServiceUsername] listType:MALManga completion:^(id responseObject){
                        [_listview populateList:[Utility saveJSON:responseObject withFilename:[listservice retrieveListFileName:1] appendpath:@"" replace:TRUE] type:1];
                        [self refreshStatistics];
                        _refreshmanga = false;
                        [self enableservicemenuitems];
                    }error:^(NSError *error){
                        NSLog(@"%@", error.userInfo);
                        _refreshmanga = false;
                        [self enableservicemenuitems];
                    }];
                }
                break;
            case 2:
                    [_historyview loadHistory:refresh];
                    break;
            default:
                    break;
        }
    }
}
- (void)refreshStatistics {
    ListStatistics *ls = _appdel.liststatswindow;
    if (ls){
        [ls populateValues];
    }
}
- (void)clearlist:(int)service {
    [Utility deleteFile:[listservice retrieveListFileName:0 withServiceID:service] appendpath:@""];
    [Utility deleteFile:[listservice retrieveListFileName:1 withServiceID:service] appendpath:@""];
    [_historyview clearHistory:service];
    if ([listservice getCurrentServiceID] == service) {
        //Clears List
        NSMutableArray * a = [_listview.animelistarraycontroller mutableArrayValueForKey:@"content"];
        [a removeAllObjects];
        [_listview.animelisttb reloadData];
        [_listview.animelisttb deselectAll:self];
         a = [_listview.mangalistarraycontroller mutableArrayValueForKey:@"content"];
        [a removeAllObjects];
        [_listview.mangalisttb reloadData];
        [_listview.mangalisttb deselectAll:self];
    }

}
- (void)changeservice:(int)oldserviceid {
    //Clears List and refreshes UI for service change
    NSMutableArray * a = [_listview.animelistarraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_listview.animelisttb reloadData];
    [_listview.animelisttb deselectAll:self];
    a = [_listview.mangalistarraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_listview.mangalisttb reloadData];
    [_listview.mangalisttb deselectAll:self];
    [_historyview clearHistory];
    [self loadtitleinfoWithDifferentService:oldserviceid];
    [_searchview clearallsearch];
    [self generateSourceList];
    [self loadmainview];
    [self refreshloginlabel];
    [self initallistload];
    NSNumber * autorefreshlist = [[NSUserDefaults standardUserDefaults] valueForKey:@"refreshautomatically"];
    if (autorefreshlist.boolValue){
        [self stopTimer];
        [self startTimer];
    }
}
- (void)loadtitleinfoWithDifferentService:(int)oldserviceid {
    int currentservice = [listservice getCurrentServiceID];
    if (_infoview.selectedid > 0) {
        int tmpselectedid = _infoview.selectedid;
        _infoview.selectedid = 0;
        _progressindicator.hidden = NO;
        [_progressindicator startAnimation:self];
        switch (oldserviceid) {
            case 1: {
                switch (currentservice) {
                    case 2: {
                        // MAL > Kitsu Title ID
                        [TitleIdConverter getKitsuIDFromMALId:tmpselectedid withType:_infoview.type completionHandler:^(int kitsuid) {
                            [self loadinfo:@(kitsuid) type:_infoview.type changeView:NO];
                        } error:^(NSError *error) {
                            [self resetTitleInfoView];
                        }];
                        break;
                    }
                    case 3: {
                        [TitleIdConverter getAniIDFromMALListID:tmpselectedid withTitle:_infoview.selectedinfo[@"title"] titletype:_infoview.selectedinfo[@"type"] withType:_infoview.type completionHandler:^(int anilistid) {
                            [self loadinfo:@(anilistid) type:_infoview.type changeView:NO];
                        } error:^(NSError *error) {
                            [self resetTitleInfoView];
                        }];
                        break;
                    }
                    default:
                        [self resetTitleInfoView];
                        break;
                }
                break;
            }
            case 2: {
                if (currentservice == 3 ) {
                    [TitleIdConverter getAniIDFromKitsuID:tmpselectedid withTitle:_infoview.selectedinfo[@"title"] titletype:_infoview.selectedinfo[@"type"] withType:_infoview.type completionHandler:^(int anilistid) {
                        [self loadinfo:@(anilistid) type:_infoview.type changeView:NO];
                    } error:^(NSError *error) {
                        [self resetTitleInfoView];
                    }];
                }
                else if (_infoview.getSelectedInfo[@"mappings"]) {
                    NSDictionary *mappings = _infoview.getSelectedInfo[@"mappings"];
                    switch (currentservice) {
                        case 1: { // MyAnimeList > "myanimelist/anime" for anime or "myanimelist/manga" for manga
                            if (_infoview.type == 0 && mappings[@"myanimelist/anime"]) {
                                 [self loadinfo:mappings[@"myanimelist/anime"] type:_infoview.type  changeView:NO];
                            }
                            else if (_infoview.type == 1 && mappings[@"myanimelist/manga"]) {
                                [self loadinfo:mappings[@"myanimelist/manga"] type:_infoview.type  changeView:NO];
                            }
                            else {
                                [self resetTitleInfoView];
                            }
                            break;
                        }
                        default:
                            break;
                    }
                }
                else {
                    [self resetTitleInfoView];
                }
                break;
            }
            case 3: {
                switch (currentservice) {
                    case 1: {
                        [TitleIdConverter getMALIDFromAniListID:tmpselectedid withTitle:_selecteditem[@"title"] titletype:_selecteditem[@"type"] withType:_infoview.type completionHandler:^(int malid) {
                            [self loadinfo:@(malid) type:_infoview.type changeView:NO];
                        } error:^(NSError *error) {
                            [self resetTitleInfoView];
                        }];
                        break;
                    }
                    case 2: {
                        [TitleIdConverter getKitsuIdFromAniID:tmpselectedid withTitle:_selecteditem[@"title"] titletype:_selecteditem[@"type"] withType:_infoview.type completionHandler:^(int kitsuid) {
                            [self loadinfo:@(kitsuid) type:_infoview.type changeView:NO];
                        } error:^(NSError *error) {
                            [self resetTitleInfoView];
                        }];
                        break;
                    }
                    default:
                        [self resetTitleInfoView];
                        break;
                }
                break;
            }
            default:
                break;
        }
    }
}
- (void)initallistload {
    NSNumber *shouldrefresh = [[NSUserDefaults standardUserDefaults] valueForKey:@"refreshlistonstart"];
    if (shouldrefresh && [listservice checkAccountForCurrentService]) {
        [_appdel.servicemenucontrol enableservicemenuitems:NO];
        [self showProgressWheel:NO];
    }
    [self loadlist:shouldrefresh type:0];
    [self loadlist:shouldrefresh type:1];
    if ([listservice getCurrentServiceID] == 1) {
        [self loadlist:shouldrefresh type:2];
    }
}
#pragma mark Edit Popover
- (IBAction)performmodifytitle:(id)sender {
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    NSString *identifier = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];
    if ([identifier isEqualToString:@"animelist"]){
           NSDictionary *d = (_listview.animelistarraycontroller).selectedObjects[0];
        [_editviewcontroller showEditPopover:d showRelativeToRec:[_listview.animelisttb frameOfCellAtColumn:0 row:(_listview.animelisttb).selectedRow] ofView:_listview.animelisttb preferredEdge:0 type:0];
    }
    if ([identifier isEqualToString:@"mangalist"]){
        NSDictionary *d = (_listview.mangalistarraycontroller).selectedObjects[0];
        [_editviewcontroller showEditPopover:d showRelativeToRec:[_listview.mangalisttb frameOfCellAtColumn:0 row:(_listview.mangalisttb).selectedRow] ofView:_listview.mangalisttb preferredEdge:0 type:1];
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        [_editviewcontroller showEditPopover:[self retreveentryfromlist:_infoview.selectedid type:_infoview.type] showRelativeToRec:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge type:_infoview.type];
    }
}

#pragma mark Add Title

- (IBAction)showaddpopover:(id)sender {
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    NSString *identifier = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];
    if ([identifier isEqualToString:@"search"]){
        NSDictionary *d = (_searchview.searcharraycontroller).selectedObjects[0];
        [_addtitlecontroller showAddPopover:d showRelativeToRec:[_searchview.searchtb frameOfCellAtColumn:0 row:(_searchview.searchtb).selectedRow] ofView:_searchview.searchtb preferredEdge:0 type:AnimeSearch];
    }
    if ([identifier isEqualToString:@"mangasearch"]){
        NSDictionary *d = (_searchview.mangasearcharraycontroller).selectedObjects[0];
        [_addtitlecontroller showAddPopover:d showRelativeToRec:[_searchview.mangasearchtb frameOfCellAtColumn:0 row:(_searchview.mangasearchtb).selectedRow] ofView:_searchview.mangasearchtb preferredEdge:0 type:MangaSearch];
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        [_addtitlecontroller showAddPopover:_infoview.selectedinfo showRelativeToRec:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge type:_infoview.type];
    }
    else if ([identifier isEqualToString:@"seasons"]){
        NSDictionary *d = (_seasonview.seasonarraycontroller).selectedObjects[0];
        d = d[@"id"];
        switch ([listservice getCurrentServiceID]) {
            case 1: {
                [listservice retrieveTitleInfo:[NSString stringWithFormat:@"%@",d[@"id"]].intValue withType:MALAnime useAccount:NO completion:^(id responseObject){
                    [_addtitlecontroller showAddPopover:(NSDictionary *)responseObject showRelativeToRec:[_seasonview.seasontableview frameOfCellAtColumn:0 row:(_seasonview.seasontableview).selectedRow] ofView:_seasonview.seasontableview preferredEdge:0 type:0];
                }error:^(NSError *error){
                    NSLog(@"Error: %@", error);
                }];
                break;
            }
            case 2: {
                [TitleIdConverter getKitsuIDFromMALId:[NSString stringWithFormat:@"%@",d[@"id"]].intValue withType:KitsuAnime completionHandler:^(int kitsuid) {
                    [listservice retrieveTitleInfo:kitsuid withType:KitsuAnime useAccount:NO completion:^(id responseObject){
                        [_addtitlecontroller showAddPopover:(NSDictionary *)responseObject showRelativeToRec:[_seasonview.seasontableview frameOfCellAtColumn:0 row:(_seasonview.seasontableview).selectedRow] ofView:_seasonview.seasontableview preferredEdge:0 type:0];
                    }error:^(NSError *error){
                        NSLog(@"Error: %@", error);
                    }];
                } error:^(NSError *error) {}];
                break;
            }
            default:
                break;
        }
    }
    if ([identifier isEqualToString:@"airing"]){
        NSDictionary *d = (_airingview.airingarraycontroller).selectedObjects[0];
        switch ([listservice getCurrentServiceID]) {
            case 1: {
                [_addtitlecontroller showAddPopover:d showRelativeToRec:[_airingview.airingtb frameOfCellAtColumn:0 row:(_airingview.airingtb).selectedRow] ofView:_airingview.airingtb preferredEdge:0 type:0];
                break;
            }
            case 2: {
                [TitleIdConverter getKitsuIDFromMALId:[NSString stringWithFormat:@"%@",d[@"id"]].intValue withType:KitsuAnime completionHandler:^(int kitsuid) {
                    [listservice retrieveTitleInfo:kitsuid withType:KitsuAnime useAccount:NO completion:^(id responseObject){
                        [_addtitlecontroller showAddPopover:(NSDictionary *)responseObject showRelativeToRec:[_airingview.airingtb frameOfCellAtColumn:0 row:(_airingview.airingtb).selectedRow] ofView:_airingview.airingtb preferredEdge:0 type:0];
                    }error:^(NSError *error){
                        NSLog(@"Error: %@", error);
                    }];
                } error:^(NSError *error) {}];
                break;
            }
            default:
                 break;
        }
    }

}

#pragma mark Title Information View
- (void)loadinfo:(NSNumber *) idnum type:(int)type changeView:(bool)changeview {
    int previd;
    int prevtype;
    if (idnum.intValue == _infoview.selectedid && type == _infoview.type) {
        [self changetoinfoview];
        return;
    }
    else {
        previd = _infoview.selectedid;
        prevtype = _infoview.type;
        _infoview.selectedid = 0;
        [self changetoinfoview];
    }
    _noinfoview.hidden = YES;
    _progressindicator.hidden = NO;
    [_progressindicator startAnimation:nil];
    [listservice retrieveTitleInfo:idnum.intValue withType:type useAccount:NO completion:^(id responseObject){
        _infoview.selectedid = idnum.intValue;
        _infoview.type = type;
        [_progressindicator stopAnimation:nil];
        if (type == MALAnime) {
            [_infoview populateAnimeInfoView:responseObject];
        }
        else {
            [_infoview populateMangaInfoView:responseObject];
        }
    }error:^(NSError *error){
        NSLog(@"Error: %@", error);
        [_progressindicator stopAnimation:nil];
        _infoview.selectedid = previd;
        _infoview.type = prevtype;
        if (_infoview.selectedid == 0) {
            _noinfoview.hidden = NO;
            _progressindicator.hidden = YES;
        }
        [self loadmainview];
    }];
}

- (void)changetoinfoview {
    int currentservice = [listservice getCurrentServiceID];
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"donated"]) {
        if (currentservice == 1) {
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:8]byExtendingSelection:false];
        }
        else {
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:7]byExtendingSelection:false];
        }
    }
    else {
        if (currentservice == 1) {
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:6]byExtendingSelection:false];
        }
        else {
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:5]byExtendingSelection:false];
        }
    }
    [self loadmainview];
}
- (void)resetTitleInfoView {
    _infoview.selectedid = 0;
    _noinfoview.hidden = NO;
    _progressindicator.hidden = YES;
    _infoview.selectedinfo = nil;
}
#pragma mark helpers
- (bool)checkiftitleisonlist:(int)idnum type:(int)type{
    if (type == 0){
        NSArray * list = (_listview.animelistarraycontroller).content;
        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
        if (list.count > 0){
            return true;
        }
    }
    else {
        NSArray * list = (_listview.mangalistarraycontroller).content;
        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
        if (list.count > 0){
            return true;
        }
    }
    return false;
}

- (id)retreveentryfromlist:(int)idnum type:(int)type{
    if (type == 0){
        NSArray * list = (_listview.animelistarraycontroller).content;
        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
        if (list.count > 0){
            return list[0];
        }
        else {
             return nil;
        }
    }
    else {
        NSArray * list = (_listview.mangalistarraycontroller).content;
        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
        if (list.count > 0){
            return list[0];
        }
        else {
            return nil;
        }
    }
    return nil;
}
- (void)enableservicemenuitems {
    [_appdel.servicemenucontrol enableservicemenuitems:!_refreshmanga && !_refreshanime];
    [self showProgressWheel:!_refreshmanga &&! _refreshanime];
}

- (void)showProgressWheel:(bool)hidden {
    if (hidden) {
        [_progresswheel stopAnimation:self];
        _progresswheel.hidden = YES;
    }
    else {
        if (_progresswheel.hidden) {
            [_progresswheel startAnimation:self];
        }
        _progresswheel.hidden = NO;
    }
}
@end

