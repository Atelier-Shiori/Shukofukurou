//
//  AtarashiiListCoreData.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/07/24.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "AtarashiiListCoreData.h"
#import "AppDelegate.h"
#import "listservice.h"
#import "Utility.h"

@implementation AtarashiiListCoreData
+ (NSManagedObjectContext *)managedObjectContext {
    return ((AppDelegate *)NSApplication.sharedApplication.delegate).managedObjectContext;
}

+ (bool)hasListEntriesWithUserID:(int)userid withService:(int)service withType:(int)type {
    return [self retrieveEntriesWithUserID:userid withService:service withType:type withPredicate:nil].count > 0;
}

+ (bool)hasListEntriesWithUserName:(NSString *)username withService:(int)service withType:(int)type {
    return [self retrieveEntriesWithUserName:username withService:service withType:type withPredicate:nil].count > 0;
}

+ (NSDictionary *)retrieveEntriesForUserId:(int)userid withService:(int)service withType:(int)type {
    NSArray *entries = [self retrieveEntriesWithUserID:userid withService:service withType:type withPredicate:nil];
    return [self processEntityArray:entries withType:type withService:service];
}

+ (NSDictionary *)retrieveEntriesForUserName:(NSString *)username withService:(int)service withType:(int)type {
    NSArray *entries = [self retrieveEntriesWithUserName:username withService:service withType:type withPredicate:nil];
    return [self processEntityArray:entries withType:type withService:service];
}

+ (NSDictionary *)retrieveSingleEntryForTitleID:(int)titleid withService:(int)service withType:(int)type {
    NSArray *entries;
    switch (service) {
        case 1: {
            entries = [self retrieveEntriesForUserName:[listservice.sharedInstance getCurrentServiceUsername] withService:service withType:type withPredicate:[NSPredicate predicateWithFormat:@"id == %i", titleid]];
            break;
        }
        case 2:
        case 3:
            entries = [self retrieveEntriesForUserId:[listservice.sharedInstance getCurrentUserID] withService:service withType:type withPredicate:[NSPredicate predicateWithFormat:@"id == %i", titleid]];
            break;
    }
    if (entries.count > 0) {
        return entries[0];
    }
    return nil;
}

+ (NSArray *)retrieveEntriesForUserId:(int)userid withService:(int)service withType:(int)type withPredicate:(NSPredicate *)filterpredicate {
    NSArray *entries = [self retrieveEntriesWithUserID:userid withService:service withType:type withPredicate:filterpredicate];
    NSMutableArray *tmplist = [NSMutableArray new];
    for (NSManagedObject *obj in entries) {
        NSArray *keys = obj.entity.attributesByName.allKeys;
        [tmplist addObject:[obj dictionaryWithValuesForKeys:keys]];
    }
    NSArray *uentries = tmplist.copy;
    return uentries;
}

+ (NSArray *)retrieveEntriesForUserName:(NSString *)username withService:(int)service withType:(int)type withPredicate:(NSPredicate *)filterpredicate {
    NSArray *entries = [self retrieveEntriesWithUserName:username withService:service withType:type withPredicate:filterpredicate];
    NSMutableArray *tmplist = [NSMutableArray new];
    for (NSManagedObject *obj in entries) {
        NSArray *keys = obj.entity.attributesByName.allKeys;
        [tmplist addObject:[obj dictionaryWithValuesForKeys:keys]];
    }
    NSArray *uentries = tmplist.copy;
    return uentries;
}

+ (void)insertorupdateentriesWithDictionary:(NSDictionary *)data withUserId:(int)userid withService:(int)service withType:(int)type {
    NSArray *newlist;
    switch (type) {
        case 0:
            newlist = data[@"anime"];
            break;
        case 1:
            newlist = data[@"manga"];
            break;
        default:
            return;
    }
    NSArray *existinglist = [self retrieveEntriesWithUserID:userid withService:service withType:type withPredicate:nil];
    NSDictionary *userInfo = @{ @"user_id" : @(userid), @"service" : @(service), @"type" : @(type) };
    [self processListUpdate:newlist withListArray:existinglist withUserInfo:userInfo];
}

