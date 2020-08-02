//
//  TokenReauthManager.h
//  Shukofukurou
//
//  Created by 香風智乃 on 8/2/20.
//  Copyright © 2020 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TokenReauthManager : NSObject
+ (void)checkRefreshOrReauth;
+ (void)showReAuthMessage;
@end

NS_ASSUME_NONNULL_END
