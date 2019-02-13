//
//  AtarashiiAPIListFormatKitsu.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/12/18.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "AtarashiiAPIListFormatKitsu.h"
#import "KitsuListRetriever.h"
#import "AtarashiiDataObjects.h"
#import "Utility.h"

@implementation AtarashiiAPIListFormatKitsu

+ (NSDictionary *)KitsutoAtarashiiAnimeList: (KitsuListRetriever *)retriever {
    NSMutableArray *tmpanimelist = [NSMutableArray new];
        for (NSDictionary *entry in retriever.tmplist) {
            @autoreleasepool {
                if (entry[@"relationships"][@"anime"][@"data"]) {
                    NSDictionary *metadata = [retriever retrieveMetaDataWithID:((NSNumber *)entry[@"relationships"][@"anime"][@"data"][@"id"]).intValue];
                    if (metadata) {
                        //Populate fields
                        AtarashiiAnimeListObject *lentry = [AtarashiiAnimeListObject new];
                        lentry.titleid = ((NSNumber *)metadata[@"id"]).intValue;
                        lentry.title = metadata[@"attributes"][@"canonicalTitle"];
                        lentry.episodes = metadata[@"attributes"][@"episodeCount"] != [NSNull null] ? ((NSNumber *)metadata[@"attributes"][@"episodeCount"]).intValue : 0;
                        lentry.episode_length = metadata[@"attributes"][@"episodeLength"] != [NSNull null] ? ((NSNumber *)metadata[@"attributes"][@"episodeLength"]).intValue : 0;
                        if (metadata[@"attributes"][@"posterImage"] != [NSNull null]) {
                            lentry.image_url = metadata[@"attributes"][@"posterImage"][@"large"];
                        }
                        lentry.type = [Utility convertAnimeType:metadata[@"attributes"][@"showType"]];
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
                        lentry.watching_start = entry[@"attributes"][@"startedAt"] != [NSNull null] ? [(NSString *)entry[@"attributes"][@"startedAt"] substringToIndex:10] : @"";
                        lentry.watching_end  = entry[@"attributes"][@"finishedAt"] != [NSNull null] ? [(NSString *)entry[@"attributes"][@"finishedAt"] substringToIndex:10] : @"";
                        lentry.rewatching = ((NSNumber *)entry[@"attributes"][@"reconsuming"]).boolValue;
                        lentry.rewatch_count = ((NSNumber *)entry[@"attributes"][@"reconsumeCount"]).intValue;
                        lentry.personal_comments = entry[@"attributes"][@"notes"];
                        lentry.private_entry = ((NSNumber *) entry[@"attributes"][@"private"]).boolValue;
                        [tmpanimelist addObject: lentry.NSDictionaryRepresentation];
                    }
                }
            }
        }
    return @{@"anime" : tmpanimelist, @"statistics" : @{@"days" : @([Utility calculatedays:tmpanimelist])}};
}
+ (NSDictionary *)KitsutoAtarashiiMangaList: (KitsuListRetriever *)retriever {
    NSMutableArray *tmpmangalist = [NSMutableArray new];
        for (NSDictionary *entry in retriever.tmplist) {
            @autoreleasepool {
            if (entry[@"relationships"][@"manga"][@"data"]) {
                NSDictionary *metadata = [retriever retrieveMetaDataWithID:((NSNumber *)entry[@"relationships"][@"manga"][@"data"][@"id"]).intValue];
                if (metadata) {
                    //Populate fields
                    AtarashiiMangaListObject *lentry = [AtarashiiMangaListObject new];
                    lentry.titleid = ((NSNumber *)metadata[@"id"]).intValue;
                    lentry.title = metadata[@"attributes"][@"canonicalTitle"];
                    lentry.chapters = metadata[@"attributes"][@"chapterCount"] != [NSNull null] ? ((NSNumber *)metadata[@"attributes"][@"chapterCount"]).intValue : 0;
                    lentry.volumes = metadata[@"attributes"][@"volumeCount"] != [NSNull null] ? ((NSNumber *)metadata[@"attributes"][@"volumeCount"]).intValue : 0;
                    if (metadata[@"attributes"][@"posterImage"] != [NSNull null]) {
                        lentry.image_url = metadata[@"attributes"][@"posterImage"][@"large"];
                    }
                    lentry.type = ((NSString *)metadata[@"attributes"][@"mangaType"]).capitalizedString;
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
                    lentry.volumes_read = ((NSNumber *)entry[@"attributes"][@"volumesOwned"]).intValue;
                    if (entry[@"attributes"][@"ratingTwenty"] != [NSNull null]) {
                        lentry.score = ((NSNumber *)entry[@"attributes"][@"ratingTwenty"]).intValue;
                    }
                    lentry.reading_start = entry[@"attributes"][@"startedAt"] != [NSNull null] ? [(NSString *)entry[@"attributes"][@"startedAt"] substringToIndex:10] : @"";
                    lentry.reading_end  = entry[@"attributes"][@"finishedAt"] != [NSNull null] ? [(NSString *)entry[@"attributes"][@"finishedAt"] substringToIndex:10] : @"";
                    lentry.rereading = ((NSNumber *)entry[@"attributes"][@"reconsuming"]).boolValue;
                    lentry.reread_count = ((NSNumber *)entry[@"attributes"][@"reconsumeCount"]).intValue;
                    lentry.personal_comments = entry[@"attributes"][@"notes"];
                    lentry.private_entry = ((NSNumber *) entry[@"attributes"][@"private"]).boolValue;
                    [tmpmangalist addObject: lentry.NSDictionaryRepresentation];
                }
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
    aobject.other_titles = @{@"synonyms" : (attributes[@"abbreviatedTitles"] && attributes[@"abbreviatedTitles"]  != [NSNull null]) ? attributes[@"abbreviatedTitles"] : @[], @"english" : attributes[@"titles"][@"en"] && attributes[@"titles"][@"en"] != [NSNull null] ? @[attributes[@"titles"][@"en"]] : attributes[@"titles"][@"en_jp"] && attributes[@"titles"][@"en_jp"] != [NSNull null] ? @[attributes[@"titles"][@"en_jp"]] : @[], @"japanese" : attributes[@"titles"][@"ja_jp"] && attributes[@"titles"][@"ja_jp"] != [NSNull null] ?  @[attributes[@"titles"][@"ja_jp"]] : @[] };
    aobject.rank = attributes[@"ratingRank"] != [NSNull null] ? ((NSNumber *)attributes[@"ratingRank"]).intValue : 0;
    aobject.popularity_rank = attributes[@"popularityRank"] != [NSNull null] ? ((NSNumber *)attributes[@"popularityRank"]).intValue : 0;
    if (attributes[@"posterImage"] != [NSNull null]) {
        aobject.image_url = attributes[@"posterImage"][@"large"] && attributes[@"posterimage"][@"large"] != [NSNull null] ? attributes[@"posterImage"][@"large"] : @"";
    }
    aobject.type = [Utility convertAnimeType:attributes[@"subtype"]];
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
    for (NSDictionary *d in [included filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"categories"]]) {
        [categories addObject:d[@"attributes"][@"title"]];
    }
    aobject.genres = categories;
    NSMutableArray *producers = [NSMutableArray new];
    for (NSDictionary *d in [included filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"producers"]]) {
        [producers addObject:d[@"attributes"][@"name"]];
    }
    aobject.producers = producers;
    NSMutableDictionary *mappings = [NSMutableDictionary new];
    for (NSDictionary *d in [included filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"mappings"]]) {
        mappings[d[@"attributes"][@"externalSite"]] = d[@"attributes"][@"externalId"];
    }
    aobject.mappings = mappings;
    // Generate relationships
    NSDictionary *mediaRelationships = [self generateRelatedArrays:data];
    if (mediaRelationships) {
        aobject.manga_adaptations = mediaRelationships[@"manga_adaptations"];
        aobject.prequels = mediaRelationships[@"prequels"];
        aobject.sequels = mediaRelationships[@"sequels"];
        aobject.side_stories = mediaRelationships[@"side_stories"];
        aobject.parent_story = mediaRelationships[@"parent_story"];
        aobject.character_anime = mediaRelationships[@"character_anime"];
        aobject.spin_offs = mediaRelationships[@"spin_offs"];
    }
    return aobject.NSDictionaryRepresentation;
}

