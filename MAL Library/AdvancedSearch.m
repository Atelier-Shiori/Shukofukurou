//
//  AdvancedSearch.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "AdvancedSearch.h"
#import "NSTextFieldNumber.h"
#import "MainWindow.h"
#import <AFNetworking/AFNetworking.h>
#import "Utility.h"


@interface AdvancedSearch ()

@end

@implementation AdvancedSearch
- (id)init
{
    return [super initWithNibName:@"AdvancedSearch" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    // Set dates
    [self resetdate];

}

- (IBAction)performadvancedsearch:(id)sender {
    __block NSButton * btn = sender;
    [popover setBehavior:NSPopoverBehaviorApplicationDefined];
    [btn setEnabled:NO];
    NSMutableDictionary * d = [NSMutableDictionary new];
    [d setValue:_searchfield.stringValue forKey:@"keyword"];
    [d setValue:_minscore.stringValue forKey:@"score"];
    [d setValue:@(_exclude.state) forKey:@"genre_type"];
    if ([(NSArray *)_genretokenfield.objectValue count] > 0){
        [d setValue:[(NSArray *)_genretokenfield.objectValue componentsJoinedByString:@","] forKey:@"genres"];
    }
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"YYYY-MM-DD"];
    if (_usestartdate.state == 1){
        [d setValue:[dateformat stringFromDate:[_startdate dateValue]] forKey:@"start_date"];
    }
    if (_useenddate.state == 1){
        [d setValue:[dateformat stringFromDate:[_enddate dateValue]] forKey:@"end_date"];
    }
    [d setValue:@(_airstatus.selectedTag) forKey:@"status"];
    [d setValue:@(_rating.selectedTag) forKey:@"rating"];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"https://malapi.ateliershiori.moe/2.1/anime/browse" parameters:d progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [mw populatesearchtb:responseObject];
        [btn setEnabled:YES];
        [popover setBehavior:NSPopoverBehaviorTransient];
        [popover close];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [mw clearsearchtb];
        [btn setEnabled:YES];
        [popover setBehavior:NSPopoverBehaviorTransient];
        [popover close];
    }];
}
- (IBAction)usedaterange:(id)sender {
    if (_usestartdate.state == 0){
        [_startdate setEnabled:NO];
    }
    else {
        [_startdate setEnabled:YES];
    }
    if (_useenddate.state == 0){
        [_enddate setEnabled:NO];
    }
    else {
        [_enddate setEnabled:YES];
    }
}
- (IBAction)resetfields:(id)sender {
    _searchfield.stringValue = @"";
    _genretokenfield.stringValue = @"";
    _exclude.state = 0;
    _usestartdate.state = 0;
    _useenddate.state = 0;
    [self usedaterange:sender];
    _minscore.stringValue = @"0";
    [self resetdate];
    [_airstatus selectItemAtIndex:0];
    [_rating selectItemAtIndex:0];
    
}
- (void)resetdate{
    [_startdate setDateValue:[[NSDate alloc] initWithTimeIntervalSinceNow:-315360000]]; // Last 10 years from today's date
    [_enddate setDateValue:[NSDate date]];
}
@end
