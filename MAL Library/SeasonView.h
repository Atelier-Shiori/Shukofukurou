//
//  SeasonView.h
//  Shukofukurou
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import <Cocoa/Cocoa.h>

@class MainWindow;
@class TitleCollectionView;

@interface SeasonView : NSViewController <NSCollectionViewDelegate, NSCollectionViewDataSource>
@property (strong) IBOutlet MainWindow *mw;
@property (strong) IBOutlet NSArrayController *seasonarraycontroller;
@property (strong) IBOutlet NSToolbarItem *addtitleitem;
@property (strong) IBOutlet TitleCollectionView *collectionview;

- (void)performreload:(bool)refresh completion:(void (^)(bool success)) completionHandler;
- (IBAction)seasondoubleclick:(id)sender;
- (IBAction)yearchange:(id)sender;
- (IBAction)seasonchange:(id)sender;
- (void)populateyearpopup;
- (void)populateseasonpopups;
@end
