//
//  AniListImport.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/09/02.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "AniListImport.h"
#import "AtarashiiDataObjects.h"
#import "Utility.h"

@implementation AniListImport


+ (void)retrievelist:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // Retrieves list
    [self retrieveUserIDFromUsername:username completion:^(int userid){
        NSMutableArray *tmparray = [NSMutableArray new];
        [self retrievelist:userid withArray:tmparray page:0 completion:completionHandler error:errorHandler];
    } error:^(NSError *error) {
        errorHandler(error);
    }];
}

+ (void)retrievelist:(int)userid withArray:(NSMutableArray *)tmparray page:(int)page completion:(void (^)(id))completionHandler error:(void (^)(NSError *))errorHandler  {
    // Retrieve List
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    NSDictionary *parameters = @{@"query":@"query ($id : Int!, $listType: MediaType, $page: Int) {\n  AnimeList: Page (page: $page) {\n    mediaList(userId: $id, type: $listType) {\n      id :media{id}\n      entryid: id\n      title: media {title {\n        title: userPreferred\n      }}\n      episodes: media{episodes}\n      duration: media{duration}\n      image_url: media{coverImage {\n        large\n        medium\n      }}\n        type: media{format}\n      status: media{status}\n      score: score(format: POINT_100)\n      watched_episodes: progress\n      watched_status: status\n      rewatch_count: repeat\n      private\n      notes\n      watching_start: startedAt {\n        year\n        month\n        day\n      }\n      watching_end: completedAt {\n        year\n        month\n        day\n      }\n    }\n        pageInfo {\n      total\n      currentPage\n      lastPage\n      hasNextPage\n      perPage\n    }\n  }\n}", @"variables" : @{@"id":@(userid), @"listType" : @"ANIME", @"page" : @(page)}};
        [manager POST:@"https://graphql.anilist.co" parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [tmparray addObjectsFromArray:responseObject[@"data"][@"AnimeList"][@"mediaList"]];
            if (((NSNumber *)responseObject[@"data"][@"AnimeList"][@"pageInfo"][@"hasNextPage"]).boolValue) {
                int newpagenum = page+1;
                [self retrievelist:userid withArray:tmparray page:newpagenum completion:completionHandler error:errorHandler];
                return;
            }
            completionHandler([self AniListtoAtarashiiAnimeList:tmparray]);
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            errorHandler(error);
        }];
}

+ (id)AniListtoAtarashiiAnimeList:(id)data {
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *entry in data) {
        @autoreleasepool{
            AtarashiiAnimeListObject *aentry = [AtarashiiAnimeListObject new];
            aentry.titleid = ((NSNumber *)entry[@"id"][@"id"]).intValue;
            aentry.entryid = ((NSNumber *)entry[@"entryid"]).intValue;
            aentry.title = entry[@"title"][@"title"][@"title"];
            aentry.episodes = entry[@"episodes"][@"episodes"] != [NSNull null] ? ((NSNumber *)entry[@"episodes"][@"episodes"]).intValue : 0;
            aentry.episode_length = ((NSNumber *)entry[@"duration"][@"duration"]).intValue;
            aentry.image_url = (entry[@"image_url"][@"coverImage"][@"large"] && entry[@"image_url"][@"coverImage"][@"large"] != [NSNull null] ) ? entry[@"image_url"][@"coverImage"][@"large"] : @"";
            aentry.type = entry[@"type"][@"format"];
            aentry.status = entry[@"status"][@"status"];
            if ([aentry.status isEqualToString:@"FINISHED"]||[aentry.status isEqualToString:@"CANCELLED"]) {
                aentry.status = @"finished airing";
            }
            else if ([aentry.status isEqualToString:@"RELEASING"]) {
                aentry.status = @"currently airing";
            }
            else if ([aentry.status isEqualToString:@"NOT_YET_RELEASED"]) {
                aentry.status = @"not yet aired";
            }
            aentry.score = ((NSNumber *)entry[@"score"]).intValue;
            aentry.watched_episodes = ((NSNumber *)entry[@"watched_episodes"]).intValue;
            if ([(NSString *)entry[@"watched_status"] isEqualToString:@"PAUSED"]) {
                aentry.watched_status = @"on-hold";
            }
            else if ([(NSString *)entry[@"watched_status"] isEqualToString:@"PLANNING"]) {
                aentry.watched_status = @"plan to watch";
            }
            else if ([(NSString *)entry[@"watched_status"] isEqualToString:@"CURRENT"]) {
                aentry.watched_status = @"watching";
            }
            else if ([(NSString *)entry[@"watched_status"] isEqualToString:@"REPEATING"]) {
                aentry.watched_status = @"watching";
                aentry.rewatching = true;
            }
            else {
                aentry.watched_status = ((NSString *)entry[@"watched_status"]).lowercaseString;
            }
            aentry.rewatch_count =  ((NSNumber *)entry[@"rewatch_count"]).intValue;
            aentry.private_entry =  ((NSNumber *)entry[@"private"]).boolValue;
            aentry.personal_comments = entry[@"notes"];
            aentry.watching_start = entry[@"watching_start"][@"year"] != [NSNull null] && entry[@"watching_start"][@"year"] != [NSNull null] && entry[@"watching_start"][@"year"] != [NSNull null] ? [NSString stringWithFormat:@"%@-%@-%@",entry[@"watching_start"][@"year"],entry[@"watching_start"][@"month"],entry[@"watching_start"][@"day"]] : @"";
            aentry.watching_end = entry[@"watching_end"][@"year"] != [NSNull null] && entry[@"watching_end"][@"year"] != [NSNull null] && entry[@"watching_end"][@"year"] != [NSNull null] ? [NSString stringWithFormat:@"%@-%@-%@",entry[@"watching_end"][@"year"],entry[@"watching_end"][@"month"],entry[@"watching_end"][@"day"]] : @"";
            [tmparray addObject:[aentry NSDictionaryRepresentation]];
        }
    }
    return @{@"anime" : tmparray};
}

+ (void)retrieveUserIDFromUsername:(NSString *)username completion:(void (^)(int userid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    NSDictionary *parameters = @{@"query" : @"query ($name: String) {\n  User (name: $name) {\n    id\n    name\n }\n}", @"variables" : @{@"name" : username}};
    [manager POST:@"https://graphql.anilist.co" parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSDictionary * d = responseObject[@"data"][@"User"];
        if (d[@"id"] != [NSNull null]){
            completionHandler(((NSNumber *)d[@"id"]).intValue);
        }
        else {
            errorHandler(nil);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error retrieving user information: %@", error);
        errorHandler(error);
    }];
}
@end
