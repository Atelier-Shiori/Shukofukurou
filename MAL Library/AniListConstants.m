//
//  AniListConstants.m
//  Shukofukurou
//
//  Created by 小鳥遊六花 on 4/2/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import "AniListConstants.h"

@implementation AniListConstants
#pragma mark Query
NSString *const kAnilisttoMALId = @"query ($id: Int!, $type: MediaType) {\n  Media(id: $id, type: $type) {\n    id\n    idMal\n  }\n}";
NSString *const kMALtoAniListId = @"query ($id: Int!, $type: MediaType) {\n  Media(idMal: $id, type: $type) {\n    id\n    idMal\n  }\n}";
NSString *const kAnilistTitleIdInformation = @"query ($id: Int!, $type: MediaType) {\n  Media(id: $id, type: $type) {\n    id\n    idMal\n    title {\n      romaji\n      english\n      native\n      userPreferred\n    }\n    startDate {\n      year\n      month\n      day\n    }\n    endDate {\n      year\n      month\n      day\n    }\n    coverImage {\n      large\n      medium\n    }\n    bannerImage\n    format\n    type\n    status\n    episodes\n    duration\n    chapters\n    volumes\n    description\n    averageScore\n    popularity\n    genres\n    synonyms\n    source\n   season\n    isAdult\n    hashtag\n    studios {\n      edges {\n        id\n        node {\n          name\n        }\n      }\n    }\n    relations {\n      edges {\n        relationType\n        node {\n          id\n          title {\n            romaji\n            english\n            native\n          }\n          type\n          coverImage {\n            large\n          }\n        }\n      }\n    }\n    tags {\n      id\n      name\n      description\n      category\n      rank\n      isGeneralSpoiler\n      isMediaSpoiler\n      isAdult\n    }\n    rankings {\n      id\n      rank\n      type\n      format\n      year\n      season\n      allTime\n      context\n    }\n  }\n}";
NSString *const kAnilistUsernametoUserId = @"query ($name: String) {\n  User (name: $name) {\n    id\n    name\n }\n}";
NSString *const kAnilistCurrentUsernametoUserId = @"{\n  Viewer {\n    id\n    name\n    avatar {\n      large\n      medium\n    }\n    mediaListOptions {\n      scoreFormat\n    }\n  }\n}";
NSString *const kAnilistanimeList = @"query ($id : Int!, $page: Int) {\n  AnimeList: Page (page: $page) {\n    mediaList(userId: $id, type: ANIME) {\n      id :media{id, idMal}\n      entryid: id\n      title: media {title {\n        title: userPreferred\n      }}\n      episodes: media{episodes}\n      duration: media{duration}\n      image_url: media{coverImage {\n        large\n        medium\n      }}\n        type: media{format}\n      status: media{status}\n      score: score(format: POINT_100)\n      watched_episodes: progress\n      watched_status: status\n      rewatch_count: repeat\n      private\n      notes\n      updatedAt\n      watching_start: startedAt {\n        year\n        month\n        day\n      }\n      watching_end: completedAt {\n        year\n        month\n        day\n      }\n      customLists(asArray:true)\n    }\n        pageInfo {\n      total\n      currentPage\n      lastPage\n      hasNextPage\n      perPage\n    }\n  }\n}";
NSString *const kAnilistmangaList = @"query ($id : Int!, $page: Int) {\n  MangaList: Page (page: $page) {\n    mediaList(userId: $id, type: MANGA) {\n      id :media{id,idMal}\n      entryid: id\n      title: media {title {\n        title: userPreferred\n      }}\n      chapters: media{chapters}\n      volumes: media{volumes}\n      image_url: media{coverImage {\n        large\n        medium\n      }}\n      type: media{format}\n      status: media{status}\n      score: score(format: POINT_100)\n      read_chapters: progress\n      read_volumes: progressVolumes\n      read_status: status\n      reread_count: repeat\n      private\n      notes\n      updatedAt\n      read_start: startedAt {\n        year\n        month\n        day\n      }\n      read_end: completedAt {\n        year\n        month\n        day\n      }\n      customLists(asArray:true)\n    }\n        pageInfo {\n      total\n      currentPage\n      lastPage\n      hasNextPage\n      perPage\n    }\n  }\n}";
NSString *const kAnilistreviewbytitleid = @"query ($id: Int!, $page: Int) {\n  Page (page: $page) {\n    reviews (mediaId: $id){\n      id\n      body(asHtml: true)\n      rating\n      ratingAmount\n      score\n      createdAt\n      updatedAt\n      user {\n        id\n        name\n        avatar {\n          large\n        }\n      }\n    }\n        pageInfo {\n      total\n      currentPage\n      lastPage\n      hasNextPage\n      perPage\n    }\n  }\n}";
NSString *const kAnilisttitlesearch = @"query ($query: String, $type: MediaType) {\n  Page(perPage: 50) {\n    media(search: $query, type: $type) {\n      id\n      title {\n        userPreferred\n        english\n        romaji\n      }\n      synonyms\n      coverImage {\n        medium\n        large\n      }\n      format\n      type\n      status\n      episodes\n      chapters\n      volumes\n      isAdult\n    }\n  }\n}\n\n";
NSString *const kAnilistcharacterslist = @"query ($id: Int!, $page: Int = 1, $type: MediaType) {\n  Media(id: $id, type: $type) {\n    id\n    characters(page: $page, sort: [ROLE]) {\n      pageInfo {\n        total\n        perPage\n        hasNextPage\n        currentPage\n        lastPage\n      }\n      edges {\n        node {\n          id\n          name {\n            first\n            last\n          }\n          image {\n            medium\n            large\n          }\n          description\n        }\n        role\n        voiceActors {\n          id\n          name {\n            first\n            last\n            native\n          }\n          image {\n            medium\n            large\n          }\n          language\n        }\n      }\n    }\n  }\n}";
NSString *const kAniliststafflist = @"query ($id: Int!, $page: Int = 1, $type: MediaType) {\n  Media(id: $id, type: $type) {\n    id\n    staff(page: $page, sort:[ROLE]) {\n       pageInfo {\n        total\n        perPage\n        hasNextPage\n        currentPage\n        lastPage\n      }\n      staff:edges {\n        person:node {\n          id\n          name {\n            first\n            last\n            native\n          }\n          image {\n            large\n            medium\n          }\n        }\n      }\n    }\n  }\n}";
NSString *const kAniListstaffpage = @"query ($id: Int!) {\n  Staff(id: $id) {\n    id\n    name {\n      first\n      last\n      native\n    }\n    image {\n      large\n      medium\n    }\n    description(asHtml: true)\n    favourites\n    language\n    staffMedia(page: 1, sort: [START_DATE_DESC]) {\n      edges {\n        id\n        node {\n          id\n          type\n          title {\n            romaji\n          }\n          coverImage {\n            large\n          }\n        }\n        staffRole\n      }\n    }\n    characters(sort: [ROLE_DESC]) {\n      edges {\n        id\n        node {\n        id\n          name {\n            first\n            last\n          }\n          image {\n            large\n          }\n        }\n        role\n        media {\n          id\n          title {\n            romaji\n          }\n        }\n      }\n    }\n  }\n}\n\n\n";
NSString *const kAniListcharacterpage = @"query ($id: Int!) {\n  Character(id: $id) {\n    id\n    name {\n      first\n      last\n      native\n    }\n    image {\n      large\n      medium\n    }\n    description(asHtml: true)\n    favourites\n    media(sort: [START_DATE_DESC]) {\n      pageInfo {\n        total\n        perPage\n        currentPage\n        lastPage\n        hasNextPage\n      }\n      edges {\n        id\n        node {\n          id\n          type\n          title {\n            userPreferred\n            romaji\n          }\n          coverImage {\n      large\n      medium\n    }\n        }\n        characterRole\n        voiceActors {\n          id\n          name {\n            first\n            last\n            native\n          }\n          image {\n            medium\n            large\n          }\n          language\n        }\n      }\n    }\n  }\n}\n\n";
NSString *const kAnilistpersonbyid = @"query ($season: MediaSeason, $seasonYear: Int, $page: Int) {\n   Page (page : $page) {\n     media(season: $season, seasonYear: $seasonYear, type: ANIME) {\n      id\n      idMal\n      isAdult\n      title {\n        romaji\n        english\n        native\n        userPreferred\n      }\n      format\n     }\n    pageInfo {\n      total\n      currentPage\n      lastPage\n      hasNextPage\n      perPage\n    }\n   }\n}";
NSString *const kAnilistUserProfileByUsername = @"query ($name: String) {\n  User (name: $name) {\n    id\n    name\n    about # (asHtml: true)\n    donatorTier\n    isFollowing\n    mediaListOptions {\n      scoreFormat\n    }\n    avatar {\n      large\n      medium\n    }\n    updatedAt\n  }\n}";
NSString *const kAniListSeason = @"query ($season: MediaSeason, $seasonYear: Int, $page: Int) {\n   Page (page : $page) {\n     media(season: $season, seasonYear: $seasonYear, type: ANIME) {\n      id\n      idMal\n      isAdult\n      coverImage {\n        large\n        medium\n      }\n      title {\n        romaji\n        english\n        native\n        userPreferred\n      }\n      format\n     }\n    pageInfo {\n      total\n      currentPage\n      lastPage\n      hasNextPage\n      perPage\n    }\n   }\n}";
NSString *const kAniListAiring = @"query ($page: Int) {\n   Page (page : $page) {\n     media(status: RELEASING, type: ANIME) {\n      id\n      idMal\n      isAdult\n      title {\n        romaji\n        english\n        native\n        userPreferred\n      }\n      episodes\n      format\n      meanScore\n      description\n      coverImage {\n        large\n        medium\n      }\n      nextAiringEpisode {\n        id\n        airingAt\n      }\n     }\n    pageInfo {\n      total\n      currentPage\n      lastPage\n      hasNextPage\n      perPage\n    }\n   }\n}";
NSString *const kAnilistRetrieveListTitleIdsOnly = @"query ($id : Int!, $page: Int, $type : MediaType) {\n  List: Page (page: $page) {\n    mediaList(userId: $id, type: $type) {\n      id :media{id, idMal}\n    }\n        pageInfo {\n      total\n      currentPage\n      lastPage\n      hasNextPage\n      perPage\n    }\n  }\n}";
NSString *const kAnilistCharacterSearch = @"query ($query : String) {\n  Page(perPage: 50) {\n     characters(search: $query) {\n      id\n      name {\n        first\n        last\n        native\n      }\n      image {\n        large\n        medium\n      }\n    }\n  } \n}";
NSString *const kAniListStaffSearch = @"query ($query: String) {\n  Page(perPage: 50) {\n     staff(search: $query) {\n      id\n      name {\n        first\n        last\n        native\n      }\n      image {\n        large\n        medium\n      }\n    }\n  }\n}";
NSString *const kAniListNextEpisode = @"query ($id: Int!) {\n  Media(id: $id, type: ANIME) {\n    id\n    idMal\n    title {\n      romaji\n    }\n    status\n    nextAiringEpisode {\n      id\n      airingAt\n      episode\n    }\n  }\n}\n\n\n";
#pragma mark mutations
NSString *const kAnilistAddAnimeListEntry = @"mutation ($mediaid : Int, $progress : Int, $status : MediaListStatus, $score : Int) {\n    SaveMediaListEntry(mediaId: $mediaid, progress: $progress, status: $status, scoreRaw: $score) {\n      id\n    progress\n    status\n    score(format: POINT_100)\n      updatedAt\n  }\n}";
NSString *const kAnilistAddMangaListEntry = @"mutation ($mediaid : Int, $progress : Int, $progressVolumes : Int,  $status : MediaListStatus, $score : Int) {\n    SaveMediaListEntry(mediaId: $mediaid, progress: $progress, progressVolumes: $progressVolumes,status: $status, scoreRaw: $score) {\n      id\n    progress\n    progressVolumes\n    status\n    score(format: POINT_100)\n      updatedAt\n  }\n}";
NSString *const kAnilistUpdateAnimeListEntrySimple = @"mutation ($id : Int, $progress : Int, $status : MediaListStatus, $score : Int) {\n    SaveMediaListEntry(id: $id, progress: $progress, status: $status, scoreRaw: $score) {\n      id\n    progress\n    status\n    score(format: POINT_100)\n      updatedAt\n  }\n}";
NSString *const kAnilistUpdateMangaListEntrySimple = @"mutation ($id : Int, $progress : Int, $progressVolumes : Int,  $status : MediaListStatus, $score : Int) {\n    SaveMediaListEntry(id: $id, progress: $progress, progressVolumes: $progressVolumes,status: $status, scoreRaw: $score) {\n      id\n    progress\n    progressVolumes\n    status\n    score(format: POINT_100)\n      updatedAt\n  }\n}";
NSString *const kAnilistUpdateAnimeListEntryAdvanced = @"mutation ($id : Int, $progress : Int, $status : MediaListStatus, $score : Int, $notes : String, $private : Boolean, $startedAt : FuzzyDateInput, $completedAt : FuzzyDateInput, $reconsumeCount : Int) {\n    SaveMediaListEntry(id: $id, progress: $progress, status: $status, scoreRaw: $score, notes: $notes, private: $private, startedAt: $startedAt, completedAt: $completedAt, repeat: $reconsumeCount) {\n      id\n    progress\n    status\n    score(format: POINT_100)\n    notes\n    private\n    startedAt {\n      year\n      month\n      day\n    }\n    completedAt {\n      year\n      month\n      day\n    }\n      updatedAt\n  }\n}";
NSString *const kAnilistUpdateMangaListEntryAdvanced = @"mutation ($id : Int, $progress : Int, $progressVolumes : Int, $status : MediaListStatus, $score : Int, $notes : String, $private : Boolean, $startedAt : FuzzyDateInput, $completedAt : FuzzyDateInput, $reconsumeCount : Int) {\n    SaveMediaListEntry(id: $id, progress: $progress, progressVolumes: $progressVolumes, status: $status, scoreRaw: $score, notes: $notes, private: $private, startedAt: $startedAt, completedAt: $completedAt, repeat: $reconsumeCount) {\n      id\n    progress\n    progressVolumes\n    status\n    score(format: POINT_100)\n    notes\n    private\n    startedAt {\n      year\n      month\n      day\n    }\n    completedAt {\n      year\n      month\n      day\n    }\n      updatedAt\n  }\n}";
NSString *const kAnilistDeleteListEntry = @"mutation ($id : Int) {\n  DeleteMediaListEntry (id: $id) {\n    deleted\n  }\n}";
NSString *const kAnilistModifyCustomLists = @"mutation ($id : Int, $custom_lists : [String] ) {\n    SaveMediaListEntry(id: $id, customLists : $custom_lists) {\n      id\n        customLists(asArray:true)\n      updatedAt\n  }\n}";
@end
