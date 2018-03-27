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
@end
