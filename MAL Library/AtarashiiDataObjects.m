//
//  AtarashiiDataObjects.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/12/19.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "AtarashiiDataObjects.h"

@implementation AtarashiiAnimeObject
- (id)init {
    if ([super init]) {
        self.titleid = 0;
        self.title = @"";
        self.other_titles = @{};
        self.rank = 0;
        self.popularity_rank = 0;
        self.image_url = @"";
        self.type = @"";
        self.episodes = 0;
        self.status = @"";
        self.start_date = @"";
        self.end_date = @"";
        self.broadcast = @"";
        self.duration = 0;
        self.classification = @"";
        self.members_score = 0;
        self.members_count = 0;
        self.favorited_count = 0;
        self.synposis = @"";
        self.background = @"";
        self.producers = @[];
        self.genres = @[];
        self.manga_adaptations = @[];
        self.prequels = @[];
        self.sequels = @[];
        self.side_stories = @[];
        self.parent_story = @[];
        self.character_anime = @[];
        self.spin_offs = @[];
        self.opening_theme = @[];
        self.ending_theme = @[];
        self.recommendations = @[];
        self.mappings = @{};
    }
    return self;
}

- (NSDictionary *)NSDictionaryRepresentation {
    return @{ @"id" : @(_titleid), @"title" : _title, @"other_titles" : _other_titles, @"rank" : @(_rank), @"popularity_rank" : @(_popularity_rank), @"image_url" : _image_url, @"type" : _type, @"episodes" : @(_episodes), @"status" : _status, @"start_date" : _start_date, @"end_date" : _end_date, @"broadcast" : _broadcast, @"duration" : @(_duration), @"classification" : _classification, @"members_score" : @(_members_score), @"members_count" : @(_members_count), @"favorited_count" : @(_favorited_count), @"synopsis" : _synposis, @"background" : _background, @"producers" : _producers, @"genres" : _genres, @"manga_adaptations" : _manga_adaptations, @"prequels" : _prequels, @"sequels" : _sequels, @"side_stories" : _side_stories, @"parent_story" : _parent_story, @"character_anime" : _character_anime, @"spin_offs" : _spin_offs, @"opening_theme" : _opening_theme, @"ending_theme" : _ending_theme, @"recommendations" : _recommendations, @"mappings" : _mappings };
}
@end

@implementation AtarashiiMangaObject
- (id)init {
    if ([super init]) {
        self.titleid = 0;
        self.title = @"";
        self.other_titles = @{};
        self.rank = 0;
        self.popularity_rank = 0;
        self.image_url = @"";
        self.type = @"";
        self.chapters = 0;
        self.volumes = 0;
        self.status = @"";
        self.members_score = 0;
        self.members_count = 0;
        self.favorited_count = 0;
        self.synposis = @"";
        self.genres = @[];
        self.anime_adaptations = @[];
        self.related_manga = @[];
        self.alternative_versions = @[];
        self.mappings = @{};
    }
    return self;
}

- (NSDictionary *)NSDictionaryRepresentation {
    return @{ @"id" : @(_titleid), @"title" : _title, @"other_titles" : _other_titles, @"rank" : @(_rank), @"popularity_rank" : @(_popularity_rank), @"image_url" : _image_url, @"type" : _type, @"chapters" : @(_chapters), @"volumes": @(_volumes), @"status" : _status, @"members_score" : @(_members_score), @"members_count" : @(_members_count), @"favorited_count" : @(_favorited_count), @"synopsis" : _synposis, @"genres" : _genres, @"anime_adaptations" : _anime_adaptations, @"related_manga" : _related_manga, @"alternate_versions" : _alternative_versions, @"mappings" : _mappings};
}
@end

@implementation AtarashiiAnimeListObject
- (id)init {
    if ([super init]) {
        self.titleid = 0;
        self.title = @"";
        self.entryid = 0;
        self.episodes = 0;
        self.episode_length = 0;
        self.image_url = @"";
        self.type = @"";
        self.status = @"";
        self.watched_status = @"";
        self.watched_episodes = 0;
        self.score = 0;
        self.score_type = 0;
        self.watching_start = @"";
        self.watching_end = @"";
        self.rewatching = false;
        self.rewatch_count = 0;
        self.personal_comments = @"";
    }
    return self;
}

- (NSDictionary *)NSDictionaryRepresentation {
    return @{ @"id" : @(_titleid), @"entryid" : @(_entryid), @"title" : _title, @"episodes" : @(_episodes), @"duration" : @(_episode_length), @"image_url": _image_url, @"type" : _type, @"status" : _status, @"watched_status" : _watched_status, @"watched_episodes" : @(_watched_episodes), @"score" : @(_score), @"score_type" : @(_score_type), @"watching_start" : _watching_start, @"watching_end" : _watching_end, @"rewatching" : @(_rewatching), @"rewatch_count" : @(_rewatch_count), @"personal_comments" : _personal_comments, @"private": @(_private_entry)};
}
@end

@implementation AtarashiiMangaListObject
- (id)init {
    if ([super init]) {
        self.titleid = 0;
        self.title = @"";
        self.entryid = 0;
        self.chapters = 0;
        self.volumes = 0;
        self.image_url = @"";
        self.type = @"";
        self.status = @"";
        self.read_status = @"";
        self.chapters_read = 0;
        self.volumes_read = 0;
        self.score = 0;
        self.score_type = 0;
        self.reading_start = @"";
        self.reading_end = @"";
        self.rereading = false;
        self.reread_count = 0;
        self.personal_comments = @"";
    }
    return self;
}

