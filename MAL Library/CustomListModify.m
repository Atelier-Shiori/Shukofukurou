//
//  CustomListModify.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/07/25.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "AniList.h"
#import "AtarashiiListCoreData.h"
#import "CustomListModify.h"
#import "ListView.h"
#import "listservice.h"
#import "MainWindow.h"

@interface CustomListModify ()

@end

@implementation CustomListModify
- (instancetype)init {
    return [super initWithNibName:@"CustomListModify" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)populateCustomLists:(NSDictionary *)entry withCurrentType:(int)type withSelectedId:(int)selid {
    NSMutableArray *a = [_customlistsarray mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    NSString *cliststr = entry[@"custom_lists"];
    if (cliststr.length > 0) {
        NSArray *customlist = [cliststr componentsSeparatedByString:@","];
        // Process String
        for (NSString *clistentry in customlist) {
            bool enabled = [clistentry containsString:@"[true]"];
            NSString *customlistname = [[clistentry stringByReplacingOccurrencesOfString:@"[true]" withString:@""] stringByReplacingOccurrencesOfString:@"[false]" withString:@""];
            NSMutableDictionary *lentry = [NSMutableDictionary new];
            lentry[@"name"] = customlistname;
            lentry[@"enabled"] = @(enabled);
            [a addObject:lentry];
        }
    }
    [self view];
    [_tableview reloadData];
    _currenttype = type;
    _entryid = selid;
}

- (IBAction)saveaction:(id)sender {
    _popover.behavior = NSPopoverBehaviorApplicationDefined;
    _savebtn.enabled = false;
    [AniList modifyCustomLists:_entryid withCustomLists:[self generateCustomListArray] completion:^(id responseObject) {
        _popover.behavior = NSPopoverBehaviorTransient;
        _savebtn.enabled = true;
        if (responseObject[@"data"] != [NSNull null]) {
            NSString *customliststr = [self generateCustomListStringWithArray:responseObject[@"data"][@"SaveMediaListEntry"][@"customLists"]];
            [AtarashiiListCoreData updateSingleEntry:@{@"custom_lists" : customliststr} withUserId:[listservice getCurrentUserID] withService:[listservice getCurrentServiceID] withType:_currenttype withId:_entryid withIdType:1];
            [_mw loadlist:@(false) type:_currenttype];
        }
        [_popover close];
    } error:^(NSError *error) {
        NSLog(@"%@",error);
        _popover.behavior = NSPopoverBehaviorTransient;
        _savebtn.enabled = true;
    }];
}

- (NSArray *)generateCustomListArray {
    NSMutableArray *a = [_customlistsarray mutableArrayValueForKey:@"content"];
    NSMutableArray *finalarray = [NSMutableArray new];
    for (NSDictionary *customlistentry in a) {
        if (((NSNumber *)customlistentry[@"enabled"]).boolValue) {
            [finalarray addObject:customlistentry[@"name"]];
        }
    }
    return finalarray;
}
- (NSString *)generateCustomListStringWithArray:(NSArray *)clists {
    NSMutableArray *customlists = [NSMutableArray new];
    for (NSDictionary *clist in clists) {
        NSString *clistname = clist[@"name"];
        bool enabled = ((NSNumber *)clist[@"enabled"]).boolValue;
        NSString *finalstring = [NSString stringWithFormat:@"%@[%@]",clistname, enabled ? @"true" : @"false"];
        [customlists addObject:finalstring];
    }
    return [customlists componentsJoinedByString:@","];
}
@end
