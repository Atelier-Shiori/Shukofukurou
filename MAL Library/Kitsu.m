//
//  Kitsu.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/12/14.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "Kitsu.h"
#import <AFNetworking/AFNetworking.h>
#import "AFHTTPSessionManager+Synchronous.h"
#import "AtarashiiAPIListFormatKitsu.h"
#import "KitsuListRetriever.h"
#import "Utility.h"
#import "ClientConstants.h"

@implementation Kitsu
#ifdef DEBUG
NSString *const kKeychainIdentifier = @"Shukofukurou - Kitsu DEBUG";
#else
NSString *const kKeychainIdentifier = @"Shukofukurou - Kitsu";
#endif

#pragma mark List
+ (void)retrieveList:(NSString *)username listType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    KitsuListRetriever *retriever = [KitsuListRetriever new];
    [self getKitsuid:username completion:^(int userid) {
        if (userid > -1) {
            [retriever retrieveKitsuLibrary:userid type:type atPage:0 completionHandler:^(id responseObject) {
                completionHandler(responseObject);
            } error:^(NSError *error) {
                errorHandler(error);
            }];
        }
        else {
            errorHandler(nil);
        }
    } error:^(NSError *error) {
        errorHandler(error);
    }];
}

+ (void)retrieveOwnLisWithType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    KitsuListRetriever *retriever = [KitsuListRetriever new];
    [self getOwnKitsuid:^(int userid) {
        if (userid > -1) {
            [retriever retrieveKitsuLibrary:userid type:type atPage:0 completionHandler:^(id responseObject) {
                completionHandler(responseObject);
            } error:^(NSError *error) {
                errorHandler(error);
            }];
        }
        else {
            errorHandler(nil);
        }
    } error:^(NSError *error) {
        errorHandler(error);
    }];
}
#pragma mark Search
+ (void)searchTitle:(NSString *)searchterm withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    NSMutableArray *tmparray = [NSMutableArray new];
    [self searchTitle:searchterm withType:type withDataArray:tmparray withPageOffet:0 completion:completionHandler error:errorHandler];
}

