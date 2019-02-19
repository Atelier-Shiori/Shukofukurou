//
//  AtarashiiAPIListFormatAniList.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/03/27.
//  Copyright © 2018年 MAL Updater OS X Group. All rights reserved.
//

#import "AtarashiiAPIListFormatAniList.h"
#import "AtarashiiDataObjects.h"
#import "Utility.h"

@implementation AtarashiiAPIListFormatAniList
+ (id)AniListtoAtarashiiAnimeList:(id)data {
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *entry in data) {
        @autoreleasepool{
            // Prevent duplicates
            if ([tmparray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entryid == %i", ((NSNumber *)entry[@"entryid"]).intValue]].count > 0) {
                continue;
            }
            // Create the entry in a standardized format
            AtarashiiAnimeListObject *aentry = [AtarashiiAnimeListObject new];
            aentry.titleid = ((NSNumber *)entry[@"id"][@"id"]).intValue;
            aentry.entryid = ((NSNumber *)entry[@"entryid"]).intValue;
            aentry.title = entry[@"title"][@"title"][@"title"];
            aentry.episodes = entry[@"episodes"][@"episodes"] && entry[@"episodes"][@"episodes"] != [NSNull null] ? ((NSNumber *)entry[@"episodes"][@"episodes"]).intValue : 0;
            aentry.episode_length = (entry[@"duration"][@"duration"] && entry[@"duration"][@"duration"] != [NSNull null]) ? ((NSNumber *)entry[@"duration"][@"duration"]).intValue : 0;
            if (entry[@"image_url"][@"coverImage"] != [NSNull null]) {
                aentry.image_url = (entry[@"image_url"][@"coverImage"][@"large"] && entry[@"image_url"][@"coverImage"][@"large"] != [NSNull null] ) ? entry[@"image_url"][@"coverImage"][@"large"] : @"";
                
            }
            aentry.type = entry[@"type"][@"format"] != [NSNull null] ? [Utility convertAnimeType:entry[@"type"][@"format"]] : @"";
            aentry.status =  entry[@"status"][@"status"] != [NSNull null] ? entry[@"status"][@"status"] : @"NOT_YET_RELEASED";
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
            aentry.watching_start = entry[@"watching_start"][@"year"] != [NSNull null] && entry[@"watching_start"][@"month"] != [NSNull null] && entry[@"watching_start"][@"day"] != [NSNull null] ? [self convertDate:entry[@"watching_start"]] : @"";
            aentry.watching_end = entry[@"watching_end"][@"year"] != [NSNull null] && entry[@"watching_end"][@"month"] != [NSNull null] && entry[@"watching_end"][@"day"] != [NSNull null] ? [self convertDate:entry[@"watching_end"]] : @"";
            aentry.custom_lists = entry[@"customLists"] != [NSNull null] ? [self generateCustomListStringWithArray:entry[@"customLists"]] : @"";
            aentry.lastupdated = ((NSNumber *)entry[@"updatedAt"]).longValue;
            [tmparray addObject:[aentry NSDictionaryRepresentation]];
        }
    }
    return @{@"anime" : tmparray, @"statistics" : @{@"days" : @([Utility calculatedays:tmparray])}};
}

+ (id)AniListtoAtarashiiMangaList:(id)data {
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *entry in data) {
        @autoreleasepool{
            // Prevent duplicates
            if ([tmparray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entryid == %i", ((NSNumber *)entry[@"entryid"]).intValue]].count > 0) {
                continue;
            }
            // Create the entry in a standardized format
            AtarashiiMangaListObject *mentry = [AtarashiiMangaListObject new];
            mentry.titleid = ((NSNumber *)entry[@"id"][@"id"]).intValue;
            mentry.entryid = ((NSNumber *)entry[@"entryid"]).intValue;
            mentry.title = entry[@"title"][@"title"][@"title"];
            mentry.chapters = entry[@"chapters"][@"chapters"] && entry[@"chapters"][@"chapters"] != [NSNull null] ? ((NSNumber *)entry[@"chapters"][@"chapters"]).intValue : 0;
            mentry.volumes = entry[@"volumes"][@"volumes"] && entry[@"volumes"][@"volumes"] != [NSNull null] ? ((NSNumber *)entry[@"volumes"][@"volumes"]).intValue : 0;
            if (entry[@"image_url"][@"coverImage"] != [NSNull null]) {
                mentry.image_url = (entry[@"image_url"][@"coverImage"][@"large"] && entry[@"image_url"][@"coverImage"][@"large"] != [NSNull null] ) ? entry[@"image_url"][@"coverImage"][@"large"] : @"";
            }
            mentry.type = entry[@"type"][@"format"] != [NSNull null] ? [self convertMangaType:entry[@"type"][@"format"]] : @"";
            mentry.status = entry[@"status"][@"status"] != [NSNull null] ? entry[@"status"][@"status"] : @"NOT_YET_RELEASED";
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
            mentry.reread_count =  ((NSNumber *)entry[@"reread_count"]).intValue;
            mentry.private_entry =  ((NSNumber *)entry[@"private"]).boolValue;
            mentry.personal_comments = entry[@"notes"];
            mentry.reading_start = entry[@"read_start"][@"year"] != [NSNull null] && entry[@"read_start"][@"month"] != [NSNull null] && entry[@"read_start"][@"day"] != [NSNull null] ? [self convertDate:entry[@"read_start"]] : @"";
            mentry.reading_end = entry[@"read_end"][@"year"] != [NSNull null] && entry[@"read_end"][@"month"] != [NSNull null] && entry[@"read_end"][@"day"] != [NSNull null] ?  [self convertDate:entry[@"read_end"]] : @"";
            mentry.custom_lists = entry[@"customLists"] != [NSNull null] ? [self generateCustomListStringWithArray:entry[@"customLists"]] : @"";
            mentry.lastupdated = ((NSNumber *)entry[@"updatedAt"]).longValue;
            [tmparray addObject:[mentry NSDictionaryRepresentation]];
        }
    }
    return @{@"manga" : tmparray, @"statistics" : @{@"days" : @(0)}};
}

