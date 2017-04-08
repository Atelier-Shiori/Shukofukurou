//
//  MainWindow.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/02/28.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import "MainWindow.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "NSTextFieldNumber.h"
#import "MSWeakTimer.h"
#import "Keychain.h"
#import "AddTitle.h"
#import "EditTitle.h"
#import "ListView.h"
#import "NotLoggedIn.h"
#import "SearchView.h"
#import "InfoView.h"
#import "SeasonView.h"
#import "AdvancedSearch.h"
#import "HistoryView.h"
#import "AiringView.h"
#import "NSTableViewAction.h"

@interface MainWindow ()
@property (strong, nonatomic) NSMutableArray *sourceListItems;
@end

@implementation MainWindow

- (id)init{
    self = [super initWithWindowNibName:@"MainWindow"];
    if(!self)
        return nil;
    return self;
}
- (void)awakeFromNib
{
    // Register queue
    _privateQueue = dispatch_queue_create("moe.ateliershiori.MAL Library", DISPATCH_QUEUE_CONCURRENT);
    
    // Insert code here to initialize your application
    // Fix template images
    // There is a bug where template images are not made even if they are set in XCAssets
    NSArray *images = @[@"animeinfo", @"delete", @"Edit", @"Info", @"library", @"search", @"seasons", @"anime", @"manga", @"history", @"airing"];
    NSImage * image;
    for (NSString *imagename in images){
        image = [NSImage imageNamed:imagename];
        [image setTemplate:YES];
    }
    // Generate Source List
    [self generateSourceList];
    
    // Set Resizing mask
    [_infoview.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_listview.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_historyview.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_progressview setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_searchview.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_seasonview.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_notloggedin.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_requireslicense setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_airingview.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    self.window.titleVisibility = NSWindowTitleHidden;
    
    // Fix window size
    NSRect frame = [self.window frame];
    frame.size.height = frame.size.height - 22;
    [[self window] setFrame:frame display:NO];
    [self setAppearance];
    
    // Set logged in user
    [self refreshloginlabel];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [_infoview setSelectedId:0];
    // Set Mainview
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"selectedmainview"]){
        NSNumber *selected = (NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedmainview"];
        [sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex: [selected unsignedIntegerValue]]byExtendingSelection:false];
    }
    else{
         [sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:1]byExtendingSelection:false];
    }
    // Load Touchbar
    if (NSClassFromString(@"NSTouchBar") != nil) {
        [[NSBundle mainBundle] loadNibNamed:@"MainWindow_Touch_Bar" owner:self topLevelObjects:nil];
    }
    
    NSNumber *shouldrefresh = [[NSUserDefaults standardUserDefaults] valueForKey:@"refreshlistonstart"];
    [self loadlist:shouldrefresh type:0];
    [self loadlist:shouldrefresh type:1];
    [self loadlist:shouldrefresh type:2];
    NSNumber * autorefreshlist = [[NSUserDefaults standardUserDefaults] valueForKey:@"refreshautomatically"];
    if (autorefreshlist.boolValue){
        [self startTimer];
    }
    
}

