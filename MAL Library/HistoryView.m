//
//  HistoryView.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/07.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "HistoryView.h"
#import <AFNetworking/AFNetworking.h>
#import "Utility.h"
#import "Keychain.h"
#import "NSTableViewAction.h"
#import "MainWindow.h"

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
    if (exists && !refreshlist){
        [self populateHistory:list];
        return;
    }
    else if (!exists || refreshlist){
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        [manager GET:[NSString stringWithFormat:@"%@/2.1/history/%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"], [Keychain getusername]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [self populateHistory:[Utility saveJSON:[self processHistory:responseObject] withFilename:@"history.json" appendpath:@"" replace:TRUE]];
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"%@", error.userInfo);
        }];
    }

}
- (void)populateHistory:(id)history{
    // Populates history
    NSMutableArray * a = [_historyarraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_historyarraycontroller addObjects:history];
    if (![(NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"] boolValue]){
        [_historyarraycontroller setFilterPredicate:[NSPredicate predicateWithFormat:@"type == [cd] %@", @"anime"]];
    }
    else {
        [_historyarraycontroller setFilterPredicate:nil];
    }
    [_historytb reloadData];
    [_historytb deselectAll:self];
}
- (void)clearHistory{
    NSMutableArray * a = [_historyarraycontroller content];
    [a removeAllObjects];
    [Utility deleteFile:@"history.json" appendpath:@""];
    [self.historytb reloadData];
    [self.historytb deselectAll:self];
}
- (IBAction)historydoubleclick:(id)sender {
    if ([_historytb selectedRow] >=0){
        if ([_historytb selectedRow] >-1){
            NSDictionary *d = [[_historyarraycontroller selectedObjects] objectAtIndex:0];
            NSNumber * idnum = d[@"id"];
            NSString * type = d[@"type"];
            int typenum = 0;
            if ([type isEqualToString:@"anime"]){
                typenum = 0;
            }
            else {
                typenum = 1;
            }
            [_mw loadinfo:idnum type:typenum];
        }
    }
}
-(id)processHistory:(id)object{
    NSArray * a = object;
    NSMutableArray * history = [NSMutableArray new];
    for (NSDictionary * d in a){
        NSDictionary * item = d[@"item"];
        NSNumber * idnum = item[@"id"];
        NSString * title = item[@"title"];
        NSString * type = d[@"type"];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init] ;
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString * strdate = d[@"time_updated"];
        strdate = [strdate substringWithRange:NSMakeRange(0, 10)];
        NSDate * datetime = [dateFormatter dateFromString:strdate];
        [dateFormatter setDateFormat:nil];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSString * lastupdated = [dateFormatter stringFromDate:datetime];
        [history addObject:@{@"id":idnum, @"title":title, @"type":type, @"last_updated":lastupdated}];
    }
    return history;
}
@end
