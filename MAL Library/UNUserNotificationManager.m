//
//  UNUserNotificationManager.m
//  Shukofukurou
//
//  Created by 香風智乃 on 12/17/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "UNUserNotificationManager.h"
#import <UserNotifications/UserNotifications.h>

API_AVAILABLE(macos(10.14))
@interface UNUserNotificationManager ()
@property (strong) UNUserNotificationCenter *notificationCenter;
@end

@implementation UNUserNotificationManager
- (instancetype)init {
    if (self = [super init]) {
        if (@available(macOS 10.14, *)) {
            self.notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        } else {
            // Fallback on earlier versions
            @throw [NSException
                    exceptionWithName:@"IncorrectNotificationManager"
                    reason:@"This Notification Manager is not the correct one to be used with this version of macOS."
                    userInfo:nil];
        }
    }
    return self;
}

+ (instancetype)getSharedNotificationManager {
    static dispatch_once_t sharedNotificationManagerToken;
    static UNUserNotificationManager *sharednotificationManager = nil;
    dispatch_once(&sharedNotificationManagerToken, ^{
        sharednotificationManager = [self new];
    });
    return sharednotificationManager;
}

- (void)removeNotificationWithIdentifier:(NSString *)identifier {
    if (@available(macOS 10.14, *)) {
        [self generatePendingNotificationsList:^(NSArray * _Nonnull notifications, bool success) {
            for (UNNotificationRequest *request in notifications) {
                if ([request.identifier containsString:identifier]) {
                    NSLog(@"Removed from Notification Queue: %@", request.identifier);
                    [_notificationCenter removePendingNotificationRequestsWithIdentifiers:@[request.identifier]];
                }
            }
        }];
    }
}

- (void)removeAllPendingNotifications {
    [_notificationCenter removeAllPendingNotificationRequests];
}

- (void)generatePendingNotificationsList:(void (^)(NSArray *notifications, bool success))completionHandler {
    if (@available(macOS 10.14, *)) {
        [_notificationCenter getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            NSMutableArray *pendingNotifications = [NSMutableArray new];
            for (UNNotificationRequest *request in requests) {
                [pendingNotifications addObject:request];
            }
            completionHandler(pendingNotifications, true);
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)setNotification:(NSManagedObject *)notificationobj {
    if (@available(macOS 10.14, *)) {
        if ([notificationobj valueForKey:@"title"] && [notificationobj valueForKey:@"nextepisode"] && [notificationobj valueForKey:@"anilistid"] && [notificationobj valueForKey:@"servicetitleid"] && [notificationobj valueForKey:@"service"]) {
            UNMutableNotificationContent *content = [UNMutableNotificationContent new];
            content.title = [notificationobj valueForKey:@"title"];
            content.body = [NSString stringWithFormat:@"Episode %@ has aired.", [notificationobj valueForKey:@"nextepisode"]];
            content.sound = [UNNotificationSound defaultSound];
            content.userInfo = @{@"anilistid" : [notificationobj valueForKey:@"anilistid"], @"servicetitleid" : [notificationobj valueForKey:@"servicetitleid"], @"service" : [notificationobj valueForKey:@"service"]};
            NSDate *airdate = (NSDate *)[notificationobj valueForKey:@"nextairdate"];
            if (airdate) {
                NSDateComponents *triggerDate = [[NSCalendar currentCalendar]
                                                 components:NSCalendarUnitYear +
                                                 NSCalendarUnitMonth + NSCalendarUnitDay +
                                                 NSCalendarUnitHour + NSCalendarUnitMinute +
                                                 NSCalendarUnitSecond fromDate:airdate];
                UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:triggerDate
                                                                                                                  repeats:NO];
                NSString *identifier = [NSString stringWithFormat:@"airing-%@-%.f",[notificationobj valueForKey:@"anilistid"],airdate.timeIntervalSince1970];
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                                      content:content
                                                                                      trigger:trigger];
                [_notificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    if (error != nil) {
                        NSLog(@"Something went wrong: %@",error);
                    }
                    else {
                        NSLog(@"Successfully scheduled notification: %@", identifier);
                    }
                }];
            }
            else {
                NSLog(@"Something went wrong: Invalid Air Date");
            }
        }
        else {
            NSLog(@"Something went wrong. Missing values");
            [self generateDebugOutput:notificationobj];
        }
    } else {
    }
}

- (void)generateDebugOutput:(NSManagedObject *)notificationobj {
    if (![notificationobj valueForKey:@"title"]) {
        NSLog(@"Title is missing.");
    }
    if (![notificationobj valueForKey:@"nextepisode"]) {
        NSLog(@"Next episode is missing.");
    }
    if (![notificationobj valueForKey:@"anilistid"]) {
        NSLog(@"AniList ID is missing.");
    }
    if (![notificationobj valueForKey:@"service"]) {
        NSLog(@"Service is missing.");
    }
    if (![notificationobj valueForKey:@"servicetitleid"]) {
        NSLog(@"Service ID is missing");
    }
}
@end
