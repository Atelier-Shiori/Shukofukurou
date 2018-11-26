//
//  AiringSchedule.h
//  Hiyoko
//
//  Created by 香風智乃 on 9/17/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AiringSchedule : NSObject
+ (void)autofetchAiringScheduleWithCompletionHandler: (void (^)(bool success, bool refreshed))completionHandler;
+ (void)retrieveAiringScheduleShouldRefresh:(bool)refresh completionhandler: (void (^)(bool success, bool refreshed))completionHandler;
+ (NSArray *)retrieveAiringDataForDay:(NSString *)day;
+ (NSArray *)retrieveAiringData;
@end

NS_ASSUME_NONNULL_END
