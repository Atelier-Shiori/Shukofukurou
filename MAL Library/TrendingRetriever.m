//
//  TrendingRetriever.m
//  Shukofukurou-IOS
//
//  Created by 香風智乃 on 11/6/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import "TrendingRetriever.h"
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import <Hakuchou/Hakuchou.h>
#import "Utility.h"
#import "listservice.h"

@implementation TrendingRetriever
+ (NSManagedObjectContext *)managedObjectContext {
    return ((AppDelegate *)NSApplication.sharedApplication.delegate).managedObjectContext;
}

+ (void)getTrendListForService:(int)service withType:(int)type shouldRefresh:(bool)shouldRefresh completion:(void (^)(id responseobject))completionHandler error:(void (^)(NSError *error))errorHandler {
    bool shouldretrieve = true;
    if ([self retrieveTrendingObjectForService:service forType:type]) {
        if (![self checkifTrendListNeedsRefresh:service forType:type]) {
            shouldretrieve = false;
            completionHandler([self retrieveTrendingListForService:service forType:type]);
        }
    }
    if (shouldretrieve || shouldRefresh) {
        [self retrieveTrendList:service withType:type completion:^(id responseobject) {
            [self saveTrendingListToCoreData:responseobject forService:service forType:type];
            completionHandler([self retrieveTrendingListForService:service forType:type]);
        } error:errorHandler];
    }
}

+ (void)retrieveTrendList:(int)service withType:(int)type completion:(void (^)(id responseobject))completionHandler error:(void (^)(NSError *error))errorHandler {
    switch (service) {
        case 1:
            [self retrieveMALTrending:type completion:completionHandler error:errorHandler];
            break;
        case 2:
            [self retrieveKitsuTrending:type completion:completionHandler error:errorHandler];
            break;
        case 3:
            [self retrieveAniListTrending:type completion:completionHandler error:errorHandler];
            break;
    }
}

+ (void)retrieveMALTrending:(int)type completion:(void (^)(id responseobject))completionHandler error:(void (^)(NSError *error))errorHandler {
    __block NSMutableDictionary *finaldict = [NSMutableDictionary new];
    __block AFHTTPSessionManager *manager = [Utility jsonmanager];
    AFOAuthCredential *cred = [listservice.sharedInstance.myanimelistManager getFirstAccount];
    if (cred && cred.expired) {
        [listservice.sharedInstance.myanimelistManager refreshToken:^(bool success) {
            if (success) {
                [self retrieveMALTrending:type completion:completionHandler error:errorHandler];
            }
            else {
                errorHandler(nil);
            }
        }];
        return;
    }
    if (cred) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    }
    else {
        errorHandler(nil);
    }
    if (type == 0) {
        [manager GET:@"https://api.myanimelist.net/v2/anime/ranking?ranking_type=airing&limit=20&fields=alternative_titles,num_episodes,media_type,status,mean,nsfw" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            finaldict[@"Popular This Season"] = [AtarashiiAPIListFormatMAL MALAnimeSearchtoAtarashii:responseObject];
            [manager GET:@"https://api.myanimelist.net/v2/anime/ranking?ranking_type=all&limit=20&fields=alternative_titles,num_episodes,media_type,status,mean,nsfw" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                finaldict[@"Highest Rated"] = [AtarashiiAPIListFormatMAL MALAnimeSearchtoAtarashii:responseObject];
                completionHandler(finaldict);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                errorHandler(error);
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            errorHandler(error);
        }];
    }
    else {
        [manager GET:@"https://api.myanimelist.net/v2/manga/ranking?ranking_type=all&limit=20&fields=alternative_titles,num_chapters,num_volumes,media_type,status,mean,nsfw" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            finaldict[@"Highest Rated"] = [AtarashiiAPIListFormatMAL MALMangaSearchtoAtarashii:responseObject];
            completionHandler(finaldict);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            errorHandler(error);
        }];
    }
}

