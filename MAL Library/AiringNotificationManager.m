//
//  AiringNotificationManager.m
//  Shukofukurou-IOS
//
//  Created by 香風智乃 on 11/7/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import "AiringNotificationManager.h"
#import "TitleIdEnumerator.h"
#import "AppDelegate.h"
#import "AtarashiiListCoreData.h"
#import "listservice.h"
#import <Hakuchou/AniListConstants.h>
#import "Utility.h"
#import <AFNetworking/AFNetworking.h>
#import <UserNotifications/UserNotifications.h>
#import "MSWeakTimer.h"
#import "NotificationManager.h"
#import "NSUserNotificationManager.h"
#import "UNUserNotificationManager.h"

@import UserNotifications;

@interface AiringNotificationManager ()
@property (strong) NotificationManager *notificationManager;
@property (strong) NSMutableArray *schedulednotifications;
@property (strong, nonatomic) dispatch_queue_t notificationQueue;
@property (strong, nonatomic) MSWeakTimer *refreshtimer;
@property bool timeractive;
@end

@implementation AiringNotificationManager
+ (AiringNotificationManager *)sharedAiringNotificationManager {
    return ((AppDelegate *)NSApplication.sharedApplication.delegate).airingnotificationmanager;
}

+ (int)airingNotificationServiceSource {
    return (int)[NSUserDefaults.standardUserDefaults integerForKey:@"airingnotification_service"];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype) init {
    if (self = [super init]) {
        self.managedObjectContext = ((AppDelegate *)NSApplication.sharedApplication.delegate).managedObjectContext;
        if (@available(macOS 10.14, *)) {
            self.notificationManager = (NotificationManager *)[UNUserNotificationManager new];
        }
        else {
            self.notificationManager = (NotificationManager *)[NSUserNotificationManager new];
        }
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recieveNotification:) name:@"AirNotifyServiceChanged" object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recieveNotification:) name:@"AirNotifyToggled" object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recieveNotification:) name:@"UserLoggedOut" object:nil];
        self.schedulednotifications = [NSMutableArray new];
        _notificationQueue = dispatch_queue_create("moe.ateliershiori.Shukofukurou.notification", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)recieveNotification:(NSNotification *)notification {
    int service = [AiringNotificationManager airingNotificationServiceSource];
    if ([notification.name isEqualToString:@"AirNotifyServiceChanged"]) {
        [self clearNotifyList];
        [self checknotifications:^(bool success) {}];
    }
    else if ([notification.name isEqualToString:@"AirNotifyToggled"]) {
        [self toggletimer];
        if ([NSUserDefaults.standardUserDefaults boolForKey:@"airnotificationsenabled"]) {
            [self checknotifications:^(bool success) {}];
        }
        else {
            [self clearNotifyList];
        }
    }
    else if ([notification.name isEqualToString:@"UserLoggedOut"]) {
        if (service == [listservice.sharedInstance getCurrentServiceID]) {
            [self clearNotifyList];
        }
    }
}

- (void)toggletimer {
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"airnotificationsenabled"] && !_timeractive) {
        NSLog(@"Air Notification refresh timer enabled");
        _refreshtimer = [MSWeakTimer scheduledTimerWithTimeInterval:900 target:self selector:@selector(firetimer) userInfo:nil repeats:YES dispatchQueue:_notificationQueue];
        _timeractive = true;
    }
    else {
        NSLog(@"Air Notification refresh timer disabled");
        [_refreshtimer invalidate];
        _timeractive = false;
    }
}

- (void)firetimer {
    NSLog(@"Checking for new Air Notifications");
    [self checknotifications:^(bool success) {
        
    }];
}

- (void)checknotifications:(void (^)(bool success))completionHandler {
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"airnotificationsenabled"]) {
        [self checkListForAiringTitles:^(bool success) {
            if (success) {
                [self checkForNewNotifications:^(bool success) {
                    if (success) {
                        [NSNotificationCenter.defaultCenter postNotificationName:@"AirNotifyRefreshed" object:nil];
                        completionHandler(true);
                    }
                    else {
                        completionHandler(false);
                    }
                }];
            }
            else {
                completionHandler(false);
            }
        }];
    }
    else {
        [NSNotificationCenter.defaultCenter postNotificationName:@"AirNotifyRefreshed" object:nil];
        completionHandler(true);
    }
}