-(void)generateSourceList{
    self.sourceListItems = [[NSMutableArray alloc] init];
    
    //Library Group
    PXSourceListItem *libraryItem = [PXSourceListItem itemWithTitle:@"LIBRARY" identifier:@"library"];
    PXSourceListItem *animelistItem = [PXSourceListItem itemWithTitle:@"Anime List" identifier:@"animelist"];
    [animelistItem setIcon:[NSImage imageNamed:@"library"]];
    PXSourceListItem *mangalistItem = [PXSourceListItem itemWithTitle:@"Manga List" identifier:@"mangalist"];
    [mangalistItem setIcon:[NSImage imageNamed:@"library"]];
    PXSourceListItem *historyItem = [PXSourceListItem itemWithTitle:@"History" identifier:@"history"];
    [historyItem setIcon:[NSImage imageNamed:@"history"]];
    [libraryItem setChildren:[NSArray arrayWithObjects:animelistItem, mangalistItem, historyItem, nil]];
    // Search
    PXSourceListItem *searchgroupItem = [PXSourceListItem itemWithTitle:@"SEARCH" identifier:@"searchgroup"];
    PXSourceListItem *searchItem = [PXSourceListItem itemWithTitle:@"Anime" identifier:@"search"];
    [searchItem setIcon:[NSImage imageNamed:@"anime"]];
    PXSourceListItem *mangasearchItem = [PXSourceListItem itemWithTitle:@"Manga" identifier:@"mangasearch"];
    [mangasearchItem setIcon:[NSImage imageNamed:@"manga"]];
    [searchgroupItem setChildren:[NSArray arrayWithObjects:searchItem, mangasearchItem, nil]];
    // Discover Group
    PXSourceListItem *discoverItem = [PXSourceListItem itemWithTitle:@"DISCOVER" identifier:@"discover"];
    PXSourceListItem *titleinfoItem = [PXSourceListItem itemWithTitle:@"Title Info" identifier:@"titleinfo"];
    [titleinfoItem setIcon:[NSImage imageNamed:@"animeinfo"]];
    PXSourceListItem *seasonsItem = [PXSourceListItem itemWithTitle:@"Seasons" identifier:@"seasons"];
    [seasonsItem setIcon:[NSImage imageNamed:@"seasons"]];
    PXSourceListItem *airingItem = [PXSourceListItem itemWithTitle:@"Airing" identifier:@"airing"];
    [airingItem setIcon:[NSImage imageNamed:@"airing"]];
    [discoverItem setChildren:[NSArray arrayWithObjects:titleinfoItem,seasonsItem, airingItem, nil]];
    
    // Populate Source List
    [self.sourceListItems addObject:libraryItem];
    [self.sourceListItems addObject:searchgroupItem];
    [self.sourceListItems addObject:discoverItem];
    [sourceList reloadData];

}

- (IBAction)addlicense:(id)sender {
    [_appdel enterDonationKey:sender];
}

- (IBAction)viewDonation:(id)sender {
    // Show Donation Page
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://malupdaterosx.ateliershiori.moe/donate/"]];
}

- (void)setDelegate:(AppDelegate*) adelegate{
    _appdel = adelegate;
}


