//
//  MainWindow.m
//  Nekomata
//
//  Created by 桐間紗路 on 2017/02/28.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import "MainWindow.h"
#import "AppDelegate.h"
#import "NSString_stripHtml.h"
#import "Utility.h"
#import "NSTextFieldNumber.h"
#import "MSWeakTimer.h"
#import "Keychain.h"

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
    _privateQueue = dispatch_queue_create("moe.ateliershiori.nekomata", DISPATCH_QUEUE_CONCURRENT);
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
    //PXSourceListItem *seasonsItem = [PXSourceListItem itemWithTitle:@"Seasons" identifier:@"seasons"];
    //[seasonsItem setIcon:[NSImage imageNamed:@"seasons"]];
 [discoverItem setChildren:[NSArray arrayWithObjects:searchItem, titleinfoItem/*,seasonsItem*/, nil]];
   
   // Populate Source List
    [self.sourceListItems addObject:libraryItem];
    [self.sourceListItems addObject:discoverItem];
    [sourceList reloadData];
    // Set Resizeing mask
    [_animeinfoview setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_animelistview setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_progressview setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_searchview setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_seasonview setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    self.window.titleVisibility = NSWindowTitleHidden;
    [self setAppearence];
    // Fix textview text color
    _infoviewdetailstextview.textColor = NSColor.controlTextColor;
    _infoviewsynopsistextview.textColor = NSColor.controlTextColor;
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

-(void)setDelegate:(AppDelegate*) adelegate{
    appdel = adelegate;
}

- (IBAction)performlogin:(id)sender {
    [appdel showloginpref];
}

- (IBAction)sharetitle:(id)sender {
    NSDictionary * d;
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    if ([identifier isEqualToString:@"animelist"]){
        d = [[_animelistarraycontroller selectedObjects] objectAtIndex:0];
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        d = selectedanimeinfo;
    }

    //Generate Items to Share
    NSArray *shareItems = [NSArray arrayWithObjects:[NSString stringWithFormat:@"Check out %@ out on AniList ", d[@"title_romaji"]], [NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/anime/%@", d[@"id"]]] ,nil];
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
-(void)setAppearence{
    NSString * appearence = [[NSUserDefaults standardUserDefaults] valueForKey:@"appearence"];
    NSString *appearencename;
    if ([appearence isEqualToString:@"Light"]){
        appearencename = NSAppearanceNameVibrantLight;
    }
    else{
        appearencename = NSAppearanceNameVibrantDark;
    }
    w.appearance = [NSAppearance appearanceNamed:appearencename];
    _progressview.appearance = [NSAppearance appearanceNamed:appearencename];
    _animeinfoview.appearance = [NSAppearance appearanceNamed:appearencename];
    _notloggedinview.appearance = [NSAppearance appearanceNamed:appearencename];
    _filterbarview.appearance = [NSAppearance appearanceNamed:appearencename];
    [w setFrame:[w frame] display:false];
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
                [_mainview replaceSubview:[_mainview.subviews objectAtIndex:0] with:_animelistview];
                _animelistview.frame = mainviewframe;
                [_animelistview setFrameOrigin:origin];
            }
            else {
                [_mainview replaceSubview:[_mainview.subviews objectAtIndex:0] with:_notloggedinview];
                _notloggedinview.frame = mainviewframe;
                [_notloggedinview setFrameOrigin:origin];
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
        [_toolbar insertItemWithItemIdentifier:@"AddTitleSearch" atIndex:0];
        [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:1];
        [_toolbar insertItemWithItemIdentifier:@"search" atIndex:2];
      
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        if (selectedid > 0){
            if ([self checkiftitleisonlist:selectedid]){
                 [_toolbar insertItemWithItemIdentifier:@"editInfo" atIndex:0];
            }
            else{
                [_toolbar insertItemWithItemIdentifier:@"AddTitleInfo" atIndex:0];
            }
            [_toolbar insertItemWithItemIdentifier:@"viewonmal" atIndex:1];
            [_toolbar insertItemWithItemIdentifier:@"ShareInfo" atIndex:2];
        }
    }
    else if ([identifier isEqualToString:@"seasons"]){
       [_toolbar insertItemWithItemIdentifier:@"AddTitleSeason" atIndex:0];
        [_toolbar insertItemWithItemIdentifier:@"yearselect" atIndex:1];
        [_toolbar insertItemWithItemIdentifier:@"seasonselect" atIndex:2];
        [_toolbar insertItemWithItemIdentifier:@"refresh" atIndex:3];
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
        NSMutableArray * a = [searcharraycontroller content];
        [a removeAllObjects];
        [searchtb reloadData];
        [searchtb deselectAll:self];
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
#pragma mark Anime List
-(void)loadlist:(NSNumber *)refresh{
    id list;
    bool exists = [Utility checkifFileExists:@"animelist.json" appendPath:@""];
    bool refreshlist = refresh.boolValue;
    list = [Utility loadJSON:@"animelist.json" appendpath:@""];
    if (exists && !refreshlist){
        [self populateList:list];
        return;
    }
    else if (!exists || refreshlist){
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    [manager GET:[NSString stringWithFormat:@"https://malapi.ateliershiori.moe/2.1/animelist/%@", [Keychain getusername]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [self populateList:[Utility saveJSON:responseObject withFilename:@"animelist.json" appendpath:@"" replace:TRUE]];
    
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"%@", error.userInfo);
    }];
    }
}
-(void)populateList:(id)object{
    // Populates list
    NSMutableArray * a = [_animelistarraycontroller content];
    [a removeAllObjects];
    NSDictionary * data = object;
    NSArray * list=data[@"anime"];
    [_animelistarraycontroller addObjects:list];
    [self populatefiltercounts:data[@"status_count"]];
    [_animelisttb reloadData];
    [_animelisttb deselectAll:self];
    [self performfilter];
}
-(void)populatefiltercounts:(NSDictionary*)d{
    // Generates item counts for each status filter
    NSNumber *watching = d[@"watching"];
    NSNumber *completed = d[@"completed"];
    NSNumber *onhold = d[@"on_hold"];
    NSNumber *dropped = d[@"dropped"];
    NSNumber *plantowatch = d[@"plan_to_watch"];
    _watchingfilter.title = [NSString stringWithFormat:@"Watching (%i)",watching.intValue];
    _completedfilter.title = [NSString stringWithFormat:@"Completed (%i)",completed.intValue];
    _onholdfilter.title = [NSString stringWithFormat:@"On Hold (%i)",onhold.intValue];
    _droppedfilter.title = [NSString stringWithFormat:@"Dropped (%i)",dropped.intValue];
    _plantowatchfilter.title = [NSString stringWithFormat:@"Plan to watch (%i)",plantowatch.intValue];
}
- (IBAction)filterperform:(id)sender {
    [self performfilter];
}
-(void)performfilter{
    // This method generates a predicate rule to use as a filter
    NSMutableArray * predicateformat = [NSMutableArray new];
    NSMutableArray * predicateobjects = [NSMutableArray new];
    bool titlefilterused = false;
    if (_animelistfilter.stringValue.length > 0){
        [predicateformat addObject: @"(title_romaji CONTAINS [cd] %@)"];
        [predicateobjects addObject: _animelistfilter.stringValue];
        titlefilterused = true;
    }
    NSArray * filterstatus = [self obtainfilterstatus];
    for (int i=0; i < [filterstatus count]; i++){
        NSDictionary *d = [filterstatus objectAtIndex:i];
        if ([filterstatus count] == 1){
            [predicateformat addObject:@"(watched_status ==[cd] %@)"];
            
        }
        else if (i == [filterstatus count]-1){
            [predicateformat addObject:@"watched_status ==[cd] %@)"];
        }
        else if (i == 0){
            [predicateformat addObject:@"(watched_status ==[cd] %@ OR "];
        }
        else{
                [predicateformat addObject:@"watched_status ==[cd] %@ OR "];
        }
        [predicateobjects addObject:[[d allKeys] objectAtIndex:0]];
    }
    if ([predicateformat count] ==0 || [filterstatus count] == 0){
        // Empty filter predicate
        _animelistarraycontroller.filterPredicate = [NSPredicate predicateWithFormat:@"watched_status == %@",@""];
    }
    else{
        // Build Predicate rules
        NSMutableString * predicaterule = [NSMutableString new];
        for (int i=0; i < [predicateformat count]; i++){
            NSString *format = [predicateformat objectAtIndex:i];
            if (titlefilterused && i==0){
                if ([predicateformat count] == 1) {
                    [predicaterule appendString:format];
                    continue;
                }
                else{
                    [predicaterule appendFormat:@"%@ AND ", format];
                    continue;
                }
            }
            [predicaterule appendString:format];
        }
        NSPredicate * predicate = [NSPredicate predicateWithFormat:predicaterule argumentArray:predicateobjects];
        _animelistarraycontroller.filterPredicate = predicate;
    }
}
- (IBAction)refreshlist:(id)sender {
    [self loadlist:@(true)];
}

- (IBAction)animelistdoubleclick:(id)sender {
    if ([_animelisttb clickedRow] >=0){
        if ([_animelisttb clickedRow] >-1){
            NSString *action = [[NSUserDefaults standardUserDefaults] valueForKey: @"listdoubleclickaction"];
            NSDictionary *d = [[_animelistarraycontroller selectedObjects] objectAtIndex:0];
            if ([action isEqualToString:@"View Anime Info"]){
                NSNumber * idnum = d[@"id"];
               [self loadanimeinfo:idnum];
            }
            else if([action isEqualToString:@"Modify Title"]){
                [self showEditPopover:d showRelativeToRec:[_animelisttb frameOfCellAtColumn:0 row:[_animelisttb selectedRow]] ofView:_animelisttb preferredEdge:0];
            }
        }
    }
}

- (IBAction)deletetitle:(id)sender {
    NSAlert * alert = [[NSAlert alloc] init] ;
    NSDictionary *d = [[_animelistarraycontroller selectedObjects] objectAtIndex:0];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert setMessageText:[NSString stringWithFormat:@"Are you sure you want to delete %@ from your list?", d[@"title_romaji"]]];
    [alert setInformativeText:@"Once you delete this title, this cannot be undone."];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode== NSAlertFirstButtonReturn) {
            [self deletetitle];
        }
    }];
}
-(void)clearlist{
    //Clears List
    NSMutableArray * a = [_animelistarraycontroller content];
    [a removeAllObjects];
    [Utility deleteFile:@"animelist.json" appendpath:@""];
    [_animelisttb reloadData];
    [_animelisttb deselectAll:self];
}
-(NSArray *)obtainfilterstatus{
    // Generates an array of selected filters
    NSMutableArray * a = [NSMutableArray new];
    NSMutableArray * final = [NSMutableArray new];
    [a addObject:@{@"watching":@(_watchingfilter.state)}];
    [a addObject:@{@"completed":@(_completedfilter.state)}];
    [a addObject:@{@"on-hold":@(_onholdfilter.state)}];
    [a addObject:@{@"dropped":@(_droppedfilter.state)}];
    [a addObject:@{@"plan to watch":@(_plantowatchfilter.state)}];
    for (NSDictionary *d in a){
            NSNumber *add = [d objectForKey:[[d allKeys] objectAtIndex:0]];
        if (add.boolValue){
            [final addObject:d];
        }
    }
    return final;
}
-(void)deletetitle{
    NSDictionary *d = [[_animelistarraycontroller selectedObjects] objectAtIndex:0];
    NSNumber * selid = d[@"id"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [Keychain getBase64]] forHTTPHeaderField:@"Authorization"];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager DELETE:[NSString stringWithFormat:@"https://malapi/2.1/animelist/%i", selid.intValue] parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
        [self loadlist:@(true)];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
    }];
}
#pragma mark Edit Popover
-(void)showEditPopover:(NSDictionary *)d showRelativeToRec:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)rectedge{
    selecteditem = d;
    [_minieditpopovernumformat setMaximum:d[@"episodes"]];
    NSString *airingstatus = d[@"status"];
    if ([airingstatus isEqualToString:@"finished airing"]){
        selectedaircompleted = true;
    }
    else{
        selectedaircompleted = false;
    }
    if ([airingstatus isEqualToString:@"finished airing"]||[airingstatus isEqualToString:@"currently airing"]){
        selectedaired = true;
    }
    else{
        selectedaired = false;
    }
    [_minipopoverepfield setIntValue:[(NSNumber *)d[@"watched_episodes"] intValue]];
    [_minipopovertotalep setIntValue:[(NSNumber *)d[@"episodes"] intValue]];
    [_minipopoverstatus selectItemWithTitle:d[@"watched_status"]];
    [_minipopoverscore setFloatValue:[(NSNumber *)d[@"score"] floatValue]];
    [_minipopoverstatustext setStringValue:@""];
    selectededitid = [(NSNumber *)d[@"id"] intValue];
    [_minieditpopover showRelativeToRect:rect ofView:view preferredEdge:rectedge];
}

