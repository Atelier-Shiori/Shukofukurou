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
            [statuscount setObject:[NSNumber numberWithLong:[list count]] forKey:@"watching"];
            break;
            case 1:
            list = lists[@"on_hold"];
            [statuscount setObject:[NSNumber numberWithLong:[list count]] forKey:@"on_hold"];
            break;
            case 2:
            list = lists[@"completed"];
            [statuscount setObject:[NSNumber numberWithLong:[list count]] forKey:@"completed"];
            break;
            case 3:
            list = lists[@"plan_to_watch"];
            [statuscount setObject:[NSNumber numberWithLong:[list count]] forKey:@"plan_to_watch"];
            break;
            case 4:
            list = lists[@"dropped"];
            [statuscount setObject:[NSNumber numberWithLong:[list count]] forKey:@"dropped"];
            break;
        }
        [fulllist addObjectsFromArray:[self processAnimeListEntries:list]];
    }
    [final setObject:fulllist forKey:@"list"];
    [final setObject:statuscount forKey:@"status_count"];
    return final;
}
+ (NSArray *)processAnimeListEntries:(NSArray *)list {
    NSMutableArray *tmplist = [NSMutableArray new];
    for (NSDictionary *item in list){
        NSDictionary *details = item[@"anime"];
        NSMutableDictionary *newitem = [NSMutableDictionary new];
        [newitem setObject:item[@"series_id"] forKey:@"id"];
        [newitem setObject:item[@"record_id"] forKey:@"record_id"];
        [newitem setObject:item[@"rewatched"] forKey:@"rewatched"];
        [newitem setObject:item[@"score"] forKey:@"score"];
        [newitem setObject:item[@"score_raw"] forKey:@"score_raw"];
        [newitem setObject:item[@"priority"] forKey:@"priority"];
        [newitem setObject:item[@"hidden_default"] forKey:@"hidden_default"];
        [newitem setObject:item[@"added_time"] forKey:@"added_time"];
        [newitem setObject:item[@"episodes_watched"] forKey:@"watched_episodes"];
        [newitem setObject:item[@"started_on"] forKey:@"started_on"];
        [newitem setObject:item[@"list_status"] forKey:@"watched_status"];
        [newitem setObject:details[@"title_romaji"] forKey:@"title_romaji"];
        [newitem setObject:details[@"title_english"] forKey:@"title_english"];
        [newitem setObject:details[@"type"] forKey:@"type"];
        [newitem setObject:details[@"total_episodes"] forKey:@"episodes"];
        [newitem setObject:details[@"airing_status"] forKey:@"status"];
        if (details[@"advanced_rating_scores"]){
            [newitem setObject:details[@"advanced_rating_scores"] forKey:@"advanced_rating_scores"];
        }
        else{
            [newitem setObject:[NSArray new] forKey:@"advanced_rating_scores"];
        }
        if (!details[@"notes"]){
            [newitem setObject:[NSNull null] forKey:@"notes"];
        }
        else{
            [newitem setObject:details[@"notes"] forKey:@"notes"];
        }
        [newitem setObject:item[@"custom_lists"] forKey:@"custom_lists"];
        [tmplist addObject:newitem];
    }
    return tmplist;
}
    
+ (AFOAuthCredential *)getFirstAccessToken{
    return [AFOAuthCredential retrieveCredentialWithIdentifier:@"MAL Library - AniList Token"];
}
    
+ (void)retrievetoken:(void (^)(bool success)) completionHandler {
    AFOAuthCredential *cred = [self getFirstAccessToken];
    if (!cred||cred.expired) {
        if (cred.expired) {
            [AFOAuthCredential deleteCredentialWithIdentifier:@"MAL Library - AniList Token"];
        }
        NSURL *baseURL = [NSURL URLWithString:@"https://anilist.co/api/"];
        AFOAuth2Manager *OAuth2Manager =
        [[AFOAuth2Manager alloc] initWithBaseURL:baseURL
                                        clientID:kanilistclient
                                          secret:kanilistsecretkey];
        [OAuth2Manager authenticateUsingOAuthWithURLString:@"auth/access_token" parameters:@{@"grant_type":@"client_credentials"} success:^(AFOAuthCredential *credential) {
            NSLog(@"Token: %@", credential.accessToken);
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
