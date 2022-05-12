//
//  ProfileWindowController.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/10/07.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "ProfileWindowController.h"
#import "ListView.h"
#import "ProfileViewController.h"
#import "listservice.h"
#import "ListStatistics.h"
#import "AppDelegate.h"
#import "servicemenucontroller.h"

@interface ProfileWindowController ()
@property (strong) IBOutlet NSVisualEffectView *noselectionview;
@property (strong) IBOutlet NSView *noprofileview;
@property (strong) IBOutlet ListView *listview;
@property (strong) ListStatistics *liststats;

@property (strong) IBOutlet ProfileViewController *profilevc;
@property (weak) IBOutlet NSProgressIndicator *progresswheel;
@property (strong, nonatomic) NSMutableArray *sourceListItems;
@property bool loadedprofile;
@property (strong) IBOutlet NSSearchField *searchfield;
@property (strong) IBOutlet NSToolbar *toolbar;
@property (strong) NSSplitViewController *splitview;
@end

@implementation ProfileWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [_listview removeAllFilterBindings];
    [_profilevc view];
    _liststats = [ListStatistics new];
    [_liststats window];
    [self loadMainView];
    [self setAppearance];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recieveNotification:) name:@"AppAppearenceChanged" object:nil];
}
- (void)windowWillClose:(NSNotification *)notification {
    // Cleanup
    if (_liststats) {
        [_liststats.window close];
    }
    _searchfield.stringValue = @"";
    [self resetprofilewindow];
}

- (instancetype)init {
    return [super initWithWindowNibName:@"ProfileWindowController"];
}

- (void)recieveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"AppAppearenceChanged"]) {
        [self setAppearance];
    }
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)awakeFromNib
{
    // Add blank subview to mainview
    [_mainview addSubview:[NSView new]];
    [self setUpSplitView];
    // Generate Source List
    [self generateSourceList];
    
    // Set Resizing mask
    (_listview.view).autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    (_noselectionview).autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
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
}

- (void)setUpSplitView {
    _splitview = [NSSplitViewController new];
    NSSplitViewItem *sourceListSplitViewItem = [NSSplitViewItem sidebarWithViewController:_sourcelistviewcontroller];
    NSSplitViewItem *mainViewSplitViewItem = [NSSplitViewItem splitViewItemWithViewController:_mainviewcontroller];
    sourceListSplitViewItem.maximumThickness = 250;
    [_splitview addSplitViewItem:sourceListSplitViewItem];
    [_splitview addSplitViewItem:mainViewSplitViewItem];
    _splitview.splitView.autosaveName = @"ProfileWindowSplitView";
    [self.window setContentViewController:_splitview];
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
    if ([[group identifier] isEqualToString:@"profileg"])
        return YES;
    return NO;
}

- (void)sourceListSelectionDidChange:(NSNotification *)notification
{
    [self loadMainView];
}


- (void)loadMainView {
    NSRect mainviewframe = _mainview.frame;
    //long selectedrow = _sourceList.selectedRow;
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    NSString *identifier = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];
    NSPoint origin = NSMakePoint(0, 0);
    if ([identifier isEqualToString:@"profile"]) {
        if (_loadedprofile) {
            [self replaceMainViewWithView:_profilevc.view];
            _profilevc.view.frame = mainviewframe;
            [_profilevc.view setFrameOrigin:origin];
        }
        else {
            [self loadnoprofileview];
        }
    }
    else if ([identifier isEqualToString:@"animelist"]) {
        if (_loadedprofile) {
            [self replaceMainViewWithView:_listview.view];
            [_listview loadList:0];
            _listview.animelistview.frame = mainviewframe;
            [_listview.animelistview setFrameOrigin:origin];
        }
        else {
            [self loadnoprofileview];
        }
    }
    else if ([identifier isEqualToString:@"mangalist"]) {
        if (_loadedprofile) {
            [self replaceMainViewWithView:_listview.view];
            [_listview loadList:1];
            _listview.mangalistview.frame = mainviewframe;
            [_listview.mangalistview setFrameOrigin:origin];
        }
        else {
             [self loadnoprofileview];
        }
    }
    [self loadtoolbar];
}

