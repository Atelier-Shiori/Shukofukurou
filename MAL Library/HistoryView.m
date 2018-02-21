//
//  HistoryView.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/07.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "HistoryView.h"
#import "Utility.h"
#import "Keychain.h"
#import "NSTableViewAction.h"
#import "MainWindow.h"
//#import "MyAnimeList.h"
#import "listservice.h"
@interface HistoryView ()

@end

@implementation HistoryView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (void)loadHistory:(NSNumber *)refresh{
    id list;
    bool refreshlist = refresh.boolValue;
    bool exists = [Utility checkifFileExists:[listservice retrieveHistoryFileName] appendPath:@""];
    if (exists && !refreshlist) {
        list = [Utility loadJSON:[listservice retrieveHistoryFileName] appendpath:@""];
        [self populateHistory:list];
        return;
    }
    else if (!exists || refreshlist) {
        [listservice retriveUpdateHistory:[listservice getCurrentServiceUsername] completion:^(id response){
            [self populateHistory:[Utility saveJSON:response withFilename:[listservice retrieveHistoryFileName] appendpath:@"" replace:TRUE]];
        }error:^(NSError *error){
            NSLog(@"%@", error.userInfo);
        }];
    }

}
- (void)populateHistory:(id)history {
    // Populates history
    NSMutableArray *a = [_historyarraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_historyarraycontroller addObjects:history];
    if (!((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"]).boolValue) {
        _historyarraycontroller.filterPredicate = [NSPredicate predicateWithFormat:@"type == [cd] %@", @"anime"];
    }
    else {
        [_historyarraycontroller setFilterPredicate:nil];
    }
    [_historytb reloadData];
    [_historytb deselectAll:self];
}
- (void)clearHistory {
    [self clearHistory:[listservice getCurrentServiceID]];
}
- (void)clearHistory:(int)serviceid {
    [Utility deleteFile:[listservice retrieveHistoryFileName:serviceid] appendpath:@""];
    if ([listservice getCurrentServiceID] == serviceid) {
        NSMutableArray *a = _historyarraycontroller.content;
        [a removeAllObjects];
        [self.historytb reloadData];
        [self.historytb deselectAll:self];
    }
}
- (IBAction)historydoubleclick:(id)sender {
    if (_historytb.selectedRow >=0) {
        if (_historytb.selectedRow >-1) {
            NSDictionary *d = _historyarraycontroller.selectedObjects[0];
            NSNumber *idnum = d[@"id"];
            NSString *type = d[@"type"];
            int typenum = 0;
            if ([type isEqualToString:@"anime"]) {
                typenum = 0;
            }
            else {
                typenum = 1;
            }
            [_mw loadinfo:idnum type:typenum];
        }
    }
}
@end
