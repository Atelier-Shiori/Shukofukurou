//
//  NSUserNotificationManager.m
//  Shukofukurou
//
//  Created by 香風智乃 on 12/17/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "NSUserNotificationManager.h"

@interface NSUserNotificationManager ()
@property (strong) NSUserNotificationCenter *notificationCenter;
@end

@implementation NSUserNotificationManager
- (instancetype)init {
    if (self = [super init]) {
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        self.notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    }
    return self;
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

+ (instancetype)getSharedNotificationManager {
    static dispatch_once_t sharedNotificationManagerToken;
    static NSUserNotificationManager *sharednotificationManager = nil;
    dispatch_once(&sharedNotificationManagerToken, ^{
        sharednotificationManager = [self new];
    });
    return sharednotificationManager;
}

- (void)removeNotificationWithIdentifier:(NSString *)identifier {
    [self generatePendingNotificationsList:^(NSArray *notifications, bool success) {
        for (NSUserNotification *notification in notifications) {
            if ([notification.identifier containsString:identifier]) {
                NSLog(@"Removed from Notification Queue: %@", notification.identifier);
                [self.notificationCenter removeScheduledNotification:notification];
            }
        }
    }];
}

- (void)removeAllPendingNotifications {
    [self generatePendingNotificationsList:^(NSArray *notifications, bool success) {
        for (NSUserNotification *notification in notifications) {
            [_notificationCenter removeScheduledNotification:notification];
        }
    }];
}

- (void)generatePendingNotificationsList:(void (^)(NSArray *notifications, bool success))completionHandler {
    completionHandler(_notificationCenter.scheduledNotifications, true);
}

- (void)setNotification:(NSManagedObject *)notificationobj {
    if ([notificationobj valueForKey:@"title"] && [notificationobj valueForKey:@"nextepisode"] && [notificationobj valueForKey:@"anilistid"] && [notificationobj valueForKey:@"servicetitleid"] && [notificationobj valueForKey:@"service"]) {
        NSUserNotification *content = [NSUserNotification new];
        content.title = [notificationobj valueForKey:@"title"];
        content.informativeText = [NSString stringWithFormat:@"Episode %@ has aired.", [notificationobj valueForKey:@"nextepisode"]];
        content.soundName = NSUserNotificationDefaultSoundName;
        content.userInfo = @{@"anilistid" : [notificationobj valueForKey:@"anilistid"], @"servicetitleid" : [notificationobj valueForKey:@"servicetitleid"], @"service" : [notificationobj valueForKey:@"service"]};
        NSDate *airdate = (NSDate *)[notificationobj valueForKey:@"nextairdate"];
        if (airdate) {
            content.deliveryDate = airdate;
            content.identifier = [NSString stringWithFormat:@"airing-%@-%.f",[notificationobj valueForKey:@"anilistid"],airdate.timeIntervalSince1970];
            
            [_notificationCenter scheduleNotification:content];
        }
    }
    else {
        NSLog(@"Something went wrong. Missing values");
        [self generateDebugOutput:notificationobj];
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
