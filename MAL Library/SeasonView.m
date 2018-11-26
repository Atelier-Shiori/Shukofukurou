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
            [_mw loadinfo:d[@"id"] type:0 changeView:YES forcerefresh:NO];
        }
    }
}

- (IBAction)yearchange:(id)sender {
    [self loadseasondata:_seasonyrpicker.title.intValue forSeason: _seasonpicker.title refresh:NO];
}

- (IBAction)seasonchange:(id)sender {
    [self loadseasondata:_seasonyrpicker.title.intValue forSeason: _seasonpicker.title refresh:NO];
}

- (void)populateseasonpopups{
    [self populateyearpopup];
}
- (void)performreload:(bool)refresh completion:(void (^)(bool success)) completionHandler {
    [self loadseasondata:_seasonyrpicker.title.intValue forSeason:_seasonpicker.title refresh:refresh completion:completionHandler];
}

- (void)loadseasondata:(int)year forSeason:(NSString *)season refresh:(bool)refresh {
    [self loadseasondata:year forSeason:season refresh:refresh completion:^(bool success) {}];
}

- (void)loadseasondata:(int)year forSeason:(NSString *)season refresh:(bool)refresh completion:(void (^)(bool success)) completionHandler {
    if (_seasonyrpicker.itemArray.count > 0){
        [AniListSeasonListGenerator retrieveSeasonDataWithSeason:season withYear:year refresh:refresh completion:^(id responseObject) {
            NSMutableArray *sarray = [_seasonarraycontroller mutableArrayValueForKey:@"content"];
            NSNumber *selectedAnimeID = nil;
            if (_seasontableview.selectedRow >= 0) {
                selectedAnimeID = _seasonarraycontroller.selectedObjects[0][@"id"];
            }
            [sarray removeAllObjects];
            NSArray *a = [responseObject sortedArrayUsingDescriptors:_seasonarraycontroller.sortDescriptors];
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
            completionHandler(true);
        } error:^(NSError *error) {
            NSLog(@"Can't Retrieve Season Data: %@", error.localizedDescription);
            completionHandler(false);
        }];
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
    [self loadseasondata:_seasonyrpicker.title.intValue forSeason: _seasonpicker.title refresh:NO];
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
