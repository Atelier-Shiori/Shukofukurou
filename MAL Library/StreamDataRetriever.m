//
//  StreamDataRetriever.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/06/20.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved.
//

#import "AppDelegate.h"
#import "StreamDataRetriever.h"
#import "Utility.h"
#import <AFNetworking/AFNetworking.h>
#import "listservice.h"
#import "TitleIDMapper.h"

@implementation StreamDataRetriever
+ (NSManagedObjectContext *)managedObjectContext {
    return ((AppDelegate *)NSApplication.sharedApplication.delegate).managedObjectContext;
}

+ (void)saveStreamData:(id)responseObject {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSError *error = nil;
    NSDictionary *streamentry = responseObject;
    NSManagedObject *entry = [self checkExistingEntryForTitle:((NSNumber *)streamentry[@"id"]).intValue];
    if (!entry) {
        entry = [NSEntityDescription insertNewObjectForEntityForName:@"AniListStreamSites" inManagedObjectContext:moc];;
        [entry setValue:streamentry[@"name"] forKey:@"title"];
        [entry setValue:streamentry[@"id"] forKey:@"titleid"];
    }
    NSString *sitesjson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:streamentry[@"links"] options:NSJSONWritingPrettyPrinted  error:nil] encoding:NSUTF8StringEncoding];
    [entry setValue:sitesjson forKey:@"sites"];
    int unixtimestamp = [NSDate.date timeIntervalSince1970];
    [entry setValue:@(unixtimestamp) forKey:@"retrievedate"];
    [moc save:&error];
}

+ (NSManagedObject *)checkExistingEntryForTitle:(int)titleid {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"AniListStreamSites" inManagedObjectContext:moc];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"titleid == %i", titleid];
    NSArray *streamentries =  [moc executeFetchRequest:fetchRequest error:&error];
    if (streamentries.count > 0) {
        return streamentries[0];
    }
    return nil;
}

+ (void)retrieveSitesForTitle:(int)titleid completion:(void (^)(id responseObject)) completionHandler {
    [TitleIDMapper.sharedInstance retrieveTitleIdForService:listservice.sharedInstance.getCurrentServiceID withTitleId:@(titleid).stringValue withTargetServiceId:titleIDMapAniList withType:MALAnime completionHandler:^(id  _Nonnull ntitleid, bool success) {
        if (success && ntitleid != [NSNull null]) {
            NSManagedObject *streamentry = [self checkExistingEntryForTitle:((NSNumber *)ntitleid).intValue];
            int lastretrievedate = ((NSNumber *)[streamentry valueForKey:@"retrievedate"]).intValue;
            int currenttimeintervaldif = (int)[NSDate.date timeIntervalSince1970] - lastretrievedate;
            if (streamentry && currenttimeintervaldif <= 5184000) {
                @try {
                    // Deserialize other_titles JSON object
                    NSError *error;
                    NSArray *jsondata = [NSJSONSerialization JSONObjectWithData:[(NSString *)[streamentry valueForKey:@"sites"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                    if (jsondata) {
                        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"site" ascending:YES];
                        completionHandler([jsondata sortedArrayUsingDescriptors:@[descriptor]]);
                    }
                }
                @catch (NSException *ex) {
                    NSLog(@"Unable to deserialize stream site data with exception: %@", ex);
                    completionHandler(@{});
                }
            }
            else {
                        [listservice.sharedInstance.anilistManager retrieveStreamLinksForId:((NSNumber *)ntitleid).intValue completion:^(id responseObject) {
                            [self saveStreamData:responseObject];
                            [self retrieveSitesForTitle:titleid completion:completionHandler];
                        } error:^(NSError *error) {
                            if (!error) {
                                NSManagedObjectContext *moc = [self managedObjectContext];
                                NSArray *shows = [self getAllObjects];
                                NSArray *filteredshows = [shows filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"titleid == %i",titleid]];
                                for (NSManagedObject *sentry in filteredshows) {
                                    NSArray *tmparray = [shows filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"titleid == %i",titleid]];
                                    if (tmparray.count == 0) {
                                        [moc deleteObject:sentry];
                                    }
                                }
                                completionHandler(@{});
                            }
                            else {
                                completionHandler(@{});
                            }
                        }];
            }
        }
        else {
            completionHandler(@{});
        }
    }];
}

+ (NSArray *)getAllObjects {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"AniListStreamSites" inManagedObjectContext:moc];
    NSArray *streamentries =  [moc executeFetchRequest:fetchRequest error:&error];
    if (streamentries) {
        return streamentries;
    }
    return @[];
}

+ (void)removeAllStreamEntries {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSArray *streamentries = [self getAllObjects];
    for (NSManagedObject *mobject in streamentries) {
        [moc deleteObject:mobject];
    }
    [moc save:nil];
}

@end
