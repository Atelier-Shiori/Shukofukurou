//
//  AniList.h
//  Shukofukurou
//
//  Created by 小鳥遊六花 on 3/31/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFOAuthCredential;

@interface AniList : NSObject


typedef NS_ENUM(unsigned int, AniListMediaType) {
    AniListAnime = 0,
    AniListManga = 1
};

typedef NS_ENUM(unsigned int, AniListPersonType) {
    AniListCharacter = 0,
    AniLisStaff = 1
};

+ (void)retrieveList:(NSString *)username listType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)searchTitle:(NSString *)searchterm withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)searchPeople:(NSString *)searchterm withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveTitleInfo:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveReviewsForTitle:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (bool)tokenexpired;
+ (void)verifyAccountWithPin:(NSString *)pin completion:(void (^)(id responseObject))completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveProfile:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)addAnimeTitleToList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)addMangaTitleToList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)updateAnimeTitleOnList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score withExtraFields:(NSDictionary *)efields completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)updateMangaTitleOnList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score withExtraFields:(NSDictionary *)efields completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)removeTitleFromList:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveTitleIdsWithlistType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)modifyCustomLists:(int)titleid withCustomLists:(NSArray *)customlists completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveStaff:(int)titleid completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrievePersonDetails:(int)personid completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveCharacterDetails:(int)characterid completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (AFOAuthCredential *)getFirstAccount;
+ (bool)removeAccount;
+ (void)getOwnAnilistid:(void (^)(int userid, NSString *username, NSString *scoreformat, NSString *avatar)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)getAniListUserid:(NSString *)username completion:(void (^)(int userid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)getUserRatingType:(void (^)(NSString *scoretype)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)saveuserinfoforcurrenttoken;
@end