- (void)checkListForAiringTitles:(void (^)(bool success))completionHandler {
    NSLog(@"Checking for new airing titles");
    __block int service = [AiringNotificationManager airingNotificationServiceSource];
    NSArray *list;
    switch (service) {
        case 1: {
            NSDictionary *udict = [listservice.sharedInstance getAllUserNames];
            if (udict[@"myanimelist"] != [NSNull null]) {
                list = [AtarashiiListCoreData retrieveEntriesForUserName:udict[@"myanimelist"] withService:1 withType:0 withPredicate:[NSPredicate predicateWithFormat:@"status ==[c] %@ AND (watched_status ==[c] %@ OR watched_status ==[c] %@)", @"currently airing", @"watching", @"plan to watch"]];
                break;
            }
            return;
        }
        case 2:
        case 3: {
            NSDictionary *uiddict = [listservice.sharedInstance getAllUserID];
            int uid = 0;
            switch (service) {
                case 2: {
                    if (uiddict[@"kitsu"] != [NSNull null]) {
                        uid = ((NSNumber *)uiddict[@"kitsu"]).intValue;
                        break;
                    }
                    return;
                }
                case 3: {
                    if (uiddict[@"anilist"] != [NSNull null]) {
                        uid = ((NSNumber *)uiddict[@"anilist"]).intValue;
                        break;
                    }
                    return;
                }
                default:
                    return;
            }
            list = [AtarashiiListCoreData retrieveEntriesForUserId:uid withService:service withType:0 withPredicate:[NSPredicate predicateWithFormat:@"status ==[c] %@ AND (watched_status ==[c] %@ OR watched_status ==[c] %@)", @"currently airing", @"watching", @"plan to watch"]];
            break;
        }
        default: {
            return;
        }
    }
    TitleIdEnumerator *tenum = [[TitleIdEnumerator alloc] initWithList:list withType:0 completion:^(TitleIdEnumerator * _Nonnull titleidenum) {
        NSLog(@"Adding New Entries");
        for (NSDictionary *entry in list) {
            int anilistid = [titleidenum findTargetIdFromSourceId:((NSNumber *)entry[@"id"]).intValue];
            if (![self retrieveNotificationItem:anilistid isAniListID:YES withService:service] && anilistid > 0) {
                    [self addNotifyingTitle:entry withAniListID:anilistid withService:service];
            }
            else if (![self retrieveIgnoredNotificationItem:((NSNumber *)entry[@"id"]).intValue withService:service] && anilistid == 0) {
                    [self addIgnoreNotifyingTitle:entry withService:service];
            }
        }
        completionHandler(true);
    }];
    [tenum generateTitleIdMappingList:service toService:3];
}

- (void)checkForNewNotifications:(void (^)(bool success))completionHandler {
    NSLog(@"Checking for new notifications");
    [self performNewNotificationCheck:[self getAllNotifications:YES] withPosition:0 completionHandler:completionHandler];
}

- (void)performNewNotificationCheck:(NSArray *)notificationList withPosition:(int)position completionHandler:(void (^)(bool success))completionHandler {
    if (notificationList.count == 0) {
        completionHandler(true);
        return;
    }
    AFHTTPSessionManager *sessionmanager = [Utility jsonmanager];
    __block NSManagedObjectContext *notifyobj = notificationList[position];
    if ([notifyobj valueForKey:@"nextairdate"] != [NSNull null]) {
        if ([(NSDate *)[notifyobj valueForKey:@"nextairdate"] timeIntervalSinceNow] > 0) {
            if (notificationList.count == position+1) {
                [self setNotifications];
                completionHandler(true);
            }
            else {
                int newPosition = position + 1;
                [self performNewNotificationCheck:notificationList withPosition:newPosition completionHandler:completionHandler];
            }
            return;
        }
    }
    if ([notifyobj valueForKey:@"anilistid"] == [NSNull null] || ![notifyobj valueForKey:@"anilistid"]) {
        if (notificationList.count == position+1) {
            [self setNotifications];
            completionHandler(true);
        }
        else {
            int newPosition = position + 1;
            [self performNewNotificationCheck:notificationList withPosition:newPosition completionHandler:completionHandler];
        }
        return;
    }
    NSNumber *titleid = (NSNumber *)[notifyobj valueForKey:@"anilistid"];
    if (!titleid) {
        if (notificationList.count == position+1) {
            [self setNotifications];
            completionHandler(true);
        }
        else {
            int newPosition = position + 1;
            [self performNewNotificationCheck:notificationList withPosition:newPosition completionHandler:completionHandler];
        }
        return;
    }
    NSDictionary *parameters = @{@"query" : kAniListNextEpisode, @"variables" : @{@"id": titleid}};
    [sessionmanager POST:@"https://graphql.anilist.co/" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.managedObjectContext performBlockAndWait:^{
            NSDictionary *animeinfo = responseObject[@"data"][@"Media"];
            bool finished = [(NSString *)animeinfo[@"status"] isEqualToString:@"FINISHED"] || [(NSString *)animeinfo[@"status"] isEqualToString:@"CANCELLED"];
            [notifyobj setValue:@(finished) forKey:@"finished"];
            [notifyobj setValue:animeinfo[@"nextAiringEpisode"] != [NSNull null] ? [NSDate dateWithTimeIntervalSince1970:((NSNumber *)animeinfo[@"nextAiringEpisode"][@"airingAt"]).longValue] : nil forKey:@"nextairdate"];
            [notifyobj setValue:animeinfo[@"nextAiringEpisode"] != [NSNull null] ? animeinfo[@"nextAiringEpisode"][@"episode"] : @(0) forKey:@"nextepisode"];
            [self.managedObjectContext save:nil];
        }];
        if (notificationList.count == position+1) {
            [self setNotifications];
            completionHandler(true);
        }
        else {
            int newPosition = position + 1;
            [self performNewNotificationCheck:notificationList withPosition:newPosition completionHandler:completionHandler];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Unable to retrieve next airing date: %@", error);
        completionHandler(false);
    }];
}