+ (NSDictionary *)AniListAnimeInfotoAtarashii:(NSDictionary *)data {
    AtarashiiAnimeObject *aobject = [AtarashiiAnimeObject new];
    NSDictionary *title = data[@"data"][@"Media"];
    aobject.titleid = ((NSNumber *)title[@"id"]).intValue;
    aobject.title = title[@"title"][@"romaji"];
    // Create other titles
    aobject.other_titles = @{@"synonyms" : title[@"synonyms"] && title[@"synonyms"] != [NSNull null] ? title[@"synonyms"] : @[]  , @"english" : title[@"title"][@"english"] != [NSNull null] && title[@"title"][@"english"] ? @[title[@"title"][@"english"]] : @[], @"japanese" : title[@"title"][@"native"] != [NSNull null] && title[@"title"][@"native"] ? @[title[@"title"][@"native"]] : @[] };
    aobject.popularity_rank = title[@"popularity"] != [NSNull null] ? ((NSNumber *)title[@"popularity"]).intValue : 0;
    #if defined(AppStore)
    if (title[@"coverImage"] != [NSNull null]) {
        aobject.image_url = title[@"coverImage"][@"large"] && title[@"coverImage"] != [NSNull null] && !((NSNumber *)title[@"isAdult"]).boolValue ? title[@"coverImage"][@"large"] : @"";
    }
    aobject.synposis = !((NSNumber *)title[@"isAdult"]).boolValue ? title[@"description"] != [NSNull null] ? title[@"description"] : @"No synopsis available" : @"Synopsis not available for adult titles";
    #else
    bool allowed = ([NSUserDefaults.standardUserDefaults boolForKey:@"showadult"] || !((NSNumber *)title[@"isAdult"]).boolValue);
    if (title[@"coverImage"] != [NSNull null]) {
        aobject.image_url = title[@"coverImage"][@"large"] && title[@"coverImage"] != [NSNull null] && title[@"coverImage"][@"large"] && allowed ?  title[@"coverImage"][@"large"] : @"";
    }
    aobject.synposis = allowed ? title[@"description"] != [NSNull null] ? title[@"description"] : @"No synopsis available" : @"Synopsis not available for adult titles";
    #endif
    aobject.type = title[@"format"] != [NSNull null] ? [Utility convertAnimeType:title[@"format"]] : @"";
    aobject.episodes = title[@"episodes"] && title[@"episodes"] != [NSNull null] ? ((NSNumber *)title[@"episodes"]).intValue : 0;
    aobject.start_date = title[@"startDate"] != [NSNull null] ? [NSString stringWithFormat:@"%@-%@-%@",title[@"startDate"][@"year"],title[@"startDate"][@"month"],title[@"startDate"][@"day"]] : @"";
    aobject.end_date = title[@"endDate"] != [NSNull null] ? [NSString stringWithFormat:@"%@-%@-%@",title[@"endDate"][@"year"],title[@"endDate"][@"month"],title[@"endDate"][@"day"]] : @"";
    aobject.duration = title[@"duration"] && title[@"duration"] != [NSNull null] ? ((NSNumber *)title[@"duration"]).intValue : 0;
    aobject.classification = @"";
    aobject.hashtag = title[@"hashtag"] != [NSNull null] ? title[@"hashtag"] : @"";
    aobject.season = title[@"season"] != [NSNull null] ? ((NSString *)title[@"season"]).capitalizedString : @"Unknown";
    aobject.source = title[@"source"] != [NSNull null] ? [(NSString *)title[@"source"] stringByReplacingOccurrencesOfString:@"_" withString:@" "].capitalizedString : @"";
    aobject.members_score = title[@"averageScore"] != [NSNull null] ? ((NSNumber *)title[@"averageScore"]).floatValue : 0;
    NSString *tmpstatus  = title[@"status"] != [NSNull null] ? title[@"status"] : @"NOT_YET_RELEASED";
    if ([tmpstatus isEqualToString:@"FINISHED"]||[tmpstatus isEqualToString:@"CANCELLED"]) {
        tmpstatus = @"finished airing";
    }
    else if ([tmpstatus isEqualToString:@"RELEASING"]) {
        tmpstatus = @"currently airing";
    }
    else if ([tmpstatus isEqualToString:@"NOT_YET_RELEASED"]) {
        tmpstatus = @"not yet aired";
    }
    aobject.status = tmpstatus;
    NSMutableArray *genres = [NSMutableArray new];
    for (NSString *genre in title[@"genres"]) {
        [genres addObject:genre];
    }
    aobject.genres = genres;
    NSMutableArray *studiosarray = [NSMutableArray new];
    if (title[@"studios"] != [NSNull null]) {
        for (NSDictionary *studio in title[@"studios"][@"edges"]) {
            [studiosarray addObject:studio[@"node"][@"name"]];
        }
    }
    aobject.producers = studiosarray;
    if (title[@"idMal"]) {
        aobject.mappings = @{@"myanimelist/anime" : title[@"idMal"]};
    }
    NSMutableArray *mangaadaptations = [NSMutableArray new];
    for (NSDictionary *adpt in [(NSArray *)title[@"relations"][@"edges"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"relationType == %@", @"ADAPTATION"]]) {
        if ([(NSString *)adpt[@"node"][@"type"] isEqualToString:@"MANGA"]) {
            [mangaadaptations addObject: @{@"manga_id": adpt[@"node"][@"id"], @"title" : adpt[@"node"][@"title"][@"romaji"]}];
        }
    }
    NSMutableArray *sidestories = [NSMutableArray new];
    for (NSDictionary *side in [(NSArray *)title[@"relations"][@"edges"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"relationType == %@", @"SIDE_STORY"]]) {
        if ([(NSString *)side[@"node"][@"type"] isEqualToString:@"ANIME"]) {
            [sidestories addObject: @{@"anime_id": side[@"node"][@"id"], @"title" : side[@"node"][@"title"][@"romaji"]}];
        }
    }
    NSMutableArray *sequels = [NSMutableArray new];
    for (NSDictionary *sequel in [(NSArray *)title[@"relations"][@"edges"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"relationType == %@", @"SEQUEL"]]) {
        if ([(NSString *)sequel[@"node"][@"type"] isEqualToString:@"ANIME"]) {
            [sequels addObject: @{@"anime_id": sequel[@"node"][@"id"], @"title" : sequel[@"node"][@"title"][@"romaji"]}];
        }
    }
    NSMutableArray *prequels = [NSMutableArray new];
    for (NSDictionary *prequel in [(NSArray *)title[@"relations"][@"edges"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"relationType == %@", @"PREQUEL"]]) {
        if ([(NSString *)prequel[@"node"][@"type"] isEqualToString:@"ANIME"]) {
            [prequels addObject: @{@"anime_id": prequel[@"node"][@"id"], @"title" : prequel[@"node"][@"title"][@"romaji"]}];
        }
    }
    aobject.manga_adaptations = mangaadaptations;
    aobject.side_stories = sidestories;
    aobject.sequels = sequels;
    aobject.prequels = prequels;

    return aobject.NSDictionaryRepresentation;
}

