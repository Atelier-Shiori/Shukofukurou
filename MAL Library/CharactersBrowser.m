//
//  CharactersBrowser.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/07/26.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "CharactersBrowser.h"
#import "CharacterView.h"
#import "listservice.h"
#import <CocoaOniguruma/OnigRegexp.h>
#import <CocoaOniguruma/OnigRegexpUtility.h>
#import "Utility.h"

@interface CharactersBrowser ()
@property (strong, nonatomic) NSMutableArray *sourceListItems;
@property (strong) NSDictionary *castdict;
@property (strong) IBOutlet NSSplitView *splitview;
@property (strong) IBOutlet NSVisualEffectView *noselectionview;
@property (weak) IBOutlet NSProgressIndicator *progresswheel;
@property (strong) CharacterView *characterviewcontroller;
@property (strong) IBOutlet NSView *mainview;
@property (strong) IBOutlet NSToolbarItem *toolbarviewonmal;
@property (strong) IBOutlet NSToolbarItem *toolbarshare;
@property (strong) IBOutlet NSTextField *noselectionheader;
@end

@implementation CharactersBrowser

- (instancetype)init{
    self = [super initWithWindowNibName:@"CharactersBrowser"];
    if (!self)
        return nil;
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.sourceListItems = [[NSMutableArray alloc] init];
    [_mainview addSubview:[NSView new]];
    _characterviewcontroller = [CharacterView new];
    _characterviewcontroller.cb = self;
    // Set Resizing masks
    _noselectionview.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    _characterviewcontroller.view.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    [self setDefaultView];
    [self enabletoolbaritems:NO];
    [self setAppearance];
}

- (void)windowWillClose:(NSNotification *)notification {
    // Cleanup
    [_sourceListItems removeAllObjects];
    [_sourceList reloadData];
    _castdict = nil;
    [_characterviewcontroller cleanup];
    _selectedtitleid = 0;
    _selectedtitle = nil;
    [self setDefaultView];
}

#pragma mark -
#pragma mark Source List Data Source Methods
- (NSUInteger)sourceList:(PXSourceList*)sourceList numberOfChildrenOfItem:(id)item {
    if (!item)
        return self.sourceListItems.count;
    
    return [item children].count;
}

- (id)sourceList:(PXSourceList*)aSourceList child:(NSUInteger)index ofItem:(id)item {
    if (!item)
        return self.sourceListItems[index];
    
    return [item children][index];
}

- (BOOL)sourceList:(PXSourceList*)aSourceList isItemExpandable:(id)item {
    return [item hasChildren];
}


