//
//  StreamDataRetriever.h
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/06/20.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StreamDataRetriever : NSObject
typedef NS_ENUM(unsigned int, StreamLocality) {
    StreamRegionUS = 0,
    StreamRegionCA = 1,
    StreamRegionUK = 2,
    StreamRegionAU = 3
};
+ (void)retrieveStreamData;
+ (void)performrestrieveStreamData;
@end