+ (NSDictionary *)AniListMangaInfotoAtarashii:(NSDictionary *)data {
    AtarashiiMangaObject *mobject = [AtarashiiMangaObject new];
    NSDictionary *title = data[@"data"][@"Media"];
    mobject.titleid = ((NSNumber *)title[@"id"]).intValue;
    mobject.title = title[@"title"][@"romaji"];
    // Create other titles
    mobject.other_titles = @{@"synonyms" : title[@"synonyms"] && title[@"synonyms"] != [NSNull null] ? title[@"synonyms"] : @[] , @"english" : title[@"title"][@"english"] != [NSNull null] && title[@"title"][@"english"] ? @[title[@"title"][@"english"]] : @[], @"japanese" : title[@"title"][@"native"] != [NSNull null] && title[@"title"][@"native"] ? @[title[@"title"][@"native"]] : @[] };
    mobject.popularity_rank = title[@"popularity"] != [NSNull null] ? ((NSNumber *)title[@"popularity"]).intValue : 0;
#if defined(AppStore)
    if (title[@"coverImage"] != [NSNull null]) {
        mobject.image_url = title[@"coverImage"][@"large"] && title[@"coverImage"] != [NSNull null] && !((NSNumber *)title[@"isAdult"]).boolValue ? title[@"coverImage"][@"large"] : @"";
    }
    mobject.synposis = !((NSNumber *)title[@"isAdult"]).boolValue ? title[@"description"] != [NSNull null] ? title[@"description"] : @"No synopsis available" : @"Synopsis not available for adult titles";
#else
    bool allowed = ([NSUserDefaults.standardUserDefaults boolForKey:@"showadult"] || !((NSNumber *)title[@"isAdult"]).boolValue);
    if (title[@"coverImage"] != [NSNull null]) {
        mobject.image_url = title[@"coverImage"][@"large"] && title[@"coverImage"] != [NSNull null] && title[@"coverImage"][@"large"] && allowed ?  title[@"coverImage"][@"large"] : @"";
    }
    mobject.synposis = allowed ? title[@"description"] != [NSNull null] ? title[@"description"] : @"No synopsis available" : @"Synopsis not available for adult titles";
#endif
    mobject.type = title[@"format"] != [NSNull null] ? [self convertMangaType:title[@"format"]] : @"";
    mobject.chapters = title[@"chapters"] != [NSNull null] ? ((NSNumber *)title[@"chapters"]).intValue : 0;
    mobject.volumes = title[@"volumes"] != [NSNull null] ? ((NSNumber *)title[@"volumes"]).intValue : 0;
    mobject.members_score = title[@"averageScore"] != [NSNull null] ? ((NSNumber *)title[@"averageScore"]).floatValue : 0;
    NSString *tmpstatus  = title[@"status"] != [NSNull null] ? title[@"status"] : @"NOT_YET_RELEASED";
    if ([tmpstatus isEqualToString:@"FINISHED"]||[tmpstatus isEqualToString:@"CANCELLED"]) {
        tmpstatus = @"finished";
    }
    else if ([tmpstatus isEqualToString:@"RELEASING"]) {
        tmpstatus = @"publishing";
    }
    else if ([tmpstatus isEqualToString:@"NOT_YET_RELEASED"]) {
        tmpstatus = @"not yet published";
    }
    mobject.status = tmpstatus;
    NSMutableArray *genres = [NSMutableArray new];
    for (NSString *genre in title[@"genres"]) {
        [genres addObject:genre];
    }
    mobject.genres = genres;
    if (title[@"idMal"]) {
        mobject.mappings = @{@"myanimelist/manga" : title[@"idMal"]};
    }
    NSMutableArray *animeadaptations = [NSMutableArray new];
    for (NSDictionary *adpt in [(NSArray *)title[@"relations"][@"edges"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"relationType == %@", @"ADAPTATION"]]) {
        if ([(NSString *)adpt[@"node"][@"type"] isEqualToString:@"ANIME"]) {
            [animeadaptations addObject: @{@"anime_id": adpt[@"node"][@"id"], @"title" : adpt[@"node"][@"title"][@"romaji"]}];
        }
    }
    NSMutableArray *alternativestories = [NSMutableArray new];
    for (NSDictionary *alt in [(NSArray *)title[@"relations"][@"edges"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"relationType == %@", @"ALTERNATIVE"]]) {
        if ([(NSString *)alt[@"node"][@"type"] isEqualToString:@"MANGA"]) {
            [alternativestories addObject: @{@"manga_id": alt[@"node"][@"id"], @"title" : alt[@"node"][@"title"][@"romaji"]}];
        }
    }
    mobject.anime_adaptations = animeadaptations;
    mobject.alternative_versions = alternativestories;
    
    return mobject.NSDictionaryRepresentation;
}