#pragma mark Source List Delegate Methods
- (NSView *)sourceList:(PXSourceList *)aSourceList viewForItem:(id)item {
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


- (BOOL)sourceList:(PXSourceList*)aSourceList isGroupAlwaysExpanded:(id)group {
    if ([[group identifier] isEqualToString:@"characters"])
        return YES;
    else if ([[group identifier] isEqualToString:@"staff"])
        return YES;
    else if ([[group identifier] isEqualToString:@"voiceactors"])
        return YES;
    return NO;
}

- (void)sourceListSelectionDidChange:(NSNotification *)notification
{
    [self loadPerson];
    [self enabletoolbaritems:YES];
}


#pragma mark -
#pragma mark SplitView Delegate

- (void) splitView:(NSSplitView*) splitView resizeSubviewsWithOldSize:(NSSize) oldSize {
    if (splitView == _splitview)
    {
        CGFloat dividerPos = NSWidth((splitView.subviews[0]).frame);
        CGFloat width = NSWidth(splitView.frame);
        
        if (dividerPos < 0)
            dividerPos = 0;
        if (width - dividerPos < 528 + splitView.dividerThickness)
            dividerPos = width - (528 + splitView.dividerThickness);
        
        [splitView adjustSubviews];
        [splitView setPosition:dividerPos ofDividerAtIndex:0];
    }
}

- (CGFloat) splitView:(NSSplitView*) splitView constrainSplitPosition:(CGFloat) proposedPosition ofSubviewAt:(NSInteger) dividerIndex {
    if (splitView == _splitview)
    {
        CGFloat width = NSWidth(splitView.frame);
        
        if (ABS(167 - proposedPosition) <= 8)
            proposedPosition = 180;
        if (proposedPosition < 0)
            proposedPosition = 0;
        if (width - proposedPosition < 528 + splitView.dividerThickness)
            proposedPosition = width - (528 + splitView.dividerThickness);
    }
    
    return proposedPosition;
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification {
    [self.window setFrame:self.window.frame display:false];
}

#pragma mark -
#pragma mark Main View functions
- (void)setDefaultView {
    [self replaceMainViewSubViewWithView:_noselectionview];
}

- (void)replaceMainViewSubViewWithView:(NSView *)view {
    NSRect mainviewframe = _mainview.frame;
    NSPoint origin = NSMakePoint(0, 0);
    [_mainview replaceSubview:(_mainview.subviews)[0] with:view];
    view.frame = mainviewframe;
    [view setFrameOrigin:origin];
}

- (void)enabletoolbaritems:(bool)enable {
    _toolbarshare.enabled = enable;
    _toolbarviewonmal.enabled = enable;
}

- (void)startstopanimation:(bool)enable {
    if (enable) {
        _noselectionheader.hidden = true;
        _progresswheel.hidden = false;
        [_progresswheel startAnimation:self];
    }
    else {
        _noselectionheader.hidden = false;
        _progresswheel.hidden = true;
        [_progresswheel stopAnimation:self];
    }
}

#pragma mark -
#pragma mark Staff Source List

- (void)retrievestafflist:(int)idnum {
    [listservice retrieveStaff:idnum completion:^(id responseObject){
        [self generateSourceList:responseObject];
        _selectedtitleid = idnum;
        [self enabletoolbaritems:NO];
    }error:^(NSError *error){
        
    }];
}

-(void)generateSourceList:(NSDictionary *)d {
    // Generates source list
    [_sourceListItems removeAllObjects];
    PXSourceListItem *characterItem = [PXSourceListItem itemWithTitle:@"CHARACTERS" identifier:@"characters"];
    PXSourceListItem *voiceactorsItem = [PXSourceListItem itemWithTitle:@"VOICE ACTORS" identifier:@"voiceactors"];
    PXSourceListItem *staffItem = [PXSourceListItem itemWithTitle:@"STAFF" identifier:@"staff"];
    if (d[@"Characters"]) {
        NSArray *characters = d[@"Characters"];
        NSMutableArray *charactergroupitems = [NSMutableArray new];
        for (NSDictionary * character in characters) {
            PXSourceListItem *characterI = [PXSourceListItem itemWithTitle:character[@"name"] identifier:[NSString stringWithFormat:@"character-%@",character[@"id"]]];
            characterI.icon = [NSImage imageNamed:@"person"];
            [charactergroupitems addObject:characterI];
        }
        characterItem.children = charactergroupitems;
        NSArray *voiceactors = [self generatevoiceactorlist:d[@"Characters"]];
        if (voiceactors.count > 0) {
            NSMutableArray *voiceactorsgroupitems = [NSMutableArray new];
            for (NSDictionary * voiceactor in voiceactors) {
                PXSourceListItem *voiceactorI = [PXSourceListItem itemWithTitle:voiceactor[@"name"] identifier:[NSString stringWithFormat:@"staff-%@",voiceactor[@"id"]]];
                voiceactorI.icon = [NSImage imageNamed:@"person"];
                [voiceactorsgroupitems addObject:voiceactorI];
            }
            voiceactorsItem.children = voiceactorsgroupitems;
        }
    }
    
    if (d[@"Staff"]) {
        NSArray *staff = d[@"Staff"];
        NSMutableArray *staffgroupitems = [NSMutableArray new];
        for (NSDictionary * member in staff) {
            PXSourceListItem *memberI = [PXSourceListItem itemWithTitle:member[@"name"] identifier:[NSString stringWithFormat:@"staff-%@",member[@"id"]]];
            memberI.icon = [NSImage imageNamed:@"person"];
            [staffgroupitems addObject:memberI];
        }
        staffItem.children = staffgroupitems;
    }
    // Populate Source List
    [self.sourceListItems addObject:characterItem];
    [self.sourceListItems addObject:voiceactorsItem];
    [self.sourceListItems addObject:staffItem];
    [_sourceList reloadData];
    _castdict = d;
    [self setDefaultView];
}

#pragma mark Other Methods

- (void)loadPerson {
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    NSString *tmpstring = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];
    OnigRegexp *regex = [OnigRegexp compile:@"(character|staff)-"];
    NSString *type = [regex search:tmpstring].strings[0];
    int idnum = [tmpstring stringByReplacingOccurrencesOfString:type withString:@""].intValue;
    type = [type stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if ([type isEqualToString:@"character"]) {
        NSDictionary *charinfo = [self retrievecharacterinformation:idnum];
        [_characterviewcontroller populateCharacterInfo:charinfo withTitle:_selectedtitle];
        [self replaceMainViewSubViewWithView:_characterviewcontroller.view];
    }
    else if ([type isEqualToString:@"staff"]) {
        [self retrievestaffinformation:idnum];
    }
}

- (IBAction)vieonmal:(id)sender {
    switch ([listservice getCurrentServiceID]) {
        case 1: {
            if (_characterviewcontroller.persontype == PersonCharacter) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/character/%i",_characterviewcontroller.selectedid]]];
            }
            else {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/people/%i",_characterviewcontroller.selectedid]]];
            }
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            if (_characterviewcontroller.persontype == PersonCharacter) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/character/%i",_characterviewcontroller.selectedid]]];
            }
            else {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/staff/%i",_characterviewcontroller.selectedid]]];
            }
            break;
        }
        default:
            break;
    }
            
}

