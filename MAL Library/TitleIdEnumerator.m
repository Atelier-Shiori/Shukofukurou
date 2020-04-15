//
//  TitleIdEnumerator.m
//  Shukofukurou-IOS
//
//  Created by 香風智乃 on 11/12/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import "TitleIdEnumerator.h"
#import "TitleIDMapper.h"

@interface TitleIdEnumerator ()
@property (strong) TitleIDMapper *mapper;
@end

@implementation TitleIdEnumerator
- (instancetype) initWithList:(NSArray *)list withType:(int)type completion:(void (^)(TitleIdEnumerator *titleidenum))completionHandler {
    if (self = [super init]) {
        self.tmplist = list;
        self.type = type;
        _completionHandler = completionHandler;
        _titleidmap = [NSMutableArray new];
        _mapper = [TitleIDMapper sharedInstance];
    }
    return self;
}
- (void)generateTitleIdMappingList:(int)sourceserviceid toService:(int)targetserviceid {
    _currentposition = 0;
    _sourceserviceid = sourceserviceid;
    _targetserviceid = targetserviceid;
    [self performListConvert];
}
- (void)performListConvert {
    if (_currentposition == _tmplist.count) {
        NSLog(@"Complete");
        _completionHandler(self);
        return;
    }
    switch (_sourceserviceid) {
        case 1: {
            switch (_targetserviceid) {
                case 1: {
                    [self titleidconvertSuccess:((NSNumber *)self.tmplist[_currentposition][@"id"]).intValue withTargetid:((NSNumber *)self.tmplist[_currentposition][@"id"]).intValue];
                    break;
                }
                case 2: {
                    [_mapper retrieveTitleIdForService:1 withTitleId:((NSNumber *)_tmplist[self.currentposition][@"id"]).stringValue withTargetServiceId:2 withType:_type completionHandler:^(id  _Nonnull titleid, bool success) {
                        if (success) {
                            [self titleidconvertSuccess:((NSNumber *)self.tmplist[self.currentposition][@"id"]).intValue withTargetid:((NSNumber *)titleid).intValue];
                        }
                        else {
                             [self titleidconvertFailure:((NSNumber *)self.tmplist[self.currentposition][@"id"]).intValue];
                        }
                    }];
                    break;
                }
                case 3: {
                    [_mapper retrieveTitleIdForService:1 withTitleId:((NSNumber *)_tmplist[self.currentposition][@"id"]).stringValue withTargetServiceId:3 withType:_type completionHandler:^(id  _Nonnull titleid, bool success) {
                        if (success && ![titleid isKindOfClass:[NSNull class]]) {
                            [self titleidconvertSuccess:((NSNumber *)self.tmplist[self.currentposition][@"id"]).intValue withTargetid:((NSNumber *)titleid).intValue];
                        }
                        else {
                            [self titleidconvertFailure:((NSNumber *)self.tmplist[self.currentposition][@"id"]).intValue];
                        }
                    }];
                    break;
                }
            }
            break;
        }
        case 2: {
            switch (_targetserviceid) {
                case 1: {
                    [_mapper retrieveTitleIdForService:2 withTitleId:((NSNumber *)_tmplist[self.currentposition][@"id"]).stringValue withTargetServiceId:1 withType:_type completionHandler:^(id  _Nonnull titleid, bool success) {
                        if (success) {
                            [self titleidconvertSuccess:((NSNumber *)self.tmplist[self.currentposition][@"id"]).intValue withTargetid:((NSNumber *)titleid).intValue];
                        }
                        else {
                            [self titleidconvertFailure:((NSNumber *)self.tmplist[self.currentposition][@"id"]).intValue];
                        }
                    }];
                    break;
                }
                case 2: {
                    [self titleidconvertSuccess:((NSNumber *)self.tmplist[_currentposition][@"id"]).intValue withTargetid:((NSNumber *)self.tmplist[_currentposition][@"id"]).intValue];
                    break;
                }
                case 3: {
                    [_mapper retrieveTitleIdForService:2 withTitleId:((NSNumber *)_tmplist[self.currentposition][@"id"]).stringValue withTargetServiceId:3 withType:_type completionHandler:^(id  _Nonnull titleid, bool success) {
                        if (success && titleid != [NSNull null]) {
                            [self titleidconvertSuccess:((NSNumber *)self.tmplist[self.currentposition][@"id"]).intValue withTargetid:((NSNumber *)titleid).intValue];
                        }
                        else {
                            [self titleidconvertFailure:((NSNumber *)self.tmplist[self.currentposition][@"id"]).intValue];
                        }
                    }];
                    break;
                }
            }
            break;
        }
        case 3: {
            switch (_targetserviceid) {
                case 1: {
                    [_mapper retrieveTitleIdForService:3 withTitleId:((NSNumber *)_tmplist[self.currentposition][@"id"]).stringValue withTargetServiceId:1 withType:_type completionHandler:^(id  _Nonnull titleid, bool success) {
                        if (success) {
                            [self titleidconvertSuccess:((NSNumber *)self.tmplist[self.currentposition][@"id"]).intValue withTargetid:((NSNumber *)titleid).intValue];
                        }
                        else {
                            [self titleidconvertFailure:((NSNumber *)self.tmplist[self.currentposition][@"id"]).intValue];
                        }
                    }];
                    break;
                }
                case 2: {
                    [_mapper retrieveTitleIdForService:3 withTitleId:((NSNumber *)_tmplist[self.currentposition][@"id"]).stringValue withTargetServiceId:2 withType:_type completionHandler:^(id  _Nonnull titleid, bool success) {
                        if (success) {
                            [self titleidconvertSuccess:((NSNumber *)self.tmplist[self.currentposition][@"id"]).intValue withTargetid:((NSNumber *)titleid).intValue];
                        }
                        else {
                            [self titleidconvertFailure:((NSNumber *)self.tmplist[self.currentposition][@"id"]).intValue];
                        }
                    }];
                    break;
                }
                case 3: {
                    [self titleidconvertSuccess:((NSNumber *)self.tmplist[_currentposition][@"id"]).intValue withTargetid:((NSNumber *)self.tmplist[_currentposition][@"id"]).intValue];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)titleidconvertSuccess:(int)sourceid withTargetid:(int)targetid {
    NSLog(@"Success. Source id: %i, Target id: %i", sourceid, targetid);
    [_titleidmap addObject:@{@"source_id" : @(sourceid), @"target_id" : @(targetid)}];
    _currentposition++;
    [self performListConvert];
}

- (void)titleidconvertFailure:(int)sourceid {
    NSLog(@"Failure. Source id: %i", sourceid);
    [_titleidmap addObject:@{@"source_id" : @(sourceid), @"target_id" : @(0)}];
    _currentposition++;
    [self performListConvert];
}

- (int)findTargetIdFromSourceId:(int)sourceid {
    NSArray *filtered = [_titleidmap filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"source_id == %i", sourceid]];
    if (filtered.count > 0) {
        return ((NSNumber *)filtered[0][@"target_id"]).intValue;
    }
    return -1;
}
@end