+ (void)retrieveAniListTrending:(int)type completion:(void (^)(id responseobject))completionHandler error:(void (^)(NSError *error))errorHandler {
    NSMutableDictionary *finaldict = [NSMutableDictionary new];
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    __block NSDictionary *variables = @{@"type" : type == 0 ? @"ANIME" : @"MANGA"};
    __block NSDictionary *parameters = @{@"query" : [self getAnilistQueryForSort:TrendListTypeScore], @"variables" : variables};
    [manager POST:@"https://graphql.anilist.co" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"data"] != [NSNull null]) {
            finaldict[@"Highest Rated"] = type == 0 ? [AtarashiiAPIListFormatAniList AniListAnimeSearchtoAtarashii:responseObject] : [AtarashiiAPIListFormatAniList AniListMangaSearchtoAtarashii:responseObject];
            parameters = @{@"query" : [self getAnilistQueryForSort:TrendListTypeNew], @"variables" : variables};
            [manager POST:@"https://graphql.anilist.co" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (responseObject[@"data"] != [NSNull null]) {
                    finaldict[@"Newly Added"] = type == 0 ? [AtarashiiAPIListFormatAniList AniListAnimeSearchtoAtarashii:responseObject] : [AtarashiiAPIListFormatAniList AniListMangaSearchtoAtarashii:responseObject];
                    parameters = @{@"query" : [self getAnilistQueryForSort:TrendListTypeTrending], @"variables" : variables};
                    [manager POST:@"https://graphql.anilist.co" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        if (responseObject[@"data"] != [NSNull null]) {
                            finaldict[@"Trending"] = type == 0 ? [AtarashiiAPIListFormatAniList AniListAnimeSearchtoAtarashii:responseObject] : [AtarashiiAPIListFormatAniList AniListMangaSearchtoAtarashii:responseObject];
                            if (type == 0) {
                                parameters = @{@"query" : [self getAnilistQueryForSort:TrendListTypeSeasonPopular], @"variables" : variables};
                                [manager POST:@"https://graphql.anilist.co" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                    if (responseObject[@"data"] != [NSNull null]) {
                                        finaldict[@"Popular This Season"] = [AtarashiiAPIListFormatAniList AniListAnimeSearchtoAtarashii:responseObject];
                                        completionHandler(finaldict);
                                    }
                                    else {
                                        errorHandler(nil);
                                    }
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    errorHandler(error);
                                }];
                            }
                            else {
                                completionHandler(finaldict);
                            }
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
        else {
            errorHandler(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}

+ (void)retrieveKitsuTrending:(int)type completion:(void (^)(id responseobject))completionHandler error:(void (^)(NSError *error))errorHandler {
    NSMutableDictionary *finaldict = [NSMutableDictionary new];
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager GET:[self getKitsuTrendingURLs:TrendListTypeScore withType:type] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"data"] && responseObject[@"data"] != [NSNull null]) {
            finaldict[@"Highest Rated"] = type == 0 ? [AtarashiiAPIListFormatKitsu KitsuAnimeSearchtoAtarashii:responseObject] : [AtarashiiAPIListFormatKitsu KitsuMangaSearchtoAtarashii:responseObject];
            [manager GET:[self getKitsuTrendingURLs:TrendListTypeNew withType:type] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (responseObject[@"data"] && responseObject[@"data"] != [NSNull null]) {
                    finaldict[@"Newly Added"] = type == 0 ? [AtarashiiAPIListFormatKitsu KitsuAnimeSearchtoAtarashii:responseObject] : [AtarashiiAPIListFormatKitsu KitsuMangaSearchtoAtarashii:responseObject];
                    [manager GET:[self getKitsuTrendingURLs:TrendListTypeTrending withType:type] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        if (responseObject[@"data"] && responseObject[@"data"] != [NSNull null]) {
                            finaldict[@"Trending"] = type == 0 ? [AtarashiiAPIListFormatKitsu KitsuAnimeSearchtoAtarashii:responseObject] : [AtarashiiAPIListFormatKitsu KitsuMangaSearchtoAtarashii:responseObject];
                            if (type == 0) {
                                [manager GET:[self getKitsuTrendingURLs:TrendListTypeSeasonPopular withType:type] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                    if (responseObject[@"data"] && responseObject[@"data"] != [NSNull null]) {
                                        finaldict[@"Popular This Season"] =  [AtarashiiAPIListFormatKitsu KitsuAnimeSearchtoAtarashii:responseObject];
                                        completionHandler(finaldict);
                                    }
                                    else {
                                        errorHandler(nil);
                                    }
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    errorHandler(error);
                                }];
                            }
                            else {
                                completionHandler(finaldict);
                            }
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
        else {
            errorHandler(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}

#pragma mark Core Data
+ (void)saveTrendingListToCoreData:(NSDictionary *)responseData forService:(int)service forType:(int)type {
    NSManagedObject *trendobj = [self retrieveTrendingObjectForService:service forType:type];
    if (!trendobj) {
        trendobj = [NSEntityDescription insertNewObjectForEntityForName:@"Trending" inManagedObjectContext:[self managedObjectContext]];
        [trendobj setValue:@(service) forKey:@"service"];
        [trendobj setValue:@(type) forKey:@"type"];
    }
    [trendobj setValue:[self serializeDictionarytoJSON:responseData] forKey:@"jsonData"];
    [trendobj setValue:[NSDate date] forKey:@"lastUpdated"];
    [[self managedObjectContext] save:nil];
}

+ (NSDictionary *)retrieveTrendingListForService:(int)service forType:(int)type {
    NSManagedObject *trendobj = [self retrieveTrendingObjectForService:service forType:type];
    if (trendobj) {
        NSError *error;
        NSDictionary *jsondata = [NSJSONSerialization JSONObjectWithData:[(NSString *)[trendobj valueForKey:@"jsonData"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (jsondata) {
            return jsondata;
        }
    }
    return nil;
}

+ (NSManagedObject *)retrieveTrendingObjectForService:(int)service forType:(int)type {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Trending" inManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"service == %i AND type == %i", service, type];
    fetchRequest.predicate = predicate;
    NSError *error = nil;
    NSArray *trendingentries = [moc executeFetchRequest:fetchRequest error:&error];
    if (trendingentries.count > 0) {
        return trendingentries[0];
    }
    return nil;
}

+ (bool)checkifTrendListNeedsRefresh:(int)service forType:(int)type {
    NSManagedObject *trendobj = [self retrieveTrendingObjectForService:service forType:type];
    if (trendobj) {
        return ((NSDate *)[trendobj valueForKey:@"lastUpdated"]).timeIntervalSinceNow < -43200;
    }
    return true;
}

#pragma mark helpers
+ (NSString *)getKitsuTrendingURLs:(TrendListType)sort withType:(int)type {
    NSString *typestr = @"";
    switch (type) {
        case 0:
            typestr = @"anime";
            break;
        case 1:
            typestr = @"manga";
            break;
        default:
            break;
    }
    switch (sort) {
        case TrendListTypeScore:
            return [NSString stringWithFormat:@"https://kitsu.io/api/edge/%@?page[limit]=10&sort=-averageRating", typestr];
        case TrendListTypeNew:
            return [NSString stringWithFormat:@"https://kitsu.io/api/edge/%@?page[limit]=10&sort=-createdAt", typestr];
        case TrendListTypeTrending:
            return [NSString stringWithFormat:@"https://kitsu.io/api/edge/trending/%@", typestr];
        case TrendListTypeSeasonPopular:
            return [NSString stringWithFormat:@"https://kitsu.io/api/edge/%@?page[limit]=10&sort=popularityRank&filter[status]=current",typestr];
        default:
            break;
    }
}

+ (NSString *)getAnilistQueryForSort:(TrendListType)sort {
    NSString *sortstr = @"";
    switch (sort) {
        case TrendListTypeScore:
            sortstr = @"SCORE_DESC";
            break;
        case TrendListTypeNew:
            sortstr = @"ID_DESC";
            break;
        case TrendListTypeTrending:
            sortstr = @"TRENDING_DESC";
            break;
        case TrendListTypeSeasonPopular:
            return @"query ($type: MediaType) {\n  Page(perPage: 10) {\n    media(type: $type, sort: POPULARITY_DESC, status: RELEASING) {\n      id\n      idMal\n      isAdult\n      coverImage {\n        large\n        medium\n      }\n      title {\n        romaji\n        english\n        native\n        userPreferred\n      }\n      episodes\n      chapters\n      volumes\n      format\n      averageScore\n      status\n    }\n  }\n}";
    }
    return [NSString stringWithFormat:@"query ($type: MediaType) {\n  Page(perPage: 10) {\n    media(type: $type, sort: %@) {\n      id\n      title {\n        userPreferred\n        english\n        romaji\n      }\n      synonyms\n      coverImage {\n        medium\n        large\n      }\n      format\n      type\n      status\n      episodes\n      chapters\n      volumes\n      isAdult\n    }\n  }\n}", sortstr];
}

+ (NSString *)serializeDictionarytoJSON:(id)responseObject {
    if (@available(macOS 10.13, *)) {
        return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingSortedKeys error:nil] encoding:NSUTF8StringEncoding];
    } else {
        // Fallback on earlier versions
        return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil] encoding:NSUTF8StringEncoding];
    }
}

@end
