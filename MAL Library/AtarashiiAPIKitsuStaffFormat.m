//
//  AtarashiiAPIKitsuStaffFormat.m
//  MAL Library
//
//  Created by 桐間紗路 on 2018/01/04.
//  Copyright © 2018年 Atelier Shiori. All rights reserved.
//
//https://kitsu.io/api/edge/castings?anime_id=7203?&include=person,person.castings

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
    return nil;
}
- (NSDictionary *)findPerson:(NSNumber *)personid {
    return nil;
}
- (NSDictionary *)findcasting:(NSNumber *)castingid {
    return nil;
}
@end
