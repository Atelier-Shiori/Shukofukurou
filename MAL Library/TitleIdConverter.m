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
#import "Kitsu.h"

@implementation TitleIdConverter
+ (void)getKitsuIDFromMALId:(int)malid  withType:(int)type completionHandler:(void (^)(int kitsuid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
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
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/mappings?filter[external_site]=myanimelist/%@&filter[external_id]=%i",typestr, malid] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
            errorHandler(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}
+ (int)lookupTitleID:(int)malid withType:(int)type fromService:(int)fromservice toService:(int)toservice {
    NSString *mappingsname = [self getMappingFileName:fromservice withToService:toservice];
    if (mappingsname.length == 0) {
        return -1;
    }
    if ([Utility checkifFileExists:mappingsname appendPath:@""]) {
        NSArray * mappings = [Utility loadJSON:mappingsname appendpath:@""];
        switch (fromservice) {
            case 1:
                mappings = [mappings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"mal_id == %i", malid]];
                break;
            case 2:
                mappings = [mappings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"kitsu_id == %i", malid]];
                break;
            case 3:
                mappings = [mappings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"mal_id == %i", malid]];
                break;
            default:
                break;
        }
        if (mappings.count > 0) {
            NSString *mappingtype = mappings[0][@"type"] ? mappings[0][@"type"] : @"anime";
            if (([mappingtype isEqualToString:@"anime"] && type == 0) || ([mappingtype isEqualToString:@"manga"] && type == 1)) {
                switch (toservice) {
                    case 1:
                        return ((NSNumber *)mappings[0][@"mal_id"]).intValue;
                    case 2:
                        return ((NSNumber *)mappings[0][@"kitsu_id"]).intValue;
                    case 3:
                        return ((NSNumber *)mappings[0][@"anilist_id"]).intValue;
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
@end
