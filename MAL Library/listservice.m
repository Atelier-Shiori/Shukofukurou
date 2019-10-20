//
//  listservice.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/12/14.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "listservice.h"
#import "Keychain.h"
#import "ClientConstants.h"

@implementation listservice
@synthesize kitsuManager;
@synthesize anilistManager;
@synthesize myanimelistManager;
/* Note: Current Service type will be specified as the following:
         1. MyAnimeList
         2. Kitsu
         3. AniList */
    
+ (instancetype)sharedInstance {
    static listservice *sharedManager = nil;
    static dispatch_once_t listservicetoken;
    dispatch_once(&listservicetoken, ^{
        sharedManager = [listservice new];
    });
    return sharedManager;
}
    
- (instancetype)init {
    if (self = [super init]) {
        anilistManager = [[AniList alloc] initWithClientId:kanilistclient withClientSecret:kanilistsecretkey];
        kitsuManager = [[Kitsu alloc] initWithClientId:kKitsuClient withClientSecret:kKitsusecretkey];
        myanimelistManager = [[MyAnimeList alloc] initWithClientId:kMALClient withRedirectURL:kMALRedirectURL];
    }
    return self;
}
    
- (int)getCurrentServiceID {
    return (int)[NSUserDefaults.standardUserDefaults integerForKey:@"currentservice"];
}

- (bool)checkUserData {
    switch ([self getCurrentServiceID]) {
        case 1: {
            NSString *malusername = [NSUserDefaults.standardUserDefaults valueForKey:@"mal-username"];
            int malid = (int)[NSUserDefaults.standardUserDefaults integerForKey:@"mal-userid"];
            return malusername && malid > 0;
        }
        case 2: {
            NSString *kitsuusername = [NSUserDefaults.standardUserDefaults valueForKey:@"kitsu-username"];
            int kitsuid = (int)[NSUserDefaults.standardUserDefaults integerForKey:@"kitsu-userid"];
            return kitsuusername && kitsuid > 0;
        }
        case 3: {
            NSString *anilistusername = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-username"];
            int anilistid = (int)[NSUserDefaults.standardUserDefaults integerForKey:@"anilist-userid"];
            return anilistusername && anilistid > 0;
        }
        default: {
            break;
        }
    }
    return false;
}

