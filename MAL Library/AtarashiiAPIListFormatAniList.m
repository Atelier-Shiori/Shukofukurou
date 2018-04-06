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
            // Prevent duplicates
            if ([tmparray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entryid == %i", ((NSNumber *)entry[@"entryid"]).intValue]].count > 0) {
                continue;
            }
            // Create the entry in a standardized format
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
            // Prevent duplicates
            if ([tmparray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entryid == %i", ((NSNumber *)entry[@"entryid"]).intValue]].count > 0) {
                continue;
            }
            // Create the entry in a standardized format
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
+ (NSDictionary *)AniListAnimeInfotoAtarashii:(NSDictionary *)data {
    AtarashiiAnimeObject *aobject = [AtarashiiAnimeObject new];
    NSDictionary *title = data[@"data"][@"Media"];
    aobject.titleid = ((NSNumber *)title[@"id"]).intValue;
    aobject.title = title[@"title"][@"romaji"];
    // Create other titles
    aobject.other_titles = @{@"synonyms" : title[@"synonyms"] , @"english" : title[@"title"][@"english"] != [NSNull null] && title[@"title"][@"english"] ? @[title[@"title"][@"english"]] : @[], @"japanese" : title[@"title"][@"native"] != [NSNull null] && title[@"title"][@"native"] ? @[title[@"title"][@"native"]] : @[] };
    aobject.popularity_rank = title[@"popularity"] != [NSNull null] ? ((NSNumber *)title[@"popularity"]).intValue : 0;
    aobject.image_url = title[@"coverImage"][@"large"] && title[@"coverImage"] != [NSNull null] && !((NSNumber *)title[@"isAdult"]).boolValue ? title[@"coverImage"][@"large"] : @"";
    aobject.type = title[@"format"];
    aobject.episodes = title[@"episodes"] != [NSNull null] ? ((NSNumber *)title[@"episodes"]).intValue : 0;
    aobject.start_date = title[@"startDate"] != [NSNull null] ? [NSString stringWithFormat:@"%@-%@-%@",title[@"startDate"][@"year"],title[@"startDate"][@"month"],title[@"startDate"][@"day"]] : @"";
    aobject.end_date = title[@"endDate"] != [NSNull null] ? [NSString stringWithFormat:@"%@-%@-%@",title[@"endDate"][@"year"],title[@"endDate"][@"month"],title[@"endDate"][@"day"]] : @"";
    aobject.duration = title[@"duration"] != [NSNull null] ? ((NSNumber *)title[@"duration"]).intValue : 0;
    aobject.classification = @"";
    aobject.synposis = !((NSNumber *)title[@"isAdult"]).boolValue ? title[@"description"] : @"Synopsis not available for adult titles";
    aobject.members_score = title[@"averageScore"] != [NSNull null] ? ((NSNumber *)title[@"averageScore"]).floatValue : 0;
    NSString *tmpstatus = title[@"status"];
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
    mobject.other_titles = @{@"synonyms" : title[@"synonyms"] , @"english" : title[@"title"][@"english"] != [NSNull null] && title[@"title"][@"english"] ? @[title[@"title"][@"english"]] : @[], @"japanese" : title[@"title"][@"native"] != [NSNull null] && title[@"title"][@"native"] ? @[title[@"title"][@"native"]] : @[] };
    mobject.popularity_rank = title[@"popularity"] != [NSNull null] ? ((NSNumber *)title[@"popularity"]).intValue : 0;
    mobject.image_url = title[@"coverImage"][@"large"] && title[@"coverImage"] != [NSNull null] && !((NSNumber *)title[@"isAdult"]).boolValue ? title[@"coverImage"][@"large"] : @"";
    mobject.type = title[@"format"];
    mobject.chapters = title[@"chapters"] != [NSNull null] ? ((NSNumber *)title[@"chapters"]).intValue : 0;
    mobject.volumes = title[@"volumes"] != [NSNull null] ? ((NSNumber *)title[@"volumes"]).intValue : 0;
    mobject.synposis = !((NSNumber *)title[@"isAdult"]).boolValue ? title[@"description"] : @"Synopsis not available for adult titles";
    mobject.members_score = title[@"averageScore"] != [NSNull null] ? ((NSNumber *)title[@"averageScore"]).floatValue : 0;
    NSString *tmpstatus = title[@"status"];
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
            AtarashiiAnimeObject *aobject = [AtarashiiAnimeObject new];
            aobject.titleid = ((NSNumber *)d[@"id"]).intValue;
            aobject.title = d[@"title"][@"romaji"];
            aobject.other_titles = @{@"synonyms" : d[@"synonyms"] , @"english" : d[@"title"][@"english"] != [NSNull null] && d[@"title"][@"english"] ? @[d[@"title"][@"english"]] : @[], @"japanese" : d[@"title"][@"native"] != [NSNull null] && d[@"title"][@"native"] ? @[d[@"title"][@"native"]] : @[] };
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
    NSArray *dataarray = data[@"data"][@"Page"][@"media"];
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *d in dataarray) {
        @autoreleasepool {
            AtarashiiMangaObject *mobject = [AtarashiiMangaObject new];
            mobject.titleid = ((NSNumber *)d[@"id"]).intValue;
            mobject.title = d[@"title"][@"romaji"];
            mobject.other_titles = @{@"synonyms" : d[@"synonyms"] , @"english" : d[@"title"][@"english"] != [NSNull null] && d[@"title"][@"english"] ? @[d[@"title"][@"english"]] : @[], @"japanese" : d[@"title"][@"native"] != [NSNull null] && d[@"title"][@"native"] ? @[d[@"title"][@"native"]] : @[] };
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
+ (NSDictionary *)generateStaffList:(NSArray *)staffarray withCharacterArray:(NSArray *)characterarray {
    // Generate character list
    NSMutableArray *tmpcharacterarray = [NSMutableArray new];
    for (NSDictionary *acharacter in characterarray) {
        @autoreleasepool {
            NSNumber *characterid = acharacter[@"node"][@"id"];
            NSString *role = ((NSString *)acharacter[@"role"]).lowercaseString.capitalizedString;
            NSString *charactername = acharacter[@"node"][@"name"][@"last"] != [NSNull null] ? [NSString stringWithFormat:@"%@, %@",acharacter[@"node"][@"name"][@"last"],acharacter[@"node"][@"name"][@"first"]] : acharacter[@"node"][@"name"][@"first"];
            NSString *description = acharacter[@"node"][@"description"] != [NSNull null] ? acharacter[@"node"][@"description"] : @"No character description provided";
            NSString *imageurl = acharacter[@"node"][@"image"] != [NSNull null] && acharacter[@"node"][@"image"][@"large"] ? acharacter[@"node"][@"image"][@"large"] : @"";
            NSMutableArray *castingsarray = [NSMutableArray new];
            for (NSDictionary *va in acharacter[@"voiceActors"]) {
                [castingsarray addObject:@{@"id" : va[@"id"], @"name" : va[@"name"][@"last"] != [NSNull null] ? [NSString stringWithFormat:@"%@, %@", va[@"name"][@"last"], va[@"name"][@"first"]] : va[@"name"][@"first"], @"image" : va[@"image"] != [NSNull null] && va[@"image"][@"large"] ? va[@"image"][@"large"] : @"" , @"language" : va[@"language"]}];
            }
            [tmpcharacterarray addObject:@{@"id" : characterid.copy, @"name" : charactername.copy, @"role" : role.copy, @"image" : imageurl.copy, @"description" : description.copy,  @"actors" : castingsarray.copy}];
        }
    }
    // Generate staff list
    NSMutableArray *tmpstaffarray = [NSMutableArray new];
    
    for (NSDictionary *staffmember in staffarray) {
        @autoreleasepool {
            NSNumber *personid = staffmember[@"person"][@"id"];
            NSString *personname = staffmember[@"person"][@"name"][@"last"] != [NSNull null] ? [NSString stringWithFormat:@"%@, %@",staffmember[@"person"][@"name"][@"last"],staffmember[@"person"][@"name"][@"first"]] : staffmember[@"person"][@"name"][@"first"];
            NSString *imageurl = staffmember[@"person"][@"image"] != [NSNull null] && staffmember[@"person"][@"image"][@"large"] ? staffmember[@"person"][@"image"][@"large"] : @"";
            NSString *role = @"";
            [tmpstaffarray addObject:@{@"id" : personid.copy, @"name" : personname.copy, @"image" : imageurl.copy, @"role" : role.copy}];
        }
    }
    NSDictionary *finaldict = @{@"Characters" : tmpcharacterarray.copy, @"Staff" : tmpstaffarray.copy};
    // Clear Arrays
    return finaldict;
}

+ (NSDictionary *)AniListPersontoAtarashii:(NSDictionary *)person {
    AtarashiiPersonObject *personobj = [AtarashiiPersonObject new];
    personobj.personid = ((NSNumber *)person[@"id"]).intValue;
    personobj.name = person[@"name"][@"last"] != [NSNull null] ? [NSString stringWithFormat:@"%@, %@", person[@"name"][@"last"], person[@"name"][@"first"]] : person[@"name"][@"first"];
    personobj.image_url = person[@"image"] != [NSNull null] && person[@"image"][@"large"] ? person[@"image"][@"large"] : @"";
    personobj.native_name = person[@"name"][@"native"] && person[@"name"][@"native"] != [NSNull null] ? person[@"name"][@"native"] : @"";
    personobj.more_details = person[@"description"] != [NSNull null] ? person[@"description"] : @"";
    NSMutableArray *staffroles = [NSMutableArray new];
    for (NSDictionary *staffrole in person[@"staffMedia"][@"edges"]) {
        @autoreleasepool {
            AtarrashiiStaffObject *srole = [AtarrashiiStaffObject new];
            srole.position = staffrole[@"staffRole"];
            srole.anime = @{@"id" : staffrole[@"id"], @"title" : staffrole[@"node"][@"title"][@"romaji"], @"image_url" : staffrole[@"node"][@"coverImage"] != [NSNull null] && staffrole[@"node"][@"coverImage"][@"large"] ? staffrole[@"node"][@"coverImage"][@"large"] : @""};
            [staffroles addObject:srole.NSDictionaryRepresentation];
        }
    }
    personobj.anime_staff_positions = staffroles;
    NSMutableArray *characterroles = [NSMutableArray new];
    for (NSDictionary *characterrole in person[@"characters"][@"edges"]) {
        @autoreleasepool {
            AtarashiiVoiceActingRoleObject *vaobj = [AtarashiiVoiceActingRoleObject new];
            vaobj.characterid = ((NSNumber *)characterrole[@"id"]).intValue;
            vaobj.name = characterrole[@"node"][@"name"][@"last"] != [NSNull null] ? [NSString stringWithFormat:@"%@, %@", characterrole[@"node"][@"name"][@"last"], characterrole[@"node"][@"name"][@"first"]] : characterrole[@"node"][@"name"][@"first"];
            vaobj.image_url = characterrole[@"node"][@"image"] != [NSNull null] && characterrole[@"node"][@"image"][@"large"] ? characterrole[@"node"][@"image"][@"large"] : @"";
            for (NSDictionary *anime in characterrole[@"media"]) {
                vaobj.anime = @{@"id" : anime[@"id"], @"title" : anime[@"title"][@"romaji"]};
                [characterroles addObject:vaobj.NSDictionaryRepresentation];
            }
        }
    }
    personobj.voice_acting_roles = characterroles;
    return personobj.NSDictionaryRepresentation;
}
@end