- (IBAction)share:(id)sender {
    //Generate Items to Share
    NSArray *shareItems = @[];
    switch ([listservice getCurrentServiceID]) {
        case 1: {
            if (_characterviewcontroller.persontype == PersonCharacter) {
                shareItems = @[[NSString stringWithFormat:@"Check out %@ out on MyAnimeList ", [Utility convertNameFormat:_characterviewcontroller.charactername.stringValue]], [NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/character/%i", _characterviewcontroller.selectedid]]];
            }
            else {
                shareItems = @[[NSString stringWithFormat:@"Check out %@ out on MyAnimeList ", [Utility convertNameFormat:_characterviewcontroller.charactername.stringValue]], [NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/people/%i", _characterviewcontroller.selectedid]]];
            }
            break;
        }
        case 3: {
            if (_characterviewcontroller.persontype == PersonCharacter) {
                shareItems = @[[NSString stringWithFormat:@"Check out %@ out on AniList ", [Utility convertNameFormat:_characterviewcontroller.charactername.stringValue]], [NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/character/%i", _characterviewcontroller.selectedid]]];
            }
            else {
                shareItems = @[[NSString stringWithFormat:@"Check out %@ out on AniList ", [Utility convertNameFormat:_characterviewcontroller.charactername.stringValue]], [NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/staff/%i", _characterviewcontroller.selectedid]]];
            }
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

- (NSDictionary *)retrievecharacterinformation:(int)idnum {
    NSArray *characters = _castdict[@"Characters"];
    for (NSDictionary *d in characters) {
        if (((NSNumber *)d[@"id"]).intValue == idnum) {
            return d;
        }
    }
    return nil;
}

- (void)retrievestaffinformation:(int)idnum {
    [self replaceMainViewSubViewWithView:_noselectionview];
    [self startstopanimation:true];
    [listservice retrievePersonDetails:idnum completion:^(id responseObject){
        [self startstopanimation:false];
        [_characterviewcontroller populateStaffInformation:responseObject];
        [self replaceMainViewSubViewWithView:_characterviewcontroller.view];
    }error:^(NSError *error) {
        [self startstopanimation:false];
    }];
}

- (NSArray *)generatevoiceactorlist:(NSArray *)characterarray {
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *d in characterarray) {
        if (d[@"actors"]) {
            NSArray *voiceactors = d[@"actors"];
            for (NSDictionary *actor in voiceactors) {
                if ([tmparray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", actor[@"id"]]].count == 0) {
                    [tmparray addObject:actor];
                }
            }
        }
    }
    return tmparray;
}

- (int)getIndexOfItemWithIdentifier:(NSString *)string {
    int index = 0;
    for (PXSourceListItem *item in _sourceListItems) {
        if (item.children.count > 0) {
            for (PXSourceListItem *childitem in item.children) {
                index++;
                if ([childitem.identifier isEqualToString:string]) {
                    return index;
                }
            }
        }
        index++;
    }
    return 0;
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
        _characterviewcontroller.view.appearance = [NSAppearance appearanceNamed:appearancename];
        [self.window setFrame:self.window.frame display:false];
    }
}

@end
