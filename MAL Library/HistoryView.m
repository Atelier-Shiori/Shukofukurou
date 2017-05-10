//
//  HistoryView.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/07.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import "HistoryView.h"
#import "Utility.h"
#import "Keychain.h"
#import "NSTableViewAction.h"
#import "MainWindow.h"
#import "MyAnimeList.h"

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
    bool exists = [Utility checkifFileExists:@"history.json" appendPath:@""];
    list = [Utility loadJSON:@"history.json" appendpath:@""];
    if (exists && !refreshlist) {
        [self populateHistory:list];
        return;
    }
    else if (!exists || refreshlist) {
        [MyAnimeList retriveUpdateHistory:[Keychain getusername] completion:^(id response){
            [self populateHistory:[Utility saveJSON:response withFilename:@"history.json" appendpath:@"" replace:TRUE]];
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
- (void)clearHistory{
    NSMutableArray *a = _historyarraycontroller.content;
    [a removeAllObjects];
    [Utility deleteFile:@"history.json" appendpath:@""];
    [self.historytb reloadData];
    [self.historytb deselectAll:self];
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
