//
//  MyAnimeList.h
//  Shukofukurou
//
//  Created by 天々座理世 on 2017/04/11.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved. Licensed under 3-clause BSD License
//

#import <Foundation/Foundation.h>

@interface MyAnimeList : NSObject
typedef NS_ENUM(unsigned int, MediaType) {
    MALAnime = 0,
    MALManga = 1
};
+ (void)retrieveList:(NSString *)username listType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveAiringSchedule:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)searchTitle:(NSString *)searchterm withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)advsearchTitle:(NSString *)searchterm withType:(int)type withGenres:(NSString *)genres excludeGenres:(bool)exclude startDate:(NSDate *)startDate endDate:(NSDate *)endDate minScore:(int)minscore rating:(int)rating withStatus:(int)status completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveTitleInfo:(int)titleid withType:(int)type useAccount:(bool)useAccount completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveReviewsForTitle:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retriveUpdateHistory:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (bool)verifyAccount;
+ (void)verifyAccountWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveProfile:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)addAnimeTitleToList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)addMangaTitleToList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)updateAnimeTitleOnList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score withTags:(NSString *)tags withExtraFields:(NSDictionary *)efields completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)updateMangaTitleOnList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score withTags:(NSString *)tags withExtraFields:(NSDictionary *)efields completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)removeTitleFromList:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrievemessagelist:(int)page completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrievemessage:(int)messageid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)sendmessage:(NSString *)username withSubject:(NSString *)subject withMessage:(NSString *)message withthreadID:(int)threadid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)deletemessage:(int)messageid completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrieveStaff:(int)titleid completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)retrievePersonDetails:(int)personid completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
@end