+ (NSArray *)AniListAnimeSearchtoAtarashii:(NSDictionary *)data {
    NSArray *dataarray = data[@"data"][@"Page"][@"media"];
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *d in dataarray) {
        @autoreleasepool {
#if defined(AppStore)
            if (((NSNumber *)d[@"isAdult"]).boolValue) {
                continue;
            }
#else
            if (((NSNumber *)d[@"isAdult"]).boolValue && ![NSUserDefaults.standardUserDefaults boolForKey:@"showadult"]) {
                continue;
            }
#endif
            AtarashiiAnimeObject *aobject = [AtarashiiAnimeObject new];
            aobject.titleid = ((NSNumber *)d[@"id"]).intValue;
            aobject.title = d[@"title"][@"romaji"];
            aobject.other_titles = @{@"synonyms" : d[@"synonyms"] && d[@"synonyms"] != [NSNull null] ? d[@"synonyms"] : @[] , @"english" : d[@"title"][@"english"] != [NSNull null] && d[@"title"][@"english"] ? @[d[@"title"][@"english"]] : @[], @"japanese" : d[@"title"][@"native"] != [NSNull null] && d[@"title"][@"native"] ? @[d[@"title"][@"native"]] : @[] };
            if (d[@"coverImage"] != [NSNull null]) {
                aobject.image_url = d[@"coverImage"] != [NSNull null] ? d[@"coverImage"][@"large"] : @"";
            }
            aobject.status = d[@"status"] != [NSNull null] ? d[@"status"] : @"NOT_YET_RELEASED";
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
            aobject.type = d[@"format"] != [NSNull null] ? [Utility convertAnimeType:d[@"format"]] : @"";
            [tmparray addObject:aobject.NSDictionaryRepresentation];
        }
    }
    return tmparray;
}

+ (NSArray *)AniListMangaSearchtoAtarashii:(NSDictionary *)data {
    NSArray *dataarray = data[@"data"][@"Page"][@"media"];
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *d in dataarray) {
        @autoreleasepool {
#if defined(AppStore)
            if (((NSNumber *)d[@"isAdult"]).boolValue) {
                continue;
            }
#else
            if (((NSNumber *)d[@"isAdult"]).boolValue && ![NSUserDefaults.standardUserDefaults boolForKey:@"showadult"]) {
                continue;
            }
#endif
            AtarashiiMangaObject *mobject = [AtarashiiMangaObject new];
            mobject.titleid = ((NSNumber *)d[@"id"]).intValue;
            mobject.title = d[@"title"][@"romaji"];
            mobject.other_titles = @{@"synonyms" : d[@"synonyms"] && d[@"synonyms"] != [NSNull null] ? d[@"synonyms"] : @[]  , @"english" : d[@"title"][@"english"] != [NSNull null] && d[@"title"][@"english"] ? @[d[@"title"][@"english"]] : @[], @"japanese" : d[@"title"][@"native"] != [NSNull null] && d[@"title"][@"native"] ? @[d[@"title"][@"native"]] : @[] };
            if (d[@"coverImage"] != [NSNull null]) {
                mobject.image_url = d[@"coverImage"] != [NSNull null] ? d[@"coverImage"][@"large"] : @"";
            }
            mobject.status = d[@"status"] != [NSNull null] ? d[@"status"] : @"NOT_YET_RELEASED";
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
            mobject.type = d[@"format"] != [NSNull null] ? [self convertMangaType:d[@"format"]] : @"";
            [tmparray addObject:mobject.NSDictionaryRepresentation];
        }
    }
    return tmparray;
}

