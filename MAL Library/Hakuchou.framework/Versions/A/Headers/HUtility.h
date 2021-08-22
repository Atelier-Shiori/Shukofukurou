//
//  Utility.h
//  Hakuchou
//
//  Created by 香風智乃 on 3/4/19.
//  Copyright © 2019 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HUtility : NSObject
+ (NSString *)urlEncodeString:(NSString *)string;
+ (double)calculatedays:(NSArray *)list;
+ (NSString *)dateIntervalToDateString:(double)timeinterval;
+ (NSString *)convertAnimeType:(NSString *)type;
+ (NSNumber *)getLastUpdatedDateWithResponseObject:(id)responseObject withService:(int)service;
+ (NSDate *)dateStringToDate:(NSString *)datestring;
+ (NSDate *)isodateStringToDate:(NSString *)datestring;
+ (NSDictionary *)dateStringToAiringSeasonAndYear:(NSString *)datestring;
+ (NSDictionary *)aniListdateStringToAiringSeasonAndYear:(NSDictionary *)dateDict;
+ (int)parseSeason:(NSString *)string;
+ (bool)grayAreaCheckByClassification:(NSString *)classification;
+ (bool)grayAreaCheckByTags:(NSArray *)tags;
+ (bool)grayAreaCheck:(NSArray *)genres withTitle:(NSString *)title withAltTitles:(NSDictionary *)alttitles;
@end

NS_ASSUME_NONNULL_END
