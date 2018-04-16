//
//  TitleIdConverter.m
//  MAL Library
//
//  Created by 小鳥遊六花 on 2/27/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "TitleIdConverter.h"
#import <AFNetworking/AFNetworking.h>
#import "Utility.h"
#import "listservice.h"
#import "AppDelegate.h"
#import "XMLReader.h"
#import "Keychain.h"

@implementation TitleIdConverter
static BOOL lookingupid;
static BOOL importing;

+ (void)getKitsuIDFromMALId:(int)malid withTitle:(NSString *)title titletype:(NSString *)titletype withType:(int)type completionHandler:(void (^)(int kitsuid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    if (lookingupid && !importing)  {
        return;
    }
    // Check to see if title exists in the title id mappings. If so, just use the id from the mapping.
    int tmpid = [self lookupTitleID:malid withType:type fromService:1 toService:2];
    if (tmpid > 0) {
        completionHandler(tmpid);
        return;
    }
    lookingupid = true;
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    NSString *typestr = @"";
    switch (type) {
        case 0:
            typestr = @"anime";
            break;
        case 1:
            typestr = @"manga";
        default:
            break;
    }
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/mappings?filter[externalSite]=myanimelist/%@&filter[external_id]=%i",typestr, malid] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (((NSArray *)responseObject[@"data"]).count > 0) {
            NSDictionary *mapping = responseObject[@"data"][0];
            NSString *relationshipurl = mapping[@"relationships"][@"item"][@"links"][@"self"];
            [manager GET:relationshipurl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (responseObject[@"data"][@"id"]) {
                    NSNumber *kitsuid = responseObject[@"data"][@"id"];
                    [self savetitleidtomapping:malid withNewID:kitsuid.intValue withType:type fromService:1 toService:2];
                    completionHandler(kitsuid.intValue);
                }
                else {
                    errorHandler(nil);
                }
                lookingupid = false;
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                errorHandler(error);
                lookingupid = false;
            }];
        }
        else {
            [Kitsu searchTitle:title withType:type completion:^(id responseObject) {
                int newid = [self findTitle:title withType:titletype withResponseObject:responseObject];
                if (newid > 0) {
                    [self savetitleidtomapping:malid withNewID:newid withType:type fromService:1 toService:2];
                    completionHandler(newid);
                }
                else {
                    errorHandler(nil);
                }
                lookingupid = false;
            } error:^(NSError *error) {
                errorHandler(nil);
                lookingupid = false;
            }];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
        lookingupid = false;
    }];
}
+ (void)getMALIDFromKitsuId:(int)kitsuid withTitle:(NSString *)title titletype:(NSString *)titletype withType:(int)type completionHandler:(void (^)(int malid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    if (lookingupid && !importing)  {
        return;
    }
    int tmpid = [self lookupTitleID:kitsuid withType:type fromService:2 toService:1];
    if (tmpid > 0) {
        completionHandler(tmpid);
        return;
    }
    lookingupid = true;
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    NSString *typestr = @"";
    switch (type) {
        case 0:
            typestr = @"anime";
            break;
        case 1:
            typestr = @"manga";
        default:
            break;
    }
    NSString *filterstr = [NSString stringWithFormat:@"myanimelist/%@", typestr];
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/%@/%i?include=mappings&fields[anime]=id",typestr ,kitsuid] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        for (NSDictionary *map in responseObject[@"included"]) {
            if ([(NSString *)map[@"attributes"][@"externalSite"] caseInsensitiveCompare:filterstr] == NSOrderedSame) {
                NSNumber *malid = map[@"attributes"][@"externalId"];
                [self savetitleidtomapping:kitsuid withNewID:malid.intValue withType:type fromService:2 toService:1];
                completionHandler(malid.intValue);
                lookingupid = false;
                break;
            }
        }
        if (lookingupid) {
            lookingupid = false;
            [self retrieveMALIDwithTitle:title withMediaType:type withType:titletype completionHandler:^(int malid) {
                [self savetitleidtomapping:kitsuid withNewID:malid withType:type fromService:2 toService:1];
                completionHandler(malid);
                lookingupid = false;
            } error:^(NSError *error) {
                errorHandler(error);
                lookingupid = false;
            }];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
        lookingupid = false;
    }];
}