- (NSDictionary *)NSDictionaryRepresentation {
    return @{ @"id" : @(_titleid), @"entryid" : @(_entryid), @"title" : _title, @"chapters" : @(_chapters), @"volumes" : @(_volumes), @"image_url": _image_url, @"type" : _type, @"status" : _status, @"read_status" : _read_status, @"chapters_read" : @(_chapters_read), @"volumes_read" : @(_volumes_read), @"score" : @(_score), @"score_type" : @(_score_type), @"watching_start" : _reading_start, @"reading_end" : _reading_end, @"rereading" : @(_rereading), @"reread_count" : @(_reread_count), @"personal_comments" : _personal_comments, @"private": @(_private_entry)};
}
@end

@implementation AtarashiiPersonObject
- (id)init {
    if ([super init]) {
        _personid = 0;
        _name = @"";
        _alternate_names = @[];
        _given_name = @"";
        _familyname = @"";
        _birthdate = @"";
        _website_url = @"";
        _more_details = @"";
        _favorited_count = 0;
        _voice_acting_roles = @[];
        _anime_staff_positions = @[];
        _published_manga = @[];
    }
    return self;
}

- (NSDictionary *)NSDictionaryRepresentation {
    return @{@"id" : @(_personid), @"name" : _name, @"alternate_names" : _alternate_names, @"family_name" : _familyname, @"birthdate" : _birthdate, @"website_url" : _website_url, @"more_details" : _more_details, @"favorited_count" : @(_favorited_count), @"voice_acting_roles" : _voice_acting_roles, @"anime_staff_positions" : _anime_staff_positions, @"published_manga" : _published_manga};
}
@end

@implementation AtarashiiVoiceActingRoleObject
- (id)init {
    if ([super init]) {
        _characterid = 0;
        _name = @"";
        _image_url = @"";
        _main_role = false;
        _anime = @[];
    }
    return self;
}

- (NSDictionary *)NSDictionaryRepresentation {
    return @{@"id" : @(_characterid), @"name" : _name, @"image_url" : _image_url, @"main_role" : @(_main_role), @"anime" : _anime,};
}
@end

@implementation AtarrashiiStaffObject
- (id)init {
    if ([super init]) {
        _position = @"";
        _details = @"";
        _anime = @[];
    }
    return self;
}

- (NSDictionary *)NSDictionaryRepresentation {
    return @{@"position" : _position, @"details" : _details, @"anime" : _anime};
}
@end

@implementation AtarashiiPublishedMangaObject
- (id)init {
    if ([super init]) {
        _position = @"";
        _manga = @[];
    }
    return self;
}

- (NSDictionary *)NSDictionaryRepresentation {
    return @{@"position" : _position, @"manga" : _manga};
}
@end

@implementation AtarashiiReviewObject
- (id)init {
    if ([super init]) {
        self.username = @"";
        self.date = @"";
        self.avatar_url = @"";
        self.review = @"";
    }
    return self;
}
- (NSDictionary *)NSDictionaryRepresentation {
    if (self.mediatype == 0) {
        return @{@"date" : _date, @"rating" : @(_rating), @"username" : _username, @"episodes" : @(_episodes), @"watched_episodes" : @(_watched_episodes), @"helpful" : @(_helpful), @"helpful_total" : @(_helpful_total), @"avatar_url" : _avatar_url, @"review" : _review };
    }
    else {
        return @{@"date" : _date, @"rating" : @(_rating), @"username" : _username, @"chapters" : @(_chapters), @"read_chapters" : @(_read_chapters), @"helpful" : @(_helpful), @"helpful_total" : @(_helpful_total), @"avatar_url" : _avatar_url, @"review" : _review };
    }
    return @{};
}
@end

@implementation AtarashiiUserObject
- (id)init {
    if ([super init]) {
        self.avatar_url = @"";
        self.last_online = @"";
        self.gender = @"";
        self.birthday = @"";
        self.location = @"";
        self.website = @"";
        self.join_date = @"";
        self.access_rank = @"";
        self.anime_list_views = 0;
        self.manga_list_views = 0;
        self.forum_posts = 0;
        self.reviews = 0;
        self.recommendations = 0;
        self.blog_posts = 0;
        self.clubs = 0;
        self.comments = 0;
        self.extradict = @{};
    }
    return self;
}
- (NSDictionary *)NSDictionaryRepresentation {
    return @{@"avatar_url" : _avatar_url, @"details" : @{@"last_online" : _last_online, @"gender" :  _gender, @"birthday" : _birthday, @"location" : _location, @"website" : _website, @"join_date" : _join_date, @"access_rank" : _access_rank, @"anime_list_views" : @(_anime_list_views), @"manga_list_views" : @(_manga_list_views), @"forum_posts" : @(_forum_posts), @"reviews" : @(_reviews), @"recommendations" : @(_recommendations), @"blog_posts" : @(_blog_posts), @"clubs" : @(_clubs), @"comments" : @(_comments), @"extra" : _extradict}};
}
@end
