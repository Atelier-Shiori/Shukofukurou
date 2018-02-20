//
//  Kitsu.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/12/14.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "Kitsu.h"
#import <AFNetworking/AFNetworking.h>
#import "AtarashiiAPIListFormatKitsu.h"
#import "KitsuListRetriever.h"
#import "Utility.h"
#import "ClientConstants.h"

@implementation Kitsu
NSString *const kKeychainIdentifier = @"MAL Library - Kitsu";

+ (void)retrieveList:(NSString *)username listType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)retrieveAiringSchedule:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)searchTitle:(NSString *)searchterm withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [Utility httpmanager];
    
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/%@/?filter[text]=%@", type == KitsuAnime ? @"anime" : @"manga", [Utility urlEncodeString:searchterm]] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (type == KitsuAnime) {
            completionHandler([AtarashiiAPIListFormatKitsu KitsuAnimeSearchtoAtarashii:responseObject]);
        }
        else if (type == KitsuManga) {
            completionHandler([AtarashiiAPIListFormatKitsu KitsuMangaSearchtoAtarashii:responseObject]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}
+ (void)advsearchTitle:(NSString *)searchterm withType:(int)type withGenres:(NSString *)genres excludeGenres:(bool)exclude startDate:(NSDate *)startDate endDate:(NSDate *)endDate minScore:(int)minscore rating:(int)rating withStatus:(int)status completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)retrieveTitleInfo:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [Utility httpmanager];

    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/%@/%i?include=categories,mappings", type == KitsuAnime ? @"anime" : @"manga", titleid] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (type == KitsuAnime) {
            completionHandler([AtarashiiAPIListFormatKitsu KitsuAnimeInfotoAtarashii:responseObject]);
        }
        else if (type == KitsuManga) {
            completionHandler([AtarashiiAPIListFormatKitsu KitsuMangaInfotoAtarashii:responseObject]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
    
}
+ (void)retrieveReviewsForTitle:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)retriveUpdateHistory:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (bool)tokenexpired {
    AFOAuthCredential *cred = [self getFirstAccount];
    if (cred) {
        return cred.expired;
    }
    return false;
}
+ (void)refreshToken:(void (^)(bool success))completion {
    AFOAuthCredential *cred =
    [AFOAuthCredential retrieveCredentialWithIdentifier:kKeychainIdentifier];
    NSURL *baseURL = [NSURL URLWithString:kKitsuBaseURL];
    AFOAuth2Manager *OAuth2Manager = [[AFOAuth2Manager alloc] initWithBaseURL:baseURL
                                                                     clientID:kKitsuClient
                                                                       secret:kKitsusecretkey];
    [OAuth2Manager setUseHTTPBasicAuthentication:NO];
    [OAuth2Manager authenticateUsingOAuthWithURLString:kKitsuTokenURL
                                            parameters:@{@"grant_type":@"refresh_token", @"refresh_token":cred.refreshToken} success:^(AFOAuthCredential *credential) {
                                                NSLog(@"Token refreshed");
                                                [AFOAuthCredential storeCredential:credential
                                                                    withIdentifier:kKeychainIdentifier];
                                                completion(true);
                                            }
                                            failure:^(NSError *error) {
                                                completion(false);
                                            }];
}
+ (void)verifyAccountWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(id responseObject))completionHandler error:(void (^)(NSError * error)) errorHandler {
    NSURL *baseURL = [NSURL URLWithString:kKitsuBaseURL];
    AFOAuth2Manager *OAuth2Manager =
    [[AFOAuth2Manager alloc] initWithBaseURL:baseURL
                                    clientID:kKitsuClient
                                      secret:kKitsusecretkey];
    [OAuth2Manager authenticateUsingOAuthWithURLString:kKitsuTokenURL parameters:@{@"grant_type":@"password", @"username":username, @"password":password} success:^(AFOAuthCredential *credential) {
        [AFOAuthCredential storeCredential:credential
                            withIdentifier:kKeychainIdentifier];
        [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"hachidori-username"];
        completionHandler(@{@"success":@(true)});
    }
    failure:^(NSError *error) {
        errorHandler(error);
    }];
}
+ (void)retrieveProfile:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)addAnimeTitleToList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
    
}
+ (void)addMangaTitleToList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)updateAnimeTitleOnList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score withTags:(NSString *)tags completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)updateMangaTitleOnList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score withTags:(NSString *)tags completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)removeTitleFromList:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)retrievemessagelist:(int)page completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)retrievemessage:(int)messageid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)sendmessage:(NSString *)username withSubject:(NSString *)subject withMessage:(NSString *)message withthreadID:(int)threadid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)deletemessage:(int)messageid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)retrieveStaff:(int)titleid completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)retrievePersonDetails:(int)personid completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
}

#pragma mark helpers
+ (AFOAuthCredential *)getFirstAccount {
    return [AFOAuthCredential retrieveCredentialWithIdentifier:kKeychainIdentifier];
}
+ (bool)removeAccount {
    return [AFOAuthCredential deleteCredentialWithIdentifier:kKeychainIdentifier];
}

@end