+ (NSArray *)AniListReviewstoAtarashii:(NSArray *)reviews withType:(int)type {
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *review in reviews) {
        @autoreleasepool {
            AtarashiiReviewObject *nreview = [AtarashiiReviewObject new];
            nreview.mediatype = type;
            nreview.date = [Utility dateIntervalToDateString:((NSNumber *)review[@"createdAt"]).doubleValue];
            nreview.rating = ((NSNumber *)review[@"score"]).intValue;
            nreview.helpful = ((NSNumber *)review[@"rating"]).intValue;
            nreview.helpful_total = ((NSNumber *)review[@"rating"]).intValue;
            nreview.avatar_url = review[@"user"][@"avatar"] != [NSNull null] && review[@"user"][@"avatar"][@"large"] ? review[@"user"][@"avatar"][@"large"] : @"";
            nreview.review = review[@"body"];
            nreview.actual_username = review[@"user"][@"name"];
            nreview.username = nreview.actual_username;
            [tmparray addObject:nreview.NSDictionaryRepresentation];
        }
    }
    return tmparray;
}

+ (NSDictionary *)AniListUserProfiletoAtarashii:(NSDictionary *)userdata {
    AtarashiiUserObject *uobject = [AtarashiiUserObject new];
    uobject.avatar_url = userdata[@"avatar"][@"large"];
    uobject.extradict = @{@"about" : userdata[@"about"], @"following" : userdata[@"isFollowing"], @"scoreFormat" : userdata[@"mediaListOptions"][@"scoreFormat"]};
    return uobject.NSDictionaryRepresentation;
}

