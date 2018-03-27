//
//  AniListImport.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/09/02.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "AniListImport.h"
#import "AtarashiiDataObjects.h"
#import "AtarashiiAPIListFormatAniList.h"
#import "ClientConstants.h"
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
            completionHandler([AtarashiiAPIListFormatAniList AniListtoAtarashiiAnimeList:tmparray]);
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            errorHandler(error);
        }];
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
