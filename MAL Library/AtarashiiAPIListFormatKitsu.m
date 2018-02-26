//
//  AtarashiiAPIListFormatKitsu.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/12/18.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "AtarashiiAPIListFormatKitsu.h"
#import "KitsuListRetriever.h"
#import "AtarashiiDataObjects.h"

@implementation AtarashiiAPIListFormatKitsu

+ (NSDictionary *)KitsutoAtarashiiAnimeList: (KitsuListRetriever *)retriever {
    NSMutableArray *tmpanimelist = [NSMutableArray new];
    for (NSDictionary *entry in retriever.tmplist) {
        if (entry[@"relationships"][@"anime"][@"data"]) {
            NSDictionary *metadata = [retriever retrieveMetaDataWithID:((NSNumber *)entry[@"relationships"][@"anime"][@"data"][@"id"]).intValue];
            if (metadata) {
                //Populate fields
                AtarashiiAnimeListObject *lentry = [AtarashiiAnimeListObject new];
                lentry.titleid = ((NSNumber *)metadata[@"id"]).intValue;
                lentry.title = metadata[@"attributes"][@"canonicalTitle"];
                lentry.episodes = metadata[@"attributes"][@"episodeCount"] != [NSNull null] ? ((NSNumber *)metadata[@"attributes"][@"episodeCount"]).intValue : 0;
                lentry.episode_length = metadata[@"attributes"][@"episodeLength"] != [NSNull null] ? ((NSNumber *)metadata[@"attributes"][@"episodeLength"]).intValue : 0;
                if (metadata[@"attributes"][@"posterImage"][@"medium"]) {
                    lentry.image_url = metadata[@"attributes"][@"posterImage"][@"medium"];
                }
                lentry.type = metadata[@"attributes"][@"showType"];
                NSString *tmpstatus = metadata[@"attributes"][@"status"];
                if ([tmpstatus isEqualToString:@"finished"]) {
                    lentry.status = @"finished airing";
                }
                else if ([tmpstatus isEqualToString:@"current"]) {
                    lentry.status = @"currently airing";
                }
                else if ([tmpstatus isEqualToString:@"tba"]||[tmpstatus isEqualToString:@"unreleased"]||[tmpstatus isEqualToString:@"upcoming"]) {
                    lentry.status = @"not yet aired";
                }
                lentry.entryid = ((NSNumber *)entry[@"id"]).intValue;
                if ([(NSString *)entry[@"attributes"][@"status"] isEqualToString:@"on_hold"]) {
                    lentry.watched_status = @"on-hold";
                }
                else if ([(NSString *)entry[@"attributes"][@"status"] isEqualToString:@"planned"]) {
                    lentry.watched_status = @"plan to watch";
                }
                else if ([(NSString *)entry[@"attributes"][@"status"] isEqualToString:@"current"]) {
                    lentry.watched_status = @"watching";
                }
                else {
                    lentry.watched_status = (NSString *)entry[@"attributes"][@"status"];
                }
                lentry.watched_episodes = ((NSNumber *)entry[@"attributes"][@"progress"]).intValue;
                if (entry[@"attributes"][@"ratingTwenty"] != [NSNull null]) {
                    lentry.score = ((NSNumber *)entry[@"attributes"][@"ratingTwenty"]).intValue;
                }
                lentry.watching_start = entry[@"attributes"][@"startedAt"];
                lentry.watching_end  = entry[@"attributes"][@"finishedAt"];
                lentry.rewatching = ((NSNumber *)entry[@"attributes"][@"reconsuming"]).boolValue;
                lentry.rewatch_count = ((NSNumber *)entry[@"attributes"][@"reconsumeCount"]).intValue;
                lentry.personal_comments = entry[@"attributes"][@"notes"];
                lentry.private_entry = ((NSNumber *) entry[@"attributes"][@"private"]).boolValue;
                [tmpanimelist addObject: lentry.NSDictionaryRepresentation];
            }
        }
    }
    return @{@"anime" : tmpanimelist, @"statistics" : @{@"days" : @([self calculatedays:tmpanimelist])}};
}
+ (NSDictionary *)KitsutoAtarashiiMangaList: (KitsuListRetriever *)retriever {
    NSMutableArray *tmpmangalist = [NSMutableArray new];
    for (NSDictionary *entry in retriever.tmplist) {
        if (entry[@"relationships"][@"manga"][@"data"]) {
            NSDictionary *metadata = [retriever retrieveMetaDataWithID:((NSNumber *)entry[@"relationships"][@"manga"][@"data"][@"id"]).intValue];
            if (metadata) {
                //Populate fields
                AtarashiiMangaListObject *lentry = [AtarashiiMangaListObject new];
                lentry.titleid = ((NSNumber *)metadata[@"id"]).intValue;
                lentry.title = metadata[@"attributes"][@"canonicalTitle"];
                lentry.chapters = ((NSNumber *)metadata[@"attributes"][@"chapterCount"]).intValue;
                lentry.volumes = ((NSNumber *)metadata[@"attributes"][@"volumeCount"]).intValue;
                if (metadata[@"attributes"][@"posterImage"][@"medium"]) {
                    lentry.image_url = metadata[@"attributes"][@"posterImage"][@"medium"];
                }
                lentry.type = metadata[@"attributes"][@"mangaType"];
                NSString *tmpstatus = metadata[@"attributes"][@"status"];
                if ([tmpstatus isEqualToString:@"finished"]) {
                    lentry.status = tmpstatus;
                }
                else if ([tmpstatus isEqualToString:@"current"]) {
                    lentry.status = @"publishing";
                }
                else if ([tmpstatus isEqualToString:@"tba"]||[tmpstatus isEqualToString:@"unreleased"]||[tmpstatus isEqualToString:@"upcoming"]) {
                    lentry.status = @"not yet published";
                }
                lentry.entryid = ((NSNumber *)entry[@"id"]).intValue;
                if ([(NSString *)entry[@"attributes"][@"status"] isEqualToString:@"on_hold"]) {
                    lentry.read_status = @"on-hold";
                }
                else if ([(NSString *)entry[@"attributes"][@"status"] isEqualToString:@"planned"]) {
                    lentry.read_status = @"plan to read";
                }
                else if ([(NSString *)entry[@"attributes"][@"status"] isEqualToString:@"current"]) {
                    lentry.read_status = @"reading";
                }
                else if ([(NSString *)entry[@"attributes"][@"status"] isEqualToString:@"finished"]) {
                    lentry.read_status = @"completed";
                }
                else {
                    lentry.read_status = (NSString *)entry[@"attributes"][@"status"];
                }
                lentry.chapters_read = ((NSNumber *)entry[@"attributes"][@"progress"]).intValue;
                lentry.volumes_read = ((NSNumber *)entry[@"attributes"][@"voulmesOwned"]).intValue;
                if (entry[@"attributes"][@"ratingTwenty"] != [NSNull null]) {
                    lentry.score = ((NSNumber *)entry[@"attributes"][@"ratingTwenty"]).intValue;
                }
                lentry.reading_start = entry[@"attributes"][@"startedAt"];
                lentry.reading_end = entry[@"attributes"][@"finishedAt"];
                lentry.rereading = ((NSNumber *)entry[@"attributes"][@"reconsuming"]).boolValue;
                lentry.reread_count = ((NSNumber *)entry[@"attributes"][@"reconsumeCount"]).intValue;
                lentry.personal_comments = entry[@"attributes"][@"notes"];
                lentry.private_entry = ((NSNumber *) entry[@"attributes"][@"private"]).boolValue;
                [tmpmangalist addObject: lentry.NSDictionaryRepresentation];
            }
        }
    }
    return @{@"manga" : tmpmangalist, @"statistics" : @{@"days" : @(0)}};
}
+ (NSDictionary *)KitsuAnimeInfotoAtarashii:(NSDictionary *)data {
    AtarashiiAnimeObject *aobject = [AtarashiiAnimeObject new];
    NSDictionary *title = data[@"data"];
    NSDictionary *attributes = title[@"attributes"];
    aobject.titleid = ((NSNumber *)title[@"id"]).intValue;
    aobject.title = attributes[@"canonicalTitle"];
    // Create other titles
    aobject.other_titles = @{@"synonyms" : (attributes[@"abbreviatedTitles"] && attributes[@"abbreviatedTitles"]  != [NSNull null]) ? attributes[@"abbreviatedTitles"] : @[], @"english" : attributes[@"titles"][@"en"] ? @[attributes[@"titles"][@"en"]] : @[], @"japanese" : attributes[@"titles"][@"ja_jp"] ? @[attributes[@"titles"][@"ja_jp"]] : @[] };
    aobject.rank = attributes[@"ratingRank"] != [NSNull null] ? ((NSNumber *)attributes[@"ratingRank"]).intValue : 0;
    aobject.popularity_rank = attributes[@"popularityRank"] != [NSNull null] ? ((NSNumber *)attributes[@"popularityRank"]).intValue : 0;
    aobject.image_url = attributes[@"posterImage"][@"medium"] && attributes[@"posterimage"][@"medium"] != [NSNull null] ? attributes[@"posterImage"][@"medium"] : @"";
    aobject.type = attributes[@"subtype"];
    aobject.episodes = attributes[@"episodeCount"] != [NSNull null] ? ((NSNumber *)attributes[@"episodeCount"]).intValue : 0;
    aobject.start_date = attributes[@"startDate"];
    aobject.end_date = attributes[@"endDate"];
    aobject.duration = attributes[@"episodeLength"] != [NSNull null] ? ((NSNumber *)attributes[@"episodeLength"]).intValue : 0;
    aobject.classification = attributes[@"ageRating"] != [NSNull null] ? [NSString stringWithFormat:@"%@ - %@", attributes[@"ageRating"], attributes[@"ageRatingGuide"]] : @"Unknown";
    aobject.synposis = attributes[@"synopsis"];
    aobject.members_score = attributes[@"averageRating"] != [NSNull null] ? ((NSNumber *)attributes[@"averageRating"]).floatValue : 0;
    aobject.members_count = attributes[@"userCount"] != [NSNull null] ? ((NSNumber *)attributes[@"userCount"]).intValue : 0;
    aobject.favorited_count = attributes[@"favoritesCount"] != [NSNull null] ? ((NSNumber *)attributes[@"favoritesCount"]).intValue : 0;
    NSString *tmpstatus = attributes[@"status"];
    if ([tmpstatus isEqualToString:@"finished"]) {
        aobject.status = @"finished airing";
    }
    else if ([tmpstatus isEqualToString:@"current"]) {
        aobject.status = @"currently airing";
    }
    else if ([tmpstatus isEqualToString:@"tba"]||[tmpstatus isEqualToString:@"unreleased"]||[tmpstatus isEqualToString:@"upcoming"]) {
        aobject.status = @"not yet aired";
    }
    NSArray * included = data[@"included"];
    NSMutableArray *categories = [NSMutableArray new];
    for (NSDictionary *d in included) {
        if ([(NSString *)d[@"type"] isEqualToString:@"categories"]) {
            [categories addObject:d[@"attributes"][@"title"]];
        }
    }
    aobject.genres = categories;
    NSMutableDictionary *mappings = [NSMutableDictionary new];
    for (NSDictionary *d in included) {
        if ([(NSString *)d[@"type"] isEqualToString:@"mappings"]) {
            [mappings setObject:d[@"attributes"][@"externalId"] forKey:@"externalSite"];
        }
    }
    aobject.mappings = mappings;
    return aobject.NSDictionaryRepresentation;
}

