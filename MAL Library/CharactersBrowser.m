//
//  CharactersBrowser.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/07/26.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "CharactersBrowser.h"
#import "CharacterView.h"
#import "MyAnimeList.h"
#import <CocoaOniguruma/OnigRegexp.h>
#import <CocoaOniguruma/OnigRegexpUtility.h>

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
    [_mainview addSubview:[NSView new]];
    _characterviewcontroller = [CharacterView new];
    // Set Resizing masks
    _noselectionview.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    _characterviewcontroller.view.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    [self setDefaultView];
    [self enabletoolbaritems:NO];
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
    if([[group identifier] isEqualToString:@"characters"])
        return YES;
    else if([[group identifier] isEqualToString:@"staff"])
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

- (void) splitView:(NSSplitView*) splitView resizeSubviewsWithOldSize:(NSSize) oldSize
{
    if (splitView == _splitview)
    {
        CGFloat dividerPos = NSWidth([[[splitView subviews] objectAtIndex:0] frame]);
        CGFloat width = NSWidth([splitView frame]);
        
        if (dividerPos < 0)
            dividerPos = 0;
        if (width - dividerPos < 528 + [splitView dividerThickness])
            dividerPos = width - (528 + [splitView dividerThickness]);
        
        [splitView adjustSubviews];
        [splitView setPosition:dividerPos ofDividerAtIndex:0];
    }
}

- (CGFloat) splitView:(NSSplitView*) splitView constrainSplitPosition:(CGFloat) proposedPosition ofSubviewAt:(NSInteger) dividerIndex
{
    if (splitView == _splitview)
    {
        CGFloat width = NSWidth([splitView frame]);
        
        if (ABS(167 - proposedPosition) <= 8)
            proposedPosition = 180;
        if (proposedPosition < 0)
            proposedPosition = 0;
        if (width - proposedPosition < 528 + [splitView dividerThickness])
            proposedPosition = width - (528 + [splitView dividerThickness]);
    }
    
    return proposedPosition;
}

- (void)retrievestafflist:(int)idnum {
    [MyAnimeList retrieveStaff:idnum completion:^(id responseObject){
        [self generateSourceList:responseObject];
        _selectedtitleid = idnum;
        [self enabletoolbaritems:NO];
    }error:^(NSError *error){
        
    }];
}

-(void)generateSourceList:(NSDictionary *)d {
    // Generates source list
    self.sourceListItems = [[NSMutableArray alloc] init];
    PXSourceListItem *characterItem = [PXSourceListItem itemWithTitle:@"CHARACTERS" identifier:@"characters"];
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
    [self.sourceListItems addObject:staffItem];
    [_sourceList reloadData];
    _castdict = d;
    [self setDefaultView];
}


- (void)splitViewDidResizeSubviews:(NSNotification *)notification{
    [self.window setFrame:self.window.frame display:false];
}

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
}

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

- (NSDictionary *)retrievecharacterinformation:(int)idnum {
    NSArray *characters = _castdict[@"Characters"];
    for (NSDictionary *d in characters) {
        if (((NSNumber *)d[@"id"]).intValue == idnum) {
            return d;
        }
    }
    return nil;
}
- (void)enabletoolbaritems:(bool)enable {
    _toolbarshare.enabled = enable;
    _toolbarviewonmal.enabled = enable;
}
@end