- (void)setNotifications {
    NSArray *notifications = [self getAllNotifications:NO];
    [self generatePendingNotificationsList:^(bool success) {
        for (NSManagedObject *notifyobj in notifications) {
            bool hasAirDate = [notifyobj valueForKey:@"nextairdate"] != [NSNull null];
            bool scheduled = [self scheduledNotificationExist:((NSNumber *)[notifyobj valueForKey:@"anilistid"]).intValue] != nil;
            if (hasAirDate && !scheduled) {
                [self setNotification:notifyobj];
            }
        }
        [self cleanupFinishedTitles];
    }];
}

- (void)setNotification:(NSManagedObject *)notificationobj {
    if ([notificationobj valueForKey:@"nextairdate"] != [NSNull null]) {
        [_notificationManager setNotification:notificationobj];
        if (@available(macOS 10.14, *)) {
        }
        else {
            [self generatePendingNotificationsList:^(bool success) {
                if (success) {
                    NSUserNotification * notification = [self scheduledNotificationExist:((NSNumber *)[notificationobj valueForKey:@"anilistid"]).intValue];
                    if (notification) {
                        NSLog(@"Successfully scheduled notification: %@", notification.identifier);
                    }
                    else {
                        NSLog(@"Something went wrong trying to schedule notification");
                    }
                }
            }];
        }
    }
    else {
        NSLog(@"Skipping %@, No Air Date and Time", [notificationobj valueForKey:@"anilistid"]);
    }
    
}

- (void)removependingnotification:(int)anilistid {
    [_notificationManager removeNotificationWithIdentifier:[NSString stringWithFormat:@"airing-%i",anilistid]];
}

- (void)addNotifyingTitle:(NSDictionary *)titleInfo withAniListID:(int)anilistid withService:(int)service {
    [_managedObjectContext performBlockAndWait:^{
        NSManagedObject *notifyobj = [self retrieveNotificationItem:anilistid isAniListID:YES withService:service];
        if (!notifyobj) {
            notifyobj = [NSEntityDescription insertNewObjectForEntityForName:@"Notifications" inManagedObjectContext:self.managedObjectContext];
        }
        [notifyobj setValue:@(anilistid) forKey:@"anilistid"];
        [notifyobj setValue:@(service) forKey:@"service"];
        [notifyobj setValue:titleInfo[@"id"] forKey:@"servicetitleid"];
        [notifyobj setValue:titleInfo[@"title"] forKey:@"title"];
        [notifyobj setValue:@YES forKey:@"enabled"];
        [notifyobj setValue:@NO forKey:@"finished"];
        [self.managedObjectContext save:nil];
    }];
}

- (void)addIgnoreNotifyingTitle:(NSDictionary *)titleInfo withService:(int)service {
    [_managedObjectContext performBlockAndWait:^{
        NSManagedObject *notifyiobj = [self retrieveIgnoredNotificationItem:((NSNumber *)titleInfo[@"id"]).intValue withService:service];
        if (!notifyiobj) {
            notifyiobj = [NSEntityDescription insertNewObjectForEntityForName:@"NotificationsIgnore" inManagedObjectContext:self.managedObjectContext];
        }
        [notifyiobj setValue:titleInfo[@"id"] forKey:@"id"];
        [notifyiobj setValue:@(service) forKey:@"service"];
        [notifyiobj setValue:titleInfo[@"title"] forKey:@"title"];
        [self.managedObjectContext save:nil];
    }];
}

- (void)removeNotifyingTitle:(int)titleid withService:(int)service {
    __block NSManagedObject *notifyobj = [self retrieveNotificationItem:titleid isAniListID:NO withService:service];
    if (notifyobj) {
        [_managedObjectContext performBlockAndWait:^{
            int anilistid = ((NSNumber *)[notifyobj valueForKey:@"anilistid"]).intValue;
            [self.managedObjectContext deleteObject:notifyobj];
            [self.managedObjectContext save:nil];
            [self removependingnotification:anilistid];
        }];
    }
}

