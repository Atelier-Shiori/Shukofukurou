//
//  MainWindow.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/02/28.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "MainWindow.h"
#import "listservice.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "NSTextFieldNumber.h"
#import "MSWeakTimer.h"
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
#import "TrendingView.h"
#import "NSTableViewAction.h"
#import "servicemenucontroller.h"
#import "AtarashiiListCoreData.h"
#import "TitleInfoCache.h"
#import "TitleCollectionView.h"
#import "HistoryManager.h"

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

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)awakeFromNib
{
    // Register queue
    _privateQueue = dispatch_queue_create("moe.ateliershiori.Shukofukurou", DISPATCH_QUEUE_CONCURRENT);
    // Add blank subview to mainview
    [_mainview addSubview:[NSView new]];
    // Insert code here to initialize your application
    // Fix template images
    // There is a bug where template images are not made even if they are set in XCAssets
    NSArray *images = @[@"animeinfo", @"delete", @"Edit", @"Info", @"library", @"search", @"seasons", @"anime", @"manga", @"history", @"airing", @"reviews", @"newmessage", @"reply", @"cast", @"person", @"stats", @"safari", @"advsearch", @"send", @"increment", @"customlists", @"editcustomlists", @"trending", @"episodes", @"cleanhistory"];
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
    (_trendingview.view).autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
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
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recieveNotification:) name:@"TitleCacheToggled" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recieveNotification:) name:@"AppAppearenceChanged" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recieveNotification:) name:@"LoadTitleInfo" object:nil];
}

- (void)recieveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"TitleCacheToggled"]) {
        [self createToolbar];
    }
    else if ([notification.name isEqualToString:@"AppAppearenceChanged"]) {
        [self setAppearance];
    }
    else if ([notification.name isEqualToString:@"LoadTitleInfo"]) {
        if ([notification.object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *notifyobject = notification.object;
            [self loadinfo:notifyobject[@"id"] type:((NSNumber *)notifyobject[@"type"]).intValue changeView:YES forcerefresh:NO];
            [self.window makeKeyAndOrderFront:self];
        }
    }
}

