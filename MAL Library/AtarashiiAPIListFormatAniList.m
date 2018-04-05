//
//  AtarashiiAPIListFormatAniList.m
//  MAL Library
//
//  Created by 天々座理世 on 2018/03/27.
//  Copyright © 2018年 Atelier Shiori. All rights reserved.
//

#import "AtarashiiAPIListFormatAniList.h"
#import "AtarashiiDataObjects.h"
#import "Utility.h"

@implementation AtarashiiAPIListFormatAniList
+ (id)AniListtoAtarashiiAnimeList:(id)data {
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *entry in data) {
        @autoreleasepool{
            AtarashiiAnimeListObject *aentry = [AtarashiiAnimeListObject new];
            aentry.titleid = ((NSNumber *)entry[@"id"][@"id"]).intValue;
            aentry.entryid = ((NSNumber *)entry[@"entryid"]).intValue;
            aentry.title = entry[@"title"][@"title"][@"title"];
            aentry.episodes = entry[@"episodes"][@"episodes"] != [NSNull null] ? ((NSNumber *)entry[@"episodes"][@"episodes"]).intValue : 0;
            aentry.episode_length = ((NSNumber *)entry[@"duration"][@"duration"]).intValue;
            aentry.image_url = (entry[@"image_url"][@"coverImage"][@"large"] && entry[@"image_url"][@"coverImage"][@"large"] != [NSNull null] ) ? entry[@"image_url"][@"coverImage"][@"large"] : @"";
            aentry.type = entry[@"type"][@"format"];
            aentry.status = entry[@"status"][@"status"];
            if ([aentry.status isEqualToString:@"FINISHED"]||[aentry.status isEqualToString:@"CANCELLED"]) {
                aentry.status = @"finished airing";
            }
            else if ([aentry.status isEqualToString:@"RELEASING"]) {
                aentry.status = @"currently airing";
            }
            else if ([aentry.status isEqualToString:@"NOT_YET_RELEASED"]) {
                aentry.status = @"not yet aired";
            }
            aentry.score = ((NSNumber *)entry[@"score"]).intValue;
            aentry.watched_episodes = ((NSNumber *)entry[@"watched_episodes"]).intValue;
            if ([(NSString *)entry[@"watched_status"] isEqualToString:@"PAUSED"]) {
                aentry.watched_status = @"on-hold";
            }
            else if ([(NSString *)entry[@"watched_status"] isEqualToString:@"PLANNING"]) {
                aentry.watched_status = @"plan to watch";
            }
            else if ([(NSString *)entry[@"watched_status"] isEqualToString:@"CURRENT"]) {
                aentry.watched_status = @"watching";
            }
            else if ([(NSString *)entry[@"watched_status"] isEqualToString:@"REPEATING"]) {
                aentry.watched_status = @"watching";
                aentry.rewatching = true;
            }
            else {
                aentry.watched_status = ((NSString *)entry[@"watched_status"]).lowercaseString;
            }
            aentry.rewatch_count =  ((NSNumber *)entry[@"rewatch_count"]).intValue;
            aentry.private_entry =  ((NSNumber *)entry[@"private"]).boolValue;
            aentry.personal_comments = entry[@"notes"];
            aentry.watching_start = entry[@"watching_start"][@"year"] != [NSNull null] && entry[@"watching_start"][@"year"] != [NSNull null] && entry[@"watching_start"][@"year"] != [NSNull null] ? [NSString stringWithFormat:@"%@-%@-%@",entry[@"watching_start"][@"year"],entry[@"watching_start"][@"month"],entry[@"watching_start"][@"day"]] : @"";
            aentry.watching_end = entry[@"watching_end"][@"year"] != [NSNull null] && entry[@"watching_end"][@"year"] != [NSNull null] && entry[@"watching_end"][@"year"] != [NSNull null] ? [NSString stringWithFormat:@"%@-%@-%@",entry[@"watching_end"][@"year"],entry[@"watching_end"][@"month"],entry[@"watching_end"][@"day"]] : @"";
            [tmparray addObject:[aentry NSDictionaryRepresentation]];
        }
    }
    return @{@"anime" : tmparray, @"statistics" : @{@"days" : @([Utility calculatedays:tmparray])}};
}
+ (id)AniListtoAtarashiiMangaList:(id)data {
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *entry in data) {
        @autoreleasepool{
            AtarashiiMangaListObject *mentry = [AtarashiiMangaListObject new];
            mentry.titleid = ((NSNumber *)entry[@"id"][@"id"]).intValue;
            mentry.entryid = ((NSNumber *)entry[@"entryid"]).intValue;
            mentry.title = entry[@"title"][@"title"][@"title"];
            mentry.chapters = entry[@"chapters"][@"chapters"] != [NSNull null] ? ((NSNumber *)entry[@"chapters"][@"chapters"]).intValue : 0;
            mentry.volumes = entry[@"volumes"][@"volumes"] != [NSNull null] ? ((NSNumber *)entry[@"volumes"][@"volumes"]).intValue : 0;
            mentry.image_url = (entry[@"image_url"][@"coverImage"][@"large"] && entry[@"image_url"][@"coverImage"][@"large"] != [NSNull null] ) ? entry[@"image_url"][@"coverImage"][@"large"] : @"";
            mentry.type = entry[@"type"][@"format"];
            mentry.status = entry[@"status"][@"status"];
            if ([mentry.status isEqualToString:@"FINISHED"]||[mentry.status isEqualToString:@"CANCELLED"]) {
                mentry.status = @"finished";
            }
            else if ([mentry.status isEqualToString:@"RELEASING"]) {
                mentry.status = @"publishing";
            }
            else if ([mentry.status isEqualToString:@"NOT_YET_RELEASED"]) {
                mentry.status = @"not yet published";
            }
            mentry.score = ((NSNumber *)entry[@"score"]).intValue;
            mentry.chapters_read = ((NSNumber *)entry[@"read_chapters"]).intValue;
            mentry.volumes_read = ((NSNumber *)entry[@"read_volumes"]).intValue;
            if ([(NSString *)entry[@"read_status"] isEqualToString:@"PAUSED"]) {
                mentry.read_status = @"on-hold";
            }
            else if ([(NSString *)entry[@"read_status"] isEqualToString:@"PLANNING"]) {
                mentry.read_status = @"plan to read";
            }
            else if ([(NSString *)entry[@"read_status"] isEqualToString:@"CURRENT"]) {
                mentry.read_status = @"reading";
            }
            else if ([(NSString *)entry[@"read_status"] isEqualToString:@"REPEATING"]) {
                mentry.read_status = @"reading";
                mentry.rereading = true;
            }
            else {
                mentry.read_status = ((NSString *)entry[@"read_status"]).lowercaseString;
            }
            mentry.reread_count =  ((NSNumber *)entry[@"rewatch_count"]).intValue;
            mentry.private_entry =  ((NSNumber *)entry[@"private"]).boolValue;
            mentry.personal_comments = entry[@"notes"];
            mentry.reading_start = entry[@"read_start"][@"year"] != [NSNull null] && entry[@"read_start"][@"year"] != [NSNull null] && entry[@"read_start"][@"year"] != [NSNull null] ? [NSString stringWithFormat:@"%@-%@-%@",entry[@"read_start"][@"year"],entry[@"read_start"][@"month"],entry[@"read_start"][@"day"]] : @"";
            mentry.reading_end = entry[@"read_end"][@"year"] != [NSNull null] && entry[@"read_end"][@"year"] != [NSNull null] && entry[@"read_end"][@"year"] != [NSNull null] ? [NSString stringWithFormat:@"%@-%@-%@",entry[@"read_end"][@"year"],entry[@"read_end"][@"month"],entry[@"read_end"][@"day"]] : @"";
            [tmparray addObject:[mentry NSDictionaryRepresentation]];
        }
    }
    return @{@"manga" : tmparray, @"statistics" : @{@"days" : @(0)}};
}