+ (NSDictionary *)generateStaffList:(NSArray *)staffarray withCharacterArray:(NSArray *)characterarray withType:(NSString *)type {
    // Generate character list
    int mediatype = [type isEqualToString:@"ANIME"] ? 0: 1;
    NSMutableArray *tmpcharacterarray = [NSMutableArray new];
    for (NSDictionary *acharacter in characterarray) {
        @autoreleasepool {
            NSNumber *characterid = acharacter[@"node"][@"id"];
            NSString *role = ((NSString *)acharacter[@"role"]).lowercaseString.capitalizedString;
            NSString *charactername = acharacter[@"node"][@"name"][@"last"] != [NSNull null] && ((NSString *)acharacter[@"node"][@"name"][@"last"]).length > 0 && acharacter[@"node"][@"name"][@"first"] != [NSNull null] && ((NSString *)acharacter[@"node"][@"name"][@"first"]).length > 0 ? [NSString stringWithFormat:@"%@, %@",acharacter[@"node"][@"name"][@"last"],acharacter[@"node"][@"name"][@"first"]] : acharacter[@"node"][@"name"][@"first"] != [NSNull null] && ((NSString *)acharacter[@"node"][@"name"][@"first"]).length > 0 ? acharacter[@"node"][@"name"][@"first"] : acharacter[@"node"][@"name"][@"last"];
            NSString *description = acharacter[@"node"][@"description"] != [NSNull null] ? acharacter[@"node"][@"description"] : @"No character description provided";
            NSString *imageurl = acharacter[@"node"][@"image"] != [NSNull null] && acharacter[@"node"][@"image"][@"large"] ? acharacter[@"node"][@"image"][@"large"] : @"";
            NSMutableArray *castingsarray = [NSMutableArray new];
            if (mediatype == 0) {
                for (NSDictionary *va in acharacter[@"voiceActors"]) {
                    [castingsarray addObject:@{@"id" : va[@"id"], @"name" : va[@"name"][@"last"] != [NSNull null] && ((NSString *)va[@"name"][@"last"]).length > 0 ? [NSString stringWithFormat:@"%@, %@",va[@"name"][@"last"],va[@"name"][@"first"]] : va[@"name"][@"first"], @"image" : va[@"image"] != [NSNull null] && va[@"image"][@"large"] ? va[@"image"][@"large"] : @"" , @"language" : ((NSString *)va[@"language"]).lowercaseString.capitalizedString}];
                }
            }
            [tmpcharacterarray addObject:@{@"id" : characterid.copy, @"name" : charactername.copy, @"role" : role.copy, @"image" : imageurl.copy, @"description" : description.copy,  @"actors" : castingsarray.copy}];
        }
    }
    // Generate staff list
    NSMutableArray *tmpstaffarray = [NSMutableArray new];
    
    for (NSDictionary *staffmember in staffarray) {
        @autoreleasepool {
            NSNumber *personid = staffmember[@"person"][@"id"];
            NSString *personname = staffmember[@"person"][@"name"][@"last"] != [NSNull null] && ((NSString *)staffmember[@"person"][@"name"][@"last"]).length > 0 ? [NSString stringWithFormat:@"%@, %@",staffmember[@"person"][@"name"][@"last"],staffmember[@"person"][@"name"][@"first"]] : staffmember[@"person"][@"name"][@"first"];
            NSString *imageurl = staffmember[@"person"][@"image"] != [NSNull null] && staffmember[@"person"][@"image"][@"large"] ? staffmember[@"person"][@"image"][@"large"] : @"";
            NSString *role = @"";
            if ([tmpstaffarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name ==[c] %@", personname]].count == 0) {
                [tmpstaffarray addObject:@{@"id" : personid.copy, @"name" : personname.copy, @"image" : imageurl.copy, @"role" : role.copy}];
            }
        }
    }
    NSDictionary *finaldict = @{@"Characters" : tmpcharacterarray.copy, @"Staff" : tmpstaffarray.copy};
    // Clear Arrays
    return finaldict;
}

+ (NSDictionary *)AniListPersontoAtarashii:(NSDictionary *)person {
    AtarashiiPersonObject *personobj = [AtarashiiPersonObject new];
    personobj.personid = ((NSNumber *)person[@"id"]).intValue;
    personobj.name = person[@"name"][@"last"] != [NSNull null] && ((NSString *)person[@"name"][@"last"]).length > 0 ? [NSString stringWithFormat:@"%@, %@",person[@"name"][@"last"],person[@"name"][@"first"]] : person[@"name"][@"first"];
    personobj.image_url = person[@"image"] != [NSNull null] && person[@"image"][@"large"] ? person[@"image"][@"large"] : @"";
    personobj.native_name = person[@"name"][@"native"] && person[@"name"][@"native"] != [NSNull null] ? person[@"name"][@"native"] : @"";
    personobj.more_details = person[@"description"] != [NSNull null] ? person[@"description"] : @"";
    personobj.favorited_count = person[@"favourites"] != [NSNull null] ? ((NSNumber *)person[@"favourites"]).intValue : 0;
    personobj.language = person[@"language"] != [NSNull null] ? ((NSString *)person[@"language"]).capitalizedString : @"";
    NSMutableArray *staffroles = [NSMutableArray new];
    NSMutableArray *mangaroles = [NSMutableArray new];
    for (NSDictionary *staffrole in person[@"staffMedia"][@"edges"]) {
        @autoreleasepool {
            NSString *type = staffrole[@"node"][@"type"];
            if ([type isEqualToString:@"ANIME"]) {
                AtarrashiiStaffObject *srole = [AtarrashiiStaffObject new];
                srole.position = staffrole[@"staffRole"];
                srole.anime = @{@"id" : staffrole[@"node"][@"id"], @"title" : staffrole[@"node"][@"title"][@"romaji"], @"image_url" : staffrole[@"node"][@"coverImage"] != [NSNull null] && staffrole[@"node"][@"coverImage"][@"large"] ? staffrole[@"node"][@"coverImage"][@"large"] : @""};
                [staffroles addObject:srole.NSDictionaryRepresentation];
            }
            else {
                AtarashiiPublishedMangaObject *pmrole = [AtarashiiPublishedMangaObject new];
                pmrole.position = staffrole[@"staffRole"];
                pmrole.manga = @{@"id" : staffrole[@"node"][@"id"], @"title" : staffrole[@"node"][@"title"][@"romaji"], @"image_url" : staffrole[@"node"][@"coverImage"] != [NSNull null] && staffrole[@"node"][@"coverImage"][@"large"] ? staffrole[@"node"][@"coverImage"][@"large"] : @""};
                [mangaroles addObject:pmrole.NSDictionaryRepresentation];
            }
        }
    }
    personobj.anime_staff_positions = staffroles;
    personobj.published_manga = mangaroles;
    NSMutableArray *characterroles = [NSMutableArray new];
    for (NSDictionary *characterrole in person[@"characters"][@"edges"]) {
        @autoreleasepool {
            AtarashiiVoiceActingRoleObject *vaobj = [AtarashiiVoiceActingRoleObject new];
            vaobj.characterid = ((NSNumber *)characterrole[@"node"][@"id"]).intValue;
            vaobj.name = characterrole[@"node"][@"name"][@"last"] != [NSNull null] && ((NSString *)characterrole[@"node"][@"name"][@"last"]).length > 0 ? [NSString stringWithFormat:@"%@, %@",characterrole[@"node"][@"name"][@"last"],characterrole[@"node"][@"name"][@"first"]] : characterrole[@"node"][@"name"][@"first"];
            vaobj.image_url = characterrole[@"node"][@"image"] != [NSNull null] && characterrole[@"node"][@"image"][@"large"] ? characterrole[@"node"][@"image"][@"large"] : @"";
            vaobj.main_role = [(NSString *)characterrole[@"role"] isEqualToString:@"MAIN"];
            for (NSDictionary *anime in characterrole[@"media"]) {
                vaobj.anime = @{@"id" : anime[@"id"], @"title" : anime[@"title"][@"romaji"]};
                [characterroles addObject:vaobj.NSDictionaryRepresentation];
            }
        }
    }
    personobj.voice_acting_roles = characterroles;
    return personobj.NSDictionaryRepresentation;
}

+ (NSDictionary *)AniListCharactertoAtarashii:(NSDictionary *)person {
    AtarashiiPersonObject *personobj = [AtarashiiPersonObject new];
    personobj.personid = ((NSNumber *)person[@"id"]).intValue;
    personobj.name = person[@"name"][@"last"] != [NSNull null] && ((NSString *)person[@"name"][@"last"]).length > 0 ? [NSString stringWithFormat:@"%@, %@",person[@"name"][@"last"],person[@"name"][@"first"]] : person[@"name"][@"first"];
    personobj.image_url = person[@"image"] != [NSNull null] && person[@"image"][@"large"] ? person[@"image"][@"large"] : @"";
    personobj.native_name = person[@"name"][@"native"] && person[@"name"][@"native"] != [NSNull null] ? person[@"name"][@"native"] : @"";
    personobj.more_details = person[@"description"] != [NSNull null] ? person[@"description"] : @"";
    personobj.favorited_count = person[@"favourites"] != [NSNull null] ? ((NSNumber *)person[@"favourites"]).intValue : 0;
    NSMutableArray *voiceactors = [NSMutableArray new];
    NSMutableArray *animeappearences = [NSMutableArray new];
    NSMutableArray *mangaappearences = [NSMutableArray new];
    if (person[@"media"][@"edges"] && person[@"media"][@"edges"] != [NSNull null]) {
        for (NSDictionary *media in person[@"media"][@"edges"]) {
            NSDictionary *mediainfo = @{@"id" : media[@"node"][@"id"], @"title" : media[@"node"][@"title"][@"romaji"], @"image" :  media[@"node"][@"coverImage"] != [NSNull null] && media[@"node"][@"coverImage"][@"large"] ? media[@"node"][@"coverImage"][@"large"] : @"", @"role" : ((NSString *)media[@"characterRole"]).capitalizedString};
            if ([(NSString *)media[@"node"][@"type"] isEqualToString:@"ANIME"]) {
                [animeappearences addObject:mediainfo];
                for (NSDictionary *va in media[@"voiceActors"]) {
                    @autoreleasepool {
                        if ([voiceactors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", va[@"id"]]].count == 0) {
                               [voiceactors addObject:@{@"id" : va[@"id"], @"name" : va[@"name"][@"last"] != [NSNull null] && ((NSString *)va[@"name"][@"last"]).length > 0 ? [NSString stringWithFormat:@"%@, %@",va[@"name"][@"last"],va[@"name"][@"first"]] : va[@"name"][@"first"], @"image" : va[@"image"] != [NSNull null] && va[@"image"][@"large"] ? va[@"image"][@"large"] : @"" , @"language" : ((NSString *)va[@"language"]).lowercaseString.capitalizedString}];
                        }
                    }
                }
            }
            else {
                [mangaappearences addObject:mediainfo];
            }
        }
    }
    personobj.appeared_anime = animeappearences.copy;
    personobj.appeared_manga = mangaappearences.copy;
    personobj.voice_actors = voiceactors;
    return personobj.NSDictionaryRepresentation;
}

+ (NSArray *)normalizePersonSearchData:(id)searchdata {
    // Generate staff list
    NSMutableArray *tmpstaffarray = [NSMutableArray new];
    if (searchdata[@"data"][@"Page"] != [NSNull null] && searchdata[@"data"][@"Page"]) {
        NSArray *dataarray = searchdata[@"data"][@"Page"][@"staff"] ? searchdata[@"data"][@"Page"][@"staff"] : searchdata[@"data"][@"Page"][@"characters"];
        for (NSDictionary *staffmember in dataarray) {
            @autoreleasepool {
                NSNumber *personid = staffmember[@"id"];
                NSString *personname = staffmember[@"name"][@"last"] != [NSNull null] && ((NSString *)staffmember[@"name"][@"last"]).length > 0 ? [NSString stringWithFormat:@"%@, %@",staffmember[@"name"][@"last"],staffmember[@"name"][@"first"]] : staffmember[@"name"][@"first"];
                NSString *imageurl = staffmember[@"image"] != [NSNull null] && staffmember[@"image"][@"large"] ? staffmember[@"image"][@"large"] : @"";
                NSString *role = @"";
                if ([tmpstaffarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name ==[c] %@", personname]].count == 0) {
                    [tmpstaffarray addObject:@{@"id" : personid.copy, @"name" : personname.copy, @"image" : imageurl.copy, @"role" : role.copy}];
                }
            }
        }
    }
    return tmpstaffarray.copy;
}

+ (NSArray *)normalizeSeasonData:(NSArray *)seasonData withSeason:(NSString *)season withYear:(int)year {
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *d in seasonData) {
        @autoreleasepool {
            if (((NSNumber *)d[@"isAdult"]).boolValue) {
                continue;
            }
            AtarashiiAnimeObject *aobject = [AtarashiiAnimeObject new];
            aobject.titleid = ((NSNumber *)d[@"id"]).intValue;
            aobject.titleidMal = d[@"idMal"] != [NSNull null] ? ((NSNumber *)d[@"idMal"]).intValue : 0;
            aobject.title = d[@"title"][@"romaji"];
            aobject.other_titles = @{@"synonyms" : d[@"synonyms"] && d[@"synonyms"] != [NSNull null] ? d[@"synonyms"] : @[] , @"english" : d[@"title"][@"english"] != [NSNull null] && d[@"title"][@"english"] ? @[d[@"title"][@"english"]] : @[], @"japanese" : d[@"title"][@"native"] != [NSNull null] && d[@"title"][@"native"] ? @[d[@"title"][@"native"]] : @[] };
            if (d[@"coverImage"] != [NSNull null]) {
                aobject.image_url = d[@"coverImage"] != [NSNull null] ? d[@"coverImage"][@"large"] : @"";
            }
            aobject.type = d[@"format"] != [NSNull null] ? [Utility convertAnimeType:d[@"format"]] : @"";
            NSMutableDictionary *finaldict = [[NSMutableDictionary alloc] initWithDictionary:aobject.NSDictionaryRepresentation];
            finaldict[@"year"] = @(year);
            finaldict[@"season"] = season;
            finaldict[@"service"] = @(3);
            [tmparray addObject:finaldict.copy];
        }
    }
    return tmparray.copy;
}

+ (NSArray *)normalizeAiringData:(NSArray *)airdata {
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *d in airdata) {
        @autoreleasepool {
            if (((NSNumber *)d[@"isAdult"]).boolValue) {
                continue;
            }
            AtarashiiAnimeObject *aobject = [AtarashiiAnimeObject new];
            aobject.titleid = ((NSNumber *)d[@"id"]).intValue;
            aobject.titleidMal = d[@"idMal"] != [NSNull null] ? ((NSNumber *)d[@"idMal"]).intValue : 0;
            aobject.title = d[@"title"][@"romaji"];
            aobject.other_titles = @{@"synonyms" : d[@"synonyms"] && d[@"synonyms"] != [NSNull null] ? d[@"synonyms"] : @[] , @"english" : d[@"title"][@"english"] != [NSNull null] && d[@"title"][@"english"] ? @[d[@"title"][@"english"]] : @[], @"japanese" : d[@"title"][@"native"] != [NSNull null] && d[@"title"][@"native"] ? @[d[@"title"][@"native"]] : @[] };
            if (d[@"coverImage"] != [NSNull null]) {
                aobject.image_url = d[@"coverImage"] != [NSNull null] ? d[@"coverImage"][@"large"] : @"";
            }
            aobject.episodes = d[@"episodes"] && d[@"episodes"] != [NSNull null] ? ((NSNumber *)d[@"episodes"]).intValue : 0;
            aobject.type = d[@"format"] != [NSNull null] ? [Utility convertAnimeType:d[@"format"]] : @"";
            aobject.status = @"currently airing";
            NSMutableDictionary *finaldictionary = [[NSMutableDictionary alloc] initWithDictionary:[aobject NSDictionaryRepresentation]];
            if (d[@"nextAiringEpisode"] != [NSNull null]) {
                switch ([self getDayFromDateInterval:((NSNumber *)d[@"nextAiringEpisode"][@"airingAt"]).intValue]) {
                    case 1:
                        //Sunday
                        finaldictionary[@"day"] = @"sunday";
                        break;
                    case 2:
                        //Monday
                        finaldictionary[@"day"] = @"monday";
                        break;
                    case 3:
                        //Tuesday
                        finaldictionary[@"day"] = @"tuesday";
                        break;
                    case 4:
                        //Wednesday
                        finaldictionary[@"day"] = @"wednesday";
                        break;
                    case 5:
                        //Thursday
                        finaldictionary[@"day"] = @"thursday";
                        break;
                    case 6:
                        //Friday
                        finaldictionary[@"day"] = @"friday";
                        break;
                    case 7:
                        //Saturday
                        finaldictionary[@"day"] = @"saturday";
                        break;
                    default:
                        break;
                        
                }
            }
            else {
               finaldictionary[@"day"] = @"unknown";
            }
            [tmparray addObject:finaldictionary.copy];
        }
    }
    return tmparray.copy;
}

#pragma mark helpers

+ (NSString *)convertMangaType:(NSString *)type {
    NSString *tmpstr = type.lowercaseString;
    tmpstr = [tmpstr stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    tmpstr = tmpstr.capitalizedString;
    return tmpstr;
}

+ (NSString *)convertDate:(NSDictionary *)date {
    NSString *tmpyear = ((NSNumber *)date[@"year"]).stringValue;
    NSString *tmpmonth = ((NSNumber *)date[@"month"]).stringValue;
    NSString *tmpday = ((NSNumber *)date[@"day"]).stringValue;
    if (tmpmonth.intValue < 10) {
        tmpmonth = [@"0" stringByAppendingString:tmpmonth];
    }
    if (tmpday.intValue < 10) {
        tmpday = [@"0" stringByAppendingString:tmpday];
    }
    return [NSString stringWithFormat:@"%@-%@-%@", tmpyear, tmpmonth, tmpday];
}

+ (NSString *)generateCustomListStringWithArray:(NSArray *)clists {
    NSMutableArray *customlists = [NSMutableArray new];
    for (NSDictionary *clist in clists) {
        NSString *clistname = clist[@"name"];
        bool enabled = ((NSNumber *)clist[@"enabled"]).boolValue;
        NSString *finalstring = [NSString stringWithFormat:@"%@[%@]",clistname, enabled ? @"true" : @"false"];
        [customlists addObject:finalstring];
    }
    return [customlists componentsJoinedByString:@"||"];
}

+ (NSArray *)generateIDArrayWithType:(int)type withIdArray:(NSArray *)idarray {
    // Converts AniList output into a cleaner array of ids
    NSString *typestr = @"";
    if (type == 0) {
        typestr = @"anime";
    }
    else {
        typestr = @"manga";
    }
    NSMutableArray *tmplist = [NSMutableArray new];
    for (NSDictionary *identry in idarray) {
        if (identry[@"idMal"] != [NSNull null]) {
            [tmplist addObject:@{[NSString stringWithFormat:@"anilist/%@",typestr] : identry[@"id"][@"id"], [NSString stringWithFormat:@"myanimelist/%@",typestr] : identry[@"id"][@"idMal"]}];
        }
    }
    return tmplist.copy;
}

+ (long)getDayFromDateInterval:(int)dateinterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateinterval];
    NSDateComponents *component = [NSCalendar.currentCalendar components:NSCalendarUnitWeekday fromDate:date];
    return component.weekday;
}
@end
