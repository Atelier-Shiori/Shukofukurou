//
//  SeasonView.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "SeasonView.h"
#import "Utility.h"
#import "MainWindow.h"
#import "AniListSeasonListGenerator.h"
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
    if (_seasontableview.selectedRow >= 0) {
        if (_seasontableview.selectedRow > -1) {
            NSDictionary *d = _seasonarraycontroller.selectedObjects[0];
            switch ([listservice getCurrentServiceID]) {
                case 1: {
                    NSNumber *idnum = d[@"idMal"];
                    [_mw loadinfo:idnum type:0 changeView:YES];
                    break;
                }
                case 2: {
                    [TitleIdConverter getKitsuIDFromMALId:((NSNumber *)d[@"idMal"]).intValue withTitle:d[@"title"] titletype:@"" withType:KitsuAnime completionHandler:^(int kitsuid) {
                        [_mw loadinfo:@(kitsuid) type:0 changeView:YES];
                    } error:^(NSError *error) {
                        [Utility showsheetmessage:[NSString stringWithFormat:@"%@ could't be found on %@", d[@"title"], [listservice currentservicename]] explaination:@"Try searching for this title instead"  window:self.view.window];
                    }];
                    break;
                }
                case 3: {
                    [_mw loadinfo:d[@"id"] type:0 changeView:YES];
                }
                default:
                    break;
            }
        }
    }
}

- (IBAction)yearchange:(id)sender {
    [self loadseasondata:_seasonyrpicker.title.intValue forSeason: _seasonpicker.title];
}

- (IBAction)seasonchange:(id)sender {
    [self loadseasondata:_seasonyrpicker.title.intValue forSeason: _seasonpicker.title];
}
- (void)populateseasonpopups{
    [self populateyearpopup];
}

- (void)loadseasondata:(int)year forSeason:(NSString *)season{
    if (_seasonyrpicker.itemArray.count > 0){
        if ([Utility checkifFileExists:[NSString stringWithFormat:@"%i-%@.json",year,season] appendPath:@"/anilistseasondata/"]){
            NSMutableArray *sarray = [_seasonarraycontroller mutableArrayValueForKey:@"content"];
            NSNumber *selectedAnimeID = nil;
            if (_seasontableview.selectedRow >= 0) {
                selectedAnimeID = _seasonarraycontroller.selectedObjects[0][@"id"];
            }
            [sarray removeAllObjects];
            NSArray *a =  [Utility loadJSON:[NSString stringWithFormat:@"%i-%@.json",year,season] appendpath:@"/anilistseasondata/"];
            a = [a sortedArrayUsingDescriptors:_seasonarraycontroller.sortDescriptors];
            [_seasonarraycontroller addObjects:a];
            [_seasontableview reloadData];
            [_seasontableview deselectAll:self];
            if (selectedAnimeID != nil) {
                for (NSUInteger index = 0; index < a.count; index++) {
                    if (((NSNumber *)a[index][@"id"]).intValue == selectedAnimeID.intValue) {
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

- (void)populateyearpopup {
    [_seasonyrpicker removeAllItems];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    int currentyear = 1990;
    while (currentyear <= components.year) {
        [_seasonyrpicker addItemWithTitle:@(currentyear).stringValue];
        currentyear++;
    }
    [_seasonyrpicker selectItemAtIndex:_seasonyrpicker.itemArray.count-1];
    [self loadseasondata:_seasonyrpicker.title.intValue forSeason: _seasonpicker.title];
}

- (void)performseasondataretrieval:(int)year forSeason:(NSString *)season loaddata:(bool)loaddata {
    [AniListSeasonListGenerator retrieveSeasonDataWithSeason:season withYear:year completion:^(id responseObject) {
        [Utility saveJSON:responseObject withFilename:[NSString stringWithFormat:@"%i-%@.json",year,season] appendpath:@"/anilistseasondata/" replace:true];
        if (loaddata){
            [self loadseasondata:year forSeason:season];
        }
    } error:^(NSError *error) {
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
