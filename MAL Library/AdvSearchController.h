//
//  AdvSearchController.h
//  Shukofukurou
//
//  Created by 香風智乃 on 5/7/19.
//  Copyright © 2019 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvSearchController : NSViewController
@property int currentadvsearch;
@property int currentlistservice;
@property (strong, nullable) NSDictionary *animeadvsearchoptions;
@property (strong, nullable) NSDictionary *mangaadvsearchoptions;

- (void)loadViewForType:(int)type;
- (void)resetanime;
- (void)resetmanga;
- (void)generateadvsearchdictionary;
- (NSDictionary *)getAdvSearchOptionsForType:(int)type;
@end

NS_ASSUME_NONNULL_END
