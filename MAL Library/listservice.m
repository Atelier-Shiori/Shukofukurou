//
//  listservice.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/12/14.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "listservice.h"
#import "Keychain.h"

@implementation listservice
/* Note: Current Service type will be specified as the following:
         1. MyAnimeList
         2. Kitsu
         3. AniList */
+ (int)getCurrentServiceID {
    return (int)[NSUserDefaults.standardUserDefaults integerForKey:@"currentservice"];
}
+ (void)retrieveList:(NSString *)username listType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList retrieveList:username listType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [Kitsu retrieveList:username listType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            break;
        }
    }
    
}
+ (void)retrieveAiringSchedule:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
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
    }
}
+ (void)searchTitle:(NSString *)searchterm withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList searchTitle:searchterm withType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)advsearchTitle:(NSString *)searchterm withType:(int)type withGenres:(NSString *)genres excludeGenres:(bool)exclude startDate:(NSDate *)startDate endDate:(NSDate *)endDate minScore:(int)minscore rating:(int)rating withStatus:(int)status completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList advsearchTitle:searchterm withType:type withGenres:genres excludeGenres:exclude startDate:startDate endDate:endDate minScore:minscore rating:rating withStatus:status completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)retrieveTitleInfo:(int)titleid withType:(int)type useAccount:(bool)useAccount completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList retrieveTitleInfo:titleid withType:type useAccount:useAccount completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [Kitsu retrieveTitleInfo:titleid withType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)retrieveReviewsForTitle:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList retrieveReviewsForTitle:titleid withType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)retriveUpdateHistory:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList retriveUpdateHistory:username completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (bool)verifyAccount {
    switch ([self getCurrentServiceID]) {
        case 1: {
            return [MyAnimeList verifyAccount];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
    return false;
}
+ (void)verifyAccountWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    [self verifyAccountWithUsername:username password:password withServiceID:[self getCurrentServiceID] completion:completionHandler error:errorHandler];

}
+ (void)verifyAccountWithUsername:(NSString *)username password:(NSString *)password withServiceID:(int)serviceid completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch (serviceid) {
        case 1: {
            [MyAnimeList verifyAccountWithUsername:username password:password completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            [Kitsu verifyAccountWithUsername:username password:password completion:completionHandler error:errorHandler];
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)retrieveProfile:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList retrieveProfile:username completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)addAnimeTitleToList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList addAnimeTitleToList:titleid withEpisode:episode withStatus:status withScore:score completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)addMangaTitleToList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList addMangaTitleToList:titleid withChapter:chapter withVolume:volume withStatus:status withScore:score completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)updateAnimeTitleOnList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score withTags:(NSString *)tags completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList updateAnimeTitleOnList:titleid withEpisode:episode withStatus:status withScore:score withTags:tags completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)updateMangaTitleOnList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score withTags:(NSString *)tags completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList updateMangaTitleOnList:titleid withChapter:chapter withVolume:volume withStatus:status withScore:score withTags:tags completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)removeTitleFromList:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList removeTitleFromList:titleid withType:type completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)retrievemessagelist:(int)page completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList retrievemessagelist:page completionHandler:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)retrievemessage:(int)messageid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList retrievemessage:messageid completionHandler:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)sendmessage:(NSString *)username withSubject:(NSString *)subject withMessage:(NSString *)message withthreadID:(int)threadid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList sendmessage:username withSubject:subject withMessage:message withthreadID:threadid completionHandler:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)deletemessage:(int)messageid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList deletemessage:messageid completionHandler:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)retrieveStaff:(int)titleid completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList retrieveStaff:titleid completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (void)retrievePersonDetails:(int)personid completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    switch ([self getCurrentServiceID]) {
        case 1: {
            [MyAnimeList retrievePersonDetails:personid completion:completionHandler error:errorHandler];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
}
+ (NSString *)retrieveListFileName:(int)type {
    return [self retrieveListFileName:type withServiceID:[self getCurrentServiceID]];
}
+ (NSString *)retrieveListFileName:(int)type withServiceID:(int)serviceid {
    switch (serviceid) {
        case 1: {
            if (type == 0) {
                return @"mal-animelist.json";
            }
            else if (type == 1) {
                return @"mal-mangalist.json";
            }
            break;
        }
        case 2: {
            if (type == 0) {
                return @"kitsu-animelist.json";
            }
            else if (type == 1) {
                return @"kitsu-mangalist.json";
            }
            break;
        }
        case 3: {
            if (type == 0) {
                return @"anilist-animelist.json";
            }
            else if (type == 1) {
                return @"anilist-mangalist.json";
            }
            break;
        }
    }
    return @"";
}
+ (id)retrieveHistoryFileName {
    return [self retrieveHistoryFileName:[self getCurrentServiceID]];
}
+ (id)retrieveHistoryFileName:(int)serviceid {
    switch (serviceid) {
        case 1: {
            return @"mal-history.json";
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
    }
    return @"";
}
+ (bool)checkAccountForCurrentService {
    int service = [listservice getCurrentServiceID];
    if ((![Keychain checkaccount] && service == 1) || (![Kitsu getFirstAccount] && service == 2)) {
        return false;
    }
    return true;
}
+ (NSString *)getCurrentServiceUsername {
    switch ([self getCurrentServiceID]) {
        case 1:
            return [Keychain getusername];
        case 2:
            return [NSUserDefaults.standardUserDefaults valueForKey:@"kitsu-username"];
        default:
            break;
    }
    return @"";
}
@end
