//
//  NewStreamDataRetriever.m
//  Shukofukurou-IOS
//
//  Created by 香風智乃 on 11/13/19.
//  Copyright © 2019 MAL Updater OS X Group. All rights reserved.
//

#import "AppDelegate.h"
#import "NewStreamDataRetriever.h"
#import <AFNetworking/AFNetworking.h>
#import "listservice.h"
#import "TitleIDMapper.h"
#import "Utility.h"

@implementation NewStreamDataRetriever
+ (NSManagedObjectContext *)managedObjectContext {
    return ((AppDelegate *)NSApplication.sharedApplication.delegate).managedObjectContext;
}

+ (void)retrieveStreamDataForTitleID:(int)ntitleid withService:(int)service completion:(void (^)(NSArray *entries, bool success))completionHandler {
    if (listservice.sharedInstance.getCurrentServiceID != 1) {
        // Convert ID
        [[TitleIDMapper sharedInstance] retrieveTitleIdForService:service withTitleId:@(ntitleid).stringValue withTargetServiceId:1 withType:0 completionHandler:^(id  _Nonnull titleid, bool success) {
            if (success) {
                [NewStreamDataRetriever performStreamDataRetrievalForTitleId:((NSNumber *)titleid).intValue completion:completionHandler];
            }
        }];
        return;
    }
    else {
        [NewStreamDataRetriever performStreamDataRetrievalForTitleId:ntitleid completion:completionHandler];
    }
}

+ (void)performStreamDataRetrievalForTitleId:(int)titleid  completion:(void (^)(NSArray *entries, bool success))completionHandler {
    NSString *region = @"";
    switch (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"stream_region"]).intValue) {
        case StreamRegionUS:
            region = @"us";
            break;
        case StreamRegionCA:
            region = @"ca";
            break;
        case StreamRegionUK:
            region = @"uk";
            break;
        case StreamRegionAU:
            region = @"au";
            break;
        default:
            break;
    }
    NSArray *existinglinks = [NewStreamDataRetriever retrieveExistingStreamLink:titleid withRegion:region];
    if (existinglinks.count > 0) {
        long lastupdatedtimestamp = ((NSNumber *)existinglinks[0][@"last_updated"]).longValue;
        long difference = NSDate.date.timeIntervalSince1970 - lastupdatedtimestamp;
        if (difference < 604800) {
            completionHandler(existinglinks, true);
            return;
        }
    }
    [[Utility jsonmanager] GET:[NSString stringWithFormat:@"https://streamdata.malupdaterosx.moe/lookup/%@/%i",region,titleid] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [NewStreamDataRetriever processLinksWithArray:responseObject[@"data"] withTitleId:titleid withRegion:region];
        completionHandler([NewStreamDataRetriever retrieveExistingStreamLink:titleid withRegion:region], true);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionHandler(@[],false);
    }];
}

+ (NSArray *)retrieveExistingStreamLink:(int)titleid withRegion:(NSString *)region {
    NSMutableArray *tmparray = [NSMutableArray new];
    [[NewStreamDataRetriever managedObjectContext] performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = [NSEntityDescription entityForName:@"StreamData" inManagedObjectContext:self.managedObjectContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mal_id == %i AND regionname == %@", titleid, region];
        fetchRequest.predicate = predicate;
        NSError *error = nil;
        NSArray *links = [[NewStreamDataRetriever managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        if (links.count > 0) {
            for (NSManagedObject *link in links) {
                [tmparray addObject:[link dictionaryWithValuesForKeys:link.entity.attributesByName.allKeys]];
            }
        }
    }];
    return tmparray;
}

+ (NSArray *)retrieveExistingStreamLinkObjects:(int)titleid withRegion:(NSString *)region {
    __block NSArray *links = @[];
    [[NewStreamDataRetriever managedObjectContext] performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = [NSEntityDescription entityForName:@"StreamData" inManagedObjectContext:self.managedObjectContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mal_id == %i AND regionname == %@", titleid, region];
        fetchRequest.predicate = predicate;
        NSError *error = nil;
        links = [[NewStreamDataRetriever managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    }];
    return links;
}

+ (NSManagedObject *)checkLinkExistsWithTitleId:(int)titleid withSiteName:(NSString *)sitename withRegionName:(NSString *)regionname {
    __block NSManagedObject *link;
    [[NewStreamDataRetriever managedObjectContext] performBlockAndWait:^{
           NSFetchRequest *fetchRequest = [NSFetchRequest new];
           fetchRequest.entity = [NSEntityDescription entityForName:@"StreamData" inManagedObjectContext:self.managedObjectContext];
           NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mal_id == %i AND regionname == %@ AND sitename == %@", titleid, regionname,sitename];
           fetchRequest.predicate = predicate;
           NSError *error = nil;
           NSArray *links = [[NewStreamDataRetriever managedObjectContext] executeFetchRequest:fetchRequest error:&error];
           if (links.count > 0) {
               link = links[0];
           }
       }];
    return link;
}

+ (void)processLinksWithArray:(NSArray *)links withTitleId:(int)titleid withRegion:(NSString *)region {
    for (NSDictionary *link in links) {
        NSManagedObject *elink = [NewStreamDataRetriever checkLinkExistsWithTitleId:((NSNumber *)link[@"mal_id"]).intValue withSiteName:link[@"sitename"] withRegionName:link[@"regionname"]];
        if (elink) {
            if (![(NSString *)link[@"url"] isEqualToString:[elink valueForKey:@"url"]]) {
                [elink setValue:link[@"url"] forKey:@"url"];
                [[NewStreamDataRetriever managedObjectContext] save:nil];
            }
        }
        else {
            [NewStreamDataRetriever insertLinkEntryWithDictionary:link];
        }
    }
    NSArray *existinglinks = [self retrieveExistingStreamLinkObjects:titleid withRegion:region];
    for (NSManagedObject * elink in existinglinks) {
        @autoreleasepool {
            if ([links filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"sitename == %@ AND mal_id == %i AND regionname == %@", [elink valueForKey:@"sitename"], ((NSNumber *)[elink valueForKey:@"mal_id"]).intValue, [elink valueForKey:@"regionname"]]].count == 0) {
                [[NewStreamDataRetriever managedObjectContext] deleteObject:elink];
            }
        }
    }
    [[NewStreamDataRetriever managedObjectContext] save:nil];
}

+ (void)insertLinkEntryWithDictionary:(NSDictionary *)entry {
    NSManagedObject *nlink = [NSEntityDescription insertNewObjectForEntityForName:@"StreamData" inManagedObjectContext:self.managedObjectContext];
    [nlink setValue:entry[@"mal_id"] forKey:@"mal_id"];
    [nlink setValue:entry[@"regionname"] forKey:@"regionname"];
    [nlink setValue:entry[@"title"] forKey:@"title"];
    [nlink setValue:entry[@"url"] forKey:@"url"];
    [nlink setValue:entry[@"sitename"] forKey:@"sitename"];
    [nlink setValue:@(NSDate.date.timeIntervalSince1970) forKey:@"last_updated"];
    [[NewStreamDataRetriever managedObjectContext] save:nil];
}

@end