+ (NSDictionary *)KitsuMangaInfotoAtarashii:(NSDictionary *)data {
    AtarashiiMangaObject *mobject = [AtarashiiMangaObject new];
    NSDictionary *title = data[@"data"];
    NSDictionary *attributes = title[@"attributes"];
    mobject.titleid = ((NSNumber *)title[@"id"]).intValue;
    mobject.title = attributes[@"canonicalTitle"];
    // Create other titles
    mobject.other_titles = @{@"synonyms" : (attributes[@"abbreviatedTitles"] && attributes[@"abbreviatedTitles"]  != [NSNull null]) ? attributes[@"abbreviatedTitles"] : @[], @"english" : @[attributes[@"titles"][@"en"]] , @"japanese" : @[attributes[@"titles"][@"ja_jp"]] };
    mobject.rank = attributes[@"ratingRank"] != [NSNull null] ? ((NSNumber *)attributes[@"ratingRank"]).intValue : 0;
    mobject.popularity_rank = attributes[@"popularityRank"] != [NSNull null] ? ((NSNumber *)attributes[@"popularityRank"]).intValue : 0;
    mobject.image_url = attributes[@"posterImage"][@"medium"] && attributes[@"posterImage"][@"medium"] != [NSNull null] ? attributes[@"posterImage"][@"medium"] : @"";
    mobject.type = attributes[@"subtype"];
    mobject.chapters = attributes[@"chapterCount"] != [NSNull null] ? ((NSNumber *)attributes[@"chapterCount"]).intValue : 0;
    mobject.volumes = attributes[@"volumeCount"] != [NSNull null] ? ((NSNumber *)attributes[@"volumeCount"]).intValue : 0;
    mobject.members_score = attributes[@"averageRating"] != [NSNull null] ? ((NSNumber *)attributes[@"averageRating"]).floatValue : 0;
    mobject.members_count = attributes[@"userCount"] != [NSNull null] ? ((NSNumber *)attributes[@"userCount"]).intValue : 0;
    mobject.favorited_count = attributes[@"favoritesCount"] != [NSNull null] ? ((NSNumber *)attributes[@"favoritesCount"]).intValue : 0;
    mobject.synposis = attributes[@"synopsis"];
    NSString *tmpstatus = attributes[@"status"];
    if ([tmpstatus isEqualToString:@"finished"]) {
        mobject.status = tmpstatus;
    }
    else if ([tmpstatus isEqualToString:@"current"]) {
        mobject.status = @"publishing";
    }
    else if ([tmpstatus isEqualToString:@"tba"]||[tmpstatus isEqualToString:@"unreleased"]||[tmpstatus isEqualToString:@"upcoming"]) {
        mobject.status = @"not yet published";
    }
    NSArray * included = data[@"included"];
    NSMutableArray *categories = [NSMutableArray new];
    for (NSDictionary *d in included) {
        if ([(NSString *)d[@"type"] isEqualToString:@"categories"]) {
            [categories addObject:d[@"attributes"][@"title"]];
        }
    }
    mobject.genres = categories;
    NSMutableDictionary *mappings = [NSMutableDictionary new];
    for (NSDictionary *d in included) {
        if ([(NSString *)d[@"type"] isEqualToString:@"mappings"]) {
            [mappings setObject:d[@"attributes"][@"externalId"] forKey:@"externalSite"];
        }
    }
    mobject.mappings = mappings;
    return mobject.NSDictionaryRepresentation;
}

