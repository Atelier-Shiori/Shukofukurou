//
//  MyAnimeList.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/11.
//  Copyright © 2017年 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import <Foundation/Foundation.h>

@interface MyAnimeList : NSObject
typedef NS_ENUM(unsigned int, MediaType) {
    MALAnime = 0,
    MALManga = 1
};
+(void)retrieveList:(NSString *)username listType:(int)type completion:(void (^)(id responseObject)) completionHandler Error: (void (^)(NSError * error)) errorHandler;
+(void)searchTitle:(NSString *)searchterm withType:(int)type completion:(void (^)(id responseObject)) completionHandler Error: (void (^)(NSError * error)) errorHandler;
+(void)retrieveTitleInfo:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler Error: (void (^)(NSError * error)) errorHandler;
+(void)retriveUpdateHistory:(NSString *)username completion:(void (^)(id responseObject)) completionHandler Error: (void (^)(NSError * error)) errorHandler;
+(void)addAnimeTitleToList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler Error: (void (^)(NSError * error)) errorHandler;
+(void)addMangaTitleToList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler Error: (void (^)(NSError * error)) errorHandler;
+(void)updateAnimeTitleOnList:(int)titleid withEpisode:(int)episode withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler Error: (void (^)(NSError * error)) errorHandler;
+(void)updateMangaTitleOnList:(int)titleid withChapter:(int)chapter withVolume:(int)volume withStatus:(NSString *)status withScore:(int)score completion:(void (^)(id responseObject)) completionHandler Error: (void (^)(NSError * error)) errorHandler;
+(void)removeTitleFromList:(int)titleid withType:(int)type completion:(void (^)(id responseObject)) completionHandler Error: (void (^)(NSError * error)) errorHandler;
@end
