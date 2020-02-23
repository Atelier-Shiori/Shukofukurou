//
//  HistoryManager.h
//  Shukofukurou-IOS
//
//  Created by 天々座理世 on 7/30/19.
//  Copyright © 2019 MAL Updater OS X Group. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HistoryManager : NSObject
typedef NS_ENUM(unsigned int, HistoryActionType) {
    HistoryActionTypeAddTitle = 0,
    HistoryActionTypeUpdateTitle = 1,
    HistoryActionTypeIncrement = 2,
    HistoryActionTypeDeleteTitle = 3,
    HistoryActionTypeScrobbleTitle = 4,
    HistoryActionTypeEditCustomList = 5
};
+ (instancetype)sharedInstance;
- (void)insertHistoryRecord:(int)titleid
            withTitle:(NSString *)title
withHistoryActionType:(HistoryActionType)historyActionType
          withSegment:(int)segment
        withMediaType:(int)mediatype
          withService:(int)service;
- (void)synchistory:(void (^)(NSArray *history)) completionHandler;
- (NSArray *)retrieveHistoryList;
- (void)pruneLocalHistory;
- (void)pruneicloudHistory:(void (^)(void)) completionHandler;
- (void)removeAllHistoryRecords;
- (void)removeAlliCloudHistoryRecords:(void (^)(void)) completionHandler;
@end

NS_ASSUME_NONNULL_END
