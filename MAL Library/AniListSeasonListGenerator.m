//
//  AniListSeasonListGenerator.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/07/12.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import "AtarashiiAPIListFormatAniList.h"
#import "AniListSeasonListGenerator.h"
#import "AniListConstants.h"
#import "Utility.h"

@interface AniListSeasonListGenerator ()

@end

@implementation AniListSeasonListGenerator
+ (void)retrieveSeasonDataWithSeason:(NSString *)season withYear:(int)year completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    NSMutableArray *tmplist = [NSMutableArray new];
    [self retrieveSeasonDataWithSeason:season withYear:year withPage:1 withArray:tmplist completion:completionHandler error:errorHandler];
}

+ (void)retrieveSeasonDataWithSeason:(NSString *)season withYear:(int)year withPage:(int)page withArray:(NSMutableArray *)array completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler{
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    NSDictionary *parameters = @{@"query" : kAniListSeason, @"variables" : @{@"season" : season.uppercaseString, @"seasonYear" : @(year), @"page" : @(page)}};
    [manager POST:@"https://graphql.anilist.co" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"data"] != [NSNull null]) {
            NSDictionary *dpage = responseObject[@"data"][@"Page"];
            [array addObjectsFromArray:dpage[@"media"]];
            if (((NSNumber *)dpage[@"pageInfo"][@"hasNextPage"]).boolValue) {
                int newpage = page + 1;
                [self retrieveSeasonDataWithSeason:season withYear:year withPage:newpage withArray:array completion:completionHandler error:errorHandler];
            }
            else {
                completionHandler([AtarashiiAPIListFormatAniList normalizeSeasonData:array]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}

@end