- (void)removeIgnoreNotifyingTitle:(int)titleid withService:(int)service {
    __block NSManagedObject *notifyiobj = [self retrieveIgnoredNotificationItem:titleid withService:service];
    if (notifyiobj) {
        [_managedObjectContext performBlockAndWait:^{
            [self.managedObjectContext deleteObject:notifyiobj];
            [self.managedObjectContext save:nil];
        }];
    }
}

- (void)cleanupFinishedTitles {
    NSLog(@"Clearing Finished Titles from Notifications");
    [_managedObjectContext performBlockAndWait:^{
        NSArray *notifications;
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = [NSEntityDescription entityForName:@"Notifications" inManagedObjectContext:self.managedObjectContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"finished == %i", 1];
        fetchRequest.predicate = predicate;
        NSError *error = nil;
        notifications = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (NSManagedObject *notifyobj in notifications) {
            [self.managedObjectContext deleteObject:notifyobj];
        }
        [self.managedObjectContext save:nil];
        NSLog(@"Removed: %li finished titles", notifications.count);
    }];
}

- (void)clearNotifyList {
    [_managedObjectContext performBlockAndWait:^{
        NSArray *notifications;
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = [NSEntityDescription entityForName:@"Notifications" inManagedObjectContext:self.managedObjectContext];
        NSError *error = nil;
        notifications = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (NSManagedObject *notifyobj in notifications) {
            [self.managedObjectContext deleteObject:notifyobj];
        }
        fetchRequest.entity = [NSEntityDescription entityForName:@"NotificationsIgnore" inManagedObjectContext:self.managedObjectContext];
        error = nil;
        notifications = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (NSManagedObject *notifyobj in notifications) {
            [self.managedObjectContext deleteObject:notifyobj];
        }
        [self.managedObjectContext save:nil];
    }];
    [self removeAllPrendingNotifications];
}

- (NSManagedObject *)retrieveNotificationItem:(int)titleid isAniListID:(bool)isAniListID withService:(int)service {
    __block NSArray *notifications = @[];
    [_managedObjectContext performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = [NSEntityDescription entityForName:@"Notifications" inManagedObjectContext:self.managedObjectContext];
        NSPredicate *predicate;
        if (!isAniListID) {
            predicate = [NSPredicate predicateWithFormat:@"service == %i AND servicetitleid == %i", service, titleid];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"service == %i AND anilistid == %i", service, titleid];
        }
        fetchRequest.predicate = predicate;
        NSError *error = nil;
        notifications = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    if (notifications.count > 0) {
        return notifications[0];
    }
    return nil;
}

- (NSManagedObject *)retrieveIgnoredNotificationItem:(int)titleid withService:(int)service {
    __block NSArray *notifications = @[];
    [_managedObjectContext performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = [NSEntityDescription entityForName:@"NotificationsIgnore" inManagedObjectContext:self.managedObjectContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"service == %i AND id == %i", service, titleid];
        fetchRequest.predicate = predicate;
        NSError *error = nil;
        notifications = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    if (notifications.count > 0) {
        return notifications[0];
    }
    return nil;
}

- (NSArray *)getAllNotifications:(bool)includeall {
    __block NSArray *notifications = @[];
    [_managedObjectContext performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = [NSEntityDescription entityForName:@"Notifications" inManagedObjectContext:self.managedObjectContext];
        NSPredicate *predicate = includeall ? [NSPredicate predicateWithFormat:@"finished == %i", 0] : [NSPredicate predicateWithFormat:@"enabled == %i AND finished == %i", 1, 0];
        fetchRequest.predicate = predicate;
        NSError *error = nil;
        notifications = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    return notifications;
}

#pragma mark helpers
- (void)generatePendingNotificationsList:(void (^)(bool success))completionHandler {
    [_schedulednotifications removeAllObjects];
    [_notificationManager generatePendingNotificationsList:^(NSArray * _Nonnull notifications, bool success) {
        [_schedulednotifications addObjectsFromArray:notifications];
        completionHandler(true);
    }];
}

- (id)scheduledNotificationExist:(int)anilistid {
    if (@available(macOS 10.14, *)) {
        for (UNNotificationRequest *notification in _schedulednotifications) {
            if ([notification.identifier containsString:[NSString stringWithFormat:@"airing-%i",anilistid]]) {
                return notification;
            }
        }
    }
    else {
        for (NSUserNotification *notification in _schedulednotifications) {
            if ([notification.identifier containsString:[NSString stringWithFormat:@"airing-%i",anilistid]]) {
                return notification;
            }
        }
    }
    return nil;
}
- (void)removeAllPrendingNotifications {
    [_notificationManager removeAllPendingNotifications];
}
@end
