//
//  AtarashiiAPIKitsuStaffFormat.m
//  MAL Library
//
//  Created by 桐間紗路 on 2018/01/04.
//  Copyright © 2018年 Atelier Shiori. All rights reserved.
//
//
//
//https://kitsu.io/api/edge/anime-staff?anime_id=7203&include=person&fields[people]=name,malId
//https://kitsu.io/api/edge/anime-characters?anime_id=7203&include=character,character.castings,character.castings.person&fields[castings]=voiceActor,featured,person&fields[people]=name,image,malId

#import "AtarashiiAPIKitsuStaffFormat.h"

@implementation AtarashiiAPIKitsuStaffFormat
- (id)initwithDataDictionary:(NSDictionary *)characterdata withStaffData:(NSDictionary *)staffdata {
    if ([super init]) {
        _personarray = [NSMutableArray new];
        _castingarray = [NSMutableArray new];
        _anime_staff = [NSMutableArray new];
        _characters = [NSMutableArray new];
        _animecharacters = [NSMutableArray new];
        if (characterdata[@"data"] && staffdata[@"data"]) {
            _animecharacters = characterdata[@"data"];
            NSArray *includes = characterdata[@"included"];
            [_personarray addObjectsFromArray:[includes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"people"]]];
            [_castingarray addObjectsFromArray:[includes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"castings"]]];
            [_characters addObjectsFromArray:[includes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"characters"]]];
            _anime_staff = staffdata[@"data"];
            includes = staffdata[@"included"];
            [_personarray addObjectsFromArray:[includes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"people"]]];
            [_castingarray addObjectsFromArray:[includes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"castings"]]];
        }
    }
    return self;
}

- (NSDictionary *)generateStaffList {
    // Generate character list
    NSMutableArray *characterarray = [NSMutableArray new];
    for (NSDictionary *acharacter in _animecharacters) {
        NSDictionary *cdata = [self findAnimeCharacter:acharacter[@"relationships"][@"character"][@"data"][@"id"]];
        if (cdata) {
            NSNumber *characterid = cdata[@"id"];
            NSString *role = acharacter[@"attributes"][@"role"];
            NSString *charactername = cdata[@"attributes"][@"canonicalName"];
            NSString *description = cdata[@"attributes"][@"description"];
            NSString *imageurl = cdata[@"attributes"][@"image"][@"original"];
            NSMutableArray *castingsarray = [NSMutableArray new];
            for (NSDictionary *castings in cdata[@"relationships"][@"castings"][@"data"]) {
                NSDictionary *casting = [self findcasting:castings[@"id"]];
                if (casting[@"relationships"][@"person"][@"data"] != [NSNull null]) {
                    NSDictionary *voiceactor = [self findPerson:casting[@"relationships"][@"person"][@"data"][@"id"]];
                    if (voiceactor) {
                        [castingsarray addObject:@{@"id" : voiceactor[@"id"], @"name" : voiceactor[@"attributes"][@"name"], @"image" : voiceactor[@"attributes"][@"image"] , @"language" : voiceactor[@"attributes"][@"language"]}];
                    }
                }
            }
            [characterarray addObject:@{@"id" : characterid, @"name" : charactername, @"role" : role, @"image" : imageurl, @"description" : description}];
        }
    }
    // Generate staff list
    NSMutableArray *staffarray = [NSMutableArray new];
    
    for (NSDictionary *staffdata in _anime_staff) {
        NSDictionary *sdata = [self findPerson:staffdata[@"relationships"][@"person"][@"data"][@"id"]];
        if (sdata) {
            NSNumber *personid = sdata[@"id"];
            NSString *personname = sdata[@"attributes"][@"name"];
            NSString *imageurl = sdata[@"attributes"][@"image"];
            NSString *role = staffdata[@"attributes"][@"role"];
            [staffarray addObject:@{@"id" : personid, @"name" : personname, @"image" : imageurl, @"role" : role}];
        }
    }
    NSDictionary *finaldict = [@{@"Characters" : characterarray, @"Staff" : staffarray} copy];
    // Clear Arrays
    _personarray = nil;
    _castingarray = nil;
    _anime_staff = nil;
    _characters = nil;
    _animecharacters = nil;
    return finaldict;
}

- (NSDictionary *)findPerson:(NSNumber *)personid {
    NSArray *filtered = [_personarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", personid]];
    if (filtered.count > 0) {
        return filtered[0];
    }
    return nil;
}

- (NSDictionary *)findcasting:(NSNumber *)castingid {
    NSArray *filtered = [_castingarray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", castingid]];
    if (filtered.count > 0) {
        return filtered[0];
    }
    return nil;
}

- (NSDictionary *)findAnimeCharacter:(NSNumber *)characterid {
    NSArray *filtered = [_characters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", characterid]];
    if (filtered.count > 0) {
        return filtered[0];
    }
    return nil;
}

@end
