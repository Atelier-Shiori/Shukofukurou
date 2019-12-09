//
//  NewStreamDataRetriever.h
//  Shukofukurou-IOS
//
//  Created by 香風智乃 on 11/13/19.
//  Copyright © 2019 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewStreamDataRetriever : NSObject
typedef NS_ENUM(unsigned int, StreamLocality) {
    StreamRegionUS = 0,
    StreamRegionCA = 1,
    StreamRegionUK = 2,
    StreamRegionAU = 3
};
+ (void)retrieveStreamDataForTitleID:(int)ntitleid withService:(int)service completion:(void (^)(NSArray *entries, bool success))completionHandler;
@end

NS_ASSUME_NONNULL_END
