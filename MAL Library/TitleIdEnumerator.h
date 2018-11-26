//
//  TitleIdEnumerator.h
//  Shukofukurou-IOS
//
//  Created by 香風智乃 on 11/12/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TitleIdEnumerator : NSObject
@property (strong) NSMutableArray *titleidmap;
@property int sourceserviceid;
@property int targetserviceid;
@property int type;
@property (strong) NSArray *tmplist;
@property int currentposition;
@property (nonatomic, copy) void (^completionHandler)(TitleIdEnumerator *titleidenum);
- (instancetype) initWithList:(NSArray *)list withType:(int)type completion:(void (^)(TitleIdEnumerator *titleidenum))completionHandler;
- (void)generateTitleIdMappingList:(int)sourceserviceid toService:(int)targetserviceid;
- (int)findTargetIdFromSourceId:(int)sourceid;
@end

NS_ASSUME_NONNULL_END