- (IBAction)sharetitle:(id)sender {
    NSDictionary * d;
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    int type = 0;
    if ([identifier isEqualToString:@"animelist"]){
        d = [[_listview.animelistarraycontroller selectedObjects] objectAtIndex:0];
        type = AnimeType;
    }
    if ([identifier isEqualToString:@"mangalist"]){
        d = [[_listview.mangalistarraycontroller selectedObjects] objectAtIndex:0];
        type = MangaType;
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        d = [_infoview getSelectedInfo];
        type = [_infoview getType];
    }

    //Generate Items to Share
    NSArray *shareItems;
    if (type == AnimeType){
        shareItems = [NSArray arrayWithObjects:[NSString stringWithFormat:@"Check out %@ out on MyAnimeList ", d[@"title"]], [NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/anime/%@", d[@"id"]]] ,nil];
    }
    else {
        shareItems = [NSArray arrayWithObjects:[NSString stringWithFormat:@"Check out %@ out on MyAnimeList ", d[@"title"]], [NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/manga/%@", d[@"id"]]] ,nil];
    }
    //Get Share Picker
    NSSharingServicePicker *sharePicker = [[NSSharingServicePicker alloc] initWithItems:shareItems];
    sharePicker.delegate = nil;
    NSButton * btn = (NSButton *)sender;
    // Show Share Box
    [sharePicker showRelativeToRect:[btn bounds] ofView:btn preferredEdge:NSMinYEdge];
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
    if ([Keychain checkaccount]){
        [self loadlist:@(true) type:0];
        [self loadlist:@(true) type:1];
        [self loadlist:@(true) type:2];
    }
}

- (void)windowWillClose:(NSNotification *)notification{
    [[NSApplication sharedApplication] terminate:0];
}
- (void)setAppearance{
    NSString * appearence = [[NSUserDefaults standardUserDefaults] valueForKey:@"appearance"];
    NSString *appearancename;
    if ([appearence isEqualToString:@"Light"]){
        appearancename = NSAppearanceNameVibrantLight;
    }
    else{
        appearancename = NSAppearanceNameVibrantDark;
    }
    w.appearance = [NSAppearance appearanceNamed:appearancename];
    _progressview.appearance = [NSAppearance appearanceNamed:appearancename];
    _infoview.view.appearance = [NSAppearance appearanceNamed:appearancename];
    _notloggedin.view.appearance = [NSAppearance appearanceNamed:appearancename];
    _listview.filterbarview.appearance = [NSAppearance appearanceNamed:appearancename];
    _listview.filterbarview2.appearance = [NSAppearance appearanceNamed:appearancename];
    _advsearchpopover.appearance = [NSAppearance appearanceNamed:appearancename];
    _minieditpopover.appearance = [NSAppearance appearanceNamed:appearancename];
    _addpopover.appearance = [NSAppearance appearanceNamed:appearancename];
    [w setFrame:[w frame] display:false];
}
- (void)refreshloginlabel{
    if ([Keychain checkaccount]){
        _loggedinuser.stringValue = [NSString stringWithFormat:@"Logged in as %@",[Keychain getusername]];
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
    
    return [[item children] count];
}

- (id)sourceList:(PXSourceList*)aSourceList child:(NSUInteger)index ofItem:(id)item
{
    if (!item)
        return self.sourceListItems[index];
    
    return [[item children] objectAtIndex:index];
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
#pragma mark Main View Control
- (void)loadmainview{
    NSRect mainviewframe = _mainview.frame;
    [_mainview addSubview:[NSView new]];
    long selectedrow = [sourceList selectedRow];
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    NSPoint origin = NSMakePoint(0, 0);
        if ([identifier isEqualToString:@"animelist"]){
            if ([Keychain checkaccount]){
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
            if ([(NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"] boolValue]){
                if ([Keychain checkaccount]){
                    [self replaceMainViewWithView:_listview.view];
                    [_listview loadList:1];
                    _listview.mangalistview.frame = mainviewframe;
                    [_listview.mangalistview setFrameOrigin:origin];
                }
                else {
                     [self loadNotLoggedIn];
                }
            }
            else {
                [self loadnotLicensed];
            }
        }
        else if ([identifier isEqualToString:@"history"]){
            if ([Keychain checkaccount]){
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
            if ([(NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"] boolValue]){
                [self replaceMainViewWithView:_searchview.view];
                [_searchview loadsearchView:MangaSearch];
                _searchview.mangasearch.frame = mainviewframe;
                [_searchview.mangasearch setFrameOrigin:origin];
            }
            else {
                [_mainview replaceSubview:[_mainview.subviews objectAtIndex:0] with:_requireslicense];
                _requireslicense.frame = mainviewframe;
                [self loadnotLicensed];
            }
        }
        else if ([identifier isEqualToString:@"titleinfo"]){
            if ([_infoview getSelectedId] > 0){
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
            if ([[[_airingview airingarraycontroller] arrangedObjects] count] == 0){
                // Load Airing List
                [_airingview loadAiring:@(false)];
            }
        }
        else{
            // Fallback
            [sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:2]byExtendingSelection:false];
            [self loadmainview];
            return;
        }
    // Save current view
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLong:selectedrow] forKey:@"selectedmainview"];
    [self createToolbar];
}
- (void)replaceMainViewWithView:(NSView *)view{
    NSRect mainviewframe = _mainview.frame;
    NSPoint origin = NSMakePoint(0, 0);
    [_mainview replaceSubview:[_mainview.subviews objectAtIndex:0] with:view];
    view.frame = mainviewframe;
    [view setFrameOrigin:origin];
}
- (void)loadNotLoggedIn{
    [self replaceMainViewWithView:_notloggedin.view];
}
- (void)loadnotLicensed{
    [self replaceMainViewWithView:_requireslicense];
}
- (void)createToolbar{
    NSArray *toolbaritems = [_toolbar items];
    // Remove Toolbar Items
    for (int i = 0; i < [toolbaritems count]; i++){
        [_toolbar removeItemAtIndex:0];
    }
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    int indexoffset = 0;
    
    if ([identifier isEqualToString:@"animelist"]){
        if ([Keychain checkaccount]){
            [_toolbar insertItemWithItemIdentifier:@"editList" atIndex:0];
            [_toolbar insertItemWithItemIdentifier:@"DeleteTitle" atIndex:1];
            [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:2];
            [_toolbar insertItemWithItemIdentifier:@"ShareList" atIndex:3];
            [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:4];
            [_toolbar insertItemWithItemIdentifier:@"filter" atIndex:5];
        }
    }
    else if ([identifier isEqualToString:@"mangalist"]){
        if ([(NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"] boolValue]){
            if ([Keychain checkaccount]){
                [_toolbar insertItemWithItemIdentifier:@"editList" atIndex:0];
                [_toolbar insertItemWithItemIdentifier:@"DeleteTitle" atIndex:1];
                [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:2];
                [_toolbar insertItemWithItemIdentifier:@"ShareList" atIndex:3];
                [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:4];
                [_toolbar insertItemWithItemIdentifier:@"filter" atIndex:5];
            }
        }
    }
    else if ([identifier isEqualToString:@"history"]){
        if ([Keychain checkaccount]){
            [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:0];
        }
        
    }
    else if ([identifier isEqualToString:@"search"]){
        if ([Keychain checkaccount]){
            [_toolbar insertItemWithItemIdentifier:@"AddTitleSearch" atIndex:0];
        }
        else {
            indexoffset = -1;
        }
        [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:1+indexoffset];
        [_toolbar insertItemWithItemIdentifier:@"advsearch" atIndex:2+indexoffset];
        [_toolbar insertItemWithItemIdentifier:@"search" atIndex:3+indexoffset];
    }
    else if ([identifier isEqualToString:@"mangasearch"]){
        if ([(NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"] boolValue]){
            if ([Keychain checkaccount]){
                [_toolbar insertItemWithItemIdentifier:@"AddTitleSearch" atIndex:0];
            }
            else {
                indexoffset = -1;
            }
            [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:1+indexoffset];
            [_toolbar insertItemWithItemIdentifier:@"advsearch" atIndex:2+indexoffset];
            [_toolbar insertItemWithItemIdentifier:@"search" atIndex:3+indexoffset];
        }
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        if ([_infoview getSelectedId] > 0){
            if ([Keychain checkaccount]){
                if ([self checkiftitleisonlist:[_infoview getSelectedId] type:[_infoview getType]]){
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
            [_toolbar insertItemWithItemIdentifier:@"ShareInfo" atIndex:2+indexoffset];
        }
    }
    else if ([identifier isEqualToString:@"seasons"]){
        if ([Keychain checkaccount]){
            [_toolbar insertItemWithItemIdentifier:@"AddTitleSeason" atIndex:0+indexoffset];
        }
        else {
            indexoffset = -1;
        }
        [_toolbar insertItemWithItemIdentifier:@"yearselect" atIndex:1+indexoffset];
        [_toolbar insertItemWithItemIdentifier:@"seasonselect" atIndex:2+indexoffset];
        [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:3+indexoffset];
        [_seasonview populateseasonpopups];
    }
    else if ([identifier isEqualToString:@"airing"]){
        if ([Keychain checkaccount]){
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
        NSMutableArray * a = [_searchview.searcharraycontroller content];
        [a removeAllObjects];
        if ([json isKindOfClass:[NSArray class]]){
           // Valid Search Results, populate
            [_searchview.searcharraycontroller addObjects:json];
        }
        [_searchview.searchtb reloadData];
        [_searchview.searchtb deselectAll:self];
    }
    else {
        NSMutableArray * a = [_searchview.mangasearcharraycontroller content];
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
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    if ([identifier isEqualToString:@"search"]){
        [_advancedsearchcontroller setSearchType:0];
    }
    else if ([identifier isEqualToString:@"mangasearch"]){
        [_advancedsearchcontroller setSearchType:1];
    }
    // Show Share Box
    [_advsearchpopover showRelativeToRect:[btn bounds] ofView:btn preferredEdge:NSMaxYEdge];
}
#pragma mark Anime List
- (IBAction)refreshlist:(id)sender {
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    if ([identifier isEqualToString:@"animelist"]){
        [self loadlist:@(true) type:0];
    }
    else if ([identifier isEqualToString:@"mangalist"]){
        [self loadlist:@(true) type:1];
    }
    else if ([identifier isEqualToString:@"history"]){
        [self loadlist:@(true) type:2];
    }
    else if ([identifier isEqualToString:@"seasons"]){
        [_seasonview performseasonindexretrieval];
    }
    else if ([identifier isEqualToString:@"airing"]){
        [_airingview loadAiring:@(true)];
    }
}
- (void)loadlist:(NSNumber *)refresh type:(int)type{
    if ([Keychain checkaccount]){
        id list;
        bool refreshlist = refresh.boolValue;
        bool exists = false;
        switch (type) {
            case 0:
                exists = [Utility checkifFileExists:@"animelist.json" appendPath:@""];
                list = [Utility loadJSON:@"animelist.json" appendpath:@""];
                if (exists && !refreshlist){
                    [_listview populateList:list type:0];
                    return;
                }
                else if (!exists || refreshlist){
                AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

                [manager GET:[NSString stringWithFormat:@"%@/2.1/animelist/%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"], [Keychain getusername]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                    [_listview populateList:[Utility saveJSON:responseObject withFilename:@"animelist.json" appendpath:@"" replace:TRUE] type:0];
                
                } failure:^(NSURLSessionTask *operation, NSError *error) {
                    NSLog(@"%@", error.userInfo);
                }];
                }
                break;
            case 1:
                exists = [Utility checkifFileExists:@"mangalist.json" appendPath:@""];
                list = [Utility loadJSON:@"mangalist.json" appendpath:@""];
                if (exists && !refreshlist){
                    [_listview populateList:list type:1];
                    return;
                }
                else if (!exists || refreshlist){
                    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                    
                    [manager GET:[NSString stringWithFormat:@"%@/2.1/mangalist/%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"], [Keychain getusername]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                        [_listview populateList:[Utility saveJSON:responseObject withFilename:@"mangalist.json" appendpath:@"" replace:TRUE] type:1];
                        
                    } failure:^(NSURLSessionTask *operation, NSError *error) {
                        NSLog(@"%@", error.userInfo);
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
- (void)clearlist{
    //Clears List
    NSMutableArray * a = [_listview.animelistarraycontroller content];
    [a removeAllObjects];
    [Utility deleteFile:@"animelist.json" appendpath:@""];
    [_listview.animelisttb reloadData];
    [_listview.animelisttb deselectAll:self];
     a = [_listview.mangalistarraycontroller content];
    [a removeAllObjects];
    [Utility deleteFile:@"mangalist.json" appendpath:@""];
    [_listview.mangalisttb reloadData];
    [_listview.mangalisttb deselectAll:self];
    [_historyview clearHistory];
    
}
#pragma mark Edit Popover
- (IBAction)performmodifytitle:(id)sender {
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    if ([identifier isEqualToString:@"animelist"]){
           NSDictionary *d = [[_listview.animelistarraycontroller selectedObjects] objectAtIndex:0];
        [_editviewcontroller showEditPopover:d showRelativeToRec:[_listview.animelisttb frameOfCellAtColumn:0 row:[_listview.animelisttb selectedRow]] ofView:_listview.animelisttb preferredEdge:0 type:0];
    }
    if ([identifier isEqualToString:@"mangalist"]){
        NSDictionary *d = [[_listview.mangalistarraycontroller selectedObjects] objectAtIndex:0];
        [_editviewcontroller showEditPopover:d showRelativeToRec:[_listview.mangalisttb frameOfCellAtColumn:0 row:[_listview.mangalisttb selectedRow]] ofView:_listview.mangalisttb preferredEdge:0 type:1];
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        [_editviewcontroller showEditPopover:[self retreveentryfromlist:[_infoview getSelectedId] type:[_infoview getType]] showRelativeToRec:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge type:[_infoview getType]];
    }
}

#pragma mark Add Title

- (IBAction)showaddpopover:(id)sender {
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    if ([identifier isEqualToString:@"search"]){
        NSDictionary *d = [[_searchview.searcharraycontroller selectedObjects] objectAtIndex:0];
        [_addtitlecontroller showAddPopover:d showRelativeToRec:[_searchview.searchtb frameOfCellAtColumn:0 row:[_searchview.searchtb selectedRow]] ofView:_searchview.searchtb preferredEdge:0 type:AnimeSearch];
    }
    if ([identifier isEqualToString:@"mangasearch"]){
        NSDictionary *d = [[_searchview.mangasearcharraycontroller selectedObjects] objectAtIndex:0];
        [_addtitlecontroller showAddPopover:d showRelativeToRec:[_searchview.mangasearchtb frameOfCellAtColumn:0 row:[_searchview.mangasearchtb selectedRow]] ofView:_searchview.mangasearchtb preferredEdge:0 type:MangaSearch];
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        [_addtitlecontroller showAddPopover:[_infoview getSelectedInfo] showRelativeToRec:[sender bounds] ofView:sender preferredEdge:0 type:[_infoview getType]];
    }
    else if ([identifier isEqualToString:@"seasons"]){
        NSDictionary *d = [[_seasonview.seasonarraycontroller selectedObjects] objectAtIndex:0];
        d = d[@"id"];
        NSNumber * idnum = @([[NSString stringWithFormat:@"%@",d[@"id"]] integerValue]);
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:[NSString stringWithFormat:@"%@/2.1/anime/%i",[[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"],idnum.intValue] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [_addtitlecontroller showAddPopover:(NSDictionary *)responseObject showRelativeToRec:[_seasonview.seasontableview frameOfCellAtColumn:0 row:[_seasonview.seasontableview selectedRow]] ofView:_seasonview.seasontableview preferredEdge:0 type:0];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    if ([identifier isEqualToString:@"airing"]){
        NSDictionary *d = [[_airingview.airingarraycontroller selectedObjects] objectAtIndex:0];
        [_addtitlecontroller showAddPopover:d showRelativeToRec:[_airingview.airingtb frameOfCellAtColumn:0 row:[_airingview.airingtb  selectedRow]] ofView:_airingview.airingtb preferredEdge:0 type:0];
    }

}


#pragma mark Title Information View
- (void)loadinfo:(NSNumber *) idnum type:(int)type {
    int previd = [_infoview getSelectedId];
    int prevtype = [_infoview getType];
    [_infoview setSelectedId:0];
    [sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:8]byExtendingSelection:false];
    [self loadmainview];
    [_noinfoview setHidden:YES];
    [_progressindicator setHidden: NO];
    [_progressindicator startAnimation:nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    if (type == AnimeType){
        [manager GET:[NSString stringWithFormat:@"%@/2.1/anime/%i",[[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"],idnum.intValue] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [_infoview setSelectedId:idnum.intValue];
            [_infoview setType:type];
            [_progressindicator stopAnimation:nil];
            [_infoview populateAnimeInfoView:responseObject];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [_progressindicator stopAnimation:nil];
            [_infoview setSelectedId:previd];
            [_infoview setType:prevtype];
            if ([_infoview getSelectedId] == 0)
                [_noinfoview setHidden:NO];
            [self loadmainview];
        }];
    }
    else {
        [manager GET:[NSString stringWithFormat:@"%@/2.1/manga/%i",[[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"],idnum.intValue] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [_infoview setSelectedId:idnum.intValue];
            [_infoview setType:type];
            [_progressindicator stopAnimation:nil];
            [_infoview populateMangaInfoView:responseObject];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [_progressindicator stopAnimation:nil];
            [_infoview setSelectedId:previd];
            [_infoview setType:prevtype];
            if ([_infoview getSelectedId] == 0)
                [_noinfoview setHidden:NO];
            [self loadmainview];
        }];
    }
}
- (bool)checkiftitleisonlist:(int)idnum type:(int)type{
    if (type == 0){
        NSArray * list = [_listview.animelistarraycontroller content];
        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
        if ([list count] > 0){
            return true;
        }
    }
    else {
        NSArray * list = [_listview.mangalistarraycontroller content];
        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
        if ([list count] > 0){
            return true;
        }
    }
    return false;
}
- (id)retreveentryfromlist:(int)idnum type:(int)type{
    if (type == 0){
        NSArray * list = [_listview.animelistarraycontroller content];
        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
        if ([list count] > 0){
            return [list objectAtIndex:0];
        }
        else {
             return nil;
        }
    }
    else {
        NSArray * list = [_listview.mangalistarraycontroller content];
        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
        if ([list count] > 0){
            return [list objectAtIndex:0];
        }
        else {
            return nil;
        }
    }
    return nil;
}

@end

