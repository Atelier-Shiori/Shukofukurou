//
//  AtarashiiAPIListFormatKitsu.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/12/18.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KitsuListRetriever;

@interface AtarashiiAPIListFormatKitsu: NSObject
+ (NSDictionary *)KitsutoAtarashiiAnimeList: (KitsuListRetriever *)retriever;
+ (NSDictionary *)KitsutoAtarashiiMangaList: (KitsuListRetriever *)retriever;
+ (NSDictionary *)KitsuAnimeInfotoAtarashii:(NSDictionary *)data;
+ (NSDictionary *)KitsuMangaInfotoAtarashii:(NSDictionary *)data;
+ (NSArray *)KitsuAnimeSearchtoAtarashii:(NSDictionary *)data;
+ (NSArray *)KitsuMangaSearchtoAtarashii:(NSDictionary *)data;
@end
