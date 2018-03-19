//
//  AniListImport.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/09/02.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "AniListImport.h"
#import "ClientConstants.h"
#import "Utility.h"

@implementation AniListImport
    
+ (void)retrievelist:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // Retrieves list
    [self retrievetoken:^(bool success) {
        if (success) {
            [self retrieveUserIDFromUsername:username completion:^(int userid){
                // Retrieve List
                AFHTTPSessionManager *manager = [Utility jsonmanager];
                
                [manager GET:[NSString stringWithFormat:@"https://anilist.co/api/user/%i/animelist/", userid] parameters:@{@"access_token":[self getFirstAccessToken].accessToken} progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                    completionHandler([self processAnimeList:responseObject]);
                    
                } failure:^(NSURLSessionTask *operation, NSError *error) {
                    errorHandler(error);
                }];
            } error:^(NSError *error) {
                errorHandler(error);
            }];
        }
        else {
            errorHandler(nil);
        }
    }];
}
    
+ (id)processAnimeList:(id)data {
    // Converts Anime List to a more usable format for a flat JSON file
    NSDictionary *d = data;
    NSDictionary *lists = d[@"lists"];
    NSMutableDictionary *final = [NSMutableDictionary new];
    NSMutableDictionary *statuscount = [NSMutableDictionary new];
    NSMutableArray * fulllist = [NSMutableArray new];
    for (int i=0; i<5; i++) {
        NSArray * list;
        switch (i) {
            case 0:
            list = lists[@"watching"];
            statuscount[@"watching"] = @([list count]);
            break;
            case 1:
            list = lists[@"on_hold"];
            statuscount[@"on_hold"] = @([list count]);
            break;
            case 2:
            list = lists[@"completed"];
            statuscount[@"completed"] = @([list count]);
            break;
            case 3:
            list = lists[@"plan_to_watch"];
            statuscount[@"plan_to_watch"] = @([list count]);
            break;
            case 4:
            list = lists[@"dropped"];
            statuscount[@"dropped"] = @([list count]);
            break;
            default:
                break;
        }
        [fulllist addObjectsFromArray:[self processAnimeListEntries:list]];
    }
    final[@"list"] = fulllist;
    final[@"status_count"] = statuscount;
    return final;
}
+ (NSArray *)processAnimeListEntries:(NSArray *)list {
    NSMutableArray *tmplist = [NSMutableArray new];
    @autoreleasepool {
        for (NSDictionary *item in list){
            NSDictionary *details = item[@"anime"];
            NSMutableDictionary *newitem = [NSMutableDictionary new];
            newitem[@"id"] = item[@"series_id"];
            newitem[@"record_id"] = item[@"record_id"];
            newitem[@"rewatched"] = item[@"rewatched"];
            newitem[@"score"] = item[@"score"];
            newitem[@"score_raw"] = item[@"score_raw"];
            newitem[@"priority"] = item[@"priority"];
            newitem[@"hidden_default"] = item[@"hidden_default"];
            newitem[@"added_time"] = item[@"added_time"];
            newitem[@"watched_episodes"] = item[@"episodes_watched"];
            newitem[@"started_on"] = item[@"started_on"];
            newitem[@"watched_status"] = item[@"list_status"];
            newitem[@"title_romaji"] = details[@"title_romaji"];
            newitem[@"title_english"] = details[@"title_english"];
            newitem[@"type"] = details[@"type"];
            newitem[@"episodes"] = details[@"total_episodes"];
            newitem[@"status"] = details[@"airing_status"];
            if (details[@"advanced_rating_scores"]){
                newitem[@"advanced_rating_scores"] = details[@"advanced_rating_scores"];
            }
            else{
                newitem[@"advanced_rating_scores"] = [NSArray new];
            }
            if (!details[@"notes"]){
                newitem[@"notes"] = [NSNull null];
            }
            else{
                newitem[@"notes"] = details[@"notes"];
            }
            newitem[@"custom_lists"] = item[@"custom_lists"];
            [tmplist addObject:[newitem copy]];
        }
    }
    return tmplist;
}
    
+ (AFOAuthCredential *)getFirstAccessToken{
    return [AFOAuthCredential retrieveCredentialWithIdentifier:@"MAL Library - AniList Access Token"];
}
    
+ (void)retrievetoken:(void (^)(bool success)) completionHandler {
    AFOAuthCredential *cred = [self getFirstAccessToken];
    if (!cred||cred.expired) {
        if (cred.expired) {
            [AFOAuthCredential deleteCredentialWithIdentifier:@"MAL Library - AniList Access Token"];
        }
        NSURL *baseURL = [NSURL URLWithString:@"https://anilist.co/api/"];
        AFOAuth2Manager *OAuth2Manager =
        [[AFOAuth2Manager alloc] initWithBaseURL:baseURL
                                        clientID:kanilistclient
                                          secret:kanilistsecretkey];
        [OAuth2Manager authenticateUsingOAuthWithURLString:@"auth/access_token" parameters:@{@"grant_type":@"client_credentials"} success:^(AFOAuthCredential *credential) {
            [AFOAuthCredential storeCredential:credential
                                withIdentifier:@"MAL Library - AniList Access Token"];
            completionHandler(true);
        }
        failure:^(NSError *error) {
                NSLog(@"Error: %@", error);
            completionHandler(false);
        }];
    }
    else {
        completionHandler(true);
    }
    
    
}
+ (void)retrieveUserIDFromUsername:(NSString *)username completion:(void (^)(int userid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    NSLog(@"%@",[self getFirstAccessToken].accessToken);
    [manager GET:[NSString stringWithFormat:@"https://anilist.co/api/user/%@", username] parameters:@{@"access_token":[self getFirstAccessToken].accessToken} progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSDictionary * d = responseObject;
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
