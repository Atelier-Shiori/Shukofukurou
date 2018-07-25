//
//  CustomListsPopover.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/07/25.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "CustomListsPopover.h"

@interface CustomListsPopover ()

@end

@implementation CustomListsPopover

- (instancetype)init {
    return [super initWithNibName:@"CustomListsPopover" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)populateandshowCustomLists:(NSArray *)clistarray {
    NSMutableArray *a = [_customlistarraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [a addObjectsFromArray:clistarray];
    [self view];
    [_tableview reloadData];
    [_tableview deselectAll:self];
}

- (IBAction)doubleclickaction:(id)sender {
    if (_tableview.selectedRow >=0) {
        if (_tableview.selectedRow >-1) {
            NSDictionary *d = _customlistarraycontroller.selectedObjects[0];
            _actionblock(d[@"name"]);
        }
    }
}
@end
