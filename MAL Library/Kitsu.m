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
#import "TitleIdConverter.h"
//#import "AtarashiiAPIKitsuStaffFormat.h"
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
    NSMutableArray *dataarray = [NSMutableArray new];
    NSMutableArray *includearray = [NSMutableArray new];
    [self retrieveReviewsForTitle:titleid withType:type withDataArray:dataarray withIncludeArray:includearray withPageOffset:0 completion:completionHandler error:errorHandler];
}

+ (void)retrieveReviewsForTitle:(int)titleid withType:(int)type withDataArray:(NSMutableArray *)dataarray withIncludeArray:(NSMutableArray *)includearray withPageOffset:(int)offset completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    NSString *reviewurl = @"";
    if (type == KitsuAnime) {
        reviewurl = [NSString stringWithFormat:@"https://kitsu.io/api/edge/media-reactions/?filter[animeId]=%i&include=anime,libraryEntry,user&fields[libraryEntries]=progress,status,ratingTwenty&fields[users]=name,avatar&fields[anime]=episodeCount&page[limit]=20&page[offset]=%i", titleid,offset];
    }
    else {
        reviewurl = [NSString stringWithFormat:@"https://kitsu.io/api/edge/media-reactions/?filter[mangaId]=%i&include=manga,libraryEntry,user&fields[libraryEntries]=progress,status,ratingTwenty&fields[users]=name,avatar&fields[manga]=chapterCount&page[limit]=20&page[offset]=%i", titleid, offset];
    }
    [manager GET:reviewurl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"data"] && responseObject[@"data"] != [NSNull null]) {
            [dataarray addObjectsFromArray:responseObject[@"data"]];
            [includearray addObjectsFromArray:responseObject[@"included"]];
        }
        if (responseObject[@"links"][@"next"]) {
            int newoffset = offset + 20;
            [self retrieveReviewsForTitle:titleid withType:type withDataArray:dataarray withIncludeArray:includearray withPageOffset:newoffset completion:completionHandler error:errorHandler];
        }
        else {
            completionHandler([AtarashiiAPIListFormatKitsu KitsuReactionstoAtarashii:@{@"data" : dataarray, @"included" : includearray} withType:type]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
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
    
    [manager POST:@"https://kitsu.io/api/edge/library-entries" parameters:@{@"data" : @{ @"type" : @"libraryEntries", @"relationships" : [self generaterelationshipdictionary:titleid withType:KitsuAnime], @"attributes" :  [self generateAnimeAttributes:episode withStatus:status withScore:score] }} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    
    [manager POST:@"https://kitsu.io/api/edge/library-entries" parameters:@{@"data" : @{ @"type" : @"libraryEntries", @"relationships" : [self generaterelationshipdictionary:titleid withType:KitsuManga], @"attributes" : [self generateMangaAttributes:chapter withVolumes:volume withStatus:status withScore:score] } } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    
    [manager PATCH:[NSString stringWithFormat:@"https://kitsu.io/api/edge/library-entries/%i",titleid] parameters:@{@"data" : @{ @"id" : @(titleid), @"type" : @"libraryEntries", @"attributes" :  [self generateAnimeAttributes:episode withStatus:status withScore:score] }} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    
    [manager PATCH:[NSString stringWithFormat:@"https://kitsu.io/api/edge/library-entries/%i",titleid] parameters:@{@"data" : @{ @"id" : @(titleid), @"type" : @"libraryEntries", @"attributes" :  [self generateMangaAttributes:chapter withVolumes:volume withStatus:status withScore:score] }} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    /*AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/anime-characters?filter[animeId]=%i&include=character,character.castings,character.castings.person&fields[castings]=voiceActor,featured,person,language&fields[people]=name,image,malId",titleid] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        __block NSDictionary *characterData = responseObject;
        [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/anime-staff?filter[animeId]=%i&include=person&fields[people]=name,malId,image",titleid] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            AtarashiiAPIKitsuStaffFormat *sformat = [[AtarashiiAPIKitsuStaffFormat alloc] initwithDataDictionary:characterData withStaffData:responseObject];
            completionHandler([sformat generateStaffList]);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            errorHandler(error);
            NSLog(@"%@",error.localizedDescription);
        }];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        errorHandler(error);
        NSLog(@"%@",error.localizedDescription);
    }];*/
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
    attributes[@"status"] = [self convertWatchStatus:status withType:KitsuAnime];
    attributes[@"progress"] = @(episode);
    attributes[@"ratingTwenty"] = score >= 2 ? @(score) : [NSNull null];
    return attributes;
}
+ (NSDictionary *)generateMangaAttributes:(int)chapter withVolumes:(int)volume withStatus:(NSString *)status withScore:(int)score {
    NSMutableDictionary * attributes = [NSMutableDictionary new];
    attributes[@"status"] = [self convertWatchStatus:status withType:KitsuManga];
    attributes[@"progress"] = @(chapter);
    attributes[@"volumesOwned"] = @(volume);
    attributes[@"ratingTwenty"] = score >= 2 ? @(score) : [NSNull null];
    return attributes;
}
+ (void)getUserRatingTypeForUsername:(NSString *)username completionHandler:(void (^)(int scoretype)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self getUserRatingTypeForUsername:username completionHandler:completionHandler error:errorHandler];
            }
            else {
                errorHandler(nil);
            }
        }];
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/users?filter[name]=%@",username] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (((NSArray *)responseObject[@"data"]).count > 0) {
            NSDictionary *d = [NSArray arrayWithArray:responseObject[@"data"]][0];
            NSString *ratingtype = d[@"attributes"][@"ratingSystem"];
            if ([ratingtype isEqualToString:@"simple"]) {
                completionHandler(ratingSimple);
            }
            else if ([ratingtype isEqualToString:@"standard"]) {
                completionHandler(ratingStandard);
            }
            else if ([ratingtype isEqualToString:@"advanced"]) {
                completionHandler(ratingAdvanced);
            }
            else {
                completionHandler(ratingSimple);
            }
        }
        else {
            completionHandler(ratingSimple);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(nil);
    }];
}
+ (NSString *)convertWatchStatus:(NSString *)status withType:(int)type{
    if (type == KitsuAnime) {
        if ([status isEqualToString:@"watching"]) {
            return @"current";
        }
        else if ([status isEqualToString:@"on-hold"]) {
            return @"on_hold";
        }
        else if ([status isEqualToString:@"plan to watch"]) {
            return @"planned";
        }
        return status;
    }
    else {
        if ([status isEqualToString:@"reading"]) {
            return @"current";
        }
        else if ([status isEqualToString:@"on-hold"]) {
            return @"on_hold";
        }
        else if ([status isEqualToString:@"plan to read"]) {
            return @"planned";
        }
        return status;
    }
}
@end