- (IBAction)performmodifytitle:(id)sender {
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    if ([identifier isEqualToString:@"animelist"]){
           NSDictionary *d = [[_animelistarraycontroller selectedObjects] objectAtIndex:0];
        [self showEditPopover:d showRelativeToRec:[_animelisttb frameOfCellAtColumn:0 row:[_animelisttb selectedRow]] ofView:_animelisttb preferredEdge:0];
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        [self showEditPopover:[self retreveentryfromlist:selectedid]showRelativeToRec:[sender bounds] ofView:sender preferredEdge:0];
    }
}

- (IBAction)performupdatetitle:(id)sender {
    [self performupdate];
}
-(void)performupdate{
    [_minipopovereditbtn setEnabled:false];
    [_minipopoverstatustext setStringValue:@""];
    if(![_minipopoverstatus.title isEqual:@"completed"] && _minipopoverepfield.intValue == _minipopovertotalep.intValue){
        [_minipopoverstatus selectItemWithTitle:@"completed"];
    }
    if(!selectedaired && (![_minipopoverstatus.title isEqual:@"plan to watch"] ||_minipopoverepfield.intValue > 0)){
        // Invalid input, mark it as such
        [_minipopovereditbtn setEnabled:true];
        [_minipopoverstatustext setStringValue:@"Invalid update."];
        [_minieditpopover setBehavior:NSPopoverBehaviorTransient];
        [_minipopoverindicator stopAnimation:nil];
        return;
    }
    if (_minipopoverepfield.intValue == _minipopovertotalep.intValue && _minipopovertotalep.intValue != 0){
        [_minipopoverstatus selectItemWithTitle:@"completed"];
        [_minipopoverepfield setIntValue:[_minipopovertotalep intValue]];
    }
    [_minieditpopover setBehavior:NSPopoverBehaviorApplicationDefined];
    [_minipopoverindicator startAnimation:nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [Keychain getBase64]] forHTTPHeaderField:@"Authorization"];
    [manager PUT:[NSString stringWithFormat:@"https://malapi.ateliershiori.moe/2.1/animelist/anime/%@", @(selectededitid)] parameters:@{ @"status":_minipopoverstatus.title, @"score":@(_minipopoverscore.intValue), @"episodes":@(_minipopoverepfield.intValue)} success:^(NSURLSessionTask *task, id responseObject) {
        [self loadlist:@(true)];
         [_minipopovereditbtn setEnabled:true];
        [_minieditpopover setBehavior:NSPopoverBehaviorTransient];
        [_minipopoverindicator stopAnimation:nil];
        [_minieditpopover close];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
         [_minipopovereditbtn setEnabled:true];
        [_minieditpopover setBehavior:NSPopoverBehaviorTransient];
        [_minipopoverindicator stopAnimation:nil];
        NSLog(@"%@", error);
        [_minipopoverstatustext setStringValue:@"Error"];
    }];
}
#pragma mark Add Title