+ (NSArray *)AniListAnimeSearchtoAtarashii:(NSDictionary *)data {
    NSArray *dataarray = data[@"data"][@"page"][@"media"];
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *d in dataarray) {
        @autoreleasepool {
            AtarashiiAnimeObject *aobject = [AtarashiiAnimeObject new];
            aobject.titleid = ((NSNumber *)d[@"id"]).intValue;
            aobject.title = d[@"title"][@"userPreferred"];
            aobject.image_url = d[@"coverImage"] != [NSNull null] ? d[@"coverImage"][@"large"] : @"";
            aobject.status = d[@"status"];
            if ([aobject.status isEqualToString:@"FINISHED"]||[aobject.status isEqualToString:@"CANCELLED"]) {
                aobject.status = @"finished airing";
            }
            else if ([aobject.status isEqualToString:@"RELEASING"]) {
                aobject.status = @"currently airing";
            }
            else if ([aobject.status isEqualToString:@"NOT_YET_RELEASED"]) {
                aobject.status = @"not yet aired";
            }
            aobject.episodes = d[@"episodes"] != [NSNull null] ? ((NSNumber *)d[@"episodes"]).intValue : 0;
            aobject.type = d[@"format"];
            [tmparray addObject:aobject.NSDictionaryRepresentation];
        }
    }
    return tmparray;
}

+ (NSArray *)AniListMangaSearchtoAtarashii:(NSDictionary *)data {
    NSArray *dataarray = data[@"data"][@"page"][@"media"];
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *d in dataarray) {
        @autoreleasepool {
            AtarashiiMangaObject *mobject = [AtarashiiMangaObject new];
            mobject.titleid = ((NSNumber *)d[@"id"]).intValue;
            mobject.title = d[@"title"][@"userPreferred"];
            mobject.image_url = d[@"coverImage"] != [NSNull null] ? d[@"coverImage"][@"large"] : @"";
            mobject.status = d[@"status"];
            if ([mobject.status isEqualToString:@"FINISHED"]||[mobject.status isEqualToString:@"CANCELLED"]) {
                mobject.status = @"finished";
            }
            else if ([mobject.status isEqualToString:@"RELEASING"]) {
                mobject.status = @"publishing";
            }
            else if ([mobject.status isEqualToString:@"NOT_YET_RELEASED"]) {
                mobject.status = @"not yet published";
            }
            mobject.chapters = d[@"chapters"] != [NSNull null] ? ((NSNumber *)d[@"chapters"]).intValue : 0;
            mobject.volumes = d[@"volumes"] != [NSNull null] ? ((NSNumber *)d[@"volumes"]).intValue : 0;
            mobject.type = d[@"format"];
            [tmparray addObject:mobject.NSDictionaryRepresentation];
        }
    }
    return tmparray;
}
@end
