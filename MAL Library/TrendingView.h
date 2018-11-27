//
//  TrendingView.h
//  Shukofukurou
//
//  Created by 香風智乃 on 11/27/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class MainWindow;
@class TitleCollectionView;

@interface TrendingView : NSViewController <NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout>
@property (strong) IBOutlet MainWindow *mw;
@property (strong) IBOutlet NSToolbarItem *addtitleitem;
@property (strong) IBOutlet TitleCollectionView *collectionview;
@property (strong) IBOutlet NSSegmentedControl *trendingtype;
@property (strong) NSDictionary *items;
- (void)refresh;
@end

NS_ASSUME_NONNULL_END
