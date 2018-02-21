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
    KitsuListRetriever *retriever = [KitsuListRetriever new];
    [self getKitsuidfromUserName:username completionHandler:^(int userid) {
        if (userid > -1) {
            [retriever retrieveKitsuLibrary:userid type:type atPage:0 completionHandler:^(id responseObject) {
                completionHandler(responseObject);
            } error:^(NSError *error) {
                errorHandler(error);
            }];
        }
        errorHandler(nil);
    } error:^(NSError *error) {
        errorHandler(error);
    }];
}
+ (void)retrieveAiringSchedule:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)searchTitle:(NSString *)searchterm withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/%@/?filter[text]=%@&page[limit]=20", type == KitsuAnime ? @"anime" : @"manga", [Utility urlEncodeString:searchterm]] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    AFHTTPSessionManager *manager = [Utility jsonmanager];

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
        [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"kitsu-username"];
        completionHandler(@{@"success":@(true)});
        [Kitsu getKitsuidfromUserName:username completionHandler:^(int userid) {
            [[NSUserDefaults standardUserDefaults] setInteger:userid forKey:@"kitsu-userid"];
        } error:^(NSError *error) {
        }];
    }
    failure:^(NSError *error) {
        errorHandler(error);
    }];
}
+ (void)retrieveProfile:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)addAnimeTitleToList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self addAnimeTitleToList:titleid withEpisode:episode withStatus:status withScore:score completion:completionHandler error:errorHandler];
            }
            else {
                errorHandler(nil);
            }
        }];
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    manager.requestSerializer = [Utility jsonrequestserializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:@"https://kitsu.io/api/edge/library-entries" parameters:@{@"data" : @{ @"relationships" : [self generaterelationshipdictionary:titleid withType:KitsuAnime], @"attributes" :  [self generateAnimeAttributes:episode withStatus:status withScore:score] }} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}
+ (void)addMangaTitleToList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self addMangaTitleToList:titleid withChapter:chapter withVolume:volume withStatus:status withScore:score completion:completionHandler error:errorHandler];
            }
            else {
                errorHandler(nil);
            }
        }];
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    manager.requestSerializer = [Utility jsonrequestserializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:@"https://kitsu.io/api/edge/library-entries" parameters:@{@"data" : @{ @"relationships" : [self generaterelationshipdictionary:titleid withType:KitsuManga], @"attributes" : [self generateMangaAttributes:chapter withVolumes:volume withStatus:status withScore:score] } } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
    
}
+ (void)updateAnimeTitleOnList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score withTags:(NSString *)tags completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // Note: Title id is entry id
    // Note: Tags field is ignored.
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self updateAnimeTitleOnList:titleid withEpisode:episode withStatus:status withScore:score withTags:tags completion:completionHandler error:errorHandler];
            }
            else {
                errorHandler(nil);
            }
        }];
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    manager.requestSerializer = [Utility jsonrequestserializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    
    [manager PATCH:[NSString stringWithFormat:@"https://kitsu.io/api/edge/library-entries/%i",titleid] parameters:@{@"data" : @{ @"attributes" :  [self generateAnimeAttributes:episode withStatus:status withScore:score] }} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}
+ (void)updateMangaTitleOnList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score withTags:(NSString *)tags completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // Note: Title id is entry id
    // Note: Tags field is ignored.
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self updateMangaTitleOnList:titleid withChapter:chapter withVolume:volume withStatus:status withScore:score withTags:tags completion:completionHandler error:errorHandler];
            }
            else {
                errorHandler(nil);
            }
        }];
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    manager.requestSerializer = [Utility jsonrequestserializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    
    [manager PATCH:[NSString stringWithFormat:@"https://kitsu.io/api/edge/library-entries/%i",titleid] parameters:@{@"data" : @{ @"attributes" :  [self generateMangaAttributes:chapter withVolumes:volume withStatus:status withScore:score] }} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
    
}
+ (void)removeTitleFromList:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // Note: Title id is entry id
    // Note; Type field is ignored
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self removeTitleFromList:titleid withType:type completion:completionHandler error:errorHandler];
            }
            else {
                errorHandler(nil);
            }
        }];
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    manager.requestSerializer = [Utility jsonrequestserializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    [manager DELETE:[NSString stringWithFormat:@"https://kitsu.io/api/edge/library-entries/%i",titleid] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
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
+ (long)getCurrentUserID {
    return [NSUserDefaults.standardUserDefaults integerForKey:@"kitsu-userid"];
}
+ (NSDictionary *)generaterelationshipdictionary:(int)titleid withType:(int)mediatype {
    //Create relationship JSON for a new library entry
    NSDictionary * userd =  @{@"data" : @{@"id" : @([self getCurrentUserID]), @"type" : @"users"}};
    NSDictionary * mediad = @{@"data" : @{@"id" : @(titleid), @"type" : mediatype == KitsuAnime ? @"anime" : @"manga"}};
    return @{@"user" : userd, @"media" : mediad};
}
+ (void)getKitsuidfromUserName:(NSString *)username completionHandler:(void (^)(int userid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/users?filter[name]=%@",[Utility urlEncodeString:username]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (responseObject[@"data"][0]) {
            completionHandler(((NSNumber *)responseObject[@"data"][0][@"id"]).intValue);
        }
        else {
            completionHandler(-1);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        errorHandler(error);
    }];
}
+ (NSDictionary *)generateAnimeAttributes:(int)episode withStatus:(NSString *)status withScore:(int)score {
    NSMutableDictionary * attributes = [NSMutableDictionary new];
    attributes[@"status"] = status;
    attributes[@"progress"] = @(episode);
    attributes[@"ratingTwenty"] = @(score);
    return attributes;
}
+ (NSDictionary *)generateMangaAttributes:(int)chapter withVolumes:(int)volume withStatus:(NSString *)status withScore:(int)score {
    NSMutableDictionary * attributes = [NSMutableDictionary new];
    attributes[@"status"] = status;
    attributes[@"progress"] = @(chapter);
    attributes[@"volumesOwned"] = @(volume);
    attributes[@"ratingTwenty"] = @(score);
    return attributes;
}
@end
