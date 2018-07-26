//
//  AtarashiiAPIListFormatAniList.h
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/03/27.
//  Copyright © 2018年 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AtarashiiAPIListFormatAniList : NSObject
+ (id)AniListtoAtarashiiAnimeList:(id)data;
+ (id)AniListtoAtarashiiMangaList:(id)data;
+ (NSDictionary *)AniListAnimeInfotoAtarashii:(NSDictionary *)data;
+ (NSDictionary *)AniListMangaInfotoAtarashii:(NSDictionary *)data;
+ (NSArray *)AniListAnimeSearchtoAtarashii:(NSDictionary *)data;
+ (NSArray *)AniListMangaSearchtoAtarashii:(NSDictionary *)data;
+ (NSArray *)AniListReviewstoAtarashii:(NSArray *)reviews withType:(int)type;
+ (NSDictionary *)AniListUserProfiletoAtarashii:(NSDictionary *)userdata;
+ (NSDictionary *)generateStaffList:(NSArray *)staffarray withCharacterArray:(NSArray *)characterarray;
+ (NSDictionary *)AniListPersontoAtarashii:(NSDictionary *)person;
+ (NSArray *)normalizeSeasonData:(NSArray *)seasonData;
+ (NSArray *)generateIDArrayWithType:(int)type withIdArray:(NSArray *)idarray;
@end
