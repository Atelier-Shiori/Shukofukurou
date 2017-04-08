//
//  AiringView.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/07.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "AiringView.h"
#import "HistoryView.h"
#import <AFNetworking/AFNetworking.h>
#import "Utility.h"
#import "NSTableViewAction.h"
#import "MainWindow.h"

@interface AiringView ()
@property bool selected;
@end

@implementation AiringView

- (id)init
{
    return [super initWithNibName:@"AiringView" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [_addtitleitem setEnabled:NO];
}

- (void)loadAiring:(NSNumber *)refresh{
    id list;
    bool refreshlist = refresh.boolValue;
    bool exists = [Utility checkifFileExists:@"airing.json" appendPath:@""];
    list = [Utility loadJSON:@"airing.json" appendpath:@""];
    NSDate * refresheddate = [[NSUserDefaults standardUserDefaults] valueForKey:@"airschdaterefreshed"];
    if (exists && !refreshlist && [refresheddate timeIntervalSinceNow] > -2592000){
        [self populateAiring:list];
        return;
    }
    else if (!exists || refreshlist){
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        [manager GET:[NSString stringWithFormat:@"%@/2.1/anime/schedule",[[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [self populateAiring:[Utility saveJSON:[self processAiring:responseObject] withFilename:@"airing.json" appendpath:@"" replace:TRUE]];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"airschdaterefreshed"];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"%@", error.userInfo);
        }];
    }
    
}
- (void)populateAiring:(id)airing{
    // Populates history
    NSMutableArray * a = [_airingarraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_airingarraycontroller addObjects:airing];
    [self filterTitles];
    [_airingtb reloadData];
    [_airingtb deselectAll:self];
}
- (void)clearHistory{
    NSMutableArray * a = [_airingarraycontroller content];
    [a removeAllObjects];
    [Utility deleteFile:@"airing.json" appendpath:@""];
    [self.airingtb reloadData];
    [self.airingtb deselectAll:self];
}
- (IBAction)airingdoubleclick:(id)sender {
    if ([_airingtb selectedRow] >=0){
        if ([_airingtb selectedRow] >-1){
            NSDictionary *d = [[_airingarraycontroller selectedObjects] objectAtIndex:0];
            NSNumber * idnum = d[@"id"];
            [_mw loadinfo:idnum type:0];
        }
    }
}
- (IBAction)changedayfilter:(id)sender{
    [self filterTitles];
}

- (void)filterTitles{
    [_airingarraycontroller setFilterPredicate:[NSPredicate predicateWithFormat:@"day == [cd] %@",_day.title]];
}

-(id)processAiring:(id)object{
    NSDictionary * d = object;
    NSMutableArray * airing = [NSMutableArray new];
    NSArray * tmparray;
    NSString * day;
    for (int i = 0; i < 9; i++){
        switch (i){
            case 0: // Monday
                day = @"monday";
                break;
            case 1: // Tuesday
                day = @"tuesday";
                break;
            case 2: // Wednesday
                day = @"wednesday";
                break;
            case 3: // Thursday
                day = @"thursday";
                break;
            case 4: // Friday
                day = @"friday";
                break;
            case 5: // Saturday
                day = @"saturday";
                break;
            case 6: // Sunday
                day = @"sunday";
                break;
            case 7: // Other
                day = @"other";
                break;
            case 8: // Unknown
                day = @"unknown";
                break;
            default:
                break;
        }
        if (d[day] != nil){
            tmparray = d[day];
            for (NSDictionary * entry in tmparray){
                NSMutableDictionary * newentry = [[NSMutableDictionary alloc] initWithDictionary:entry];
                [newentry setValue:[day uppercaseString] forKey:@"day"];
                [airing addObject:newentry];
            }
        }
        else{
            continue;
        }
    }
    return airing;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([[_airingarraycontroller selectedObjects] count] > 0){
        [_addtitleitem setEnabled:YES];
    }
    else {
        [_addtitleitem setEnabled:NO];
    }
}

@end
