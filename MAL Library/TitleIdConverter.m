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

@implementation TitleIdConverter
+ (void)getKitsuIDFromMALId:(int)malid withType:(int)type completionHandler:(void (^)(int kitsuid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // Check to see if title exists in the title id mappings. If so, just use the id from the mapping.
    int tmpid = [self lookupTitleID:malid withType:type fromService:1 toService:2];
    if (tmpid > 0) {
        completionHandler(tmpid);
        return;
    }
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
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                errorHandler(error);
            }];
        }
        else {
            [self findCurrentServiceTitleIDWithMALID:malid type:type completionHandler:^(int currentserviceid, int currentservice) {
                if (currentservice == 2) {
                    [self savetitleidtomapping:malid withNewID:currentserviceid withType:type fromService:1 toService:2];
                    completionHandler(currentserviceid);
                }
                else {
                    errorHandler(nil);
                }
            } error:^(NSError *error) {
                errorHandler(error);
            }];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}
+ (void)getMALIDFromKitsuId:(int)kitsuid withType:(int)type completionHandler:(void (^)(int malid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    int tmpid = [self lookupTitleID:kitsuid withType:type fromService:2 toService:1];
    if (tmpid > 0) {
        completionHandler(tmpid);
        return;
    }
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
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/mappings/%i?filter[externalSite]=myanimelist/%@",kitsuid,typestr] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"data"] != [NSNull null]) {
            if (responseObject[@"data"][@"id"]) {
                NSNumber *malid = responseObject[@"data"][@"id"];
                [self savetitleidtomapping:kitsuid withNewID:malid.intValue withType:type fromService:2 toService:1];
                completionHandler(malid.intValue);
            }
            else {
                errorHandler(nil);
            }
        }
        else {
            [self findMALIDWithCurrentServiceID:kitsuid type:type completionHandler:^(int malid) {
                    [self savetitleidtomapping:kitsuid withNewID:malid withType:type fromService:2 toService:1];
                    completionHandler(malid);
            } error:^(NSError *error) {
                errorHandler(error);
            }];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
    
}

#pragma mark Helpers
+ (int)lookupTitleID:(int)titleid withType:(int)type fromService:(int)fromservice toService:(int)toservice {
    NSManagedObject *mapping = [self retrieveexistingmapping:titleid withType:type fromService:fromservice];
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
    }
    return -1;
}

+ (NSManagedObject *)retrieveexistingmapping:(int)titleid withType:(int)type fromService:(int)fromservice {
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
    switch (fromservice) {
        case 1:
            predicate = [NSPredicate predicateWithFormat:@"mal_id == %li AND type == %@", titleid, typestr];
            break;
        case 2:
            predicate = [NSPredicate predicateWithFormat:@"kitsu_id == %li AND type == %@", titleid, typestr];
            break;
        case 3:
            predicate = [NSPredicate predicateWithFormat:@"anilist_id == %li  AND type == %@", titleid, typestr];
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
    NSManagedObject *mapping = [self retrieveexistingmapping:oldid withType:type fromService:fromService];
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
                    [mapping setValue:@(newid) forKey:@"anlist_id"];
                }
                break;
            }
            default:
                break;
        }
        [moc save:nil];
    }
    else {
        // Create new mapping
        [self createandsavetitleidtomapping:oldid withNewID:newid withType:type fromService:fromService toService:toService];
    }
}

+ (void)createandsavetitleidtomapping:(int)oldid withNewID:(int)newid withType:(int)type fromService:(int)fromService toService:(int)toService {
    if (fromService < 1 || fromService > 3 || toService < 1 || toService > 3 ) {
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
}
+ (void)findCurrentServiceTitleIDWithMALID:(int)malid type:(int)type completionHandler:(void (^)(int currentserviceid, int currentservice)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    [MyAnimeList retrieveTitleInfo:malid withType:type useAccount:NO completion:^(id responseObject) {
        __block NSString *title = responseObject[@"title"];
        __block NSDictionary *othertitles = responseObject[@"other_titles"];
        [listservice searchTitle:title withType:type completion:^(id responseObject) {
            for (NSDictionary *searchentry in responseObject) {
                NSString *tmptitle = searchentry[@"title"];
                if ([tmptitle isEqualToString:title]) {
                    completionHandler(((NSNumber *)searchentry[@"id"]).intValue, [listservice getCurrentServiceID]);
                    return;
                }
                else if (othertitles[@"english"]) {
                    if ([tmptitle isEqualToString:othertitles[@"english"]]) {
                        completionHandler(((NSNumber *)searchentry[@"id"]).intValue, [listservice getCurrentServiceID]);
                        return;
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
                if ([tmptitle isEqualToString:title]) {
                    completionHandler(((NSNumber *)searchentry[@"id"]).intValue);
                    return;
                }
                else if (othertitles[@"english"]) {
                    if ([tmptitle isEqualToString:othertitles[@"english"]]) {
                        completionHandler(((NSNumber *)searchentry[@"id"]).intValue);
                        return;
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
@end
