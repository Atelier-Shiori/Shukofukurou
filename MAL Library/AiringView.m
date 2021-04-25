//
//  AiringView.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2017/04/07.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "AiringView.h"
#import "AiringSchedule.h"
#import <Hakuchou/AtarashiiAPIListFormatAniList.h>
#import <AFNetworking/AFNetworking.h>
#import "Utility.h"
#import "NSTableViewAction.h"
#import "MainWindow.h"
#import "listservice.h"

@interface AiringView ()
@property bool selected;
@property (strong) IBOutlet NSVisualEffectView *loadingview;
@property (strong) IBOutlet NSProgressIndicator *loadingindicator;
@property (strong) IBOutlet NSMenuItem *addtitlemenuitem;
@property (strong) IBOutlet NSMenuItem *viewtitlemenuitem;
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
    _loadingview.wantsLayer = YES;
    _loadingview.layer.cornerRadius = 15.0;
}

- (void)fetchnewAiringData {
    [AiringSchedule autofetchAiringScheduleWithCompletionHandler:^(bool success, bool refreshed) {
        if (success && refreshed) {
            [self repopulateAiringData];
        }
    }];
}

- (void)loadAiring:(NSNumber *)refresh {
    NSDate *refresheddate = [[NSUserDefaults standardUserDefaults] valueForKey:@"airschdaterefreshed"];
    bool shouldrefresh = refresh.boolValue ? refresh.boolValue : (!refresheddate || refresheddate.timeIntervalSinceNow < -2592000);
    [self showloading:YES];
    [self retrieveAiringSchedule:shouldrefresh completion:^(id responseobject) {
        [self populateAiring:responseobject];
        [self showloading:NO];
    } error:^(NSError * error) {
        NSLog(@"Can't retrieve airing data.");
        [self showloading:NO];
    }];
}

- (void)repopulateAiringData {
    [self populateAiring:[AiringSchedule retrieveAiringData]];
}

- (void)retrieveAiringSchedule:(bool)refresh completion:(void (^)(id responseobject))completionHandler error:(void (^)(NSError *error))errorHandler {
    
    [AiringSchedule retrieveAiringScheduleShouldRefresh:refresh completionhandler:^(bool success, bool refreshed) {
        if (success) {
            completionHandler([AiringSchedule retrieveAiringData]);
        }
    }];
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
            switch ([listservice.sharedInstance getCurrentServiceID]) {
                case 1: {
                    [NSNotificationCenter.defaultCenter postNotificationName:@"LoadTitleInfo" object:@{@"id" : d[@"idMal"], @"type" : @(0)}];
                    break;
                }
                case 2: {
                    [[TitleIDMapper sharedInstance] retrieveTitleIdForService:3 withTitleId:d[@"id"] withTargetServiceId:2 withType:0 completionHandler:^(id  _Nonnull titleid, bool success) {
                        if (success && titleid && titleid != [NSNull null]  && ((NSNumber *)titleid).intValue > 0) {
                            [NSNotificationCenter.defaultCenter postNotificationName:@"LoadTitleInfo" object:@{@"id" : @(((NSNumber *)titleid).intValue), @"type" : @(0)}];
                        }
                        else {
                            [Utility showsheetmessage:[NSString stringWithFormat:@"%@ could't be found on %@", d[@"title"], [listservice.sharedInstance currentservicename]] explaination:@"Try searching for this title instead"  window:self.view.window];
                        }
                    }];
                    break;
                }
                case 3: {
                    [NSNotificationCenter.defaultCenter postNotificationName:@"LoadTitleInfo" object:@{@"id" : d[@"id"], @"type" : @(0)}];
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

- (void)showloading:(bool)loading {
    if (loading) {
        _loadingview.hidden = NO;
        [_loadingindicator startAnimation:self];
    }
    else {
        _loadingview.hidden = YES;
        [_loadingindicator stopAnimation:self];
    }
}

#pragma mark Context Menu
- (void)menuWillOpen:(NSMenu *)menu {
    long selected = self.airingtb.clickedRow;
    if (selected >= 0) {
        _addtitlemenuitem.enabled = [listservice.sharedInstance checkAccountForCurrentService];
        _viewtitlemenuitem.enabled = true;
    }
    else {
        _addtitlemenuitem.enabled = false;
        _viewtitlemenuitem.enabled = false;
    }
}
- (IBAction)rightclickAddTitle:(id)sender {
    long selected = self.airingtb.clickedRow;
    [self.airingtb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:selected] byExtendingSelection:NO];
    [_mw showaddpopover:_addtitleitem];
}
- (IBAction)rightclickViewTitle:(id)sender {
    long selected = self.airingtb.clickedRow;
    [self.airingtb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:selected] byExtendingSelection:NO];
    [self airingdoubleclick:sender];
}
@end
