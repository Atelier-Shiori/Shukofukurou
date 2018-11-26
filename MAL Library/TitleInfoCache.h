//
//  TitleInfoCache.h
//  Shukofukurou-IOS
//
//  Created by 香風智乃 on 9/27/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TitleInfoCache : NSObject
+ (NSDictionary *)getTitleInfoWithTitleID:(int)titleid withServiceID:(int)serviceid withType:(int)type ignoreLastUpdated:(bool)ignorelastupdated ;
+ (NSDictionary *)saveTitleInfoWithTitleID:(int)titleid withServiceID:(int)serviceid withType:(int)type withResponseObject:(id)responseObject;
+ (void)cleanupcacheShouldRemoveAll:(bool)removeall;
@end

NS_ASSUME_NONNULL_END
