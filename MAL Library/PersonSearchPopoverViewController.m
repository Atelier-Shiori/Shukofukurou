//
//  PersonSearchPopoverViewController.m
//  Shukofukurou
//
//  Created by 香風智乃 on 12/10/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "PersonSearchPopoverViewController.h"
#import "listservice.h"
#import "imagetexttableviewcell.h"

@interface PersonSearchPopoverViewController ()
@property (strong) IBOutlet NSSegmentedControl *searchtype;
@property (strong) NSArray *searchcontent;
@property (strong) NSString *searchterm;
@end

@implementation PersonSearchPopoverViewController

- (instancetype)init {
    return [super initWithNibName:@"PersonSearchPopoverViewController" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _searchcontent = @[];
}
- (IBAction)searchtypechanged:(id)sender {
    [self performsearch:_searchterm];
}

- (void)performsearch:(NSString *)searchterm {
    _searchterm = searchterm;
    if (_searchterm.length == 0) {
        // Clear
        _searchcontent = @[];
        [_tableview reloadData];
    }
    else {
        [AniList searchPeople:_searchterm withType:(int)_searchtype.selectedSegment completion:^(id responseObject) {
            _searchcontent = responseObject;
            [_tableview reloadData];
        } error:^(NSError *error) {
            NSLog(@"%@",error.localizedDescription);
            _searchcontent = @[];
        }];
    }
}

#pragma mark NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _searchcontent.count;
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row {
    return _searchcontent[row];
}

#pragma mark NSTableViewDelegate
- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    NSDictionary *searchentry = _searchcontent[row];
    imagetexttableviewcell *cell = [_tableview makeViewWithIdentifier:@"charactercell" owner:nil];
    if (cell) {
        cell.textField.stringValue = searchentry[@"name"];
        [cell loadimage:searchentry[@"image"]];
        return cell;
    }
    return nil;
}
- (IBAction)doubleaction:(id)sender {
    if (_tableview.selectedRow > -1) {
        NSDictionary *personentry = _searchcontent[_tableview.selectedRow];
        int persontype = _searchtype.selectedSegment == 1 ? 0 : 1;
        [NSNotificationCenter.defaultCenter postNotificationName:@"loadpersondata" object:@{@"person_id" : personentry[@"id"], @"type" : @(persontype)}];
        [_popover close];
    }
}
@end