- (void)replaceMainViewWithView:(NSView *)view {
    NSRect mainviewframe = _mainview.frame;
    NSPoint origin = NSMakePoint(0, 0);
    [_mainview replaceSubview:(_mainview.subviews)[0] with:view];
    view.frame = mainviewframe;
    [view setFrameOrigin:origin];
}

- (void)loadnoprofileview {
    [self replaceMainViewWithView:_noselectionview];
    [self loadtoolbar];
}

- (void)setLoadingView:(bool)loading {
    if (loading) {
        _noprofileview.hidden = true;
        _progresswheel.hidden = false;
        [_progresswheel startAnimation:self];
    }
    else {
        _noprofileview.hidden = false;
        _progresswheel.hidden = true;
        [_progresswheel stopAnimation:self];
    }
}

- (void)loadtoolbar {
    NSArray *toolbaritems = _toolbar.items;
    // Remove Toolbar Items
    for (int i = 0; i < toolbaritems.count; i++) {
        [_toolbar removeItemAtIndex:0];
    }
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    NSString *identifier = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];

    if ([identifier isEqualToString:@"profile"]){
        if (_loadedprofile){
            [_toolbar insertItemWithItemIdentifier:@"viewonmal" atIndex:0];
            [_toolbar insertItemWithItemIdentifier:@"stats" atIndex:1];
            [_toolbar insertItemWithItemIdentifier:@"share" atIndex:2];
            [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:3];
            [_toolbar insertItemWithItemIdentifier:@"usersearch" atIndex:4];
        }
        else {
            [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:0];
            [_toolbar insertItemWithItemIdentifier:@"usersearch" atIndex:1];
        }
    }
    else if ([identifier isEqualToString:@"animelist"] || [identifier isEqualToString:@"mangalist"]){
        if (_loadedprofile){
            [_toolbar insertItemWithItemIdentifier:@"viewonmal" atIndex:0];
            [_toolbar insertItemWithItemIdentifier:@"stats" atIndex:1];
            [_toolbar insertItemWithItemIdentifier:@"share" atIndex:2];
            [_toolbar insertItemWithItemIdentifier:@"NSToolbarFlexibleSpaceItem" atIndex:3];
            [_toolbar insertItemWithItemIdentifier:@"filter" atIndex:4];
        }
    }
    [_toolbar insertItemWithItemIdentifier:NSToolbarToggleSidebarItemIdentifier atIndex:0];
}

