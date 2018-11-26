//
//  TrendingRetriever.h
//  Shukofukurou-IOS
//
//  Created by 香風智乃 on 11/6/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrendingRetriever : NSObject
typedef NS_ENUM(unsigned int, TrendListType) {
    TrendListTypeScore = 0,
    TrendListTypeNew = 1,
    TrendListTypeTrending = 2,
    TrendListTypeSeasonPopular = 3
};
+ (void)getTrendListForService:(int)service withType:(int)type shouldRefresh:(bool)shouldRefresh completion:(void (^)(id responseobject))completionHandler error:(void (^)(NSError *error))errorHandler;
@end

NS_ASSUME_NONNULL_END