+ (NSArray *)KitsuAnimeSearchtoAtarashii:(NSDictionary *)data {
    NSArray *dataarray = data[@"data"];
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *d in dataarray) {
        AtarashiiAnimeObject *aobject = [AtarashiiAnimeObject new];
        aobject.titleid = ((NSNumber *)d[@"id"]).intValue;
        aobject.title = d[@"attributes"][@"canonicalTitle"];
        aobject.episodes = d[@"attributes"][@"episodeCount"] != [NSNull null] ? ((NSNumber *)d[@"attributes"][@"episodeCount"]).intValue : 0;
        aobject.type = d[@"attributes"][@"subtype"];
        aobject.image_url = d[@"attributes"][@"posterImage"][@"medium"] && d[@"attributes"][@"posterImage"][@"medium"] != [NSNull null] ? d[@"attributes"][@"posterImage"][@"medium"] : @"";
        NSString *tmpstatus = d[@"attributes"][@"status"];
        if ([tmpstatus isEqualToString:@"finished"]) {
            aobject.status = @"finished airing";
        }
        else if ([tmpstatus isEqualToString:@"current"]) {
            aobject.status = @"currently airing";
        }
        else if ([tmpstatus isEqualToString:@"tba"]||[tmpstatus isEqualToString:@"unreleased"]||[tmpstatus isEqualToString:@"upcoming"]) {
            aobject.status = @"not yet aired";
        }
        [tmparray addObject:aobject.NSDictionaryRepresentation];
    }
    return tmparray;
}

