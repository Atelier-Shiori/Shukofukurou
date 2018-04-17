//
//  AiringView.m
//  Shukofukuro
//
//  Created by 天々座理世 on 2017/04/07.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "AiringView.h"
#import <AFNetworking/AFNetworking.h>
#import "Utility.h"
#import "NSTableViewAction.h"
#import "MainWindow.h"
#import "listservice.h"

@interface AiringView ()
@property bool selected;
@end

@implementation AiringView

- (instancetype)init {
    return [super initWithNibName:@"AiringView" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [_addtitleitem setEnabled:NO];
    [self autoselectday];
    [self filterTitles];
}

- (void)loadAiring:(NSNumber *)refresh {
    id list;
    bool refreshlist = refresh.boolValue;
    bool exists = [Utility checkifFileExists:@"airing.json" appendPath:@""];
    list = [Utility loadJSON:@"airing.json" appendpath:@""];
    NSDate *refresheddate = [[NSUserDefaults standardUserDefaults] valueForKey:@"airschdaterefreshed"];
    if (exists && !refreshlist && refresheddate.timeIntervalSinceNow > -2592000) {
        [self populateAiring:list];
        return;
    }
    else if (!exists || refreshlist) {
        AFHTTPSessionManager *manager = [Utility jsonmanager];
        
        [manager GET:[NSString stringWithFormat:@"%@/2.1/anime/schedule",[[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [self populateAiring:[Utility saveJSON:[self processAiring:responseObject] withFilename:@"airing.json" appendpath:@"" replace:TRUE]];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"airschdaterefreshed"];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"%@", error.userInfo);
        }];
    }
    
}
- (void)populateAiring:(id)airing {
    // Populates history
    NSNumber *selectedAnimeID = nil;
    if (_airingtb.selectedRow >= 0) {
        selectedAnimeID = _airingarraycontroller.selectedObjects[0][@"id"];
    }
    NSMutableArray *a = [_airingarraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_airingarraycontroller addObjects:airing];
    [self filterTitles];
    [_airingtb reloadData];
    if (selectedAnimeID != nil) {
        for (NSUInteger index = 0; index < a.count; index++) {
            if ([_airingarraycontroller mutableArrayValueForKey:@"content"][index][@"id"] == selectedAnimeID) {
                [_airingarraycontroller setSelectionIndex:index];
                break;
            }
        }
    }
    else {
        [_airingtb deselectAll:self];
    }
}
- (void)clearHistory {
    NSMutableArray *a = _airingarraycontroller.content;
    [a removeAllObjects];
    [Utility deleteFile:@"airing.json" appendpath:@""];
    [self.airingtb reloadData];
    [self.airingtb deselectAll:self];
}
- (IBAction)airingdoubleclick:(id)sender {
    if (_airingtb.selectedRow >=0) {
        if (_airingtb.selectedRow >-1) {
            NSDictionary *d = _airingarraycontroller.selectedObjects[0];
            switch ([listservice getCurrentServiceID]) {
                case 1: {
                    NSNumber *idnum = @([NSString stringWithFormat:@"%@",d[@"id"]].integerValue);
                    [_mw loadinfo:idnum type:0 changeView:YES];
                    break;
                }
                case 2: {
                    [TitleIdConverter getKitsuIDFromMALId:[NSString stringWithFormat:@"%@",d[@"id"]].intValue withTitle:d[@"title"] titletype:d[@"type"] withType:KitsuAnime completionHandler:^(int kitsuid) {
                        [_mw loadinfo:@(kitsuid) type:0 changeView:YES];
                    } error:^(NSError *error) {
                        
                    }];
                    break;
                }
                case 3: {
                    [TitleIdConverter getAniIDFromMALListID:[NSString stringWithFormat:@"%@",d[@"id"]].intValue  withTitle:d[@"title"] titletype:d[@"type"] withType:MALAnime completionHandler:^(int anilistid) {
                        [_mw loadinfo:@(anilistid) type:0 changeView:YES];
                    } error:^(NSError *error) {
                    }];
                }
                default:
                    break;
            }
        }
    }
}
- (IBAction)changedayfilter:(id)sender {
    [self filterTitles];
}

- (void)filterTitles{
    _airingarraycontroller.filterPredicate = [NSPredicate predicateWithFormat:@"day == [cd] %@",_day.title];
}

-(id)processAiring:(id)object {
    NSDictionary *d = object;
    NSMutableArray *airing = [NSMutableArray new];
    NSArray *tmparray;
    NSString *day;
    for (int i = 0; i < 9; i++) {
        switch (i) {
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
        if (d[day] != nil) {
            tmparray = d[day];
            for (NSDictionary *entry in tmparray) {
                NSMutableDictionary *newentry = [[NSMutableDictionary alloc] initWithDictionary:entry];
                [newentry setValue:day.uppercaseString forKey:@"day"];
                [airing addObject:newentry];
            }
        }
        else {
            continue;
        }
    }
    return airing;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (_airingarraycontroller.selectedObjects.count > 0) {
        _addtitleitem.enabled = YES;
    }
    else {
        _addtitleitem.enabled = NO;
    }
}

- (void)autoselectday {
    // Auto selects day popup based on the computer's date.
    NSDateComponents *component = [NSCalendar.currentCalendar components:NSCalendarUnitWeekday fromDate:NSDate.date];
    switch (component.weekday) {
        case 1:
            //Sunday
            [_day selectItemWithTitle:@"Sunday"];
            break;
        case 2:
            //Monday
            [_day selectItemWithTitle:@"Monday"];
            break;
        case 3:
            //Tuesday
            [_day selectItemWithTitle:@"Tuesday"];
            break;
        case 4:
            //Wednesday
            [_day selectItemWithTitle:@"Wednesday"];
            break;
        case 5:
            //Thursday
            [_day selectItemWithTitle:@"Thursday"];
            break;
        case 6:
            //Friday
            [_day selectItemWithTitle:@"Friday"];
            break;
        case 7:
            //Saturday
            [_day selectItemWithTitle:@"Saturday"];
            break;
        default:
            break;
    }
}
@end
