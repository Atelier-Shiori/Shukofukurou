//
//  AtarashiiAPIKitsuStaffFormat.h
//  MAL Library
//
//  Created by 桐間紗路 on 2018/01/04.
//  Copyright © 2018年 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AtarashiiAPIKitsuStaffFormat : NSObject
@property (strong) NSMutableArray *personarray;
@property (strong) NSMutableArray *castingarray;
@property (strong) NSMutableArray *anime_staff;
@property (strong) NSMutableArray *characters;
@property (strong) NSMutableArray *animecharacters;
- (id)initwithDataDictionary:(NSDictionary *)characterdata withStaffData:(NSDictionary *)staffdata;
- (NSDictionary *)generateStaffList;

@end