+ (NSDictionary *)KitsuMangaInfotoAtarashii:(NSDictionary *)data {
    AtarashiiMangaObject *mobject = [AtarashiiMangaObject new];
    NSDictionary *title = data[@"data"];
    NSDictionary *attributes = title[@"attributes"];
    mobject.titleid = ((NSNumber *)title[@"id"]).intValue;
    mobject.title = attributes[@"canonicalTitle"];
    // Create other titles
    mobject.other_titles = @{@"synonyms" : (attributes[@"abbreviatedTitles"] && attributes[@"abbreviatedTitles"]  != [NSNull null]) ? attributes[@"abbreviatedTitles"] : @[], @"english" : attributes[@"titles"][@"en"] && attributes[@"titles"][@"en"] != [NSNull null] ? @[attributes[@"titles"][@"en"]] : attributes[@"titles"][@"en_jp"] && attributes[@"titles"][@"en_jp"] != [NSNull null] ? @[attributes[@"titles"][@"en_jp"]] : @[], @"japanese" : attributes[@"titles"][@"ja_jp"] && attributes[@"titles"][@"ja_jp"] != [NSNull null] ?  @[attributes[@"titles"][@"ja_jp"]] : @[] };
    mobject.rank = attributes[@"ratingRank"] != [NSNull null] ? ((NSNumber *)attributes[@"ratingRank"]).intValue : 0;
    mobject.popularity_rank = attributes[@"popularityRank"] != [NSNull null] ? ((NSNumber *)attributes[@"popularityRank"]).intValue : 0;
    if (attributes[@"posterImage"] != [NSNull null]) {
        mobject.image_url = attributes[@"posterImage"][@"large"] && attributes[@"posterImage"][@"large"] != [NSNull null] ? attributes[@"posterImage"][@"large"] : @"";
    }
    mobject.type = ((NSString *)attributes[@"subtype"]).capitalizedString;
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
    for (NSDictionary *d in [included filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"categories"]]) {
        [categories addObject:d[@"attributes"][@"title"]];
    }
    mobject.genres = categories;
    NSMutableDictionary *mappings = [NSMutableDictionary new];
    for (NSDictionary *d in [included filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"mappings"]]) {
        mappings[d[@"attributes"][@"externalSite"]] = d[@"attributes"][@"externalId"];
    }
    mobject.mappings = mappings;
    // Generate relationships
    NSDictionary *mediaRelationships = [self generateRelatedArrays:data];
    if (mediaRelationships) {
        mobject.anime_adaptations = mediaRelationships[@"anime_adaptations"];
        mobject.alternative_versions = mediaRelationships[@"alternative_versions"];
    }
    return mobject.NSDictionaryRepresentation;
}

