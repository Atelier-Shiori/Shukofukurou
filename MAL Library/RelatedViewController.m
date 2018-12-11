//
//  RelatedViewController.m
//  Shukofukurou
//
//  Created by 香風智乃 on 12/11/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "RelatedViewController.h"
#import <CocoaOniguruma/OnigRegexp.h>
#import <CocoaOniguruma/OnigRegexpUtility.h>

@interface RelatedViewController ()
@property (strong, nonatomic) NSMutableArray *sourceListItems;
@end

@implementation RelatedViewController

- (instancetype)init {
    return [super initWithNibName:@"RelatedViewController" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (bool)hasRelatedTitles {
    return _sourceListItems.count > 0;
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
    return YES;
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

- (void)generateRelated:(NSDictionary *)titleinfo withType:(int)type {
    if (!_sourceListItems) {
        self.sourceListItems = [[NSMutableArray alloc] init];
    }
    else {
        [_sourceListItems removeAllObjects];
    }
    if (titleinfo[@"manga_adaptations"]) {
        if (((NSArray *)titleinfo[@"manga_adaptations"]).count > 0){
            [self generateSourceListItemWithArray:titleinfo[@"manga_adaptations"] withGroupTitle:@"MANGA ADAPTATIONS" withIdentifier:@"manga_adaptations"];
        }
    }
    if (titleinfo[@"anime_adaptations"]) {
        if (((NSArray *)titleinfo[@"anime_adaptations"]).count > 0){
            [self generateSourceListItemWithArray:titleinfo[@"anime_adaptations"] withGroupTitle:@"ANIME ADAPTATIONS" withIdentifier:@"anime_adaptations"];
        }
    }
    if (titleinfo[@"prequels"]) {
        if (((NSArray *)titleinfo[@"prequels"]).count > 0){
            [self generateSourceListItemWithArray:titleinfo[@"prequels"] withGroupTitle:@"PREQUELS" withIdentifier:@"prequels"];
        }
    }
    if (titleinfo[@"sequels"]) {
        if (((NSArray *)titleinfo[@"sequels"]).count > 0){
            [self generateSourceListItemWithArray:titleinfo[@"sequels"] withGroupTitle:@"SEQUELS" withIdentifier:@"sequels"];
        }
    }
}

- (void)generateSourceListItemWithArray:(NSArray *)entries withGroupTitle:(NSString *)grouptitle withIdentifier:(NSString *)identifier {
    PXSourceListItem *item = [PXSourceListItem itemWithTitle:grouptitle identifier:identifier];
    NSMutableArray *groupitems = [NSMutableArray new];
    for (NSDictionary *entry in entries) {
        int relatedtype = entry[@"anime_id"] ? 0 : entry[@"manga_id"] ? 1 : -1;
        PXSourceListItem *item = [PXSourceListItem itemWithTitle:entry[@"title"] identifier:[NSString stringWithFormat:@"%@-%@", relatedtype == 0 ? @"anime" : @"manga", relatedtype == 0 ? entry[@"anime_id"] : entry[@"manga_id"]]];
        [groupitems addObject:item];
    }
    item.children = groupitems;
    [_sourceListItems addObject:item];
}
- (IBAction)doubleaction:(id)sender {
    NSIndexSet *selectedIndexes = _sourceList.selectedRowIndexes;
    if (selectedIndexes) {
        NSString *tmpstring = [[_sourceList itemAtRow:selectedIndexes.firstIndex] identifier];
        OnigRegexp *regex = [OnigRegexp compile:@"(anime|manga)-"];
        NSString *type = [regex search:tmpstring].strings[0];
        int idnum = [tmpstring stringByReplacingOccurrencesOfString:type withString:@""].intValue;
        type = [type stringByReplacingOccurrencesOfString:@"-" withString:@""];
        int persontype = [type isEqualToString:@"manga"] ? 1 : 0;
        [NSNotificationCenter.defaultCenter postNotificationName:@"LoadTitleInfo" object:@{@"id" : @(idnum), @"type" : @(persontype)}];
    }
}

@end
