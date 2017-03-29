//
//  MainWindow.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/02/28.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import "MainWindow.h"
#import "AppDelegate.h"
#import "NSString+HTMLtoNSAttributedString.h"
#import "Utility.h"
#import "NSTextFieldNumber.h"
#import "MSWeakTimer.h"
#import "Keychain.h"
#import "AddTitle.h"
#import "EditTitle.h"
#import "ListView.h"
#import "NotLoggedIn.h"

@interface MainWindow ()
@property (strong, nonatomic) NSMutableArray *sourceListItems;
@end

@implementation MainWindow

-(id)init{
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
    NSArray *images = @[@"animeinfo", @"delete", @"Edit", @"Info", @"library", @"search", @"seasons"];
    NSImage * image;
    for (NSString *imagename in images){
        image = [NSImage imageNamed:imagename];
        [image setTemplate:YES];
    }
    
    self.sourceListItems = [[NSMutableArray alloc] init];
    
    //Library Group
    PXSourceListItem *libraryItem = [PXSourceListItem itemWithTitle:@"LIBRARY" identifier:@"library"];
    PXSourceListItem *animelistItem = [PXSourceListItem itemWithTitle:@"Anime List" identifier:@"animelist"];
    [animelistItem setIcon:[NSImage imageNamed:@"library"]];
     [libraryItem setChildren:[NSArray arrayWithObjects:animelistItem, nil]];
    // Discover Group
    PXSourceListItem *discoverItem = [PXSourceListItem itemWithTitle:@"DISCOVER" identifier:@"discover"];
    PXSourceListItem *searchItem = [PXSourceListItem itemWithTitle:@"Search" identifier:@"search"];
      [searchItem setIcon:[NSImage imageNamed:@"search"]];
    PXSourceListItem *titleinfoItem = [PXSourceListItem itemWithTitle:@"Title Info" identifier:@"titleinfo"];
    [titleinfoItem setIcon:[NSImage imageNamed:@"animeinfo"]];
    PXSourceListItem *seasonsItem = [PXSourceListItem itemWithTitle:@"Seasons" identifier:@"seasons"];
    [seasonsItem setIcon:[NSImage imageNamed:@"seasons"]];
    [discoverItem setChildren:[NSArray arrayWithObjects:searchItem, titleinfoItem,seasonsItem, nil]];
   
   // Populate Source List
    [self.sourceListItems addObject:libraryItem];
    [self.sourceListItems addObject:discoverItem];
    [sourceList reloadData];
    // Set Resizeing mask
    [_animeinfoview setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_listview.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_progressview setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_searchview setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_seasonview setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_notloggedin.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    self.window.titleVisibility = NSWindowTitleHidden;
    // Fix window size
    NSRect frame = [self.window frame];
    frame.size.height = frame.size.height - 22;
    [[self window] setFrame:frame display:NO];
    [self setAppearance];
    // Fix textview text color
    _infoviewdetailstextview.textColor = NSColor.controlTextColor;
    _infoviewsynopsistextview.textColor = NSColor.controlTextColor;
    _infoviewbackgroundtextview.textColor = NSColor.controlTextColor;
    
    // Set logged in user
    [self refreshloginlabel];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    selectedid = 0;
    // Set Mainview
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"selectedmainview"]){
        NSNumber *selected = (NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedmainview"];
        [sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex: [selected unsignedIntegerValue]]byExtendingSelection:false];
    }
    else{
         [sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:1]byExtendingSelection:false];
    }
    NSNumber *shouldrefresh = [[NSUserDefaults standardUserDefaults] valueForKey:@"refreshlistonstart"];
    [self loadlist:shouldrefresh];
    NSNumber * autorefreshlist = [[NSUserDefaults standardUserDefaults] valueForKey:@"refreshautomatically"];
    if (autorefreshlist.boolValue){
        [self startTimer];
    }
    
}
- (IBAction)addlicense:(id)sender {
    [appdel enterDonationKey:sender];
}

-(void)setDelegate:(AppDelegate*) adelegate{
    appdel = adelegate;
}


