//
//  StreamDataRetriever.h
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/06/20.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface StreamDataRetriever : NSObject
+ (void)retrieveSitesForTitle:(int)titleid completion:(void (^)(id responseObject)) completionHandler;
+ (void)removeAllStreamEntries;
@end
