//
//  TitleInfoCache.m
//  Shukofukurou-IOS
//
//  Created by 香風智乃 on 9/27/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import "TitleInfoCache.h"
#import "AppDelegate.h"
#import "listservice.h"

@implementation TitleInfoCache
+ (NSManagedObjectContext *)managedObjectContext {
    return ((AppDelegate *)NSApplication.sharedApplication.delegate).managedObjectContext;
}

+ (NSDictionary *)getTitleInfoWithTitleID:(int)titleid withServiceID:(int)serviceid withType:(int)type ignoreLastUpdated:(bool)ignorelastupdated {
    [self cleanupcacheShouldRemoveAll:NO];
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSManagedObject *entry = [self getTitleInfoManagedObjectTitleID:titleid withServiceID:serviceid withType:type];
    if (entry) {
        if ([(NSDate *)[entry valueForKey:@"lastupdated"] timeIntervalSinceNow] < 172800 || ignorelastupdated) {
            [entry setValue:[NSDate date] forKey:@"lastaccessed"];
            [moc save:nil];
            NSError *error;
            NSDictionary *jsondata = [NSJSONSerialization JSONObjectWithData:[(NSString *)[entry valueForKey:@"jsondata"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            if (jsondata) {
                return jsondata;
            }
        }
    }
    return nil;
}

+ (NSDictionary *)saveTitleInfoWithTitleID:(int)titleid withServiceID:(int)serviceid withType:(int)type withResponseObject:(id)responseObject {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSManagedObject *entry = [self getTitleInfoManagedObjectTitleID:titleid withServiceID:serviceid withType:type];
    if (entry) {
        // Update entry only
        NSDate *nowDate = [NSDate date];
        [entry setValue:nowDate forKey:@"lastaccessed"];
        [entry setValue:nowDate forKey:@"lastupdated"];
        [entry setValue:[self serializeDictionarytoJSON:responseObject] forKey:@"jsondata"];
    }
    else {
        // Insert new entry
        entry = [NSEntityDescription insertNewObjectForEntityForName:@"CachedTitleEntries" inManagedObjectContext:moc];
        [entry setValue:@(titleid) forKey:@"titleid"];
        [entry setValue:@(serviceid) forKey:@"serviceid"];
        [entry setValue:@(type) forKey:@"type"];
        NSDate *nowDate = [NSDate date];
        [entry setValue:nowDate forKey:@"lastaccessed"];
        [entry setValue:nowDate forKey:@"lastupdated"];
        [entry setValue:[self serializeDictionarytoJSON:responseObject] forKey:@"jsondata"];
    }
    [moc save:nil];
    return responseObject;
}

+ (NSManagedObject *)getTitleInfoManagedObjectTitleID:(int)titleid withServiceID:(int)serviceid withType:(int)type {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"CachedTitleEntries" inManagedObjectContext:moc];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"titleid == %i AND type == %i AND serviceid == %i",titleid, type, serviceid];
    NSError *error = nil;
    NSArray *titleentries = [moc executeFetchRequest:fetchRequest error:&error];
    if (titleentries.count > 0) {
        return titleentries[0];
    }
    return nil;
}

+ (NSArray *)getAllTitleEntries {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"CachedTitleEntries" inManagedObjectContext:moc];
    NSError *error = nil;
    NSArray *titleentries = [moc executeFetchRequest:fetchRequest error:&error];
    if (titleentries.count > 0) {
        return titleentries;
    }
    return @[];
}

+ (NSString *)serializeDictionarytoJSON:(id)responseObject {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}

+ (void)cleanupcacheShouldRemoveAll:(bool)removeall {
    NSArray *entries = [self getAllTitleEntries];
    NSManagedObjectContext *moc = [self managedObjectContext];
    for (NSManagedObject *entry in entries) {
        if ([(NSDate *)[entry valueForKey:@"lastaccessed"] timeIntervalSinceNow] > 1209600 || removeall) {
            [moc deleteObject:entry];
        }
    }
    [moc save:nil];
}

@end
