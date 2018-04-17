//
//  SeasonView.m
//  Shukofukuro
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "SeasonView.h"
#import "Utility.h"
#import "MainWindow.h"
#import <AFNetworking/AFNetworking.h>
#import "listservice.h"

@interface SeasonView ()
@property (strong) IBOutlet NSPopUpButton *seasonyrpicker;
@property (strong) IBOutlet NSPopUpButton *seasonpicker;
@end

@implementation SeasonView

- (instancetype)init {
    return [super initWithNibName:@"SeasonView" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}


#pragma mark Seasons View
- (IBAction)seasondoubleclick:(id)sender {
    if (_seasontableview.selectedRow >=0){
        if (_seasontableview.selectedRow >-1){
            NSDictionary *d = _seasonarraycontroller.selectedObjects[0];
            switch ([listservice getCurrentServiceID]) {
                case 1: {
                    NSNumber *idnum = @([NSString stringWithFormat:@"%@",d[@"id"][@"id"]].integerValue);
                    [_mw loadinfo:idnum type:0 changeView:YES];
                    break;
                }
                case 2: {
                    [TitleIdConverter getKitsuIDFromMALId:[NSString stringWithFormat:@"%@",d[@"id"][@"id"]].intValue withTitle:d[@"title"] titletype:@"" withType:KitsuAnime completionHandler:^(int kitsuid) {
                        [_mw loadinfo:@(kitsuid) type:0 changeView:YES];
                    } error:^(NSError *error) {
                        [Utility showsheetmessage:[NSString stringWithFormat:@"%@ could't be found on %@", d[@"title"], [listservice currentservicename]] explaination:@"Try searching for this title instead"  window:self.view.window];
                    }];
                    break;
                }
                case 3: {
                    [TitleIdConverter getAniIDFromMALListID:[NSString stringWithFormat:@"%@",d[@"id"][@"id"]].intValue withTitle:d[@"title"] titletype:@"" withType:MALAnime completionHandler:^(int anilistid) {
                        [_mw loadinfo:@(anilistid) type:0 changeView:YES];
                    } error:^(NSError *error) {
                        [Utility showsheetmessage:[NSString stringWithFormat:@"%@ could't be found on %@", d[@"title"], [listservice currentservicename]] explaination:@"Try searching for this title instead"  window:self.view.window];
                    }];
                }
                default:
                    break;
            }
        }
    }
}

- (IBAction)yearchange:(id)sender {
    [self populateseasonpopup];
}

- (IBAction)seasonchange:(id)sender {
    [self loadseasondata:_seasonyrpicker.title.intValue forSeason: _seasonpicker.title];
}
- (void)populateseasonpopups{
    if ([Utility checkifFileExists:@"index.json" appendPath:@"/seasondata/"]){
        [self populateyearpopup];
    }
    else {
        [self performseasonindexretrieval];
    }
}
- (void)loadseasondata:(int)year forSeason:(NSString *)season{
    if (_seasonyrpicker.itemArray.count > 0){
        if ([Utility checkifFileExists:[NSString stringWithFormat:@"%i-%@.json",year,season] appendPath:@"/seasondata/"]){
            NSMutableArray *sarray = [_seasonarraycontroller mutableArrayValueForKey:@"content"];
            NSString *selectedAnimeID = nil;
            if (_seasontableview.selectedRow >= 0) {
                selectedAnimeID = _seasonarraycontroller.selectedObjects[0][@"id"][@"id"];
            }
            [sarray removeAllObjects];
            NSDictionary *d =  [Utility loadJSON:[NSString stringWithFormat:@"%i-%@.json",year,season] appendpath:@"/seasondata/"];
            NSArray *a = d[@"anime"];
            a = [a sortedArrayUsingDescriptors:_seasonarraycontroller.sortDescriptors];
            [_seasonarraycontroller addObjects:a];
            [_seasontableview reloadData];
            [_seasontableview deselectAll:self];
            if (selectedAnimeID != nil) {
                for (NSUInteger index = 0; index < a.count; index++) {
                    if ([a[index][@"id"][@"id"] isEqualToString:selectedAnimeID]) {
                        [_seasonarraycontroller setSelectionIndex:index];
                        break;
                    }
                }
            }
        }
        else {
            [self performseasondataretrieval:year forSeason:season loaddata:true];
        }
    }
}
- (void)populateyearpopup{
    [_seasonyrpicker removeAllItems];
    NSDictionary *d = [Utility loadJSON:@"index.json" appendpath:@"/seasondata/"];
    NSArray *a = d[@"years"];
    for (int i = 0; i < a.count; i++){
        NSDictionary *yr = a[i];
        NSNumber *year = yr[@"year"];
        [_seasonyrpicker addItemWithTitle:year.stringValue];
    }
    [_seasonyrpicker selectItemAtIndex:_seasonyrpicker.itemArray.count-1];
    [self populateseasonpopup];
}
- (void)populateseasonpopup{
    [_seasonpicker removeAllItems];
    NSDictionary *d = [Utility loadJSON:@"index.json" appendpath:@"/seasondata/"];
    NSArray *a = d[@"years"];
    NSDictionary *yr = a[_seasonyrpicker.indexOfSelectedItem];
    NSArray *s = yr[@"seasons"];
    for (int i = 0; i < s.count; i++){
        NSDictionary *season = s[i];
        NSString *seasonname = season[@"season"];
        [_seasonpicker addItemWithTitle:seasonname];
    }
    [_seasonpicker selectItemAtIndex:_seasonpicker.itemArray.count-1];
    [self loadseasondata:_seasonyrpicker.title.intValue forSeason: _seasonpicker.title];
}
- (void)performseasonindexretrieval{
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager GET:@"https://raw.githubusercontent.com/Atelier-Shiori/anime-season-json/master/index.json" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [Utility saveJSON:responseObject withFilename:@"index.json" appendpath:@"/seasondata/" replace:true];
        [self populateyearpopup];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
- (void)performseasondataretrieval:(int)year forSeason:(NSString *)season loaddata:(bool)loaddata {
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager GET:[NSString stringWithFormat:@"https://raw.githubusercontent.com/Atelier-Shiori/anime-season-json/master/data/%i-%@.json",year,season] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [Utility saveJSON:responseObject withFilename:[NSString stringWithFormat:@"%i-%@.json",year,season] appendpath:@"/seasondata/" replace:true];
        if (loaddata){
            [self loadseasondata:year forSeason:season];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (_seasonarraycontroller.selectedObjects.count > 0){
        [_addtitleitem setEnabled:YES];
    }
    else {
        [_addtitleitem setEnabled:NO];
    }
}
@end