- (void)generateSourceList {
    self.sourceListItems = [[NSMutableArray alloc] init];
    //Library Group
    PXSourceListItem *libraryItem = [PXSourceListItem itemWithTitle:@"LIBRARY" identifier:@"library"];
    PXSourceListItem *animelistItem = [PXSourceListItem itemWithTitle:@"Anime List" identifier:@"animelist"];
    animelistItem.icon = [NSImage imageNamed:@"library"];
    PXSourceListItem *historyItem = [PXSourceListItem itemWithTitle:@"History" identifier:@"history"];
    historyItem.icon = [NSImage imageNamed:@"history"];
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"donated"]) {
        PXSourceListItem *mangalistItem = [PXSourceListItem itemWithTitle:@"Manga List" identifier:@"mangalist"];
        mangalistItem.icon = [NSImage imageNamed:@"library"];
        libraryItem.children = @[animelistItem, mangalistItem, historyItem];
    }
    else {
        libraryItem.children = @[animelistItem, historyItem];
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
    PXSourceListItem *trendingItem = [PXSourceListItem itemWithTitle:@"Trending" identifier:@"trending"];
    trendingItem.icon = [NSImage imageNamed:@"trending"];
    discoverItem.children = @[titleinfoItem,seasonsItem, airingItem, trendingItem];
    
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
    switch ([listservice.sharedInstance getCurrentServiceID]) {
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
        case 3: {
            if (type == AnimeType){
                shareItems = @[[NSString stringWithFormat:@"Check out %@ out on AniList", d[@"title"]], [NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/anime/%@", d[@"id"]]]];
            }
            else {
                shareItems = @[[NSString stringWithFormat:@"Check out %@ out on AniList", d[@"title"]], [NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/manga/%@", d[@"id"]]]];
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
    if ([listservice.sharedInstance checkAccountForCurrentService]) {
        switch ([listservice.sharedInstance getCurrentServiceID]) {
            case 1: {
                [self performtimerlistrefresh];
                break;
            }
            case 2: {
                [listservice.sharedInstance.kitsuManager getUserRatingType:^(int scoretype) {
                    [NSUserDefaults.standardUserDefaults setInteger:scoretype forKey:@"kitsu-ratingsystem"];
                    [self performtimerlistrefresh];
                } error:^(NSError *error) {
                    NSLog(@"Error loading list: %@", error.localizedDescription);
                }];
            }
            case 3: {
                [listservice.sharedInstance.anilistManager getUserRatingType:^(NSString *scoretype) {
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
    [_airingview fetchnewAiringData];
}
- (void)performtimerlistrefresh {
    [_appdel.servicemenucontrol enableservicemenuitems:NO];
    [self showProgressWheel:NO];
    [self loadlist:@(true) type:0];
    [self loadlist:@(true) type:1];
    [self loadlist:@(true) type:2];
}
- (void)windowWillClose:(NSNotification *)notification{
    [[NSApplication sharedApplication] terminate:nil];
}

- (void)setAppearance {
    if (@available(macOS 10.14, *)) {
        // Do not set appearence on macOS Versions >= 10.14
        return;
    }
    else {
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
        _notloggedin.view.appearance = [NSAppearance appearanceNamed:appearancename];
        _listview.filterbarview.appearance = [NSAppearance appearanceNamed:appearancename];
        _listview.filterbarview2.appearance = [NSAppearance appearanceNamed:appearancename];
        _advsearchpopover.appearance = [NSAppearance appearanceNamed:appearancename];
        _minieditpopover.appearance = [NSAppearance appearanceNamed:appearancename];
        _addpopover.appearance = [NSAppearance appearanceNamed:appearancename];
        _infoview.othertitlepopover.appearance = [NSAppearance appearanceNamed:appearancename];
        _listview.customlistpopover.appearance = [NSAppearance appearanceNamed:appearancename];
        _listview.customlistpopoverviewcontroller.view.appearance = [NSAppearance appearanceNamed:appearancename];
        [_w setFrame:_w.frame display:false];
    }
}

- (void)refreshloginlabel{
    if ([listservice.sharedInstance checkAccountForCurrentService]) {
        _loggedinuser.stringValue = [NSString stringWithFormat:@"Logged in as %@ (%@)",[listservice.sharedInstance getCurrentServiceUsername], [listservice.sharedInstance currentservicename]];
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
        CGFloat dividerPos = NSWidth((splitView.subviews[0]).frame);
        CGFloat width = NSWidth(splitView.frame);
        
        if (dividerPos < 0)
            dividerPos = 0;
        if (width - dividerPos < 558 + splitView.dividerThickness)
            dividerPos = width - (558 + splitView.dividerThickness);
        
        [splitView adjustSubviews];
        [splitView setPosition:dividerPos ofDividerAtIndex:0];
    }
}

- (CGFloat) splitView:(NSSplitView*) splitView constrainSplitPosition:(CGFloat) proposedPosition ofSubviewAt:(NSInteger) dividerIndex
{
    if (splitView == _splitview)
    {
        CGFloat width = NSWidth(splitView.frame);
        
        if (ABS(137 - proposedPosition) <= 8)
            proposedPosition = 150;
        if (proposedPosition < 0)
            proposedPosition = 0;
        if (width - proposedPosition < 558 + splitView.dividerThickness)
            proposedPosition = width - (558 + splitView.dividerThickness);
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
    if (![listservice.sharedInstance checkAccountForCurrentService] && [listservice.sharedInstance getCurrentServiceID] == 1) {
        [self loadNotLoggedIn];
        [self createToolbar];
        return;
    }
        if ([identifier isEqualToString:@"animelist"]){
            if ([listservice.sharedInstance checkAccountForCurrentService]) {
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
                if ([listservice.sharedInstance checkAccountForCurrentService]) {
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
            if ([listservice.sharedInstance checkAccountForCurrentService]) {
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
            if (_infoview.selectedid > 0 && !_infoview.forcerefresh){
                [self replaceMainViewWithView:_infoview.view];
            }
            else {
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
        else if ([identifier isEqualToString:@"trending"]){
            [self replaceMainViewWithView:_trendingview.view];
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
    if (![listservice.sharedInstance checkAccountForCurrentService] && [listservice.sharedInstance getCurrentServiceID] == 1) {
        return;
    }
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    NSString *identifier = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];
    int indexoffset = 0;
    if ([identifier isEqualToString:@"animelist"]){
        if ([listservice.sharedInstance checkAccountForCurrentService]) {
            [_toolbar insertItemWithItemIdentifier:@"editList" atIndex:0];
            [_toolbar insertItemWithItemIdentifier:@"DeleteTitle" atIndex:1];
            [_toolbar insertItemWithItemIdentifier:@"incrementprogress" atIndex:2];
            if ([listservice.sharedInstance getCurrentServiceID] == 3 && [NSUserDefaults.standardUserDefaults boolForKey:@"donated"]) {
                [_toolbar insertItemWithItemIdentifier:@"editCustomLists" atIndex:3];
            }
            else {
                indexoffset = -1;
            }
            [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:4+indexoffset];
            [_toolbar insertItemWithItemIdentifier:@"viewtitleinfo" atIndex:5+indexoffset];
            [_toolbar insertItemWithItemIdentifier:@"ShareList" atIndex:6+indexoffset];
            [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:7+indexoffset];
            [_toolbar insertItemWithItemIdentifier:@"filter" atIndex:8+indexoffset];
        }
    }
    else if ([identifier isEqualToString:@"mangalist"]){
        if (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"]).boolValue) {
            if ([listservice.sharedInstance checkAccountForCurrentService]) {
                [_toolbar insertItemWithItemIdentifier:@"editList" atIndex:0];
                [_toolbar insertItemWithItemIdentifier:@"DeleteTitle" atIndex:1];
                [_toolbar insertItemWithItemIdentifier:@"incrementprogress" atIndex:2];
                if ([listservice.sharedInstance getCurrentServiceID] == 3) {
                    [_toolbar insertItemWithItemIdentifier:@"editCustomLists" atIndex:3];
                }
                else {
                    indexoffset = -1;
                }
                [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:4+indexoffset];
                [_toolbar insertItemWithItemIdentifier:@"viewtitleinfo" atIndex:5+indexoffset];
                [_toolbar insertItemWithItemIdentifier:@"ShareList" atIndex:6+indexoffset];
                [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:7+indexoffset];
                [_toolbar insertItemWithItemIdentifier:@"filter" atIndex:8+indexoffset];
            }
        }
    }
    else if ([identifier isEqualToString:@"history"]){
        if ([listservice.sharedInstance checkAccountForCurrentService]) {
            //[_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:0];
            if (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"]).boolValue) {
                [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem"  atIndex:0];
                [_toolbar insertItemWithItemIdentifier:@"historyselector" atIndex:1];
                [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem"  atIndex:2];
                [_toolbar insertItemWithItemIdentifier:@"ClearHistory" atIndex:3];
            }
        }
        
    }
    else if ([identifier isEqualToString:@"search"]){
        if ([listservice.sharedInstance checkAccountForCurrentService]) {
            [_toolbar insertItemWithItemIdentifier:@"AddTitleSearch" atIndex:0];
        }
        else {
            indexoffset = -1;
        }
        [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:1+indexoffset];
        if ([listservice.sharedInstance getCurrentServiceID] == 1) {
            [_toolbar insertItemWithItemIdentifier:@"moreresults" atIndex:2+indexoffset];
            [_toolbar insertItemWithItemIdentifier:@"search" atIndex:3+indexoffset];
        }
        else {
            [_toolbar insertItemWithItemIdentifier:@"nadvsearch" atIndex:2+indexoffset];
            [_toolbar insertItemWithItemIdentifier:@"moreresults" atIndex:3+indexoffset];
            [_toolbar insertItemWithItemIdentifier:@"search" atIndex:4+indexoffset];
        }
    }
    else if ([identifier isEqualToString:@"mangasearch"]){
        if (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"]).boolValue) {
            if ([listservice.sharedInstance checkAccountForCurrentService]) {
                [_toolbar insertItemWithItemIdentifier:@"AddTitleSearch" atIndex:0];
            }
            else {
                indexoffset = -1;
            }
            [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:1+indexoffset];
            if ([listservice.sharedInstance getCurrentServiceID] == 1) {
                [_toolbar insertItemWithItemIdentifier:@"moreresults" atIndex:2+indexoffset];
                [_toolbar insertItemWithItemIdentifier:@"search" atIndex:3+indexoffset];
            }
            else {
                [_toolbar insertItemWithItemIdentifier:@"nadvsearch" atIndex:2+indexoffset];
                [_toolbar insertItemWithItemIdentifier:@"moreresults" atIndex:3+indexoffset];
                [_toolbar insertItemWithItemIdentifier:@"search" atIndex:4+indexoffset];
            }
        }
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        if (_infoview.selectedid > 0){
            if ([listservice.sharedInstance checkAccountForCurrentService]) {
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
            bool showrefresh = [NSUserDefaults.standardUserDefaults boolForKey:@"cachetitleinfo"];
            [_toolbar insertItemWithItemIdentifier:@"viewonmal" atIndex:1+indexoffset];
            [_toolbar insertItemWithItemIdentifier:@"viewreviews" atIndex:2+indexoffset];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"donated"]) {
                int currentservice = [listservice.sharedInstance getCurrentServiceID];
                if (currentservice == 3) {
                    [_toolbar insertItemWithItemIdentifier:@"viewpeople" atIndex:3+indexoffset];
                }
                else if (currentservice == 2 && _infoview.type == MALAnime){
                    [_toolbar insertItemWithItemIdentifier:@"viewepisodes" atIndex:3+indexoffset];
                }
                else {
                    indexoffset = -1;
                }
                [_toolbar insertItemWithItemIdentifier:@"ShareInfo" atIndex:4+indexoffset];
                [_toolbar insertItemWithItemIdentifier:@"web" atIndex:5+indexoffset];
                if (showrefresh) {
                    [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:6+indexoffset];
                }
            }
            else {
                [_toolbar insertItemWithItemIdentifier:@"ShareInfo" atIndex:3+indexoffset];
                [_toolbar insertItemWithItemIdentifier:@"web" atIndex:4+indexoffset];
                if (showrefresh) {
                    [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:5+indexoffset];
                }
            }
        }
    }
    else if ([identifier isEqualToString:@"seasons"]){
        if ([listservice.sharedInstance checkAccountForCurrentService]) {
            [_toolbar insertItemWithItemIdentifier:@"AddTitleSeason" atIndex:0+indexoffset];
        }
        else {
            indexoffset = -1;
        }
        [_toolbar insertItemWithItemIdentifier:@"yearselect" atIndex:1+indexoffset];
        [_toolbar insertItemWithItemIdentifier:@"seasonselect" atIndex:2+indexoffset];
        [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:3+indexoffset];
    }
    else if ([identifier isEqualToString:@"airing"]){
        if ([listservice.sharedInstance checkAccountForCurrentService]) {
            [_toolbar insertItemWithItemIdentifier:@"AddTitleAiring" atIndex:0+indexoffset];
        }
        else {
            indexoffset = -1;
        }
        [_toolbar insertItemWithItemIdentifier:@"airingdayselect" atIndex:1+indexoffset];
        [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:2+indexoffset];
    }
    else if ([identifier isEqualToString:@"trending"]) {
        [_toolbar insertItemWithItemIdentifier:@"AddTitleTrending" atIndex:0];
        [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:1];
        if (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"]).boolValue) {
            [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:2];
            [_toolbar insertItemWithItemIdentifier:@"trendtype" atIndex:3];
            [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:4];
        }
    }
}
#pragma mark -
#pragma mark Search View
- (void)populatesearchtb:(id)json type:(int)type append:(bool)append {
    if (type == 0){
        if (!append) {
            NSMutableArray * a = (_searchview.searcharraycontroller).content;
            [a removeAllObjects];
        }
        if ([json isKindOfClass:[NSArray class]]){
           // Valid Search Results, populate
            [_searchview.searcharraycontroller addObjects:json];
        }
        [_searchview.searchtb reloadData];
        [_searchview.searchtb deselectAll:self];
    }
    else {
        if (!append) {
            NSMutableArray * a = (_searchview.mangasearcharraycontroller).content;
            [a removeAllObjects];
        }
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
    [_listview setUpdatingState:true];
    switch ([listservice.sharedInstance getCurrentServiceID]) {
        case 1: {
            [self performlistRefresh];
            break;
        }
        case 2: {
            [listservice.sharedInstance.kitsuManager getUserRatingType:^(int scoretype) {
                [NSUserDefaults.standardUserDefaults setInteger:scoretype forKey:@"kitsu-ratingsystem"];
                [self performlistRefresh];
            } error:^(NSError *error) {
                NSLog(@"Error loading list: %@", error.localizedDescription);
                [_appdel.servicemenucontrol enableservicemenuitems:YES];
            }];
        }
        case 3: {
            [listservice.sharedInstance.anilistManager getUserRatingType:^(NSString *scoretype) {
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
        [_listview setUpdatingState:false];
    }
    else if ([identifier isEqualToString:@"seasons"]){
        [_appdel.servicemenucontrol enableservicemenuitems:NO];
        [_seasonview performreload:YES completion:^(bool success) {
            [_appdel.servicemenucontrol enableservicemenuitems:YES];
        }];
    }
    else if ([identifier isEqualToString:@"airing"]){
        [_airingview loadAiring:@(true)];
        [_appdel.servicemenucontrol enableservicemenuitems:YES];
        [_listview setUpdatingState:false];
    }
    else if ([identifier isEqualToString:@"titleinfo"]) {
        [self loadinfo:@(_infoview.selectedid) type:_infoview.type changeView:NO forcerefresh:YES];
        [self loadmainview];
        [_listview setUpdatingState:false];
    }
    else if ([identifier isEqualToString:@"trending"]) {
        [_trendingview refresh];
    }
}
- (void)loadlist:(NSNumber *)refresh type:(int)type {
    if ([listservice.sharedInstance checkAccountForCurrentService]) {
        id list;
        bool refreshlist = refresh.boolValue;
        bool exists = false;
        switch (type) {
            case 0:
                exists = [self hasListEntriesWithType:0];
                if (exists && !refreshlist){
                    list = [self retrieveEntriesWithType:0];
                    [_listview populateList:list type:0];
                    [self refreshStatistics];
                    _refreshanime = false;
                    [self enableservicemenuitems];
                    return;
                }
                else if (!exists || refreshlist){
                    [_listview setUpdatingState:true];
                    [self showProgressWheel:false];
                    [_appdel.servicemenucontrol enableservicemenuitems:NO];
                    [listservice.sharedInstance retrieveownListWithType:MALAnime completion:^(id responseObject){
                        [self saveEntriesWithDictionary:responseObject withType:0];
                        [_listview populateList:[self retrieveEntriesWithType:0] type:0];
                        [self refreshStatistics];
                        _refreshanime = false;
                        [_listview setUpdatingState:false];
                        [self showProgressWheel:true];
                        [self enableservicemenuitems];
                    }error:^(NSError *error){
                        NSLog(@"%@", error.userInfo);
                        _refreshanime = false;
                        [self showProgressWheel:true];
                        [_listview setUpdatingState:false];
                        [self enableservicemenuitems];
                    }];
                }
                break;
            case 1:
                exists = [self hasListEntriesWithType:1];
                if (exists && !refreshlist){
                    list = [self retrieveEntriesWithType:1];
                    [_listview populateList:list type:1];
                    [self refreshStatistics];
                    _refreshmanga = false;
                    [self enableservicemenuitems];
                    return;
                }
                else if (!exists || refreshlist){
                    [_listview setUpdatingState:true];
                    [self showProgressWheel:false];
                    [_appdel.servicemenucontrol enableservicemenuitems:NO];
                    [listservice.sharedInstance retrieveownListWithType:MALManga completion:^(id responseObject){
                        [self saveEntriesWithDictionary:responseObject withType:1];
                        [_listview populateList:[self retrieveEntriesWithType:1] type:1];
                        [self refreshStatistics];
                        _refreshmanga = false;
                        [self showProgressWheel:true];
                        [_listview setUpdatingState:false];
                        [self enableservicemenuitems];
                    }error:^(NSError *error){
                        NSLog(@"%@", error.userInfo);
                        _refreshmanga = false;
                        [self showProgressWheel:true];
                        [_listview setUpdatingState:false];
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

- (bool)hasListEntriesWithType:(int)type {
    switch ([listservice.sharedInstance getCurrentServiceID]) {
        case 1:
            return [AtarashiiListCoreData hasListEntriesWithUserName:[listservice.sharedInstance getCurrentServiceUsername] withService:0 withType:type];
        case 2:
        case 3:
            return [AtarashiiListCoreData hasListEntriesWithUserID:[listservice.sharedInstance getCurrentUserID] withService:[listservice.sharedInstance getCurrentServiceID] withType:type];
        default:
            return false;
    }
}

- (void)saveEntriesWithDictionary:(NSDictionary *)data withType:(int)type {
    switch ([listservice.sharedInstance getCurrentServiceID]) {
        case 1:
            [AtarashiiListCoreData insertorupdateentriesWithDictionary:data withUserName:[listservice.sharedInstance getCurrentServiceUsername] withService:[listservice.sharedInstance getCurrentServiceID] withType:type];
            break;
        case 2:
        case 3:
            [AtarashiiListCoreData insertorupdateentriesWithDictionary:data withUserId:[listservice.sharedInstance getCurrentUserID] withService:[listservice.sharedInstance getCurrentServiceID] withType:type];
            break;
        default:
            break;
    }
}

- (NSDictionary *)retrieveEntriesWithType:(int)type {
    switch ([listservice.sharedInstance getCurrentServiceID]) {
        case 1:
            return [AtarashiiListCoreData retrieveEntriesForUserName:[listservice.sharedInstance getCurrentServiceUsername] withService:[listservice.sharedInstance getCurrentServiceID] withType:type];
        case 2:
        case 3:
            return [AtarashiiListCoreData retrieveEntriesForUserId:[listservice.sharedInstance getCurrentUserID] withService:[listservice.sharedInstance getCurrentServiceID] withType:type];
        default:
            return false;
    }
}

- (void)clearallentriesForService:(int)service {
    [AtarashiiListCoreData removeAllEntrieswithService:service];
}

- (void)refreshStatistics {
    ListStatistics *ls = _appdel.liststatswindow;
    if (ls){
        [ls populateValues];
    }
}
- (void)clearlist:(int)service {
    //[Utility deleteFile:[listservice.sharedInstance retrieveListFileName:0 withServiceID:service] appendpath:@""];
    //[Utility deleteFile:[listservice.sharedInstance retrieveListFileName:1 withServiceID:service] appendpath:@""];
    [self clearallentriesForService:service];
    if ([listservice.sharedInstance getCurrentServiceID] == service) {
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
    [self loadtitleinfoWithDifferentService:oldserviceid];
    [_searchview clearallsearch];
    long oldselecteditemindex = [_sourceList selectedRow];
    [self generateSourceList];
    [self selectsourcelistitemWithSelectedIndex:oldselecteditemindex withOldService:oldserviceid withNewService:[listservice.sharedInstance getCurrentServiceID]];
    [self loadmainview];
    [self refreshloginlabel];
    [self initallistload];
    [NSNotificationCenter.defaultCenter postNotificationName:@"ServiceChanged" object:nil];
    NSNumber * autorefreshlist = [[NSUserDefaults standardUserDefaults] valueForKey:@"refreshautomatically"];
    if (autorefreshlist.boolValue){
        [self stopTimer];
        [self startTimer];
    }
}

- (void)selectsourcelistitemWithSelectedIndex:(long)selectedindex withOldService:(int)oldservice withNewService:(int)newservice {
    bool donated = [NSUserDefaults.standardUserDefaults boolForKey:@"donated"];/*
    if (oldservice ==  1 && newservice > 1) {
        if (selectedindex < 4 && donated) {
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedindex] byExtendingSelection:false];
        }
        else if (selectedindex == 4 && donated) {
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:2] byExtendingSelection:false];
        }
        else if (selectedindex < 3 && !donated) {
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedindex] byExtendingSelection:false];
        }
        else if (selectedindex == 3 && !donated) {
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:2] byExtendingSelection:false];
        }
        else {
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedindex-1] byExtendingSelection:false];
        }
    }
    else if (oldservice > 1 && newservice == 1) {
        if (selectedindex < 4 && donated) {
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedindex] byExtendingSelection:false];
        }
        else if (selectedindex < 3 && !donated) {
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedindex] byExtendingSelection:false];
        }
        else {
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedindex+1] byExtendingSelection:false];
        }
    }
    else {
         [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedindex] byExtendingSelection:false];
    }*/
}

- (void)loadtitleinfoWithDifferentService:(int)oldserviceid {
    int currentservice = [listservice.sharedInstance getCurrentServiceID];
    if (_infoview.selectedid > 0) {
        int tmpselectedid = _infoview.selectedid;
        _infoview.selectedid = 0;
        _progressindicator.hidden = NO;
        [_progressindicator startAnimation:self];
        [[TitleIDMapper sharedInstance] retrieveTitleIdForService:oldserviceid withTitleId:@(tmpselectedid).stringValue withTargetServiceId:currentservice withType:_infoview.type completionHandler:^(id  _Nonnull titleid, bool success) {
            if (success && titleid && titleid != [NSNull null] && ((NSNumber *)titleid).intValue) {
                [self loadinfo:titleid type:_infoview.type changeView:NO forcerefresh:NO];
            }
            else {
                [self resetTitleInfoView];
            }
        }];
    }
}
- (void)initallistload {
    NSNumber *shouldrefresh = [[NSUserDefaults standardUserDefaults] valueForKey:@"refreshlistonstart"];
    if (shouldrefresh && [listservice.sharedInstance checkAccountForCurrentService]) {
        [_appdel.servicemenucontrol enableservicemenuitems:NO];
        [self showProgressWheel:NO];
    }
    [self loadlist:shouldrefresh type:0];
    [self loadlist:shouldrefresh type:1];
    if ([listservice.sharedInstance getCurrentServiceID] == 1) {
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
        NSIndexPath *selected = _seasonview.collectionview.selectionIndexPaths.anyObject;
        NSCollectionViewItem *collectionitem = [_seasonview.collectionview itemAtIndexPath:selected];
        NSDictionary *d = (_seasonview.seasonarraycontroller).arrangedObjects[selected.item];
        switch ([listservice.sharedInstance getCurrentServiceID]) {
            case 1: {
                [listservice.sharedInstance retrieveTitleInfo:((NSNumber *)d[@"idMal"]).intValue withType:MALAnime useAccount:NO completion:^(id responseObject){
                    [_addtitlecontroller showAddPopover:(NSDictionary *)responseObject showRelativeToRec:collectionitem.view.bounds ofView:collectionitem.view preferredEdge:NSMinYEdge type:0];
                }error:^(NSError *error){
                    NSLog(@"Error: %@", error);
                }];
                break;
            }
            case 2:
            case 3: {
                [listservice.sharedInstance retrieveTitleInfo:((NSNumber *)d[@"id"]).intValue withType:AniListAnime useAccount:NO completion:^(id responseObject) {
                    [_addtitlecontroller showAddPopover:(NSDictionary *)responseObject showRelativeToRec:collectionitem.view.bounds ofView:collectionitem.view preferredEdge:NSMinYEdge type:0];
                } error:^(NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
                break;
            }
            default:
                break;
        }
    }
    else if ([identifier isEqualToString:@"airing"]){
        NSDictionary *d = (_airingview.airingarraycontroller).selectedObjects[0];
        switch ([listservice.sharedInstance getCurrentServiceID]) {
            case 1: {
                [listservice.sharedInstance retrieveTitleInfo:((NSNumber *)d[@"idMal"]).intValue withType:MALAnime useAccount:NO completion:^(id responseObject){
                    [_addtitlecontroller showAddPopover:(NSDictionary *)responseObject showRelativeToRec:[_airingview.airingtb frameOfCellAtColumn:0 row:(_airingview.airingtb).selectedRow] ofView:_airingview.airingtb preferredEdge:0 type:0];
                }error:^(NSError *error){
                    NSLog(@"Error: %@", error);
                }];
                break;
            }
            case 2: {
                [[TitleIDMapper sharedInstance] retrieveTitleIdForService:3 withTitleId:((NSNumber *)d[@"id"]).stringValue withTargetServiceId:2 withType:0 completionHandler:^(id  _Nonnull titleid, bool success) {
                    if (success && titleid && titleid != [NSNull null] && ((NSNumber *)titleid).intValue > 0) {
                        [listservice.sharedInstance retrieveTitleInfo:((NSNumber *)titleid).intValue withType:KitsuAnime useAccount:NO completion:^(id responseObject){
                            [_addtitlecontroller showAddPopover:(NSDictionary *)responseObject showRelativeToRec:[_airingview.airingtb frameOfCellAtColumn:0 row:(_airingview.airingtb).selectedRow] ofView:_airingview.airingtb preferredEdge:0 type:0];
                        }error:^(NSError *error){
                            NSLog(@"Error: %@", error);
                        }];
                    }
                }];
                break;
            }
            case 3: {
                [_addtitlecontroller showAddPopover:d showRelativeToRec:[_airingview.airingtb frameOfCellAtColumn:0 row:(_airingview.airingtb).selectedRow] ofView:_airingview.airingtb preferredEdge:0 type:0];
                break;
            }
            default:
                break;
        }
    }
    else if ([identifier isEqualToString:@"trending"]){
        NSIndexPath *selected = _trendingview.collectionview.selectionIndexPaths.anyObject;
        NSCollectionViewItem *collectionitem = [_trendingview.collectionview itemAtIndexPath:selected];
        NSDictionary *d = _trendingview.items[_trendingview.items.allKeys[selected.section]][selected.item];
        [listservice.sharedInstance retrieveTitleInfo:((NSNumber *)d[@"id"]).intValue withType:(int)_trendingview.trendingtype.selectedSegment useAccount:NO completion:^(id responseObject) {
            [_addtitlecontroller showAddPopover:(NSDictionary *)responseObject showRelativeToRec:collectionitem.view.bounds ofView:collectionitem.view preferredEdge:NSMinYEdge type:(int)_trendingview.trendingtype.selectedSegment];
        } error:^(NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }

}

#pragma mark Title Information View
- (void)loadinfo:(NSNumber *)idnum type:(int)type changeView:(bool)changeview forcerefresh:(bool)forcerefresh {
    int previd = 0;
    int prevtype = 0;
    if (idnum.intValue == _infoview.selectedid && type == _infoview.type && !forcerefresh) {
        if (changeview) {
            [self changetoinfoview];
        }
        return;
    }
    else {
        if (!forcerefresh) {
            previd = _infoview.selectedid;
            prevtype = _infoview.type;
            _infoview.selectedid = 0;
        }
        else {
            _infoview.forcerefresh = forcerefresh;
        }
        if (changeview) {
            [self changetoinfoview];
        }
    }
    _noinfoview.hidden = YES;
    _progressindicator.hidden = NO;
    [_progressindicator startAnimation:nil];
    // Check for cache title information
    if ([self loadfromcache:idnum.intValue withType:type forcerefresh:forcerefresh ignoreLastUpdated:NO]) {
        [_appdel.servicemenucontrol enableservicemenuitems:YES];
        return;
    }
    [listservice.sharedInstance retrieveTitleInfo:idnum.intValue withType:type useAccount:NO completion:^(id responseObject){
        if ([NSUserDefaults.standardUserDefaults boolForKey:@"cachetitleinfo"]) {
            [TitleInfoCache saveTitleInfoWithTitleID:idnum.intValue  withServiceID:[listservice.sharedInstance getCurrentServiceID] withType:type withResponseObject:responseObject];
        }
        if (!_infoview.forcerefresh) {
            _infoview.selectedid = idnum.intValue;
            _infoview.type = type;
        }
        _infoview.forcerefresh = false;
        [_progressindicator stopAnimation:nil];
        if (type == MALAnime) {
            [_infoview populateAnimeInfoView:responseObject];
        }
        else {
            [_infoview populateMangaInfoView:responseObject];
        }
        [_appdel.servicemenucontrol enableservicemenuitems:YES];
        [NSNotificationCenter.defaultCenter postNotificationName:@"TitleDetailsChanged" object:nil];
    }error:^(NSError *error){
        NSLog(@"Error: %@", error);
        if (![self loadfromcache:idnum.intValue withType:type forcerefresh:forcerefresh ignoreLastUpdated:YES]) {
            // Load previous data or no title view
            _infoview.forcerefresh = false;
            [_progressindicator stopAnimation:nil];
            _infoview.selectedid = previd;
            _infoview.type = prevtype;
            if (_infoview.selectedid == 0) {
                _noinfoview.hidden = NO;
                _progressindicator.hidden = YES;
            }
        }
        [self loadmainview];
        [_appdel.servicemenucontrol enableservicemenuitems:YES];
    }];
}

- (bool)loadfromcache:(int)titleid withType:(int)type forcerefresh:(bool)forcerefresh ignoreLastUpdated:(bool)ignorelastupdated {
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"cachetitleinfo"] && !forcerefresh) {
        NSDictionary *titleinfo = [TitleInfoCache getTitleInfoWithTitleID:titleid withServiceID:[listservice.sharedInstance getCurrentServiceID] withType:type ignoreLastUpdated:ignorelastupdated];
        if (titleinfo) {
            _infoview.selectedid = titleid;
            _infoview.type = type;
            [_progressindicator stopAnimation:nil];
            if (type == MALAnime) {
                [_infoview populateAnimeInfoView:titleinfo];
            }
            else {
                [_infoview populateMangaInfoView:titleinfo];
            }
            return true;
        }
    }
    return false;
}

- (void)changetoinfoview {
    int currentservice = [listservice.sharedInstance getCurrentServiceID];
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"donated"]) {
        if (currentservice == 1) {
            //[_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:8]byExtendingSelection:false];
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:7]byExtendingSelection:false];
        }
        else {
            [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:7]byExtendingSelection:false];
        }
    }
    else {
        if (currentservice == 1) {
            //[_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:6]byExtendingSelection:false];
             [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:5]byExtendingSelection:false];
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
    [_listview setUpdatingState:_refreshmanga && _refreshanime];
    [self showProgressWheel:!_refreshmanga &&! _refreshanime];
}

- (void)showProgressWheel:(bool)hidden {
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
}
@end