- (IBAction)sharetitle:(id)sender {
    NSDictionary * d;
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    if ([identifier isEqualToString:@"animelist"]){
        d = [[_listview.animelistarraycontroller selectedObjects] objectAtIndex:0];
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        d = selectedanimeinfo;
    }

    //Generate Items to Share
    NSArray *shareItems = [NSArray arrayWithObjects:[NSString stringWithFormat:@"Check out %@ out on MyAnimeList ", d[@"title"]], [NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/anime/%@", d[@"id"]]] ,nil];
    //Get Share Picker
    NSSharingServicePicker *sharePicker = [[NSSharingServicePicker alloc] initWithItems:shareItems];
    sharePicker.delegate = nil;
    NSButton * btn = (NSButton *)sender;
    // Show Share Box
    [sharePicker showRelativeToRect:[btn bounds] ofView:btn preferredEdge:NSMinYEdge];
}
-(void)startTimer{
    _refreshtimer =  [MSWeakTimer scheduledTimerWithTimeInterval:900
                                                          target:self
                                                        selector:@selector(fireTimer)
                                                        userInfo:nil
                                                         repeats:YES
                                                   dispatchQueue:_privateQueue];
}
-(void)stopTimer{
    [_refreshtimer invalidate];
}
-(void)fireTimer{
    if ([Keychain checkaccount])
    [self loadlist:@(true)];
}

- (void)windowWillClose:(NSNotification *)notification{
    [[NSApplication sharedApplication] terminate:0];
}
-(void)setAppearance{
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
    _animeinfoview.appearance = [NSAppearance appearanceNamed:appearancename];
    _notloggedin.view.appearance = [NSAppearance appearanceNamed:appearancename];
    _listview.filterbarview.appearance = [NSAppearance appearanceNamed:appearancename];
    [w setFrame:[w frame] display:false];
}
-(void)refreshloginlabel{
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
-(void)loadmainview{
    NSRect mainviewframe = _mainview.frame;
    [_mainview addSubview:[NSView new]];
    long selectedrow = [sourceList selectedRow];
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    NSPoint origin = NSMakePoint(0, 0);
        if ([identifier isEqualToString:@"animelist"]){
            if ([Keychain checkaccount]){
                [_mainview replaceSubview:[_mainview.subviews objectAtIndex:0] with:_listview.view];
                _listview.view.frame = mainviewframe;
                [_listview.view setFrameOrigin:origin];
            }
            else {
                [_mainview replaceSubview:[_mainview.subviews objectAtIndex:0] with:_notloggedin.view];
                _notloggedin.view.frame = mainviewframe;
                [_notloggedin.view setFrameOrigin:origin];
            }
        }
        else if ([identifier isEqualToString:@"search"]){
                [_mainview replaceSubview:[_mainview.subviews objectAtIndex:0] with:_searchview];
                _searchview.frame = mainviewframe;
                [_searchview setFrameOrigin:origin];
        }
        else if ([identifier isEqualToString:@"titleinfo"]){
            if (selectedid > 0){
                [_mainview replaceSubview:[_mainview.subviews objectAtIndex:0] with:_animeinfoview];
                _animeinfoview.frame = mainviewframe;
                [_animeinfoview setFrameOrigin:origin];
            }
            else{
                [_mainview replaceSubview:[_mainview.subviews objectAtIndex:0] with:_progressview];
                _progressview.frame = mainviewframe;
                [_progressview setFrameOrigin:origin];
            }
        }
        else if ([identifier isEqualToString:@"seasons"]){
                [_mainview replaceSubview:[_mainview.subviews objectAtIndex:0] with:_seasonview];
                _seasonview.frame = mainviewframe;
                [_seasonview setFrameOrigin:origin];
        }
    // Save current view
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLong:selectedrow] forKey:@"selectedmainview"];
    [self createToolbar];
}
-(void)createToolbar{
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
    else if ([identifier isEqualToString:@"titleinfo"]){
        if (selectedid > 0){
            if ([Keychain checkaccount]){
                if ([self checkiftitleisonlist:selectedid]){
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
        [self populateseasonpopups];
    }
}
#pragma mark -
#pragma mark Search View
- (IBAction)performsearch:(id)sender {
    if ([searchtitlefield.stringValue length] > 0){
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:[NSString stringWithFormat:@"https://malapi.ateliershiori.moe/2.1/anime/search?q=%@",[Utility urlEncodeString:searchtitlefield.stringValue]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [self populatesearchtb:responseObject];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    else{
        [self clearsearchtb];
    }
   }

- (IBAction)searchtbdoubleclick:(id)sender {
    if ([searchtb clickedRow] >=0){
        if ([searchtb clickedRow] >-1){
            NSDictionary *d = [[searcharraycontroller selectedObjects] objectAtIndex:0];
            NSNumber * idnum = d[@"id"];
            [self loadanimeinfo:idnum];
        }
    }
}
-(void)populatesearchtb:(id)json{
    NSMutableArray * a = [searcharraycontroller content];
    [a removeAllObjects];
    if ([json isKindOfClass:[NSArray class]]){
       // Valid Search Results, populate
        [searcharraycontroller addObjects:json];
    }
    [searchtb reloadData];
    [searchtb deselectAll:self];
}
-(void)clearsearchtb{
    NSMutableArray * a = [searcharraycontroller content];
    [a removeAllObjects];
    [searchtb reloadData];
    [searchtb deselectAll:self];
}
- (IBAction)showadvancedpopover:(id)sender {
    NSButton * btn = (NSButton *)sender;
    // Show Share Box
    [_advsearchpopover showRelativeToRect:[btn bounds] ofView:btn preferredEdge:NSMaxYEdge];
}
#pragma mark Anime List
- (IBAction)refreshlist:(id)sender {
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    if ([identifier isEqualToString:@"animelist"]){
        [self loadlist:@(true)];
    }
    else if ([identifier isEqualToString:@"seasons"]){
        [self performseasonindexretrieval];
    }
}
-(void)loadlist:(NSNumber *)refresh{
    id list;
    bool exists = [Utility checkifFileExists:@"animelist.json" appendPath:@""];
    bool refreshlist = refresh.boolValue;
    list = [Utility loadJSON:@"animelist.json" appendpath:@""];
    if (exists && !refreshlist){
        [_listview populateList:list];
        return;
    }
    else if (!exists || refreshlist){
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    [manager GET:[NSString stringWithFormat:@"https://malapi.ateliershiori.moe/2.1/animelist/%@", [Keychain getusername]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [_listview populateList:[Utility saveJSON:responseObject withFilename:@"animelist.json" appendpath:@"" replace:TRUE]];
    
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"%@", error.userInfo);
    }];
    }
}
-(void)clearlist{
    //Clears List
    NSMutableArray * a = [_listview.animelistarraycontroller content];
    [a removeAllObjects];
    [Utility deleteFile:@"animelist.json" appendpath:@""];
    [_listview.animelisttb reloadData];
    [_listview.animelisttb deselectAll:self];
}
#pragma mark Edit Popover
- (IBAction)performmodifytitle:(id)sender {
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    if ([identifier isEqualToString:@"animelist"]){
           NSDictionary *d = [[_listview.animelistarraycontroller selectedObjects] objectAtIndex:0];
        [_editviewcontroller showEditPopover:d showRelativeToRec:[_listview.animelisttb frameOfCellAtColumn:0 row:[_listview.animelisttb selectedRow]] ofView:_listview.animelisttb preferredEdge:0];
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        [_editviewcontroller showEditPopover:[self retreveentryfromlist:selectedid]showRelativeToRec:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
    }
}

#pragma mark Add Title

- (IBAction)showaddpopover:(id)sender {
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    if ([identifier isEqualToString:@"search"]){
        NSDictionary *d = [[searcharraycontroller selectedObjects] objectAtIndex:0];
        [_addtitlecontroller showAddPopover:d showRelativeToRec:[searchtb frameOfCellAtColumn:0 row:[searchtb selectedRow]] ofView:searchtb preferredEdge:0];
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        [_addtitlecontroller showAddPopover:selectedanimeinfo showRelativeToRec:[sender bounds] ofView:sender preferredEdge:0];
    }
    else if ([identifier isEqualToString:@"seasons"]){
        NSDictionary *d = [[_seasonarraycontroller selectedObjects] objectAtIndex:0];
        d = d[@"id"];
        NSNumber * idnum = @([[NSString stringWithFormat:@"%@",d[@"id"]] integerValue]);
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:[NSString stringWithFormat:@"https://malapi.ateliershiori.moe/2.1/anime/%i",idnum.intValue] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [_addtitlecontroller showAddPopover:(NSDictionary *)responseObject showRelativeToRec:[_seasontableview frameOfCellAtColumn:0 row:[_seasontableview selectedRow]] ofView:_seasontableview preferredEdge:0];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}


#pragma mark Title Information View
-(void)loadanimeinfo:(NSNumber *) idnum{
    int previd = selectedid;
    selectedid = 0;
     [sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:4]byExtendingSelection:false];
    [self loadmainview];
    [_noinfoview setHidden:YES];
    [_progressindicator setHidden: NO];
    [_progressindicator startAnimation:nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"https://malapi.ateliershiori.moe/2.1/anime/%i",idnum.intValue] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        selectedid = idnum.intValue;
        [_progressindicator stopAnimation:nil];
        [self populateInfoView:responseObject];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [_progressindicator stopAnimation:nil];
        selectedid = previd;
        if (selectedid == 0)
            [_noinfoview setHidden:NO];
        [self loadmainview];
    }];
}
-(void)populateInfoView:(id)object{
    NSDictionary * d = object;
    NSMutableString *titles = [NSMutableString new];
    NSMutableString *details = [NSMutableString new];
    NSMutableString *genres = [NSMutableString new];
    NSAttributedString *background;
    [_infoviewtitle setStringValue:d[@"title"]];
    NSDictionary * dtitles =  d[@"other_titles"];
    NSMutableArray * othertitles = [NSMutableArray new];
    if (dtitles[@"english"] != nil){
        NSArray * e = dtitles[@"english"];
        for (NSString * etitle in e){
            [othertitles addObject:etitle];
        }
    }
    if (dtitles[@"japanese"] != nil){
        NSArray * j = dtitles[@"japanese"];
        for (NSString * jtitle in j){
            [othertitles addObject:jtitle];
        }
    }
    if (dtitles[@"synonyms"] != nil){
        NSArray * syn = dtitles[@"synonyms"];
        for (NSString * stitle in syn){
            [othertitles addObject:stitle];
        }
    }
    [titles appendString:[Utility appendstringwithArray:othertitles]];
    [_infoviewalttitles setStringValue:titles];
    if (d[@"genres"]!= nil){
        NSArray * genresa = d[@"genres"];
        [genres appendString:[Utility appendstringwithArray:genresa]];
    }
    else{
        [genres appendString:@"None"];
    }
    if (d[@"background"] != nil){
        background = [(NSString *)d[@"background"] convertHTMLtoAttStr];
    }
    else {
        background = [[NSAttributedString alloc] initWithString:@"None available"];
    }
    NSString * type = d[@"type"];
    NSNumber * score = d[@"members_score"];
    NSNumber * popularity = d[@"popularity_rank"];
    NSNumber * memberscount = d[@"members_count"];
    NSNumber *rank = d[@"rank"];
    NSNumber * favorites = d[@"favorited_count"];
    NSImage * posterimage = [Utility loadImage:[NSString stringWithFormat:@"%@.jpg",d[@"id"]] withAppendPath:@"imgcache" fromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",d[@"image_url"]]]];
    [_infoviewposterimage setImage:posterimage];
    [details appendString:[NSString stringWithFormat:@"Type: %@\n", type]];
    if (d[@"episodes"] == nil){
        if (d[@"duration"] == nil){
            [details appendString:@"Episodes: Unknown\n"];
        }
        else{
            [details appendString:[NSString stringWithFormat:@"Episodes: Unknown (%i mins per episode)\n", [(NSNumber *)d[@"duration"] intValue]]];
        }
    }
    else {
        if (d[@"duration"] == nil){
            [details appendString:[NSString stringWithFormat:@"Episodes: %i\n", [(NSNumber *)d[@"episodes"] intValue]]];
        }
        else{
            [details appendString:[NSString stringWithFormat:@"Episodes: %i (%i mins per episode)\n", [(NSNumber *)d[@"episodes"] intValue], [(NSNumber *)d[@"duration"] intValue]]];
        }
    }
    [details appendString:[NSString stringWithFormat:@"Status: %@\n", d[@"status"]]];
    [details appendString:[NSString stringWithFormat:@"Genre: %@\n", genres]];
    if (d[@"classification"] != nil){
        [details appendString:[NSString stringWithFormat:@"Classification: %@\n", d[@"classification"]]];
    }
    if (d[@"members_score"]!=nil){
        [details appendString:[NSString stringWithFormat:@"Score: %f (%i users, ranked %i)\n", score.floatValue, memberscount.intValue, rank.intValue]];
    }
    [details appendString:[NSString stringWithFormat:@"Popularity: %i\n", popularity.intValue]];
    [details appendString:[NSString stringWithFormat:@"Favorited: %i times\n", favorites.intValue]];
    NSString * synopsis = d[@"synopsis"];
    [_infoviewdetailstextview setString:details];
    [[_infoviewsynopsistextview textStorage] setAttributedString:[synopsis convertHTMLtoAttStr]];
    [[_infoviewbackgroundtextview  textStorage] setAttributedString:background];
    [self loadmainview];
    selectedanimeinfo = d;
}
- (IBAction)viewonmal:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/anime/%i",selectedid]]];
}
-(bool)checkiftitleisonlist:(int)idnum{
    NSArray * list = [_listview.animelistarraycontroller content];
    list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
    if ([list count] > 0){
        return true;
    }
    return false;
}
-(id)retreveentryfromlist:(int)idnum{
    NSArray * list = [_listview.animelistarraycontroller content];
    list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
    if ([list count] > 0){
        return [list objectAtIndex:0];
    }
    return nil;
}
#pragma mark Seasons View
- (IBAction)seasondoubleclick:(id)sender {
    if ([_seasontableview clickedRow] >=0){
        if ([_seasontableview clickedRow] >-1){
            NSDictionary *d = [[_seasonarraycontroller selectedObjects] objectAtIndex:0];
            d = d[@"id"];
            NSNumber * idnum = @([[NSString stringWithFormat:@"%@",d[@"id"]] integerValue]);
            [self loadanimeinfo:idnum];
        }
    }
}
    
- (IBAction)yearchange:(id)sender {
    [self populateseasonpopup];
}
    
- (IBAction)seasonchange:(id)sender {
    [self loadseasondata:_seasonyrpicker.title.intValue forSeason: _seasonpicker.title];
}
-(void)populateseasonpopups{
    if ([Utility checkifFileExists:@"index.json" appendPath:@"/seasondata/"]){
        [self populateyearpopup];
    }
    else {
        [self performseasonindexretrieval];
    }
}
-(void)loadseasondata:(int)year forSeason:(NSString *)season{
    if (_seasonyrpicker.itemArray.count > 0){
        if ([Utility checkifFileExists:[NSString stringWithFormat:@"%i-%@.json",year,season] appendPath:@"/seasondata/"]){
            NSMutableArray * sarray = [_seasonarraycontroller content];
            [sarray removeAllObjects];
            NSDictionary * d =  [Utility loadJSON:[NSString stringWithFormat:@"%i-%@.json",year,season] appendpath:@"/seasondata/"];
            NSArray * a = d[@"anime"];
            [_seasonarraycontroller addObjects:a];
            [_seasontableview reloadData];
            [_seasontableview deselectAll:self];
        }
        else {
            [self performseasondataretrieval:year forSeason:season loaddata:true];
        }
    }
}
-(void)populateyearpopup{
    [_seasonyrpicker removeAllItems];
    NSDictionary * d = [Utility loadJSON:@"index.json" appendpath:@"/seasondata/"];
    NSArray * a = d[@"years"];
    for (int i = 0; i < a.count; i++){
        NSDictionary * yr = [a objectAtIndex:i];
        NSNumber * year = yr[@"year"];
        [_seasonyrpicker addItemWithTitle:year.stringValue];
    }
    [_seasonyrpicker selectItemAtIndex:[[_seasonyrpicker itemArray] count]-1];
    [self populateseasonpopup];
}
-(void)populateseasonpopup{
    [_seasonpicker removeAllItems];
    NSDictionary * d = [Utility loadJSON:@"index.json" appendpath:@"/seasondata/"];
    NSArray * a = d[@"years"];
    NSDictionary * yr = [a objectAtIndex:_seasonyrpicker.indexOfSelectedItem];
    NSArray * s = yr[@"seasons"];
    for (int i = 0; i < s.count; i++){
        NSDictionary * season = [s objectAtIndex:i];
        NSString * seasonname = season[@"season"];
        [_seasonpicker addItemWithTitle:seasonname];
    }
    [self loadseasondata:_seasonyrpicker.title.intValue forSeason: _seasonpicker.title];
}
-(void)performseasonindexretrieval{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager GET:@"https://raw.githubusercontent.com/Atelier-Shiori/anime-season-json/master/index.json" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [Utility saveJSON:responseObject withFilename:@"index.json" appendpath:@"/seasondata/" replace:true];
        [self populateyearpopup];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
-(void)performseasondataretrieval:(int)year forSeason:(NSString *)season loaddata:(bool)loaddata {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager GET:[NSString stringWithFormat:@"https://raw.githubusercontent.com/Atelier-Shiori/anime-season-json/master/data/%i-%@.json",year,season] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [Utility saveJSON:responseObject withFilename:[NSString stringWithFormat:@"%i-%@.json",year,season] appendpath:@"/seasondata/" replace:true];
        if (loaddata){
            [self loadseasondata:year forSeason:season];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
@end

