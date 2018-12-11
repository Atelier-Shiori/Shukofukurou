//
//  TrendingView.m
//  Shukofukurou
//
//  Created by 香風智乃 on 11/27/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "TrendingView.h"
#import "MainWindow.h"
#import "listservice.h"
#import "TitleCollectionCell.h"
#import "TitleCollectionView.h"
#import "TrendingRetriever.h"
#import "HeaderView.h"

@interface TrendingView ()
@property (strong) IBOutlet NSVisualEffectView *loadingview;
@property (strong) IBOutlet NSProgressIndicator *loadingindicator;
@end

@implementation TrendingView
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)init {
    return [super initWithNibName:@"TrendingView" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _loadingview.wantsLayer = YES;
    _loadingview.layer.cornerRadius = 15.0;
    [_collectionview registerClass:[TitleCollectionCell class] forItemWithIdentifier:@"TitleCollectionCell"];
    _collectionview.backgroundColors = @[[NSColor clearColor]];
    [_addtitleitem setEnabled:NO];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if (![defaults boolForKey:@"donated"]) {
        [defaults setInteger:0 forKey:@"selectedtrending"];
    }
    [self loadTrending:NO];
    [_addtitleitem setEnabled:NO];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recieveNotification:) name:@"ServiceChanged" object:nil];
}

- (void)recieveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"ServiceChanged"]) {
        [self loadTrending:NO];
    }
}

- (void)refresh {
    [self loadTrending:YES];
}

- (IBAction)trendingchanged:(id)sender {
    [self loadTrending:NO];
}

- (void)loadTrending:(bool)refreshing {
    [self showloading:YES];
    [TrendingRetriever getTrendListForService:[listservice getCurrentServiceID] withType:(int)_trendingtype.selectedSegment shouldRefresh:refreshing completion:^(id  _Nonnull responseobject) {
        self.items = responseobject;
        [self.collectionview reloadData];
        [self showloading:NO];
    } error:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        [self showloading:NO];
    }];
}

#pragma mark NSCollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return _items.allKeys.count;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return ((NSArray *)_items[_items.allKeys[section]]).count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
     itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *entry = _items[_items.allKeys[indexPath.section]][indexPath.item];
    TitleCollectionCell *collectioncell = [_collectionview makeItemWithIdentifier:@"TitleCollectionCell" forIndexPath:indexPath];
    [collectioncell viewDidLoad];
    collectioncell.titlelabel.stringValue = entry[@"title"];
    [collectioncell loadimage:entry[@"image_url"]];
    return collectioncell;
}

- (NSView *)collectionView:(NSCollectionView *)collectionView
viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind
               atIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionName = _items.allKeys[indexPath.section];
    if ([kind isEqual:NSCollectionElementKindSectionHeader]) {
        HeaderView *header = (HeaderView *)[_collectionview makeSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"HeaderView" forIndexPath:indexPath];
        header.titlelabel.stringValue = sectionName;
        return header;
    }
    return [NSView new];
}


#pragma mark NSCollectionViewDelegate
- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    [_addtitleitem setEnabled:YES];
}
- (void)collectionView:(NSCollectionView *)collectionView didDeselectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    [_addtitleitem setEnabled:NO];
}

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return NSMakeSize(10000, 39);
}

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return NSZeroSize;
}

#pragma mark other

- (void)collectionItemViewDoubleClick:(id)sender {
    NSIndexPath *indexpath = _collectionview.selectionIndexPaths.anyObject;
    if (indexpath) {
        NSDictionary *d = _items[_items.allKeys[indexpath.section]][indexpath.item];
        [NSNotificationCenter.defaultCenter postNotificationName:@"LoadTitleInfo" object:@{@"id" : d[@"id"], @"type" : @((int)_trendingtype.selectedSegment)}];
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

@end
