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
#import "ListService.h"

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
    NSString *mappingsname = [self getMappingFileName:fromservice withToService:toservice];
    if (mappingsname.length == 0) {
        return -1;
    }
    if ([Utility checkifFileExists:mappingsname appendPath:@""]) {
        NSArray * mappings = [Utility loadJSON:mappingsname appendpath:@""];
        NSArray * fmappings;
        switch (fromservice) {
            case 1:
                fmappings = [mappings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"mal_id == %li", titleid]];
                break;
            case 2:
                fmappings = [mappings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"kitsu_id == %li OR kitsu_id == %@", titleid, @(titleid).stringValue]];
                break;
            case 3:
                fmappings = [mappings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"anilist_id == %li OR anilist_id == %@", titleid, @(titleid).stringValue]];
                break;
            default:
                break;
        }
        if (fmappings.count > 0) {
            NSString *mappingtype = fmappings[0][@"type"] ? fmappings[0][@"type"] : @"anime";
            if (([mappingtype isEqualToString:@"anime"] && type == 0) || ([mappingtype isEqualToString:@"manga"] && type == 1)) {
                switch (toservice) {
                    case 1:
                        return ((NSNumber *)fmappings[0][@"mal_id"]).intValue;
                    case 2:
                        return ((NSNumber *)fmappings[0][@"kitsu_id"]).intValue;
                    case 3:
                        return ((NSNumber *)fmappings[0][@"anilist_id"]).intValue;
                }
            }
        }
    }
    return -1;
}
+ (void)savetitleidtomapping:(int)oldid withNewID:(int)newid withType:(int)type fromService:(int)fromService toService:(int)toService {
    NSString *mappingsname = [self getMappingFileName:fromService withToService:toService];
    if (mappingsname.length == 0) {
        return;
    }
    NSMutableArray *tmparray = [NSMutableArray new];
    if ([Utility checkifFileExists:mappingsname appendPath:@""]) {
        [tmparray addObjectsFromArray: [Utility loadJSON:mappingsname appendpath:@""]];
    }
    NSString *strtype = type == 0 ? @"anime" : @"manga";
    switch (fromService) {
        case 1: {
            switch (toService) {
                case 2:
                    [tmparray addObject:@{@"mal_id" : @(oldid), @"kitsu_id" : @(newid), @"type" : strtype}];
                    break;
                case 3:
                    [tmparray addObject:@{@"mal_id" : @(oldid), @"anilist_id" : @(newid), @"type" : strtype}];
                    break;
                default:
                    break;
            }
            break;
        }
        case 2: {
            switch (toService) {
                case 1:
                    [tmparray addObject:@{@"mal_id" : @(newid), @"kitsu_id" : @(oldid), @"type" : strtype}];
                    break;
                case 3:
                    [tmparray addObject:@{@"anilist_id" : @(newid), @"kitsu_id" : @(oldid), @"type" : strtype}];
                    break;
                default:
                    break;
            }
            break;
        }
        case 3: {
            switch (toService) {
                case 1:
                    [tmparray addObject:@{@"mal_id" : @(newid), @"anilist_id" : @(oldid), @"type" : strtype}];
                case 2:
                    [tmparray addObject:@{@"anilist_id" : @(oldid), @"kitsu_id" : @(newid), @"type" : strtype}];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    [Utility saveJSON:tmparray withFilename:mappingsname appendpath:@"" replace:YES];
}
+ (NSString *)getMappingFileName:(int)fromService withToService:(int)toService {
    switch (fromService) {
        case 1: {
            switch (toService) {
                case 2:
                    return @"KitsuMALMappings.json";
                    break;
                case 3:
                    return @"AniListMALMappings.json";
                    break;
                default:
                    return @"";
            }
            break;
        }
        case 2: {
            switch (toService) {
                case 1:
                    return @"KitsuMALMappings.json";
                case 3:
                    return @"AniListKitsuMappings.json";
                    break;
                default:
                    return @"";
            }
            break;
        }
        case 3: {
            switch (toService) {
                case 1:
                    return @"AniListMALMappings.json";
                case 2:
                    return @"AniListKitsuMappings.json";
                    break;
                default:
                    return @"";
            }
            break;
        }
        default:
            return @"";
    }
    return @"";
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
