//
//  TitleIDMapper.h
//  Shukofukurou
//
//  Created by 香風智乃 on 2/9/19.
//  Copyright © 2019 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TitleIDMapper : NSObject
typedef NS_ENUM(unsigned int, titleIDMapperServices){
    titleIDMapMAL = 1,
    titleIDMapKitsu = 2,
    titleIDMapAniList = 3,
    titleIdMapAniDB = 4
};
+ (instancetype)sharedInstance;
- (void)retrieveTitleIdForService:(int)service withTitleId:(NSString *)titleid withTargetServiceId:(int)tserviceid withType:(int)type completionHandler:(void (^) (id titleid, bool success)) completionHandler;
- (void)clearAllMappings;
@end

NS_ASSUME_NONNULL_END
