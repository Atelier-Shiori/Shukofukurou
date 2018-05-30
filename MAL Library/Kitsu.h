//
//  Kitsu.h
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/12/14.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFOAuthCredential;
@interface Kitsu : NSObject
typedef NS_ENUM(unsigned int, KitsuMediaType) {
    KitsuAnime = 0,
    KitsuManga = 1
};
typedef NS_ENUM(unsigned int, ratingType){
    ratingSimple = 0,
    ratingStandard = 1,
    ratingAdvanced = 2
};
+ (void)retrieveList:(NSString *)username listType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveOwnLisWithType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;;
+ (void)searchTitle:(NSString *)searchterm withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveTitleInfo:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveReviewsForTitle:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (bool)tokenexpired;
+ (void)refreshToken:(void (^)(bool success))completion ;
+ (void)verifyAccountWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(id responseObject))completionHandler error:(void (^)(NSError * error)) errorHandlerr;
+ (void)retrieveProfile:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)addAnimeTitleToList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)addMangaTitleToList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)updateAnimeTitleOnList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score withExtraFields:(NSDictionary *)efields completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)updateMangaTitleOnList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score withExtraFields:(NSDictionary *)efields completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)removeTitleFromList:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveStaff:(int)titleid completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrievePersonDetails:(int)personid completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (AFOAuthCredential *)getFirstAccount;
+ (bool)removeAccount;
+ (void)getOwnKitsuid:(void (^)(int userid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)getKitsuid:(NSString *)username completion:(void (^)(int userid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)getUserRatingType:(void (^)(int scoretype)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)saveuserinfoforcurrenttoken;
@end
