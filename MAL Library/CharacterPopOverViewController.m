//
//  CharacterPopOverViewController.m
//  Shukofukurou
//
//  Created by 香風智乃 on 12/10/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "CharacterPopOverViewController.h"
#import "listservice.h"
#import <CocoaOniguruma/OnigRegexp.h>
#import <CocoaOniguruma/OnigRegexpUtility.h>
#import "Utility.h"

@interface CharacterPopOverViewController ()
@property (strong, nonatomic) NSMutableArray *sourceListItems;
@property (strong) NSDictionary *castdict;
@end

@implementation CharacterPopOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.sourceListItems = [[NSMutableArray alloc] init];
}

- (instancetype)init {
    return [super initWithNibName:@"CharacterPopOverViewController" bundle:nil];
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
    //[self loadPerson];
    //[self enabletoolbaritems:YES];
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

#pragma mark -
#pragma mark Staff Source List

- (void)retrievestafflist:(int)idnum {
    [listservice retrieveStaff:idnum completion:^(id responseObject){
        [self generateSourceList:responseObject];
        _selectedtitleid = idnum;
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
- (IBAction)doubleaction:(id)sender {
    if (_sourceList.selectedRow > -1) {
        [self loadperson];
    }
}

- (void)loadperson {
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    NSString *tmpstring = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];
    OnigRegexp *regex = [OnigRegexp compile:@"(character|staff)-"];
    NSString *type = [regex search:tmpstring].strings[0];
    int idnum = [tmpstring stringByReplacingOccurrencesOfString:type withString:@""].intValue;
    type = [type stringByReplacingOccurrencesOfString:@"-" withString:@""];
    int persontype = [type isEqualToString:@"character"] ? 1 : 0;
    [NSNotificationCenter.defaultCenter postNotificationName:@"loadpersondata" object:@{@"person_id" : @(idnum), @"type" : @(persontype)}];
}
@end