+ (NSArray *)KitsuMangaSearchtoAtarashii:(NSDictionary *)data {
    NSArray *dataarray = data[@"data"];
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *d in dataarray) {
        AtarashiiMangaObject *mobject = [AtarashiiMangaObject new];
        mobject.titleid = ((NSNumber *)d[@"id"]).intValue;
        mobject.title = d[@"attributes"][@"canonicalTitle"];
        mobject.chapters = d[@"attributes"][@"chapterCount"] != [NSNull null] ? ((NSNumber *)d[@"attributes"][@"chapterCount"]).intValue : 0;
        mobject.volumes = d[@"attributes"][@"volumeCount"] != [NSNull null] ? ((NSNumber *)d[@"attributes"][@"volumeCount"]).intValue : 0;
        mobject.type = d[@"attributes"][@"subtype"];
        mobject.image_url = d[@"attributes"][@"medium"] && d[@"attributes"][@"posterimage"][@"medium"] != [NSNull null] ? d[@"attributes"][@"posterimage"][@"medium"] : @"";
        NSString *tmpstatus = d[@"attributes"][@"status"];
        if ([tmpstatus isEqualToString:@"finished"]) {
            mobject.status = @"finished airing";
        }
        else if ([tmpstatus isEqualToString:@"current"]) {
            mobject.status = @"currently airing";
        }
        else if ([tmpstatus isEqualToString:@"tba"]||[tmpstatus isEqualToString:@"unreleased"]||[tmpstatus isEqualToString:@"upcoming"]) {
            mobject.status = @"not yet aired";
        }
        [tmparray addObject:mobject.NSDictionaryRepresentation];
    }
    return tmparray;
}

+ (double)calculatedays:(NSArray *)list {
    double duration = 0;
    for (NSDictionary *entry in list) {
        duration += ((NSNumber *)entry[@"watched_episodes"]).integerValue * ((NSNumber *)entry[@"duration"]).intValue;
    }
    duration = (duration/60)/24;
    return duration;
}
@end