- (IBAction)showaddpopover:(id)sender {
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
    if ([identifier isEqualToString:@"search"]){
        NSDictionary *d = [[searcharraycontroller selectedObjects] objectAtIndex:0];
        [self showAddPopover:d showRelativeToRec:[searchtb frameOfCellAtColumn:0 row:[searchtb selectedRow]] ofView:searchtb preferredEdge:0];
    }
    else if ([identifier isEqualToString:@"titleinfo"]){
        [self showAddPopover:[self retreveentryfromlist:selectedid]showRelativeToRec:[sender bounds] ofView:sender preferredEdge:0];
    }
}
-(void)showAddPopover:(NSDictionary *)d showRelativeToRec:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)rectedge{
    NSNumber * idnum = d[@"id"];
    if (![self checkiftitleisonlist:idnum.intValue]){
        [_popoveraddtitleexistsview setHidden:YES];
        [_addtitleview setHidden:NO];
        selecteditem = d;
        [_addnumformat setMaximum:d[@"episodes"]];
        NSString *airingstatus = d[@"status"];
        if ([airingstatus isEqualToString:@"finished airing"]){
            selectedaircompleted = true;
        }
        else{
            selectedaircompleted = false;
        }
        if ([airingstatus isEqualToString:@"finished airing"]||[airingstatus isEqualToString:@"currently airing"]){
            selectedaired = true;
        }
        else{
            selectedaired = false;
        }
        [_addepifield setIntValue:0];
        [_addtotalepisodes setIntValue:[(NSNumber *)d[@"episodes"] intValue]];
        [_addstatusfield selectItemWithTitle:@"watching"];
        [_addscorefiled setIntValue:0];
        selectededitid = [(NSNumber *)d[@"id"] intValue];
    }
    else {
        [_popoveraddtitleexistsview setHidden:NO];
        [_addtitleview setHidden:YES];
    }
    [_addpopover showRelativeToRect:rect ofView:view preferredEdge:rectedge];
}
- (IBAction)PerformAddTitle:(id)sender {
    [self addtitletolist];
}
-(void)addtitletolist{
    [_addfield setEnabled:false];
    if(![_addstatusfield isEqual:@"completed"] && _addepifield.intValue == _addtotalepisodes.intValue){
        [_addstatusfield selectItemWithTitle:@"completed"];
    }
    if(!selectedaired && (![_addstatusfield.title isEqual:@"plan to watch"] ||_addepifield.intValue > 0)){
        // Invalid input, mark it as such
        [_addfield setEnabled:true];
        [_addpopover setBehavior:NSPopoverBehaviorTransient];
        return;
    }
    if (_addepifield.intValue == _addtotalepisodes.intValue && _addtotalepisodes.intValue != 0){
        [_addstatusfield selectItemWithTitle:@"completed"];
        [_addepifield setIntValue:[_minipopovertotalep intValue]];
    }
    [_addpopover setBehavior:NSPopoverBehaviorApplicationDefined];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [Keychain getBase64]] forHTTPHeaderField:@"Authorization"];
    [manager POST:@"https://malapi.ateliershiori.moe/2.1/animelist/anime" parameters:@{@"id":@(selectededitid), @"status":_addstatusfield.title, @"score":@(_addscorefiled.intValue), @"episodes_watched":@(_addepifield.intValue)} progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [self loadlist:@(true)];
        [_addfield setEnabled:true];
        [_addpopover setBehavior:NSPopoverBehaviorTransient];
        [_addpopover close];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [_addfield setEnabled:true];
        [_addpopover setBehavior:NSPopoverBehaviorTransient];
    }];
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
    [_infoviewtitle setStringValue:d[@"title"]];
    NSDictionary * dtitles =  d[@"other_titles"];
    NSMutableArray * othertitles = [NSMutableArray new];
    if (dtitles[@"english"] != [NSNull null]){
        [othertitles addObject:dtitles[@"english"]];
    }
    if (dtitles[@"japanese"] != [NSNull null]){
        [othertitles addObject:dtitles[@"japanese"]];
    }
    if (dtitles[@"synonyms"] != [NSNull null]){
        NSArray * syn = dtitles[@"synonyms"];
        for (NSString * stitle in syn){
            [othertitles addObject:stitle];
        }
    }
    [titles appendString:[Utility appendstringwithArray:othertitles]];
    [_infoviewalttitles setStringValue:titles];
    NSArray * genresa = d[@"genres"];
    [genres appendString:[Utility appendstringwithArray:genresa]];
    NSString * type = d[@"type"];
    NSNumber * score = d[@"members_score"];
    NSNumber * popularity = d[@"popularity_rank"];
    NSImage * posterimage = [Utility loadImage:[NSString stringWithFormat:@"%@.jpg",d[@"id"]] withAppendPath:@"imgcache" fromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",d[@"image_url"]]]];
    [_infoviewposterimage setImage:posterimage];
    [details appendString:[NSString stringWithFormat:@"Type: %@\n", type]];
    [details appendString:[NSString stringWithFormat:@"Genre: %@\n", genres]];
    [details appendString:[NSString stringWithFormat:@"Score: %f/100\n", score.floatValue]];
    [details appendString:[NSString stringWithFormat:@"Popularity: %i\n", popularity.intValue]];
    NSString * synopsis = d[@"synopsis"];
    [_infoviewdetailstextview setString:details];
    [_infoviewsynopsistextview setString:[synopsis stripHtml]];
    [self loadmainview];
    selectedanimeinfo = d;
}
- (IBAction)viewonanilist:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/anime/%i",selectedid]]];
}
-(bool)checkiftitleisonlist:(int)idnum{
    NSArray * list = [_animelistarraycontroller content];
    list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
    if ([list count] > 0){
        return true;
    }
    return false;
}
-(id)retreveentryfromlist:(int)idnum{
    NSArray * list = [_animelistarraycontroller content];
    list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
    if ([list count] > 0){
        return [list objectAtIndex:0];
    }
    return nil;
}
@end