- (void)retrieveownListWithType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [myanimelistManager retrieveOwnListWithType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [kitsuManager retrieveOwnLisWithType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager retrieveOwnListWithType:type completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)retrieveList:(NSString *)username listType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [myanimelistManager retrieveList:username listType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [kitsuManager retrieveList:username listType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager retrieveList:username listType:type completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)retrieveAiringSchedule:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // TODO: Mark for Removal
    /*
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList retrieveAiringSchedule:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [MyAnimeList retrieveAiringSchedule:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [MyAnimeList retrieveAiringSchedule:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }*/
}

- (void)searchTitle:(NSString *)searchterm withType:(int)type  withSearchOptions:(NSDictionary *)options completion:(void (^)(id responseObject, int nextoffset, bool hasnextpage)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [myanimelistManager searchTitle:searchterm withType:type withCurrentPage:0 completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [kitsuManager searchTitle:searchterm withType:type withSearchOptions:options completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager searchTitle:searchterm withType:type withCurrentPage:1  withSearchOptions:options completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)searchTitle:(NSString *)searchterm withType:(int)type withOffset:(int)offset  withSearchOptions:(NSDictionary *)options completion:(void (^)(id responseObject, int nextoffset, bool hasnextpage)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [myanimelistManager searchTitle:searchterm withType:type withCurrentPage:offset completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [kitsuManager searchTitle:searchterm withType:type withDataArray:[NSMutableArray new] withPageOffet:offset withMaxOffset:offset withSearchOptions:options completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager searchTitle:searchterm withType:type withCurrentPage:offset  withSearchOptions:options completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)advsearchTitle:(NSString *)searchterm withType:(int)type withGenres:(NSString *)genres excludeGenres:(bool)exclude startDate:(NSDate *)startDate endDate:(NSDate *)endDate minScore:(int)minscore rating:(int)rating withStatus:(int)status completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // TODO: Mark for removal
    /*
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList advsearchTitle:searchterm withType:type withGenres:genres excludeGenres:exclude startDate:startDate endDate:endDate minScore:minscore rating:rating withStatus:status completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
     */
}

- (void)retrieveTitleInfo:(int)titleid withType:(int)type useAccount:(bool)useAccount completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [myanimelistManager retrieveTitleInfo:titleid withType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [kitsuManager retrieveTitleInfo:titleid withType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager retrieveTitleInfo:titleid withType:type completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)retrieveReviewsForTitle:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [myanimelistManager retrieveReviewsForTitle:titleid withType:type withPage:1 completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [kitsuManager retrieveReviewsForTitle:titleid withType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager retrieveReviewsForTitle:titleid withType:type completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)retriveUpdateHistory:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // TODO: Mark for Removal
    switch ([self getCurrentServiceID]) {
        case 1: {
            //[MyAnimeList retriveUpdateHistory:username completion:completionHandler error:errorHandler];
            break;
        }
        case 2:
        case 3: {
            completionHandler(@[]);
            break;
        }
        default: {
            break;
        }
    }
}

- (bool)verifyAccount {
    // TODO: Mark for Removal, obsolete
    switch ([self getCurrentServiceID]) {
        case 1: {
            //return [MyAnimeList verifyAccount];
        }
        default: {
            break;
        }
    }
    return false;
}

- (void)verifyAccountWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    [self verifyAccountWithUsername:username password:password withServiceID:[self getCurrentServiceID] completion:completionHandler error:errorHandler];

}

- (void)verifyAccountWithUsername:(NSString *)username password:(NSString *)password withServiceID:(int)serviceid completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch (serviceid) {
        case 1: {
            [myanimelistManager verifyAccountWithPin:password completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [kitsuManager verifyAccountWithUsername:username password:password completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager verifyAccountWithPin:password completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)retrieveProfile:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [myanimelistManager retrieveProfile:username completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [kitsuManager retrieveProfile:username completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager retrieveProfile:username completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)addAnimeTitleToList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [myanimelistManager addAnimeTitleToList:titleid withEpisode:episode withStatus:status withScore:score completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [kitsuManager addAnimeTitleToList:titleid withEpisode:episode withStatus:status withScore:score completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager addAnimeTitleToList:titleid withEpisode:episode withStatus:status withScore:score completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)addMangaTitleToList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [myanimelistManager addMangaTitleToList:titleid withChapter:chapter withVolume:volume withStatus:status withScore:score completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [kitsuManager addMangaTitleToList:titleid withChapter:chapter withVolume:volume withStatus:status withScore:score completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager addMangaTitleToList:titleid withChapter:chapter withVolume:volume withStatus:status withScore:score completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)updateAnimeTitleOnList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score withExtraFields:(NSDictionary *)efields completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [myanimelistManager updateAnimeTitleOnList:titleid withEpisode:episode withStatus:status withScore:score withExtraFields:efields completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [kitsuManager updateAnimeTitleOnList:titleid withEpisode:episode withStatus:status withScore:score withExtraFields:efields completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager updateAnimeTitleOnList:titleid withEpisode:episode withStatus:status withScore:score withExtraFields:efields completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)updateMangaTitleOnList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score withExtraFields:(NSDictionary *)efields completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [myanimelistManager updateMangaTitleOnList:titleid withChapter:chapter withVolume:volume withStatus:status withScore:score withExtraFields:efields completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [kitsuManager updateMangaTitleOnList:titleid withChapter:chapter withVolume:volume withStatus:status withScore:score withExtraFields:efields completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager updateMangaTitleOnList:titleid withChapter:chapter withVolume:volume withStatus:status withScore:score withExtraFields:efields completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)removeTitleFromList:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [myanimelistManager removeTitleFromList:titleid withType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [kitsuManager removeTitleFromList:titleid withType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager removeTitleFromList:titleid withType:type completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)retrieveTitleIdsWithlistType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            break;
        }
        case 2: {
            [kitsuManager retrieveTitleIdsWithlistType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager retrieveTitleIdsWithlistType:type completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)retrievemessagelist:(int)page completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // TODO: Remove or Placeholder
    switch ([self getCurrentServiceID]) {
        case 1: {
            //[MyAnimeList retrievemessagelist:page completionHandler:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
        default: {
            break;
        }
    }
}

- (void)retrievemessage:(int)messageid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // TODO: Remove or Placeholder
    switch ([self getCurrentServiceID]) {
        case 1: {
            //[MyAnimeList retrievemessage:messageid completionHandler:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
        default: {
            break;
        }
    }
}

- (void)sendmessage:(NSString *)username withSubject:(NSString *)subject withMessage:(NSString *)message withthreadID:(int)threadid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // TODO: Remove or Placeholder
    switch ([self getCurrentServiceID]) {
        case 1: {
            //[MyAnimeList sendmessage:username withSubject:subject withMessage:message withthreadID:threadid completionHandler:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
        default: {
            break;
        }
    }
}

- (void)deletemessage:(int)messageid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    // TODO: Remove or Placeholder
    switch ([self getCurrentServiceID]) {
        case 1: {
            //[MyAnimeList deletemessage:messageid completionHandler:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
        default: {
            break;
        }
    }
}

- (void)retrieveStaff:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            // TODO: Implement via Jikan API
            [myanimelistManager retrieveStaff:titleid completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            //[kitsuManager retrieveStaff:titleid completion:completionHandler error:errorHandler];
            /*[kitsuManager retrieveTitleInfo:titleid withType:KitsuAnime completion:^(id responseObject) {
                [TitleIdConverter getMALIDFromKitsuId:titleid withTitle:responseObject[@"title"] titletype:responseObject[@"type"] withType:KitsuAnime completionHandler:^(int malid) {
                    [MyAnimeList retrieveStaff:malid completion:completionHandler error:errorHandler];
                } error:errorHandler];
            } error:^(NSError *error) {
                errorHandler(error);
            }];*/
            break;
        }
        case 3: {
            [anilistManager retrieveStaff:titleid withType:type completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}
- (void)retrievePersonDetails:(int)personid completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            // TODO: Implement via Jikan API
            [myanimelistManager retrievePersonDetails:personid completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            //[MyAnimeList retrievePersonDetails:personid completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            [anilistManager retrievePersonDetails:personid completion:completionHandler error:errorHandler];
            break;
        }
        default: {
            break;
        }
    }
}

- (NSString *)retrieveListFileName:(int)type {
    return [self retrieveListFileName:type withServiceID:[self getCurrentServiceID]];
}

- (NSString *)retrieveListFileName:(int)type withServiceID:(int)serviceid {
    NSDictionary *usernames = [self getAllUserNames];
    switch (serviceid) {
        case 1: {
            if (type == 0) {
                return [NSString stringWithFormat:@"mal-animelist-%@.json",usernames[@"myanimelist"]];
            }
            else if (type == 1) {
                return [NSString stringWithFormat:@"mal-mangalist-%@.json",usernames[@"myanimelist"]];
            }
            break;
        }
        case 2: {
            if (type == 0) {
                return [NSString stringWithFormat:@"kitsu-animelist-%@.json",usernames[@"kitsu"]];
            }
            else if (type == 1) {
                return [NSString stringWithFormat:@"kitsu-mangalist-%@.json",usernames[@"kitsu"]];
            }
            break;
        }
        case 3: {
            if (type == 0) {
                return [NSString stringWithFormat:@"anilist-animelist-%@.json",usernames[@"anilist"]];
            }
            else if (type == 1) {
                return [NSString stringWithFormat:@"anilist-mangalist-%@.json",usernames[@"anilist"]];
            }
            break;
        }
        default: {
            break;
        }
    }
    return @"";
}

- (id)retrieveHistoryFileName {
    return [self retrieveHistoryFileName:[self getCurrentServiceID]];
}

- (id)retrieveHistoryFileName:(int)serviceid {
    NSDictionary *usernames = [self getAllUserNames];
    switch (serviceid) {
        case 1: {
            return [NSString stringWithFormat:@"mal-history-%@.json",usernames[@"myanimelist"]];
        }
        case 2: {
            return [NSString stringWithFormat:@"kitsu-history-%@.json",usernames[@"kitsu"]];
        }
        case 3: {
            return [NSString stringWithFormat:@"anilist-history-%@.json",usernames[@"anilist"]];

        }
        default: {
            break;
        }
    }
    return @"";
}

- (bool)checkAccountForCurrentService {
    int service = [listservice.sharedInstance getCurrentServiceID];
    return ([OAuthCredManager.sharedInstance getFirstAccountForService:service]);
}

- (NSString *)getCurrentServiceUsername {
    switch ([self getCurrentServiceID]) {
        case 1:
            return [NSUserDefaults.standardUserDefaults valueForKey:@"mal-username"];
        case 2:
            return [NSUserDefaults.standardUserDefaults valueForKey:@"kitsu-username"];
        case 3:
            return [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-username"];
        default:
            break;
    }
    return @"";
}

- (NSDictionary *)getAllUserNames {
    NSString *kitsuusername = [NSUserDefaults.standardUserDefaults valueForKey:@"kitsu-username"];
    NSString *anilistusername = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-username"];
    NSString *malusername = [NSUserDefaults.standardUserDefaults valueForKey:@"mal-username"];
    return @{ @"myanimelist" : malusername && malusername.length > 0 ? malusername : [NSNull null], @"kitsu" : kitsuusername && kitsuusername.length > 0 ? kitsuusername : [NSNull null], @"anilist" : anilistusername && anilistusername.length > 0 ? anilistusername : [NSNull null] };
}

- (NSDictionary *)getAllUserID {
    int kitsuid = (int)[NSUserDefaults.standardUserDefaults integerForKey:@"kitsu-userid"];
    int anilistid = (int)[NSUserDefaults.standardUserDefaults integerForKey:@"anilist-userid"];
    int malid = (int)[NSUserDefaults.standardUserDefaults integerForKey:@"mal-userid"];
    return @{ @"myanimelist" : @(malid),  @"kitsu" : kitsuid > 0 ? @(kitsuid) : [NSNull null], @"anilist" :  anilistid > 0 ? @(anilistid) : [NSNull null]};
}


- (NSString *)currentservicename {
    switch ([self getCurrentServiceID]) {
        case 1:
            return @"MyAnimeList";
        case 2:
            return @"Kitsu";
        case 3:
            return @"AniList";
        default:
            break;
    }
    return @"";
}

- (int)getCurrentUserID {
    switch ([self getCurrentServiceID]) {
        case 1:
            return (int)[NSUserDefaults.standardUserDefaults integerForKey:@"mal-userid"];
        case 2:
            return (int)[NSUserDefaults.standardUserDefaults integerForKey:@"kitsu-userid"];
        case 3:
            return (int)[NSUserDefaults.standardUserDefaults integerForKey:@"anilist-userid"];
        default:
            return -1;
    }
}
- (NSString *)getCurrentUserAvatar {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    switch ([self getCurrentServiceID]) {
        case 1:
            return [defaults valueForKey:@"mal-avatar"];
        case 2:
            return [defaults valueForKey:@"kitsu-avatar"];
        case 3:
            return [defaults valueForKey:@"anilist-avatar"];
        default:
            return @"";
    }
}
@end
