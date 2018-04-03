//
//  AniList.m
//  MAL Library
//
//  Created by 小鳥遊六花 on 3/31/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "AniList.h"
#import "AniListConstants.h"
#import "AtarashiiAPIListFormatAniList.h"
#import "ClientConstants.h"
#import <AFNetworking/AFNetworking.h>
#import "AFHTTPSessionManager+Synchronous.h"
#import "Utility.h"

@implementation AniList
NSString *const kAniListKeychainIdentifier = @"MAL Library - AniList";
#pragma mark List
+ (void)retrieveList:(NSString *)username listType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // Retrieves list
    [self getAniListUserid:username completion:^(int userid) {
        NSMutableArray *tmparray = [NSMutableArray new];
        [self retrievelist:userid withArray:tmparray withType:type page:0 completion:completionHandler error:errorHandler];
    } error:^(NSError *error) {
            errorHandler(error);
    }];
}
+ (void)retrievelist:(int)userid withArray:(NSMutableArray *)tmparray withType:(int)type page:(int)page completion:(void (^)(id))completionHandler error:(void (^)(NSError *))errorHandler  {
    // Retrieve List
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    AFOAuthCredential *cred = [AniList getFirstAccount];
    if (cred && cred.expired) {
        errorHandler(nil);
        return;
    }
    if (cred) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *parameters;
    switch (type) {
        case AniListAnime:
            parameters = @{@"query" : kAnilistanimeList, @"variables" : @{@"id":@(userid), @"page" : @(page)}};
            break;
        case AniListManga:
            parameters = @{@"query" : kAnilistmangaList, @"variables" : @{@"id":@(userid), @"page" : @(page)}};
            break;
        default:
            errorHandler(nil);
            return;
    }
    
    [manager POST:@"https://graphql.anilist.co" parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        bool nextpage = false;
        switch (type) {
            case AniListAnime:
                [tmparray addObjectsFromArray:responseObject[@"data"][@"AnimeList"][@"mediaList"]];
                nextpage = ((NSNumber *)responseObject[@"data"][@"AnimeList"][@"pageInfo"][@"hasNextPage"]).boolValue;
                break;
            case AniListManga:
                [tmparray addObjectsFromArray:responseObject[@"data"][@"MangaList"][@"mediaList"]];
                nextpage = ((NSNumber *)responseObject[@"data"][@"MangaList"][@"pageInfo"][@"hasNextPage"]).boolValue;
                break;
            default:
                errorHandler(nil);
                return;
        }
        if (nextpage) {
            int newpagenum = page+1;
            [self retrievelist:userid withArray:tmparray withType:type page:newpagenum completion:completionHandler error:errorHandler];
            return;
        }
        switch (type) {
            case AniListAnime:
                completionHandler([AtarashiiAPIListFormatAniList AniListtoAtarashiiAnimeList:tmparray]);
                break;
            case AniListManga:
                // TODO: Manga List conversion
                //        completionHandler([AtarashiiAPIListFormatAniList AniListtoAtarashiiAnimeList:tmparray]);
                break;
            default:
                errorHandler(nil);
                return;
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        errorHandler(error);
    }];
}
+ (void)retrieveAiringSchedule:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
#pragma mark Search
+ (void)searchTitle:(NSString *)searchterm withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    NSMutableArray *tmparray = [NSMutableArray new];
    [self searchTitle:searchterm withType:type withDataArray:tmparray withPageOffet:0 completion:completionHandler error:errorHandler];
}
+ (void)searchTitle:(NSString *)searchterm withType:(int)type withDataArray:(NSMutableArray *)darray withPageOffet:(int)offset completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    NSDictionary *parameters = @{@"query" : kAnilisttitlesearch, @"variables" : @{@"query" : searchterm, @"type" : type == AniListAnime ? @"ANIME" : @"MANGA"}};
    [manager POST:@"https://graphql.anilist.co" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"data"] && responseObject[@"data"] != [NSNull null]) {
            [darray addObjectsFromArray:responseObject[@"data"]];
        }
        if (type == AniListAnime) {
            //completionHandler([AtarashiiAPIListFormatKitsu KitsuAnimeSearchtoAtarashii:@{@"data":darray}]);
        }
        else if (type == AniListManga) {
            //completionHandler([AtarashiiAPIListFormatKitsu KitsuMangaSearchtoAtarashii:@{@"data":darray}]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}
+ (void)advsearchTitle:(NSString *)searchterm withType:(int)type withGenres:(NSString *)genres excludeGenres:(bool)exclude startDate:(NSDate *)startDate endDate:(NSDate *)endDate minScore:(int)minscore rating:(int)rating withStatus:(int)status completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
#pragma mark Title Information
+ (void)retrieveTitleInfo:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    NSDictionary *parameters = @{@"query" : kAnilistTitleIdInformation, @"variables" : @{@"id" : @(titleid), @"type" : type == AniListAnime ? @"ANIME" : @"MANGA"}};
    [manager POST:@"https://graphql.anilist.co" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (type == AniListAnime) {
            //completionHandler([AtarashiiAPIListFormatKitsu KitsuAnimeInfotoAtarashii:responseObject]);
        }
        else if (type == AniListManga) {
            //completionHandler([AtarashiiAPIListFormatKitsu KitsuMangaInfotoAtarashii:responseObject]);
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
    NSDictionary *parameters;
    parameters = @{@"query" : kAnilistreviewbytitleid,@"variables" : @{@"id" : @(titleid), @"page" : @(offset)}};
    [manager POST:@"https://graphql.anilist.co" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"data"] && responseObject[@"data"] != [NSNull null]) {
            [dataarray addObjectsFromArray:responseObject[@"data"]];
            [includearray addObjectsFromArray:responseObject[@"included"]];
        }
        if (responseObject[@"links"][@"next"]) {
            int newoffset = offset + 20;
            [self retrieveReviewsForTitle:titleid withType:type withDataArray:dataarray withIncludeArray:includearray withPageOffset:newoffset completion:completionHandler error:errorHandler];
        }
        else {
            //completionHandler([AtarashiiAPIListFormatKitsu KitsuReactionstoAtarashii:@{@"data" : dataarray, @"included" : includearray} withType:type]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}
#pragma mark History
+ (void)retriveUpdateHistory:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}

#pragma mark OAuth Tokens
+ (bool)tokenexpired {
    AFOAuthCredential *cred = [self getFirstAccount];
    if (cred) {
        return cred.expired;
    }
    return false;
}
+ (void)verifyAccountWithPin:(NSString *)pin completion:(void (^)(id responseObject))completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFOAuth2Manager *OAuth2Manager =
    [[AFOAuth2Manager alloc] initWithBaseURL:[NSURL URLWithString:@"https://anilist.co/"]
                                    clientID:kanilistclient
                                      secret:kanilistsecretkey];
    [OAuth2Manager authenticateUsingOAuthWithURLString:@"api/v2/oauth/token" parameters:@{@"grant_type":@"authorization_code", @"code" : pin} success:^(AFOAuthCredential *credential) {
        [AFOAuthCredential storeCredential:credential
                            withIdentifier:kAniListKeychainIdentifier];
        
        [self getOwnAnilistid:^(int userid, NSString *username, NSString *scoreformat) {
            [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"anilist-username"];
            [[NSUserDefaults standardUserDefaults] setInteger:userid forKey:@"anilist-userid"];
            [[NSUserDefaults standardUserDefaults] setValue:scoreformat forKey:@"anilist-scoreformat"];
            completionHandler(@{@"success":@(true)});
        } error:^(NSError *error) {
            
        }];
    }
                                               failure:^(NSError *error) {
                                                   errorHandler(error);
                                               }];
}
#pragma mark Profiles
+ (void)retrieveProfile:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFOAuthCredential *cred = [AniList getFirstAccount];
    if (cred && cred.expired) {
        errorHandler(nil);
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    if (cred) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    }
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/users?filter[slug]=%@&include=profileLinks,userRoles,profileLinks.profileLinkSite",username] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        /*NSDictionary *tmpdict = [AtarashiiAPIListFormatKitsu KitsuUsertoAtarashii:responseObject];
        if (tmpdict) {
            completionHandler(tmpdict);
        }
        else {
            errorHandler(nil);
        }*/
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
    
}
#pragma mark List Operations
+ (void)addAnimeTitleToList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFOAuthCredential *cred = [AniList getFirstAccount];
    if (cred && cred.expired) {
        errorHandler(nil);
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    manager.requestSerializer = [Utility jsonrequestserializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:@"https://kitsu.io/api/edge/library-entries" parameters:@{@"data" : @{ @"type" : @"libraryEntries", @"relationships" : [self generaterelationshipdictionary:titleid withType:AniListAnime], @"attributes" :  [self generateAnimeAttributes:episode withStatus:status withScore:score withExtraFields:nil] }} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}
+ (void)addMangaTitleToList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFOAuthCredential *cred = [AniList getFirstAccount];
    if (cred && cred.expired) {
        errorHandler(nil);
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    manager.requestSerializer = [Utility jsonrequestserializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:@"https://kitsu.io/api/edge/library-entries" parameters:@{@"data" : @{ @"type" : @"libraryEntries", @"relationships" : [self generaterelationshipdictionary:titleid withType:AniListManga], @"attributes" : [self generateMangaAttributes:chapter withVolumes:volume withStatus:status withScore:score withExtraFields:nil] } } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
    
}
+ (void)updateAnimeTitleOnList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score withTags:(NSString *)tags withExtraFields:(NSDictionary *)efields completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // Note: Title id is entry id
    // Note: Tags field is ignored.
    AFOAuthCredential *cred = [AniList getFirstAccount];
    if (cred && cred.expired) {
        errorHandler(nil);
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
+ (void)updateMangaTitleOnList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score withTags:(NSString *)tags withExtraFields:(NSDictionary *)efields completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // Note: Title id is entry id
    // Note: Tags field is ignored.
    AFOAuthCredential *cred = [AniList getFirstAccount];
    if (cred && cred.expired) {
        errorHandler(nil);
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
    AFOAuthCredential *cred = [AniList getFirstAccount];
    if (cred && cred.expired) {
        errorHandler(nil);
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
#pragma mark Messages
+ (void)retrievemessagelist:(int)page completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)retrievemessage:(int)messageid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)sendmessage:(NSString *)username withSubject:(NSString *)subject withMessage:(NSString *)message withthreadID:(int)threadid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
}
+ (void)deletemessage:(int)messageid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    
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
    return [AFOAuthCredential retrieveCredentialWithIdentifier:kAniListKeychainIdentifier];
}
+ (bool)removeAccount {
    return [AFOAuthCredential deleteCredentialWithIdentifier:kAniListKeychainIdentifier];
}
+ (long)getCurrentUserID {
    return [NSUserDefaults.standardUserDefaults integerForKey:@"anilist-userid"];
}
+ (NSDictionary *)generaterelationshipdictionary:(int)titleid withType:(int)mediatype {
    //Create relationship JSON for a new library entry
    NSDictionary * userd =  @{@"data" : @{@"id" : @([self getCurrentUserID]), @"type" : @"users"}};
    NSDictionary * mediad = @{@"data" : @{@"id" : @(titleid), @"type" : mediatype == AniListAnime ? @"anime" : @"manga"}};
    return @{@"user" : userd, @"media" : mediad};
}
+ (void)getOwnAnilistid:(void (^)(int userid, NSString *username, NSString *scoreformat)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFOAuthCredential *cred = [AniList getFirstAccount];
    if (cred && cred.expired) {
        errorHandler(nil);
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    [manager POST:@"https://graphql.anilist.co" parameters:@{@"query" : kAnilistCurrentUsernametoUserId, @"variables" : @{}} progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (((NSArray *)responseObject[@"data"]).count > 0) {
            NSDictionary *d = responseObject[@"data"][@"Viewer"];
            completionHandler(((NSNumber *)d[@"id"]).intValue,d[@"name"], d[@"mediaListOptions"][@"scoreFormat"]);
        }
        else {
            completionHandler(-1,@"",@"");
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        errorHandler(error);
    }];
}
+ (void)getAniListUserid:(NSString *)username completion:(void (^)(int userid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFOAuthCredential *cred = [AniList getFirstAccount];
    if (cred && cred.expired) {
        errorHandler(nil);
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/users?filter[slug]=%@", username] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
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
+ (NSDictionary *)generateAnimeAttributes:(int)episode withStatus:(NSString *)status withScore:(int)score withExtraFields:(NSDictionary *)efields {
    NSMutableDictionary * attributes = [NSMutableDictionary new];
    attributes[@"status"] = [self convertWatchStatus:status withType:AniListAnime];
    attributes[@"progress"] = @(episode);
    attributes[@"ratingTwenty"] = score >= 2 ? @(score) : [NSNull null];
    if (efields) {
        [attributes addEntriesFromDictionary:efields];
    }
    return attributes;
}
+ (NSDictionary *)generateMangaAttributes:(int)chapter withVolumes:(int)volume withStatus:(NSString *)status withScore:(int)score withExtraFields:(NSDictionary *)efields {
    NSMutableDictionary * attributes = [NSMutableDictionary new];
    attributes[@"status"] = [self convertWatchStatus:status withType:AniListManga];
    attributes[@"progress"] = @(chapter);
    attributes[@"volumesOwned"] = @(volume);
    attributes[@"ratingTwenty"] = score >= 2 ? @(score) : [NSNull null];
    if (efields) {
        [attributes addEntriesFromDictionary:efields];
    }
    return attributes;
}
+ (void)getUserRatingType:(void (^)(int scoretype)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFOAuthCredential *cred = [AniList getFirstAccount];
    if (cred && cred.expired) {
        errorHandler(nil);
        return;
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    [manager GET:@"https://kitsu.io/api/edge/users?filter[self]=true&fields[users]=ratingSystem" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (((NSArray *)responseObject[@"data"]).count > 0) {
            NSDictionary *d = [NSArray arrayWithArray:responseObject[@"data"]][0];
            NSString *ratingtype = d[@"attributes"][@"ratingSystem"];
            /*if ([ratingtype isEqualToString:@"simple"]) {
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
            }*/
        }
        else {
            //completionHandler(ratingSimple);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(nil);
    }];
}
+ (NSString *)convertWatchStatus:(NSString *)status withType:(int)type{
    if (type == AniListAnime) {
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
    AFOAuthCredential *cred = [AniList getFirstAccount];
    if (cred && cred.expired) {
        return;
    }
    AFHTTPSessionManager *manager = [Utility syncmanager];
    if (cred) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    }
    NSError *error;
    
    id responseObject = [manager syncPOST:@"https://graphql.anilist.co" parameters:@{@"query" : kAnilistCurrentUsernametoUserId, @"variables" : @{}} task:NULL error:&error];
    if (!error) {
        if (((NSArray *)responseObject[@"data"]).count > 0) {
            NSDictionary *d = responseObject[@"data"][@"Viewer"];
            NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
            [defaults setValue:d[@"id"] forKey:@"anilist-userid"];
            [defaults setValue:d[@"name"] forKey:@"anilist-username"];
            [defaults setValue:d[@"mediaListOptions"][@"scoreFormat"] forKey:@"anilist-scoreformat"];
        }
        else {
            // Remove Account, invalid token
            [self removeAccount];
        }
    }
    else {
        // Remove Account
        [self removeAccount];
    }
}
@end
