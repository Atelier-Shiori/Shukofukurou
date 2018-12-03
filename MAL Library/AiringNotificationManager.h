//
//  AiringNotificationManager.h
//  Shukofukurou-IOS
//
//  Created by 香風智乃 on 11/7/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class NSManagedObject;

@interface AiringNotificationManager : NSObject
@property (strong) NSManagedObjectContext *managedObjectContext;

+ (AiringNotificationManager *)sharedAiringNotificationManager;
+ (int)airingNotificationServiceSource;
- (void)checknotifications:(void (^)(bool success))completionHandler;
- (void)checkListForAiringTitles:(void (^)(bool success))completionHandler;
- (void)checkForNewNotifications:(void (^)(bool success))completionHandler;
- (void)setNotification:(NSManagedObject *)notificationobj;
- (void)removependingnotification:(int)anilistid;
- (void)addNotifyingTitle:(NSDictionary *)titleInfo withAniListID:(int)anilistid withService:(int)service;
- (void)addIgnoreNotifyingTitle:(NSDictionary *)titleInfo withService:(int)service;
- (void)removeNotifyingTitle:(int)titleid withService:(int)service;
- (void)removeIgnoreNotifyingTitle:(int)titleid withService:(int)service;
- (void)cleanupFinishedTitles;
- (void)clearNotifyList;
- (NSArray *)getAllNotifications:(bool)includeall;
@end

NS_ASSUME_NONNULL_END