+ (void)getMALIDFromAniListID:(int)titleid withTitle:(NSString *)title titletype:(NSString *)titletype withType:(int)type completionHandler:(void (^)(int malid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    if (lookingupid && !importing)  {
        return;
    }
    int tmpid = [self lookupTitleID:titleid withType:type fromService:3 toService:1];
    if (tmpid > 0) {
        completionHandler(tmpid);
        return;
    }
    lookingupid = true;
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    NSString *typestr = @"";
    switch (type) {
        case 0:
            typestr = @"ANIME";
            break;
        case 1:
            typestr = @"MANGA";
        default:
            break;
    }
    NSDictionary *parameters = @{@"query": @"query ($id: Int!, $type: MediaType) {\n  Media(id: $id, type: $type) {\n    id\n    idMal\n  }\n}", @"variables" : @{@"id":@(titleid), @"type" : typestr}};
    [manager POST:@"https://graphql.anilist.co" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self savetitleidtomapping:titleid withNewID:((NSNumber *)responseObject[@"data"][@"Media"][@"idMal"]).intValue withType:type fromService:3 toService:1];
            completionHandler(((NSNumber *)responseObject[@"data"][@"Media"][@"idMal"]).intValue);
            lookingupid = false;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self retrieveMALIDwithTitle:title withMediaType:type withType:titletype completionHandler:^(int malid) {
            if (malid > 0) {
                [self savetitleidtomapping:titleid withNewID:malid withType:MALAnime fromService:3 toService:1];
                completionHandler(malid);
            }
            else {
                errorHandler(nil);
            }
            lookingupid = false;
        } error:^(NSError *error) {
            errorHandler(error);
            lookingupid = false;
        }];
    }];
}
+ (void)getAniIDFromMALListID:(int)titleid withTitle:(NSString *)title titletype:(NSString *)titletype withType:(int)type completionHandler:(void (^)(int anilistid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    if (lookingupid && !importing)  {
        return;
    }
    int tmpid = [self lookupTitleID:titleid withType:type fromService:1 toService:3];
    if (tmpid > 0) {
        completionHandler(tmpid);
        return;
    }
    lookingupid = true;
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    NSString *typestr = @"";
    switch (type) {
        case 0:
            typestr = @"ANIME";
            break;
        case 1:
            typestr = @"MANGA";
        default:
            break;
    }
    NSDictionary *parameters = @{@"query": @"query ($id: Int!, $type: MediaType) {\n  Media(idMal: $id, type: $type) {\n    id\n    idMal\n  }\n}", @"variables" : @{@"id":@(titleid), @"type" : typestr}};
    [manager POST:@"https://graphql.anilist.co" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self savetitleidtomapping:titleid withNewID:((NSNumber *)responseObject[@"data"][@"Media"][@"id"]).intValue withType:type fromService:1 toService:3];
        completionHandler(((NSNumber *)responseObject[@"data"][@"Media"][@"id"]).intValue);
        lookingupid = false;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self getserviceTitleIDFromServiceID:titleid withTitle:title titletype:titletype fromServiceID:1 completionHandler:^(int anilistid) {
            if (anilistid > 0) {
                [self savetitleidtomapping:titleid withNewID:anilistid withType:type fromService:1 toService:3];
                completionHandler(anilistid);
            }
            else {
                errorHandler(nil);
            }
            lookingupid = false;
        } error:^(NSError *error) {
            errorHandler(error);
            lookingupid = false;
        }];
    }];
}
+ (void)getAniIDFromKitsuID:(int)titleid withTitle:(NSString *)title titletype:(NSString *)titletype withType:(int)type completionHandler:(void (^)(int anilistid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    if (lookingupid && !importing)  {
        return;
    }
    int tmpid = [self lookupTitleID:titleid withType:type fromService:2 toService:3];
    if (tmpid > 0) {
        completionHandler(tmpid);
        return;
    }
    lookingupid = false;
    [self getMALIDFromKitsuId:titleid withTitle:title titletype:titletype  withType:type completionHandler:^(int malid) {
        lookingupid = false;
        [self KitsuFindAniId:malid withTitle:title withTitleType:titletype withTitleid:titleid withType:type completionHandler:completionHandler error:errorHandler];
    } error:^(NSError *error) {
        lookingupid = false;
        [self retrieveMALIDwithTitle:title withMediaType:type withType:titletype completionHandler:^(int malid) {
            if (malid > 0) {
                [self KitsuFindAniId:malid withTitle:title withTitleType:titletype withTitleid:titleid withType:type completionHandler:completionHandler error:errorHandler];
                lookingupid = false;
            }
            else {
                errorHandler(nil);
                lookingupid = false;
            }
        } error:^(NSError *error) {
            errorHandler(error);
            lookingupid = false;
        }];
    }];;
}
+ (void)getKitsuIdFromAniID:(int)titleid withTitle:(NSString *)title titletype:(NSString *)titletype withType:(int)type completionHandler:(void (^)(int kitsuid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    if (lookingupid && !importing)  {
        return;
    }
    int tmpid = [self lookupTitleID:titleid withType:type fromService:3 toService:2];
    if (tmpid > 0) {
        completionHandler(tmpid);
        return;
    }
    lookingupid = false;
    [self getMALIDFromAniListID:titleid withTitle:titletype titletype:titletype withType:type completionHandler:^(int malid) {
        lookingupid = false;
        [self getKitsuIDFromMALId:malid withTitle:title titletype:titletype withType:type completionHandler:^(int kitsuid) {
            [self savetitleidtomapping:titleid withNewID:kitsuid withType:type fromService:2 toService:3];
            completionHandler(kitsuid);
            lookingupid = false;
        } error:^(NSError *error) {
            lookingupid = true;
            [Kitsu searchTitle:title withType:type completion:^(id responseObject) {
                int newid = [self findTitle:title withType:titletype withResponseObject:responseObject];
                if (newid > 0) {
                    [self savetitleidtomapping:titleid withNewID:newid withType:type fromService:3 toService:2];
                    completionHandler(newid);
                }
                else {
                    errorHandler(nil);
                }
                lookingupid = false;
            } error:^(NSError *error) {
                errorHandler(error);
                lookingupid = false;
            }];
        }];
    } error:^(NSError *error) {
        errorHandler(error);
        lookingupid = false;
    }];
}
+ (void)getMALIDFromServiceID:(int)titleid withTitle:(NSString *)title titletype:(NSString *)titletype withType:(int)type fromServiceID:(int)fromservice completionHandler:(void (^)(int malid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    if (lookingupid && !importing)  {
        return;
    }
    int tmpid = [self lookupTitleID:titleid withType:type fromService:fromservice toService:1];
    if (tmpid > 0) {
        completionHandler(tmpid);
        return;
    }
    lookingupid = true;
    [self retrieveMALIDwithTitle:title withMediaType:type withType:titletype completionHandler:^(int malid) {
        if (malid > 0) {
            [self savetitleidtomapping:titleid withNewID:malid withType:MALAnime fromService:fromservice toService:1];
            completionHandler(malid);
        }
        else {
            errorHandler(nil);
        }
        lookingupid = false;
    } error:^(NSError *error) {
        errorHandler(error);
        lookingupid = false;
    }];
}

+ (void)getserviceTitleIDFromServiceID:(int)titleid withTitle:(NSString *)title titletype:(NSString *)titletype fromServiceID:(int)fromservice completionHandler:(void (^)(int kitsuid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    if (lookingupid && !importing)  {
        return;
    }
    int tmpid = [self lookupTitleID:titleid withType:MALAnime fromService:fromservice toService:[listservice getCurrentServiceID]];
    if (tmpid > 0) {
        completionHandler(tmpid);
        return;
    }
    lookingupid = true;
    [listservice searchTitle:title withType:MALAnime completion:^(id responseObject) {
        int newid = [self findTitle:title withType:MALAnime withResponseObject:responseObject];
        if (newid > 0) {
            [self savetitleidtomapping:titleid withNewID:newid withType:MALAnime fromService:fromservice toService:[listservice getCurrentServiceID]];
            completionHandler(newid);
            lookingupid = false;
            return;
        }
        errorHandler(nil);
        lookingupid = false;
    } error:^(NSError *error) {
        errorHandler(error);
        lookingupid = false;
    }];
}

#pragma mark Helpers
+ (int)lookupTitleID:(int)titleid withType:(int)type fromService:(int)fromservice toService:(int)toservice {
    NSManagedObject *mapping = [self retrieveexistingmapping:titleid withType:type withService:fromservice];
    switch (toservice) {
        case 1: {
            if (((NSNumber *)[mapping valueForKey:@"mal_id"]).intValue > 0) {
                return ((NSNumber *)[mapping valueForKey:@"mal_id"]).intValue;
            }
            return -1;
           }
        case 2: {
            if (((NSNumber *)[mapping valueForKey:@"kitsu_id"]).intValue > 0) {
                return ((NSNumber *)[mapping valueForKey:@"kitsu_id"]).intValue;
            }
            return -1;
        }
        case 3: {
            if (((NSNumber *)[mapping valueForKey:@"anilist_id"]).intValue > 0) {
                return ((NSNumber *)[mapping valueForKey:@"anilist_id"]).intValue;
            }
            return -1;
        }
        default:
            break;
    }
    return -1;
}

+ (NSManagedObject *)retrieveexistingmapping:(int)titleid withType:(int)type withService:(int)service {
    NSManagedObjectContext *moc = ((AppDelegate *)NSApp.delegate).managedObjectContext;
    NSFetchRequest *fetch = [NSFetchRequest new];
    NSPredicate *predicate;
    fetch.entity = [NSEntityDescription entityForName:@"Titleidmappings" inManagedObjectContext:moc];
    NSString *typestr;
    switch (type) {
        case 0:
            typestr = @"anime";
            break;
        case 1:
            typestr = @"manga";
            break;
        default:
            return nil;
    }
    switch (service) {
        case 1:
            predicate = [NSPredicate predicateWithFormat:@"mal_id == %li AND type == %@", titleid, typestr];
            break;
        case 2:
            predicate = [NSPredicate predicateWithFormat:@"kitsu_id == %li AND type == %@", titleid, typestr];
            break;
        case 3:
            predicate = [NSPredicate predicateWithFormat:@"anilist_id == %li  AND type == %@", titleid, typestr];
            break;
        case 4:
            predicate = [NSPredicate predicateWithFormat:@"anidb_id == %li  AND type == %@", titleid, typestr];
            break;
        default:
            return nil;
    }
    fetch.predicate = predicate;
    NSError *error = nil;
    NSArray *fmappings = [moc executeFetchRequest:fetch error:&error];
    if (fmappings.count > 0) {
        return fmappings[0];
    }
    return nil;
}


+ (void)savetitleidtomapping:(int)oldid withNewID:(int)newid withType:(int)type fromService:(int)fromService toService:(int)toService {
    NSManagedObject *mapping = [self retrieveexistingmapping:oldid withType:type withService:fromService];
    if (!mapping) {
        // Use to service's title id
        mapping = [self retrieveexistingmapping:newid withType:type withService:toService];
    }
    if (mapping) {
        // Update existing mapping
        NSManagedObjectContext *moc = ((AppDelegate *)NSApp.delegate).managedObjectContext;
        switch (toService) {
            case 1: {
                if (((NSNumber *)[mapping valueForKey:@"mal_id"]).intValue == 0) {
                    [mapping setValue:@(newid) forKey:@"mal_id"];
                }
                break;
            }
            case 2: {
                if (((NSNumber *)[mapping valueForKey:@"kitsu_id"]).intValue == 0) {
                    [mapping setValue:@(newid) forKey:@"kitsu_id"];
                }
                break;
            }
            case 3: {
                if (((NSNumber *)[mapping valueForKey:@"anilist_id"]).intValue == 0) {
                    [mapping setValue:@(newid) forKey:@"anilist_id"];
                }
                break;
            }
            default:
                break;
        }
        switch (fromService) {
            case 1: {
                if (((NSNumber *)[mapping valueForKey:@"mal_id"]).intValue == 0) {
                    [mapping setValue:@(oldid) forKey:@"mal_id"];
                }
                break;
            }
            case 2: {
                if (((NSNumber *)[mapping valueForKey:@"kitsu_id"]).intValue == 0) {
                    [mapping setValue:@(oldid) forKey:@"kitsu_id"];
                }
                break;
            }
            case 3: {
                if (((NSNumber *)[mapping valueForKey:@"anilist_id"]).intValue == 0) {
                    [mapping setValue:@(oldid) forKey:@"anilist_id"];
                }
                break;
            }
            default:
                break;
        }
        [moc save:nil];
        [moc reset];
    }
    else {
        // Create new mapping
        [self createandsavetitleidtomapping:oldid withNewID:newid withType:type fromService:fromService toService:toService];
    }
}

+ (void)createandsavetitleidtomapping:(int)oldid withNewID:(int)newid withType:(int)type fromService:(int)fromService toService:(int)toService {
    if (fromService < 1 || fromService > 4 || toService < 1 || toService > 4 ) {
        return;
    }
    NSManagedObjectContext *moc = ((AppDelegate *)NSApp.delegate).managedObjectContext;
    NSManagedObject *obj = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Titleidmappings"
                            inManagedObjectContext: moc];
    NSString *strtype = type == 0 ? @"anime" : @"manga";
    [obj setValue:strtype forKey:@"type"];
    switch (fromService) {
        case 1:
            [obj setValue:@(oldid) forKey:@"mal_id"];
            break;
        case 2:
            [obj setValue:@(oldid) forKey:@"kitsu_id"];
            break;
        case 3:
            [obj setValue:@(oldid) forKey:@"anilist_id"];
            break;
        case 4:
            [obj setValue:@(oldid) forKey:@"anidb_id"];
            break;
        default:
            break;
    }
    switch (toService) {
        case 1:
            [obj setValue:@(newid) forKey:@"mal_id"];
            break;
        case 2:
            [obj setValue:@(newid) forKey:@"kitsu_id"];
            break;
        case 3:
            [obj setValue:@(newid) forKey:@"anilist_id"];
            break;
        default:
            break;
    }
    [moc save:nil];
    [moc reset];
}
+ (void)findCurrentServiceTitleIDWithMALID:(int)malid type:(int)type completionHandler:(void (^)(int currentserviceid, int currentservice)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    [MyAnimeList retrieveTitleInfo:malid withType:type useAccount:NO completion:^(id responseObject) {
        __block NSString *title = responseObject[@"title"];
        __block NSDictionary *othertitles = responseObject[@"other_titles"];
        [listservice searchTitle:title withType:type completion:^(id responseObject) {
            for (NSDictionary *searchentry in responseObject) {
                NSString *tmptitle = (NSString *)searchentry[@"title"];
                if ([tmptitle isEqualToString:title]) {
                    completionHandler(((NSNumber *)searchentry[@"id"]).intValue, [listservice getCurrentServiceID]);
                    return;
                }
                if (othertitles[@"english"]) {
                    for (NSString *etitle in othertitles[@"english"]) {
                        if ([title isEqualToString:etitle]) {
                            completionHandler(((NSNumber *)searchentry[@"id"]).intValue, [listservice getCurrentServiceID]);
                            return;
                        }
                    }
                }
                if (othertitles[@"japanese"]) {
                    for (NSString *jtitle in othertitles[@"japanese"]) {
                        if ([title isEqualToString:jtitle]) {
                            completionHandler(((NSNumber *)searchentry[@"id"]).intValue, [listservice getCurrentServiceID]);
                            return;
                        }
                    }
                }
                if (othertitles[@"synonyms"]) {
                    for (NSString *stitle in othertitles[@"synonyms"]) {
                        if ([title isEqualToString:stitle]) {
                            completionHandler(((NSNumber *)searchentry[@"id"]).intValue, [listservice getCurrentServiceID]);
                            return;
                        }
                    }
                }
            }
            errorHandler(nil);
        } error:^(NSError *error) {
            errorHandler(error);
        }];
    } error:^(NSError *error) {
        errorHandler(error);
    }];
}

+ (void)findMALIDWithCurrentServiceID:(int)serviceid type:(int)type completionHandler:(void (^)(int malid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    [listservice retrieveTitleInfo:serviceid withType:type useAccount:NO completion:^(id responseObject) {
        __block NSString *title = responseObject[@"title"];
        __block NSDictionary *othertitles = responseObject[@"other_titles"];
        [MyAnimeList searchTitle:title withType:type completion:^(id responseObject) {
            for (NSDictionary *searchentry in responseObject) {
                NSString *tmptitle = searchentry[@"title"];
                if (tmptitle.class != [NSString class]) {
                    continue;
                }
                if ([tmptitle isEqualToString:title]) {
                    completionHandler(((NSNumber *)searchentry[@"id"]).intValue);
                    return;
                }
                if (othertitles[@"english"]) {
                    for (NSString *etitle in othertitles[@"english"]) {
                        if ([title isEqualToString:etitle]) {
                            completionHandler(((NSNumber *)searchentry[@"id"]).intValue);
                            return;
                        }
                    }
                }
                if (othertitles[@"japanese"]) {
                    for (NSString *jtitle in othertitles[@"japanese"]) {
                        if ([title isEqualToString:jtitle]) {
                            completionHandler(((NSNumber *)searchentry[@"id"]).intValue);
                            return;
                        }
                    }
                }
                if (othertitles[@"synonyms"]) {
                    for (NSString *stitle in othertitles[@"synonyms"]) {
                        if ([title isEqualToString:stitle]) {
                            completionHandler(((NSNumber *)searchentry[@"id"]).intValue);
                            return;
                        }
                    }
                }
            }
            errorHandler(nil);
        } error:^(NSError *error) {
            errorHandler(error);
        }];
    } error:^(NSError *error) {
        errorHandler(error);
    }];
}

+ (void)retrieveMALIDwithTitle:(NSString *)searchterm withMediaType:(int)mediatype withType:(NSString *)type completionHandler:(void (^)(int malid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [Utility httpmanager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@",[Keychain getBase64]] forHTTPHeaderField:@"Authorization"];
    NSString *searchurl = [NSString stringWithFormat:@"https://myanimelist.net/api/%@/search.xml?q=%@", mediatype == MALAnime ? @"anime" : @"manga" , [Utility urlEncodeString:searchterm]];
    [manager GET:searchurl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSArray *searchdata = [self MALSearchXMLToAtarashiiDataFormat:[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] withType:mediatype];
        for (NSDictionary *d in searchdata) {
            if (![(NSString *)d[@"type"] isEqualToString:type]) {
                continue;
            }
            if ([(NSString *)d[@"title"] caseInsensitiveCompare:searchterm] == NSOrderedSame) {
                completionHandler(((NSNumber *)d[@"id"]).intValue);
                return;
            }
            for (NSString *title in d[@"synonyms"]) {
                if ([title caseInsensitiveCompare:searchterm] == NSOrderedSame) {
                    completionHandler(((NSNumber *)d[@"id"]).intValue);
                    return;
                }
            }
        }
        completionHandler(0);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        errorHandler(error);
    }];
}

+ (NSArray *)MALSearchXMLToAtarashiiDataFormat:(NSString *)xml withType:(int)type {
    NSError *error = nil;
    NSDictionary *d = [XMLReader dictionaryForXMLString:xml options:XMLReaderOptionsProcessNamespaces error:&error];
    NSArray *searchresults;
    if (d[@"anime"]||d[@"manga"]) {
        searchresults = type == MALAnime ? d[@"anime"][@"entry"] : d[@"manga"][@"entry"];
        if (![searchresults isKindOfClass:[NSArray class]]) {
            // Import only contains one object, put it in an array.
            searchresults = @[searchresults];
        }
    }
    else {
        return @[];
    }
    NSMutableArray *output = [NSMutableArray new];
    for (NSDictionary *d in searchresults) {
        NSMutableArray *synonyms = [NSMutableArray new];
        NSString *englishtitle = @"";
        if (d[@"english"][@"text"]) {
            [synonyms addObject:d[@"english"][@"text"]];
            englishtitle = d[@"english"][@"text"];
        }
        if (d[@"synonyms"][@"text"]) {
            [synonyms addObjectsFromArray:[((NSString *)d[@"synonyms"][@"text"]) componentsSeparatedByString:@";"]];
        }
        if (type == MALAnime) {
            [output addObject:@{@"id":@(((NSString *)d[@"id"][@"text"]).intValue), @"episodes":@(((NSString *)d[@"episodes"][@"text"]).intValue), @"score":@(((NSString *)d[@"score"][@"text"]).floatValue), @"status":d[@"status"][@"text"], @"start_date":[NSString stringWithFormat:@"%@",d[@"start_date"][@"text"]], @"end_date":[NSString stringWithFormat:@"%@",d[@"end_date"][@"text"]], @"synonyms": synonyms, @"synopsis":[NSString stringWithFormat:@"%@",d[@"synopsis"][@"text"]], @"type":d[@"type"][@"text"], @"title":d[@"title"][@"text"], @"english_title":englishtitle}];
        }
        else {
            [output addObject:@{@"id":@(((NSString *)d[@"id"][@"text"]).intValue), @"chapters":@(((NSString *)d[@"chapters"][@"text"]).intValue), @"volumes":@(((NSString *)d[@"volumes"][@"text"]).intValue), @"score":@(((NSString *)d[@"score"][@"text"]).floatValue), @"status":d[@"status"][@"text"], @"start_date":[NSString stringWithFormat:@"%@",d[@"start_date"][@"text"]], @"end_date":[NSString stringWithFormat:@"%@",d[@"end_date"][@"text"]], @"synonyms": synonyms, @"synopsis":[NSString stringWithFormat:@"%@",d[@"synopsis"][@"text"]], @"type":d[@"type"][@"text"], @"title":d[@"title"][@"text"], @"english_title":englishtitle}];
        }
    }
    return output;
}

+ (void)setImportStatus:(bool)isImporting {
    importing = isImporting;
    if (!isImporting) {
        lookingupid = false;
    }
}
+ (int)findTitle:(NSString *)title withType:(NSString *)titletype withResponseObject:(id)responseObject {
    for (NSDictionary *d in responseObject) {
        if ([titletype caseInsensitiveCompare:d[@"type"]] != NSOrderedSame && titletype && titletype.length > 0) {
            continue;
        }
        bool found = false;
        if (d[@"other_titles"][@"english"]) {
            for (NSString *ntitle in d[@"other_titles"][@"english"]) {
                if ([title caseInsensitiveCompare:ntitle] == NSOrderedSame) {
                    found = true;
                    break;
                }
            }
        }
        if (d[@"other_titles"][@"japanese"] && !found) {
            for (NSString *ntitle in d[@"other_titles"][@"japanese"]) {
                if ([title caseInsensitiveCompare:ntitle] == NSOrderedSame) {
                    found = true;
                    break;
                }
            }
        }
        if (d[@"other_titles"][@"synonyms"] && !found) {
            for (NSString *ntitle in d[@"other_titles"][@"synonyms"]) {
                if ([title caseInsensitiveCompare:ntitle] == NSOrderedSame) {
                    found = true;
                    break;
                }
            }
        }
        if ([title caseInsensitiveCompare:d[@"title"]] == NSOrderedSame) {
            found = true;
        }
        if (found) {
            lookingupid = false;
            return ((NSNumber *)d[@"id"]).intValue;
        }
    }
    return -1;
}
+ (void)KitsuFindAniId:(int)malid withTitle:(NSString *)title withTitleType:(NSString *)titletype withTitleid:(int)titleid withType:(int)type completionHandler:(void (^)(int anilistid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    [self getAniIDFromMALListID:malid withTitle:title titletype:titletype withType:type completionHandler:^(int anilistid) {
        [self savetitleidtomapping:titleid withNewID:anilistid withType:type fromService:2 toService:3];
        completionHandler(anilistid);
        lookingupid = false;
    } error:^(NSError *error) {
        errorHandler(error);
        lookingupid = false;
    }];
}
@end