+ (void)searchTitle:(NSString *)searchterm withType:(int)type withDataArray:(NSMutableArray *)darray withPageOffet:(int)offset completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [Utility jsonmanager];
#if defined(AppStore) // Do not provide authorization as Mac App Store rating does not allow adult content. Exclude all adult content
#else
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"showadult"]) {
        AFOAuthCredential *cred = [Kitsu getFirstAccount];
        if (cred && cred.expired) {
            [Kitsu refreshToken:^(bool success) {
                if (success) {
                    [self searchTitle:searchterm withType:type withDataArray:darray withPageOffet:offset completion:completionHandler error:errorHandler];
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
    }
#endif
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/%@/?filter[text]=%@&page[limit]=20&page[offset]=%i", type == KitsuAnime ? @"anime" : @"manga", [Utility urlEncodeString:searchterm], offset] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"data"] && responseObject[@"data"] != [NSNull null]) {
            [darray addObjectsFromArray:responseObject[@"data"]];
        }
        if (responseObject[@"links"][@"next"] && offset < 40) {
            int newoffset = offset + 20;
            [self searchTitle:searchterm withType:type withDataArray:darray withPageOffet:newoffset completion:completionHandler error:errorHandler];
        }
        else {
            if (type == KitsuAnime) {
                completionHandler([AtarashiiAPIListFormatKitsu KitsuAnimeSearchtoAtarashii:@{@"data":darray}]);
            }
            else if (type == KitsuManga) {
                completionHandler([AtarashiiAPIListFormatKitsu KitsuMangaSearchtoAtarashii:@{@"data":darray}]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}

#pragma mark Title Information
+ (void)retrieveTitleInfo:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [Utility jsonmanager];
#if defined(AppStore) // Do not provide authorization as Mac App Store rating does not allow adult content. Exclude all adult content
#else
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"showadult"]) {
        AFOAuthCredential *cred = [Kitsu getFirstAccount];
        if (cred && cred.expired) {
            [Kitsu refreshToken:^(bool success) {
                if (success) {
                    [self retrieveTitleInfo:titleid withType:type completion:completionHandler error:errorHandler];
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
    }
#endif
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/%@/%i?include=categories,mappings%@", type == KitsuAnime ? @"anime" : @"manga", titleid, type == KitsuAnime ? @",animeProductions,animeProductions.producer" : @""] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
#pragma mark Reviews
+ (void)retrieveReviewsForTitle:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    NSMutableArray *dataarray = [NSMutableArray new];
    NSMutableArray *includearray = [NSMutableArray new];
    [self retrieveReviewsForTitle:titleid withType:type withDataArray:dataarray withIncludeArray:includearray withPageOffset:0 completion:completionHandler error:errorHandler];
}

+ (void)retrieveReviewsForTitle:(int)titleid withType:(int)type withDataArray:(NSMutableArray *)dataarray withIncludeArray:(NSMutableArray *)includearray withPageOffset:(int)offset completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [Utility jsonmanager];
#if defined(AppStore) // Do not provide authorization as Mac App Store rating does not allow adult content. Exclude all adult content
#else
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"showadult"]) {
        AFOAuthCredential *cred = [Kitsu getFirstAccount];
        if (cred && cred.expired) {
            [Kitsu refreshToken:^(bool success) {
                if (success) {
                    [self retrieveReviewsForTitle:titleid withType:type withDataArray:dataarray withIncludeArray:includearray withPageOffset:offset completion:completionHandler error:errorHandler];
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
    }
#endif
    NSString *reviewurl = @"";
    if (type == KitsuAnime) {
        reviewurl = [NSString stringWithFormat:@"https://kitsu.io/api/edge/media-reactions/?filter[animeId]=%i&include=anime,libraryEntry,user&fields[libraryEntries]=progress,status,ratingTwenty&fields[users]=name,avatar,slug&fields[anime]=episodeCount&page[limit]=20&page[offset]=%i", titleid,offset];
    }
    else {
        reviewurl = [NSString stringWithFormat:@"https://kitsu.io/api/edge/media-reactions/?filter[mangaId]=%i&include=manga,libraryEntry,user&fields[libraryEntries]=progress,status,ratingTwenty&fields[users]=name,avatar,slug&fields[manga]=chapterCount&page[limit]=20&page[offset]=%i", titleid, offset];
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

#pragma mark OAuth Tokens
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
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [self saveuserinfoforcurrenttoken];
            [Kitsu getOwnKitsuid:^(int userid) {
                [[NSUserDefaults standardUserDefaults] setInteger:userid forKey:@"kitsu-userid"];
            } error:^(NSError *error) {
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(@{@"success":@(true)});
            });
        });
    }
    failure:^(NSError *error) {
        errorHandler(error);
    }];
}
#pragma mark Profiles
+ (void)retrieveProfile:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self retrieveProfile:username completion:completionHandler error:errorHandler];
            }
            else {
                errorHandler(nil);
            }
        }];
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    if (cred) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    }
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/users?filter[slug]=%@&include=profileLinks,userRoles,profileLinks.profileLinkSite",username] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *tmpdict = [AtarashiiAPIListFormatKitsu KitsuUsertoAtarashii:responseObject];
        if (tmpdict) {
            completionHandler(tmpdict);
        }
        else {
            errorHandler(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
    
}
#pragma mark List Operations
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
    [manager POST:@"https://kitsu.io/api/edge/library-entries" parameters:@{@"data" : @{ @"type" : @"libraryEntries", @"relationships" : [self generaterelationshipdictionary:titleid withType:KitsuAnime], @"attributes" :  [self generateAnimeAttributes:episode withStatus:status withScore:score withExtraFields:nil] }} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    
    [manager POST:@"https://kitsu.io/api/edge/library-entries" parameters:@{@"data" : @{ @"type" : @"libraryEntries", @"relationships" : [self generaterelationshipdictionary:titleid withType:KitsuManga], @"attributes" : [self generateMangaAttributes:chapter withVolumes:volume withStatus:status withScore:score withExtraFields:nil] } } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
    
}
+ (void)updateAnimeTitleOnList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score withExtraFields:(NSDictionary *)efields completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // Note: Title id is entry id
    // Note: Tags field is ignored.
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self updateAnimeTitleOnList:titleid withEpisode:episode withStatus:status withScore:score withExtraFields:efields completion:completionHandler error:errorHandler];
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
    
    [manager PATCH:[NSString stringWithFormat:@"https://kitsu.io/api/edge/library-entries/%i",titleid] parameters:@{@"data" : @{ @"id" : @(titleid), @"type" : @"libraryEntries", @"attributes" :  [self generateAnimeAttributes:episode withStatus:status withScore:score withExtraFields:efields] }} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}
+ (void)updateMangaTitleOnList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score withExtraFields:(NSDictionary *)efields completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // Note: Title id is entry id
    // Note: Tags field is ignored.
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self updateMangaTitleOnList:titleid withChapter:chapter withVolume:volume withStatus:status withScore:score withExtraFields:efields completion:completionHandler error:errorHandler];
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
    
    [manager PATCH:[NSString stringWithFormat:@"https://kitsu.io/api/edge/library-entries/%i",titleid] parameters:@{@"data" : @{ @"id" : @(titleid), @"type" : @"libraryEntries", @"attributes" :  [self generateMangaAttributes:chapter withVolumes:volume withStatus:status withScore:score withExtraFields:efields] }} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
#pragma mark Title List IDs
+ (void)retrieveTitleIdsWithlistType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    NSMutableArray *tmparray = [NSMutableArray new];
    // Retrieves list
    [self retrieveTitleIds:(int)[NSUserDefaults.standardUserDefaults integerForKey:@"kitsu-userid"] withArray:tmparray withType:type page:0 completion:completionHandler error:errorHandler];
}
+ (void)retrieveTitleIds:(int)userid withArray:(NSMutableArray *)tmparray withType:(int)type page:(int)page completion:(void (^)(id responseobject))completionHandler error:(void (^)(NSError *))errorHandler  {
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self retrieveTitleIds:userid withArray:tmparray withType:type page:page completion:completionHandler error:errorHandler];
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
    NSString *typestr = type == KitsuAnime ? @"anime" : @"manga";
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/library-entries?filter[userId]=%ifilter[kind]=%@&include=%@,%@.mappings&fields[library-entries]=%@&fields[%@]=mappings&fields[mappings]=externalSite,externalId&page[limit]=500&page[offset]=%i",userid,typestr,typestr,typestr,typestr,typestr,page] parameters:@{} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"included"]){
            [tmparray addObjectsFromArray:responseObject[@"included"]];
        }
        if (responseObject[@"links"][@"next"]) {
            int nextPage = page+500;
            [self retrieveTitleIds:userid withArray:tmparray withType:type page:nextPage completion:completionHandler error:errorHandler];
        }
        else {
            completionHandler([AtarashiiAPIListFormatKitsu generateIDArrayWithType:type withIdArray:tmparray]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}
#pragma mark Characters
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
+ (void)getOwnKitsuid:(void (^)(int userid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self getOwnKitsuid:completionHandler error:errorHandler];
            }
            else {
                errorHandler(nil);
            }
        }];
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    [manager GET:@"https://kitsu.io/api/edge/users?filter[self]=true" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (((NSArray *)responseObject[@"data"]).count > 0) {
            if (responseObject[@"data"][0]) {
                completionHandler(((NSNumber *)responseObject[@"data"][0][@"id"]).intValue);
            }
            else {
                completionHandler(-1);
            }
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        errorHandler(error);
    }];
}
+ (void)getKitsuid:(NSString *)username completion:(void (^)(int userid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self getKitsuid:username completion:completionHandler error:errorHandler];
            }
            else {
                errorHandler(nil);
            }
        }];
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    if (cred) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    }
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/users?filter[slug]=%@", username] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (((NSArray *)responseObject[@"data"]).count > 0) {
            completionHandler(((NSNumber *)responseObject[@"data"][0][@"id"]).intValue);
        }
        else {
            completionHandler(-1);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        errorHandler(error);
    }];
}
+ (NSDictionary *)generateAnimeAttributes:(int)episode withStatus:(NSString *)status withScore:(int)score withExtraFields:(NSDictionary *)efields {
    NSMutableDictionary * attributes = [NSMutableDictionary new];
    attributes[@"status"] = [self convertWatchStatus:status withType:KitsuAnime];
    attributes[@"progress"] = @(episode);
    attributes[@"ratingTwenty"] = score >= 2 ? @(score) : [NSNull null];
    if (efields) {
        [attributes addEntriesFromDictionary:efields];
    }
    return attributes;
}
+ (NSDictionary *)generateMangaAttributes:(int)chapter withVolumes:(int)volume withStatus:(NSString *)status withScore:(int)score withExtraFields:(NSDictionary *)efields {
    NSMutableDictionary * attributes = [NSMutableDictionary new];
    attributes[@"status"] = [self convertWatchStatus:status withType:KitsuManga];
    attributes[@"progress"] = @(chapter);
    attributes[@"volumesOwned"] = @(volume);
    attributes[@"ratingTwenty"] = score >= 2 ? @(score) : [NSNull null];
    if (efields) {
        [attributes addEntriesFromDictionary:efields];
    }
    return attributes;
}
+ (void)getUserRatingType:(void (^)(int scoretype)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self getUserRatingType:completionHandler error:errorHandler];
            }
            else {
                errorHandler(nil);
            }
        }];
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    [manager GET:@"https://kitsu.io/api/edge/users?filter[self]=true&fields[users]=ratingSystem" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

+ (void)saveuserinfoforcurrenttoken {
    // Retrieves missing user information and populates it before showing the UI.
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self saveuserinfoforcurrenttoken];
            }
        }];
        return;
    }
    AFHTTPSessionManager *manager = [Utility syncmanager];
    if (cred) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    }
    NSError *error;
    id responseObject = [manager syncGET:@"https://kitsu.io/api/edge/users?filter[self]=true&fields[users]=name,slug,avatar,ratingSystem" parameters:@{} task:NULL error:&error];
    if (!error) {
        if (((NSArray *)responseObject[@"data"]).count > 0) {
            NSDictionary *d = [NSArray arrayWithArray:responseObject[@"data"]][0];
            NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
            [defaults setValue:d[@"id"] forKey:@"kitsu-userid"];
            if (d[@"attributes"][@"name"] != [NSNull null]) {
                [defaults setValue:d[@"attributes"][@"name"] forKey:@"kitsu-username"];
            }
            else if (d[@"attributes"][@"slug"] != [NSNull null]) {
                [defaults setValue:d[@"attributes"][@"slug"] forKey:@"kitsu-username"];
            }
            else {
                [defaults setValue:@"Unknown User" forKey:@"kitsu-username"];
            }
            NSString *ratingtype = d[@"attributes"][@"ratingSystem"];
            if (ratingtype) {
                if ([ratingtype isEqualToString:@"simple"]) {
                    [defaults setInteger:ratingSimple forKey:@"kitsu-ratingsystem"];
                }
                else if ([ratingtype isEqualToString:@"standard"]) {
                    [defaults setInteger:ratingStandard forKey:@"kitsu-ratingsystem"];
                }
                else if ([ratingtype isEqualToString:@"advanced"]) {
                    [defaults setInteger:ratingAdvanced forKey:@"kitsu-ratingsystem"];
                }
            }
            else {
                 [defaults setInteger:ratingSimple forKey:@"kitsu-ratingsystem"];
            }
        }
        else {
            // Remove Account, invalid token
            [self removeAccount];
        }
    }
    else {
        if ([[error.userInfo valueForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: unauthorized (401)"]) {
            // Remove Account
            [self removeAccount];
        }
    }
}
@end