+ (NSArray *)KitsuAnimeSearchtoAtarashii:(NSDictionary *)data {
    NSArray *dataarray = data[@"data"];
    NSMutableArray *tmparray = [NSMutableArray new];
        for (NSDictionary *d in dataarray) {
            @autoreleasepool {
            AtarashiiAnimeObject *aobject = [AtarashiiAnimeObject new];
            aobject.titleid = ((NSNumber *)d[@"id"]).intValue;
            aobject.title = d[@"attributes"][@"canonicalTitle"];
            aobject.other_titles =  @{@"synonyms" : (d[@"attributes"][@"abbreviatedTitles"] && d[@"attributes"][@"abbreviatedTitles"]  != [NSNull null]) ? d[@"attributes"][@"abbreviatedTitles"] : @[], @"english" : d[@"attributes"][@"titles"][@"en"] && d[@"attributes"][@"titles"][@"en"] != [NSNull null] ? @[d[@"attributes"][@"titles"][@"en"]] : d[@"attributes"][@"titles"][@"en_jp"] && d[@"attributes"][@"titles"][@"en_jp"] != [NSNull null] ? @[d[@"attributes"][@"titles"][@"en_jp"]] : @[], @"japanese" : d[@"attributes"][@"titles"][@"ja_jp"] && d[@"attributes"][@"titles"][@"ja_jp"] != [NSNull null] ?  @[d[@"attributes"][@"titles"][@"ja_jp"]] : @[] };
            aobject.episodes = d[@"attributes"][@"episodeCount"] != [NSNull null] ? ((NSNumber *)d[@"attributes"][@"episodeCount"]).intValue : 0;
            aobject.type = [Utility convertAnimeType:d[@"attributes"][@"subtype"]];
            if (d[@"attributes"][@"posterImage"] != [NSNull null]) {
                aobject.image_url = d[@"attributes"][@"posterImage"][@"large"] && d[@"attributes"][@"posterImage"][@"large"] != [NSNull null] ? d[@"attributes"][@"posterImage"][@"large"] : @"";
            }
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
    }
    return tmparray;
}

+ (NSArray *)KitsuMangaSearchtoAtarashii:(NSDictionary *)data {
    NSArray *dataarray = data[@"data"];
    NSMutableArray *tmparray = [NSMutableArray new];
        for (NSDictionary *d in dataarray) {
            @autoreleasepool {
            AtarashiiMangaObject *mobject = [AtarashiiMangaObject new];
            mobject.titleid = ((NSNumber *)d[@"id"]).intValue;
            mobject.title = d[@"attributes"][@"canonicalTitle"];
            mobject.other_titles = @{@"synonyms" : (d[@"attributes"][@"abbreviatedTitles"] && d[@"attributes"][@"abbreviatedTitles"]  != [NSNull null]) ? d[@"attributes"][@"abbreviatedTitles"] : @[], @"english" : d[@"attributes"][@"titles"][@"en"] && d[@"attributes"][@"titles"][@"en"] != [NSNull null] ? @[d[@"attributes"][@"titles"][@"en"]] : d[@"attributes"][@"titles"][@"en_jp"] && d[@"attributes"][@"titles"][@"en_jp"] != [NSNull null] ? @[d[@"attributes"][@"titles"][@"en_jp"]] : @[], @"japanese" : d[@"attributes"][@"titles"][@"ja_jp"] && d[@"attributes"][@"titles"][@"ja_jp"] != [NSNull null] ?  @[d[@"attributes"][@"titles"][@"ja_jp"]] : @[] };
            mobject.chapters = d[@"attributes"][@"chapterCount"] != [NSNull null] ? ((NSNumber *)d[@"attributes"][@"chapterCount"]).intValue : 0;
            mobject.volumes = d[@"attributes"][@"volumeCount"] != [NSNull null] ? ((NSNumber *)d[@"attributes"][@"volumeCount"]).intValue : 0;
            mobject.type = ((NSString *)d[@"attributes"][@"subtype"]).capitalizedString;
            if (d[@"attributes"][@"posterImage"] != [NSNull null]) {
                mobject.image_url = d[@"attributes"][@"posterImage"][@"large"] && d[@"attributes"][@"posterImage"][@"large"] != [NSNull null] ? d[@"attributes"][@"posterImage"][@"large"] : @"";
            }
            NSString *tmpstatus = d[@"attributes"][@"status"];
            if ([tmpstatus isEqualToString:@"finished"]) {
                mobject.status = tmpstatus;
            }
            else if ([tmpstatus isEqualToString:@"current"]) {
                mobject.status = @"publishing";
            }
            else if ([tmpstatus isEqualToString:@"tba"]||[tmpstatus isEqualToString:@"unreleased"]||[tmpstatus isEqualToString:@"upcoming"]) {
                mobject.status = @"not yet published";
            }
            [tmparray addObject: mobject.NSDictionaryRepresentation];
        }
    }
    return tmparray;
}

+ (NSArray *)KitsuEpisodesListtoAtarashii:(NSDictionary *)data withTitleId:(int)titleid {
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *episodeEntry in data[@"data"]) {
        if (episodeEntry[@"attributes"][@"airdate"] == [NSNull null]) {
            // Skip unaired episodes
            continue;
        }
        @autoreleasepool {
            if (episodeEntry[@"attributes"][@"canonicalTitle"] != [NSNull null]) {
                AtarashiiEpisodeObject *episode = [AtarashiiEpisodeObject new];
                episode.titleId = titleid;
                episode.episodeId = ((NSNumber *)episodeEntry[@"id"]).intValue;
                episode.episodeTitle = episodeEntry[@"attributes"][@"canonicalTitle"];
                episode.episodeNumber = ((NSNumber *)episodeEntry[@"attributes"][@"number"]).intValue;
                episode.thumbnail = episodeEntry[@"attributes"][@"thumbnail"] != [NSNull null] ? episodeEntry[@"attributes"][@"thumbnail"][@"original"] : @"";
                episode.airDate = episodeEntry[@"attributes"][@"airdate"] != [NSNull null] ? episodeEntry[@"attributes"][@"airdate"] : @"";
                [tmparray addObject:episode.NSDictionaryRepresentation];
            }
        }
    }
    return tmparray;
}