- (void)generateSourceList {
    self.sourceListItems = [[NSMutableArray alloc] init];
    
    //Library Group
    PXSourceListItem *profilegroupItem = [PXSourceListItem itemWithTitle:@"PROFILE" identifier:@"profileg"];
    PXSourceListItem *profileItem = [PXSourceListItem itemWithTitle:@"User Profile" identifier:@"profile"];
    profileItem.icon = [NSImage imageWithSystemSymbolName:@"person.fill" accessibilityDescription:@""];
    PXSourceListItem *animelistItem = [PXSourceListItem itemWithTitle:@"Anime List" identifier:@"animelist"];
    animelistItem.icon = [NSImage imageWithSystemSymbolName:@"list.dash" accessibilityDescription:@""];
    PXSourceListItem *mangalistItem = [PXSourceListItem itemWithTitle:@"Manga List" identifier:@"mangalist"];
    mangalistItem.icon = [NSImage imageWithSystemSymbolName:@"list.dash" accessibilityDescription:@""];
    profilegroupItem.children = @[profileItem, animelistItem, mangalistItem];

    // Populate Source List
    [self.sourceListItems addObject:profilegroupItem];
    [_sourceList reloadData];
    [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
}


- (IBAction)profilesearch:(id)sender {
    if (_searchfield.stringValue.length == 0) {
        [self resetprofilewindow];
    }
    else {
        [self loadprofile:_searchfield.stringValue];
    }
}

- (void)loadProfileWithUsername:(NSString *)username {
    [_sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
    [self loadMainView];
    _searchfield.stringValue = username;
    [self profilesearch:nil];
}

- (void)loadprofile:(NSString *)username {
    __block servicemenucontroller *smc = ((AppDelegate *)NSApp.delegate).servicemenucontrol;
    _loadedprofile = false;
    [smc enableservicemenuitems:NO];
    [self setLoadingView:true];
    [self loadMainView];
    [_liststats.window close];
    [_profilevc loadprofilewithUsername:username completion:^(bool success){
        if (success) {
            [listservice.sharedInstance retrieveList:username listType:MALAnime completion:^(id responseObject) {
                [_listview populateList:responseObject type:MALAnime];
                [_liststats populateValues:responseObject type:1];
                [listservice.sharedInstance retrieveList:username listType:MALManga completion:^(id responseObject){
                    [_listview populateList:responseObject type:MALManga];
                    [_liststats populateValues:responseObject type:2];
                    _liststats.window.title = [NSString stringWithFormat:@"List Statistics - %@", username];
                    _loadedprofile = true;
                    [self loadMainView];
                    [self setLoadingView:false];
                    [smc enableservicemenuitems:YES];
                } error:^(NSError *error) {
                    [self setLoadingView:false];
                    [self showerrormessage:error.localizedFailureReason];
                    [smc enableservicemenuitems:YES];
                }];
            } error:^(NSError *error) {
                [self setLoadingView:false];
                [self showerrormessage:error.localizedFailureReason];
                [smc enableservicemenuitems:YES];
            }];
        }
        else {
            [self setLoadingView:false];
            [self showerrormessage:[NSString stringWithFormat:@"Cannot load profile %@. Check the username and try again",username]];
            [smc enableservicemenuitems:YES];
        }
    }];
}


# pragma mark other

- (IBAction)viewonmyanimelist:(id)sender {
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    NSString *identifier = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];
    if ([identifier isEqualToString:@"profile"]){
        if (_loadedprofile){
            switch ([listservice.sharedInstance getCurrentServiceID]) {
                case 1:
                    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/profile/%@",_searchfield.stringValue]]];
                    break;
                case 2:
                    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://kitsu.io/users/%@",_searchfield.stringValue]]];
                    break;
                case 3:
                    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/user/%@",_searchfield.stringValue]]];
                    break;
                default:
                    break;
            }
        }
    }
    else if ([identifier isEqualToString:@"animelist"]){
        if (_loadedprofile){
            switch ([listservice.sharedInstance getCurrentServiceID]) {
                case 1:
                    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/animelist/%@",_searchfield.stringValue]]];
                    break;
                case 2:
                    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://kitsu.io/users/%@/library?media=anime",_searchfield.stringValue]]];
                    break;
                case 3:
                    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/user/%@/animelist",_searchfield.stringValue]]];
                    break;
                default:
                    break;
            }
        }
    }
    else if ([identifier isEqualToString:@"mangalist"]){
        if (_loadedprofile){
            switch ([listservice.sharedInstance getCurrentServiceID]) {
                case 1:
                    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/mangalist/%@",_searchfield.stringValue]]];
                    break;
                case 2:
                    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://kitsu.io/users/%@/library?media=manga",_searchfield.stringValue]]];
                    break;
                case 3:
                    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/user/%@/mangalist",_searchfield.stringValue]]];
                    break;
                default:
                    break;
            }
        }
        
    }
}

- (IBAction)share:(id)sender {
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    NSString *identifier = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];
    
    //Generate Items to Share
    NSArray *shareItems = @[];
    if ([identifier isEqualToString:@"profile"]){
        switch ([listservice.sharedInstance getCurrentServiceID]) {
            case 1:
                shareItems = @[[NSString stringWithFormat:@"Check out %@'s profile out on MyAnimeList ", _searchfield.stringValue], [NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/profile/%@", _searchfield.stringValue]]];
                break;
            case 2:
                shareItems = @[[NSString stringWithFormat:@"Check out %@'s profile out on Kitsu ", _searchfield.stringValue], [NSURL URLWithString:[NSString stringWithFormat:@"https://kitsu.io/users/%@",_searchfield.stringValue]]];
                break;
            case 3:
                shareItems = @[[NSString stringWithFormat:@"Check out %@'s profile out on AniList ", _searchfield.stringValue], [NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/user/%@", _searchfield.stringValue]]];
                break;
            default:
                break;
        }
    }
    if ([identifier isEqualToString:@"animelist"]){
        switch ([listservice.sharedInstance getCurrentServiceID]) {
            case 1:
                shareItems = @[[NSString stringWithFormat:@"Check out %@'s anime list out on MyAnimeList ", _searchfield.stringValue], [NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/animelist/%@", _searchfield.stringValue]]];
                break;
            case 2:
                shareItems = @[[NSString stringWithFormat:@"Check out %@'s anime list out on Kitsu ", _searchfield.stringValue], [NSURL URLWithString:[NSString stringWithFormat:@"https://kitsu.io/users/%@/library?media=anime",_searchfield.stringValue]]];
                break;
            case 3:
                shareItems = @[[NSString stringWithFormat:@"Check out %@'s anime list out on AniList ", _searchfield.stringValue], [NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/user/%@/animelist", _searchfield.stringValue]]];
                break;
            default:
                break;
        }
    }
    else if ([identifier isEqualToString:@"mangalist"]){
        switch ([listservice.sharedInstance getCurrentServiceID]) {
            case 1:
                shareItems = @[[NSString stringWithFormat:@"Check out %@'s manga list out on MyAnimeList ", _searchfield.stringValue], [NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/mangalist/%@", _searchfield.stringValue]]];
                break;
            case 2:
                shareItems = @[[NSString stringWithFormat:@"Check out %@'s anime list out on Kitsu ", _searchfield.stringValue], [NSURL URLWithString:[NSString stringWithFormat:@"https://kitsu.io/users/%@/library?media=manga",_searchfield.stringValue]]];
                break;
            case 3:
                shareItems = @[[NSString stringWithFormat:@"Check out %@'s manga list out on AniList ", _searchfield.stringValue], [NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/user/%@/mangalist", _searchfield.stringValue]]];
                break;
            default:
                break;
        }
    }
    //Get Share Picker
    NSSharingServicePicker *sharePicker = [[NSSharingServicePicker alloc] initWithItems:shareItems];
    sharePicker.delegate = nil;
    NSButton * btn = (NSButton *)sender;
    // Show Share Box
    [sharePicker showRelativeToRect:btn.bounds ofView:btn preferredEdge:NSMinYEdge];
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
            self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
        }
        else{
            appearancename = NSAppearanceNameVibrantDark;
            self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
        }
        _noselectionview.appearance = [NSAppearance appearanceNamed:appearancename];
        _profilevc.view.appearance = [NSAppearance appearanceNamed:appearancename];
        _listview.filterbarview.appearance = [NSAppearance appearanceNamed:appearancename];
        _listview.filterbarview2.appearance = [NSAppearance appearanceNamed:appearancename];
        _listview.customlistpopoverviewcontroller.view.appearance = [NSAppearance appearanceNamed:appearancename];
        _listview.customlistpopover.appearance = [NSAppearance appearanceNamed:appearancename];
        [self.window setFrame:self.window.frame display:false];
    }
}

- (IBAction)viewliststats:(id)sender {
    [_liststats.window makeKeyAndOrderFront:self];
}

- (void)showerrormessage:(NSString *)errormessage {
    NSAlert *a = [NSAlert new];
    a.messageText = @"An error has occurred while loading a profile.";
    a.informativeText = errormessage;
    a.alertStyle = NSAlertStyleCritical;
    [a beginSheetModalForWindow:self.window completionHandler:nil];
}


- (void)resetprofilewindow {
    _searchfield.stringValue = @"";
    _loadedprofile = false;
    [_liststats.window close];
    [_listview clearalllists];
    [_profilevc resetprofileview];
    [self loadMainView];
}

@end
