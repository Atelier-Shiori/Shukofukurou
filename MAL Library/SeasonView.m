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
#import "TitleCollectionCell.h"
#import "TitleCollectionView.h"

@interface SeasonView ()
@property (strong) IBOutlet NSPopUpButton *seasonyrpicker;
@property (strong) IBOutlet NSPopUpButton *seasonpicker;
@property (strong) IBOutlet NSVisualEffectView *loadingview;
@property (strong) IBOutlet NSProgressIndicator *loadingindicator;
@end

@implementation SeasonView
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)init {
    return [super initWithNibName:@"SeasonView" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _loadingview.wantsLayer = YES;
    _loadingview.layer.cornerRadius = 15.0;
    [_collectionview registerClass:[TitleCollectionCell class] forItemWithIdentifier:@"TitleCollectionCell"];
    _collectionview.backgroundColors = @[[NSColor clearColor]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    _seasonarraycontroller.sortDescriptors = @[sort];
    [_addtitleitem setEnabled:NO];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recieveNotification:) name:@"ServiceChanged" object:nil];
    [self populateseasonpopups];
}

- (void)recieveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"ServiceChanged"]) {
        [self performreload:NO completion:^(bool success) {
        }];
    }
}

#pragma mark NSCollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return ((NSArray *)_seasonarraycontroller.arrangedObjects).count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
     itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *entry = ((NSArray *)_seasonarraycontroller.arrangedObjects)[indexPath.item];
    TitleCollectionCell *collectioncell = [_collectionview makeItemWithIdentifier:@"TitleCollectionCell" forIndexPath:indexPath];
    [collectioncell viewDidLoad];
    collectioncell.titlelabel.stringValue = entry[@"title"];
    [collectioncell loadimage:entry[@"image_url"]];
    return collectioncell;
}

#pragma mark NSCollectionViewDelegate
- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    [_addtitleitem setEnabled:YES];
}
- (void)collectionView:(NSCollectionView *)collectionView didDeselectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    [_addtitleitem setEnabled:NO];
}

#pragma mark Seasons View
- (void)collectionItemViewDoubleClick:(id)sender {
    NSIndexPath *indexpath = _collectionview.selectionIndexPaths.anyObject;
    if (indexpath) {
        NSDictionary *d = _seasonarraycontroller.selectedObjects[indexpath.item];
        [NSNotificationCenter.defaultCenter postNotificationName:@"LoadTitleInfo" object:@{@"id" : d[@"id"], @"type" : @(0)}];
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
        [self showloading:YES];
        [AniListSeasonListGenerator retrieveSeasonDataWithSeason:season withYear:year refresh:refresh completion:^(id responseObject) {
            NSMutableArray *sarray = [_seasonarraycontroller mutableArrayValueForKey:@"content"];
            [sarray removeAllObjects];
            [_collectionview reloadData];
            NSArray *a = [responseObject sortedArrayUsingDescriptors:_seasonarraycontroller.sortDescriptors];
            [_seasonarraycontroller addObjects:a];
            [_collectionview reloadData];
            [_collectionview deselectAll:self];
            [self showloading:NO];
            completionHandler(true);
        } error:^(NSError *error) {
            NSLog(@"Can't Retrieve Season Data: %@", error.localizedDescription);
            [self showloading:NO];
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
@end