+ (NSDictionary *)KitsuEpisodeDetailtoAtarashii:(NSDictionary *)data {
    AtarashiiEpisodeObject *episode = [AtarashiiEpisodeObject new];
    episode.episodeId = ((NSNumber *)data[@"data"][@"id"]).intValue;
    episode.episodeTitle = data[@"data"][@"attributes"][@"canonicalTitle"];
    episode.episodeNumber = ((NSNumber *)data[@"data"][@"attributes"][@"number"]).intValue;
    episode.thumbnail = data[@"data"][@"attributes"][@"thumbnail"]  != [NSNull null] ? data[@"data"][@"attributes"][@"thumbnail"][@"original"] : @"";
    episode.airDate = data[@"data"][@"attributes"][@"airdate"] != [NSNull null] ? data[@"data"][@"attributes"][@"airdate"] : @"";
    episode.synopsis = data[@"data"][@"attributes"][@"synopsis"] != [NSNull null] ? data[@"data"][@"attributes"][@"synopsis"] : @"";
    episode.episodeLength = data[@"data"][@"attributes"][@"length"] != [NSNull null] ? ((NSNumber *)data[@"data"][@"attributes"][@"length"]).intValue : -1;
    return episode.NSDictionaryRepresentation;
}

+ (NSArray *)KitsuReactionstoAtarashii:(NSDictionary *)data withType:(int)type {
    NSMutableArray *reactionsarray = [NSMutableArray new];
    NSArray *dataarray = data[@"data"];
    NSArray *mediaarray = [data[@"included"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", type == 0 ? @"anime" : @"manga"]];
    NSArray *libraryentriesarray = [data[@"included"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"libraryEntries"]];
    NSArray *usersarray = [data[@"included"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"users"]];
        for (NSDictionary *reaction in dataarray) {
            @autoreleasepool {
            NSDictionary *mediadict;
            NSDictionary *libraryentrydict;
            NSDictionary *userdict;
            NSArray *tmparray = [mediaarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", type == 0 ? reaction[@"relationships"][@"anime"][@"data"][@"id"] : reaction[@"relationships"][@"manga"][@"data"][@"id"]]];
            if (tmparray.count > 0) {
                mediadict = tmparray[0];
            }
            else {
                continue;
            }
            tmparray = [libraryentriesarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", reaction[@"relationships"][@"libraryEntry"][@"data"][@"id"]]];
            if (tmparray.count > 0) {
                libraryentrydict = tmparray[0];
            }
            else {
                continue;
            }
            if (reaction[@"relationships"][@"user"][@"data"] == [NSNull null]) {
                continue;
            }
            tmparray = [usersarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", reaction[@"relationships"][@"user"][@"data"][@"id"]]];
            if (tmparray.count > 0) {
                userdict = tmparray[0];
            }
            else {
                continue;
            }
            AtarashiiReviewObject *reviewobj = [AtarashiiReviewObject new];
            reviewobj.mediatype = type;
            reviewobj.date = [(NSString *)reaction[@"attributes"][@"createdAt"] substringToIndex:10];
            reviewobj.review = reaction[@"attributes"][@"reaction"];
            reviewobj.helpful = ((NSNumber *)reaction[@"attributes"][@"upVotesCount"]).intValue;
            reviewobj.helpful_total = reviewobj.helpful;
            reviewobj.rating = libraryentrydict[@"attributes"][@"ratingTwenty"] != [NSNull null] ? ((NSNumber *)libraryentrydict[@"attributes"][@"ratingTwenty"]).intValue : 0;
            reviewobj.username = userdict[@"attributes"][@"name"];
            reviewobj.actual_username = userdict[@"attributes"][@"slug"];
            reviewobj.avatar_url = userdict[@"attributes"][@"avatar"] != [NSNull null] ? userdict[@"attributes"][@"avatar"][@"original"] : @"";
            if (type == 0) {
                reviewobj.watched_episodes = ((NSNumber *)libraryentrydict[@"attributes"][@"progress"]).intValue;
                reviewobj.episodes = mediadict[@"attributes"][@"episodeCount"] != [NSNull null] ? ((NSNumber *)mediadict[@"attributes"][@"episodeCount"]).intValue : 0;
            }
            else {
                reviewobj.read_chapters = ((NSNumber *)libraryentrydict[@"attributes"][@"progress"]).intValue;
                reviewobj.chapters = mediadict[@"attributes"][@"chapterCount"] != [NSNull null] ? ((NSNumber *)mediadict[@"attributes"][@"chapterCount"]).intValue : 0;
            }
            [reactionsarray addObject:[reviewobj NSDictionaryRepresentation]];
        }
    }
    return reactionsarray;
}

+ (NSDictionary *)KitsuUsertoAtarashii:(NSDictionary *)userinfo {
    if (((NSArray *)userinfo[@"data"]).count > 0) {
            AtarashiiUserObject *user = [AtarashiiUserObject new];
            NSDictionary *userdata = userinfo[@"data"][0];
            user.avatar_url = userdata[@"attributes"][@"avatar"] != [NSNull null] && userdata[@"attributes"][@"avatar"] ? userdata[@"attributes"][@"avatar"][@"original"] : [NSNull null];
            user.gender = userdata[@"attributes"][@"gender"] != [NSNull null] ? userdata[@"attributes"][@"gender"] : @"Unknown";
            user.birthday =  userdata[@"attributes"][@"birthday"] != [NSNull null] ?  userdata[@"attributes"][@"gender"] : [NSNull null];
            user.location =  userdata[@"attributes"][@"location"] != [NSNull null] ?  userdata[@"attributes"][@"location"] : [NSNull null];
            user.website =  userdata[@"attributes"][@"website"] != [NSNull null] ?  userdata[@"attributes"][@"website"] : [NSNull null];
            user.join_date =  [(NSString *)userdata[@"attributes"][@"createdAt"] substringToIndex:10];
            user.access_rank = userdata[@"attributes"][@"status"];
            user.forum_posts = ((NSNumber *)userdata[@"attributes"][@"postsCount"]).intValue;
            user.reviews = ((NSNumber *)userdata[@"attributes"][@"mediaReactionsCount"]).intValue;
            user.comments = ((NSNumber *)userdata[@"attributes"][@"commentsCount"]).intValue;
            user.extradict = @{@"likes_recieved" : userdata[@"attributes"][@"likesReceivedCount"], @"likes_given" : userdata[@"attributes"][@"likesGivenCount"], @"about" : userdata[@"attributes"][@"about"] != [NSNull null] ? userdata[@"attributes"][@"about"] : [NSNull null]};
            return [user.NSDictionaryRepresentation copy];
    }
    return nil;
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
    NSArray *mediaarray = [idarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type ==[c] %@", typestr]];
    NSArray *mappingsarray = [idarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type ==[c] %@", @"mappings"]];
    NSMutableArray *tmplist = [NSMutableArray new];
    for (NSDictionary *media in mediaarray) {
        int titleidnum = ((NSNumber *)media[@"id"]).intValue;
        NSMutableDictionary *iddict = [NSMutableDictionary new];
         iddict[[NSString stringWithFormat:@"kitsu/%@",typestr]] = @(titleidnum);
        if (media[@"relationships"][@"mappings"][@"data"] && media[@"relationships"][@"mappings"][@"data"] != [NSNull null]) {
            for (NSDictionary *rmap in media[@"relationships"][@"mappings"][@"data"]) {
                int mapid = ((NSNumber *)rmap[@"id"]).intValue;
                NSArray *existingmap = [mappingsarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id ==[c] %@", @(mapid).stringValue]];
                if (existingmap.count > 0) {
                    NSString *site = existingmap[0][@"attributes"][@"externalSite"];
                    NSString *externalid = existingmap[0][@"attributes"][@"externalId"];
                    /*if ([site isEqualToString:@"anilist"]) {
                        if (([externalid containsString:@"anime"] && type == 0) || ([externalid containsString:@"manga"] && type == 1)) {
                            iddict[[NSString stringWithFormat:@"anilist/%@",typestr]] = @([[externalid stringByReplacingOccurrencesOfString:@"anime/" withString:@""] stringByReplacingOccurrencesOfString:@"manga/" withString:@""].intValue);
                        }
                    }
                    else */if (([site isEqualToString:@"myanimelist/anime"] && type == 0) || ([site isEqualToString:@"myanimelist/manga"] && type == 1)) {
                        iddict[site] = @(externalid.intValue);
                    }
                }
            }
        }
        [tmplist addObject:iddict.copy];
    }
    return tmplist.copy;
}
+ (NSDictionary *)generateRelatedArrays:(NSDictionary *)data {
    if (data[@"included"] && data[@"included"] != [NSNull null]) {
        NSArray *relationshipsArray = [(NSArray *)data[@"included"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type ==[c] %@", @"mediaRelationships"]];
        NSArray *animeArray = [(NSArray *)data[@"included"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type ==[c] %@", @"anime"]];
        NSArray *mangaArray = [(NSArray *)data[@"included"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type ==[c] %@", @"manga"]];
        NSMutableArray *manga_adaptations = [NSMutableArray new];
        NSMutableArray *prequels = [NSMutableArray new];
        NSMutableArray *sequels = [NSMutableArray new];
        NSMutableArray *side_stories = [NSMutableArray new];
        NSMutableArray *parent_story = [NSMutableArray new];
        NSMutableArray *character_anime = [NSMutableArray new];
        NSMutableArray *spin_offs = [NSMutableArray new];
        NSMutableArray *anime_adaptations = [NSMutableArray new];
        NSMutableArray *alternative_versions = [NSMutableArray new];
        for (NSDictionary *relation in relationshipsArray) {
            @autoreleasepool {
                NSString *role = relation[@"attributes"][@"role"];
                NSString *type = relation[@"relationships"][@"destination"][@"data"][@"type"];
                NSNumber *destid = relation[@"relationships"][@"destination"][@"data"][@"id"];
                NSArray *title = [[type isEqualToString:@"anime"] ? animeArray : mangaArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type ==[c] %@ AND id == %@", type, destid]];
                if (title.count > 0) {
                    NSDictionary *entry = title[0];
                    NSDictionary *finalentry = @{ [type isEqualToString:@"anime"] ? @"anime_id" : @"manga_id" : destid, @"title" : entry[@"attributes"][@"canonicalTitle"] };
                    if ([role isEqualToString:@"adaptation"]) {
                        [[type isEqualToString:@"anime"] ? anime_adaptations : manga_adaptations addObject:finalentry.copy];
                    }
                    else if ([role isEqualToString:@"prequel"]) {
                        [prequels addObject:finalentry.copy];
                    }
                    else if ([role isEqualToString:@"sequel"]) {
                        [sequels addObject:finalentry.copy];
                    }
                    else if ([role isEqualToString:@"side_story"]) {
                        [side_stories addObject:finalentry.copy];
                    }
                    else if ([role isEqualToString:@"parent_story"]) {
                        [parent_story addObject:finalentry.copy];
                    }
                    else if ([role isEqualToString:@"character"] && [type isEqualToString:@"anime"]) {
                        [character_anime addObject:finalentry.copy];
                    }
                    else if ([role isEqualToString:@"spinoff"]) {
                        [spin_offs addObject:finalentry.copy];
                    }
                    else if ([role isEqualToString:@"alternate_version"]) {
                        [alternative_versions addObject:finalentry.copy];
                    }
                }
            }
        }
        return @{@"manga_adaptations" : manga_adaptations.copy, @"prequels" : prequels.copy, @"sequels" : sequels.copy, @"side_stories" : side_stories.copy, @"parent_story" : parent_story.copy, @"character_anime" : character_anime.copy, @"spin_offs" : spin_offs.copy, @"anime_adaptations" : anime_adaptations.copy, @"alternative_versions" : alternative_versions.copy};
    }
    return nil;
}
+ (NSArray *)normalizeSeasonData:(NSArray *)seasonData withSeason:(NSString *)season withYear:(int)year {
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *d in seasonData) {
        @autoreleasepool {
            if (((NSNumber *)d[@"nsfw"]).boolValue) {
                continue;
            }
            AtarashiiAnimeObject *aobject = [AtarashiiAnimeObject new];
            aobject.titleid = ((NSNumber *)d[@"id"]).intValue;
            aobject.title = d[@"attributes"][@"canonicalTitle"];
            aobject.other_titles =  @{@"synonyms" : (d[@"attributes"][@"abbreviatedTitles"] && d[@"attributes"][@"abbreviatedTitles"]  != [NSNull null]) ? d[@"attributes"][@"abbreviatedTitles"] : @[], @"english" : d[@"attributes"][@"titles"][@"en"] && d[@"attributes"][@"titles"][@"en"] != [NSNull null] ? @[d[@"attributes"][@"titles"][@"en"]] : d[@"attributes"][@"titles"][@"en_jp"] && d[@"attributes"][@"titles"][@"en_jp"] != [NSNull null] ? @[d[@"attributes"][@"titles"][@"en_jp"]] : @[], @"japanese" : d[@"attributes"][@"titles"][@"ja_jp"] && d[@"attributes"][@"titles"][@"ja_jp"] != [NSNull null] ?  @[d[@"attributes"][@"titles"][@"ja_jp"]] : @[] };
            if (d[@"attributes"][@"posterImage"] != [NSNull null]) {
                aobject.image_url = d[@"attributes"][@"posterImage"][@"large"] && d[@"attributes"][@"posterImage"][@"large"] != [NSNull null] ? d[@"attributes"][@"posterImage"][@"large"] : @"";
            }
            aobject.type = [Utility convertAnimeType:d[@"attributes"][@"showType"]];
            NSMutableDictionary *finaldict = [[NSMutableDictionary alloc] initWithDictionary:aobject.NSDictionaryRepresentation];
            finaldict[@"year"] = @(year);
            finaldict[@"season"] = season;
            finaldict[@"service"] = @(2);
            [tmparray addObject:finaldict.copy];
        }
    }
    return tmparray.copy;
}
@end
