//
//  AtarashiiAPIListFormatMAL.h
//  Hakuchou
//
//  Created by 香風智乃 on 8/23/19.
//  Copyright © 2019 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AtarashiiAPIListFormatMAL : NSObject
+ (id)MALtoAtarashiiAnimeList:(id)data;
+ (id)MALtoAtarashiiMangaList:(id)data;
+ (NSDictionary *)MALAnimeInfotoAtarashii:(NSDictionary *)data;
+ (NSDictionary *)MALMangaInfotoAtarashii:(NSDictionary *)data;
+ (NSArray *)MALAnimeSearchtoAtarashii:(NSDictionary *)data;
+ (NSArray *)MALMangaSearchtoAtarashii:(NSDictionary *)data;
+ (NSArray *)normalizeSeasonData:(NSArray *)seasonData withSeason:(NSString *)season withYear:(int)year;
+ (NSDictionary *)MalUsertoAtarashii:(NSDictionary *)userdata;
@end

NS_ASSUME_NONNULL_END
