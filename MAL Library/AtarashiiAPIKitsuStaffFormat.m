//
//  AtarashiiAPIKitsuStaffFormat.m
//  MAL Library
//
//  Created by 桐間紗路 on 2018/01/04.
//  Copyright © 2018年 Atelier Shiori. All rights reserved.
//
//https://kitsu.io/api/edge/anime/7203/anime-staff?include=person,person.castings

#import "AtarashiiAPIKitsuStaffFormat.h"

@implementation AtarashiiAPIKitsuStaffFormat
- (id)initwithDataDictionary:(NSDictionary *)data {
    if ([super init]) {
        if (data[@"data"]) {
            _anime_staff = data[@"data"];
            NSArray *includes = data[@"included"];
            _personarray = [includes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"person"]];
            _castingarray = [includes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"castings"]];
        }
    }
    return self;
}
- (NSArray *)generateStaffList {
    
}
- (NSDictionary *)findPerson:(NSNumber *)personid {
    
}
- (NSDictionary *)findcasting:(NSNumber *)castingid {
    
}
@end
