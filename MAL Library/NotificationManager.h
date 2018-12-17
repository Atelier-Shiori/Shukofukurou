//
//  NotificationManager.h
//  Shukofukurou
//
//  Created by 香風智乃 on 12/17/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN
@interface NotificationManager : NSObject
+ (instancetype)getSharedNotificationManager;
- (void)removeNotificationWithIdentifier:(NSString *)identifier;
- (void)removeAllPendingNotifications;
- (void)generatePendingNotificationsList:(void (^)(NSArray *notifications, bool success))completionHandler;
- (void)setNotification:(NSManagedObject *)notificationobj;
@end

NS_ASSUME_NONNULL_END