+ (void)insertorupdateentriesWithDictionary:(NSDictionary *)data withUserName:(NSString *)username withService:(int)service withType:(int)type {
    NSArray *newlist;
    switch (type) {
        case 0:
            newlist = data[@"anime"];
            break;
        case 1:
            newlist = data[@"manga"];
            break;
        default:
            return;
    }
    NSArray *existinglist = [self retrieveEntriesWithUserName:username withService:service withType:type withPredicate:nil];
    NSDictionary *userInfo = @{ @"username" : username, @"service" : @(service), @"type" : @(type) };
    [self processListUpdate:newlist withListArray:existinglist withUserInfo:userInfo];
}

+ (void)updateSingleEntry:(NSDictionary *)parameters withUserId:(int)userid withService:(int)service withType:(int)type withId:(int)Id withIdType:(int)idtype {
    NSArray *listarray = [self retrieveEntriesWithUserID:userid withService:service withType:type withPredicate:nil];
    NSArray *existing;
    if (idtype == 0) {
        existing = [listarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i AND service == %i AND user_id == %i", Id, service, userid]];
    }
    else {
        existing = [listarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entryid == %i AND service == %i AND user_id == %i", Id, service, userid]];
    }
    if (existing.count > 0) {
        [self performSingleEntryUpdate:parameters withExistingEntry:existing[0]];
    }
}

+ (void)updateSingleEntry:(NSDictionary *)parameters withUserName:(NSString *)username withService:(int)service withType:(int)type withId:(int)Id withIdType:(int)idtype {
    NSArray *listarray = [self retrieveEntriesWithUserName:username withService:service withType:type withPredicate:nil];
    NSArray *existing;
    if (idtype == 0) {
        existing = [listarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i AND service == %i AND username ==[c] %@", Id, service, username]];
    }
    else {
        existing = [listarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entryid == %i AND service == %i AND username ==[c] %@", Id, service, username]];
    }
    if (existing.count > 0) {
        [self performSingleEntryUpdate:parameters withExistingEntry:existing[0]];
    }
}

+ (void)performSingleEntryUpdate:(NSDictionary *)parameters withExistingEntry:(NSManagedObject *)exentry {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSError *error = nil;
    [exentry setValuesForKeysWithDictionary:parameters];
    [moc save:&error];
}

+ (void)removeSingleEntrywithUserId:(int)userid withService:(int)service withType:(int)type withId:(int)Id withIdType:(int)idtype {
    NSArray *listarray = [self retrieveEntriesWithUserID:userid withService:service withType:type withPredicate:nil];
    NSArray *existing;
    if (idtype == 0) {
        existing = [listarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i AND service == %i AND user_id == %i", Id, service, userid]];
    }
    else {
        existing = [listarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entryid == %i AND service == %i AND user_id == %i", Id, service, userid]];
    }
    if (existing.count > 0) {
        [[self managedObjectContext] deleteObject:existing[0]];
    }
}

+ (void)removeSingleEntrywithUserName:(NSString *)username withService:(int)service withType:(int)type withId:(int)Id withIdType:(int)idtype {
    NSArray *listarray = [self retrieveEntriesWithUserName:username withService:service withType:type withPredicate:nil];
    NSArray *existing;
    if (idtype == 0) {
        existing = [listarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i AND service == %i AND username ==[c] %@", Id, service, username]];
    }
    else {
        existing = [listarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entryid == %i AND service == %i AND username ==[c] %@", Id, service, username]];
    }
    if (existing.count > 0) {
        [[self managedObjectContext] deleteObject:existing[0]];
    }
}

+ (void)removeAllEntrieswithService:(int)service {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSPredicate *predicate;
    fetchRequest.entity = [NSEntityDescription entityForName:@"AnimeListEntries" inManagedObjectContext:moc];
    predicate = [NSPredicate predicateWithFormat:@"service == %i",service];
    fetchRequest.predicate = predicate;
    NSError *error = nil;
    NSArray *listentries = [moc executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in listentries) {
        [moc deleteObject:obj];
    }
    fetchRequest.entity = [NSEntityDescription entityForName:@"MangaListEntries" inManagedObjectContext:moc];
    predicate = [NSPredicate predicateWithFormat:@"service == %i",service];
    fetchRequest.predicate = predicate;
    error = nil;
    listentries = [moc executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in listentries) {
        [moc deleteObject:obj];
    }
    [moc save:&error];
}

+ (NSArray *)retrieveEntriesWithUserID:(int)userid withService:(int)service withType:(int)type withPredicate:(NSPredicate *)filterpredicate {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSPredicate *predicate;
    switch (type) {
        case 0:
            fetchRequest.entity = [NSEntityDescription entityForName:@"AnimeListEntries" inManagedObjectContext:moc];
            break;
        case 1:
            fetchRequest.entity = [NSEntityDescription entityForName:@"MangaListEntries" inManagedObjectContext:moc];
            break;
        default:
            return @[];
    }
    predicate = [NSPredicate predicateWithFormat:@"user_id == %i AND service == %i",userid,service];
    if (filterpredicate) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate.copy, filterpredicate]];
    }
    fetchRequest.predicate = predicate;
    NSError *error = nil;
    NSArray *listentries = [moc executeFetchRequest:fetchRequest error:&error];
    return listentries;
}

+ (NSArray *)retrieveEntriesWithUserName:(NSString *)username withService:(int)service withType:(int)type withPredicate:(NSPredicate *)filterpredicate {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSPredicate *predicate;
    switch (type) {
        case 0:
            fetchRequest.entity = [NSEntityDescription entityForName:@"AnimeListEntries" inManagedObjectContext:moc];
            break;
        case 1:
            fetchRequest.entity = [NSEntityDescription entityForName:@"MangaListEntries" inManagedObjectContext:moc];
            break;
        default:
            return @[];
    }
    predicate = [NSPredicate predicateWithFormat:@"username ==[c] %@ AND service == %i",username,service];
    if (filterpredicate) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate.copy, filterpredicate]];
    }
    fetchRequest.predicate = predicate;
    NSError *error = nil;
    NSArray *listentries = [moc executeFetchRequest:fetchRequest error:&error];
    return listentries;
}

+ (NSDictionary *)processEntityArray:(NSArray *)entries withType:(int)type withService:(int)service {
    NSMutableArray *tmplist = [NSMutableArray new];
    for (NSManagedObject *obj in entries) {
        NSArray *keys = obj.entity.attributesByName.allKeys;
        [tmplist addObject:[obj dictionaryWithValuesForKeys:keys]];
    }
    switch (type) {
        case 0:
            return @{@"anime" : tmplist.copy, @"statistics": @{@"days" : @([Utility calculatedays:tmplist])}};
            break;
        case 1:
            return @{@"manga" : tmplist.copy, @"statistics": @{@"days" : @(0)}};
        default:
            return @{};
    }
}

+ (void)processListUpdate:(NSArray *)datalist withListArray:(NSArray *)listarray withUserInfo:(NSDictionary *)userinfo {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSError *error = nil;
    NSString *username = userinfo[@"username"] ? userinfo[@"username"] : @"";
    int type = ((NSNumber *)userinfo[@"type"]).intValue;
    int userid = userinfo[@"user_id"] ? ((NSNumber *) userinfo[@"user_id"]).intValue : 0;
    int service = ((NSNumber *)userinfo[@"service"]).intValue;
    for (NSDictionary *entry in datalist) {
        NSArray *existing;
        if (userid > 0) {
            existing = [listarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i AND service == %i AND user_id == %i", ((NSNumber *)entry[@"id"]).intValue, service, userid]];
        }
        else {
            existing = [listarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i AND service == %i AND username ==[c] %@", ((NSNumber *)entry[@"id"]).intValue, service, username]];
        }
        if (existing.count > 0) {
            //Update existing entry
            NSManagedObject *existingentry = existing[0];
            if (![self entryNeedsUpdatingWithEntry:entry withExistingEntry:existingentry withType:type]) {
                [existingentry setValuesForKeysWithDictionary:entry];
                [moc save:&error];
            }
            else {
                continue;
            }
        }
        else {
            // Insert
            NSManagedObject *nentry;
            switch (type) {
                case 0:
                    nentry = [NSEntityDescription insertNewObjectForEntityForName:@"AnimeListEntries" inManagedObjectContext:moc];
                    break;
                case 1:
                    nentry = [NSEntityDescription insertNewObjectForEntityForName:@"MangaListEntries" inManagedObjectContext:moc];
                    break;
                default:
                    break;
            }
            [nentry setValuesForKeysWithDictionary:entry];
            if (userid > 0) {
                [nentry setValue:@(userid) forKey:@"user_id"];
            }
            else {
                [nentry setValue:username forKey:@"username"];
            }
            [nentry setValue:@(service) forKey:@"service"];
            [moc save:&error];
        }
    }
    // Clean up entries that no longer exist on the actual list
    for (NSManagedObject *obj in listarray) {
        if ([datalist filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i",((NSNumber *)[obj valueForKey:@"id"]).intValue]].count == 0) {
            [moc deleteObject:obj];
        }
    }
    [moc save:&error];
}
+ (bool)entryNeedsUpdatingWithEntry:(NSDictionary *)entry withExistingEntry:(NSManagedObject *)existingEntry withType:(int)type {
    bool same = false;
    bool extrafieldssame = false;
    bool startdatessame = false;
    bool enddatessame = false;
    bool iseithercommentsempty = false;
    int currentlistservice = [listservice.sharedInstance getCurrentServiceID];
    switch (type) {
        case 0: {
            same = [entry[@"episodes"] isEqualToNumber:[existingEntry valueForKey:@"episodes"]] && [entry[@"watched_episodes"] isEqualToNumber:[existingEntry valueForKey:@"watched_episodes"]] && [entry[@"score"] isEqualToNumber:[existingEntry valueForKey:@"score"]] && [entry[@"rewatching"] isEqualToNumber:[existingEntry valueForKey:@"rewatching"]] && [entry[@"rewatch_count"] isEqualToNumber:[existingEntry valueForKey:@"rewatch_count"]] && [entry[@"status"] isEqualToString:[existingEntry valueForKey:@"status"]] && [entry[@"watched_status"] isEqualToString:[existingEntry valueForKey:@"watched_status"]] && [entry[@"last_updated"] isEqualToNumber:[existingEntry valueForKey:@"last_updated"] ? [existingEntry valueForKey:@"last_updated"] : @(0)]  && [entry[@"aired_start"] isEqualToString:[existingEntry valueForKey:@"aired_start"]] && [entry[@"aired_finish"] isEqualToString:[existingEntry valueForKey:@"aired_finish"]] && [entry[@"aired_season"] isEqualToString:[existingEntry valueForKey:@"aired_season"]] && ((NSNumber *)entry[@"aired_year"]).intValue == ((NSNumber *)[existingEntry valueForKey:@"aired_year"]).intValue;
            switch (currentlistservice) {
                case 1:
                    extrafieldssame = [entry[@"personal_tags"] isEqualToString:[existingEntry valueForKey:@"personal_tags"]];
                    break;
                case 2:
                    extrafieldssame = [entry[@"private"] isEqualToNumber:[existingEntry valueForKey:@"private"]];
                    iseithercommentsempty = entry[@"personal_comments"] == [NSNull null] || [existingEntry valueForKey:@"personal_comments"] == NULL;
                    extrafieldssame = iseithercommentsempty ? extrafieldssame && (entry[@"personal_comments"] == [NSNull null] && [existingEntry valueForKey:@"personal_comments"] == NULL) : extrafieldssame && [entry[@"personal_comments"] isEqualToString:[existingEntry valueForKey:@"personal_comments"]];
                    break;
                case 3:
                    extrafieldssame = [entry[@"private"] isEqualToNumber:[existingEntry valueForKey:@"private"]] && [entry[@"custom_lists"] isEqualToString:[existingEntry valueForKey:@"custom_lists"]];
                    iseithercommentsempty = entry[@"personal_comments"] == [NSNull null] || [existingEntry valueForKey:@"personal_comments"] == NULL;
                    extrafieldssame = iseithercommentsempty ? extrafieldssame && (entry[@"personal_comments"] == [NSNull null] && [existingEntry valueForKey:@"personal_comments"] == NULL) : extrafieldssame && [entry[@"personal_comments"] isEqualToString:[existingEntry valueForKey:@"personal_comments"]];
                    break;
                default:
                    break;
            }
            if ((entry[@"watching_start"] == [NSNull null] && [existingEntry valueForKey:@"watching_start"] == NULL) || (!entry[@"watching_start"] && [existingEntry valueForKey:@"watching_start"] == NULL) || [entry[@"watching_start"] isEqualToString:[existingEntry valueForKey:@"watching_start"]]) {
                startdatessame = true;
            }
            if ((entry[@"watching_end"] == [NSNull null] && [existingEntry valueForKey:@"watching_end"] == NULL) || (!entry[@"watching_end"] && [existingEntry valueForKey:@"watching_end"] == NULL) || [entry[@"watching_end"] isEqualToString:[existingEntry valueForKey:@"watching_end"]]) {
                enddatessame = true;
            }
            return (same && extrafieldssame && startdatessame && enddatessame);
        }
        case 1: {
            same = [entry[@"volumes"] isEqualToNumber:[existingEntry valueForKey:@"volumes"]] && [entry[@"volumes_read"] isEqualToNumber:[existingEntry valueForKey:@"volumes_read"]] && [entry[@"chapters"] isEqualToNumber:[existingEntry valueForKey:@"chapters"]] && [entry[@"chapters_read"] isEqualToNumber:[existingEntry valueForKey:@"chapters_read"]] && [entry[@"score"] isEqualToNumber:[existingEntry valueForKey:@"score"]] && [entry[@"rereading"] isEqualToNumber:[existingEntry valueForKey:@"rereading"]] && [entry[@"reread_count"] isEqualToNumber:[existingEntry valueForKey:@"reread_count"]] && [entry[@"status"] isEqualToString:[existingEntry valueForKey:@"status"]] && [entry[@"read_status"] isEqualToString:[existingEntry valueForKey:@"read_status"]] && [entry[@"last_updated"] isEqualToNumber:[existingEntry valueForKey:@"last_updated"]];
            switch (currentlistservice) {
                case 1:
                    extrafieldssame = [entry[@"personal_tags"] isEqualToString:[existingEntry valueForKey:@"personal_tags"]];
                    break;
                case 2:
                    extrafieldssame = [entry[@"private"] isEqualToNumber:[existingEntry valueForKey:@"private"]];
                    iseithercommentsempty = entry[@"personal_comments"] == [NSNull null] || [existingEntry valueForKey:@"personal_comments"] == NULL;
                    extrafieldssame = iseithercommentsempty ? extrafieldssame && (entry[@"personal_comments"] == [NSNull null] && [existingEntry valueForKey:@"personal_comments"] == NULL) : extrafieldssame && [entry[@"personal_comments"] isEqualToString:[existingEntry valueForKey:@"personal_comments"]];
                    break;
                case 3:
                    extrafieldssame = [entry[@"private"] isEqualToNumber:[existingEntry valueForKey:@"private"]] && [entry[@"custom_lists"] isEqualToString:[existingEntry valueForKey:@"custom_lists"]];
                    iseithercommentsempty = entry[@"personal_comments"] == [NSNull null] || [existingEntry valueForKey:@"personal_comments"] == NULL;
                    extrafieldssame = iseithercommentsempty ? extrafieldssame && (entry[@"personal_comments"] == [NSNull null] && [existingEntry valueForKey:@"personal_comments"] == NULL) : extrafieldssame && [entry[@"personal_comments"] isEqualToString:[existingEntry valueForKey:@"personal_comments"]];
                    break;
                default:
                    break;
            }
            if ((entry[@"reading_start"] == [NSNull null] && [existingEntry valueForKey:@"reading_start"] == NULL) || (!entry[@"reading_start"] && [existingEntry valueForKey:@"reading_start"] == NULL) || [entry[@"reading_start"] isEqualToString:[existingEntry valueForKey:@"reading_start"]]) {
                startdatessame = true;
            }
            if ((entry[@"reading_end"] == [NSNull null] && [existingEntry valueForKey:@"reading_end"] == NULL) || (!entry[@"reading_end"] && [existingEntry valueForKey:@"reading_end"] == NULL) || [entry[@"reading_end"] isEqualToString:[existingEntry valueForKey:@"reading_end"]]) {
                enddatessame = true;
            }
            return (same && extrafieldssame && startdatessame && enddatessame);
        }
    }
    return false;
}
@end
