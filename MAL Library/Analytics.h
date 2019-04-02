//
//  Analytics.h
//  Shukofukurou
//
//  Created by 香風智乃 on 4/2/19.
//  Copyright © 2019 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Analytics : NSObject
+ (void)sendAnalyticsWithEventTitle:(NSString *)eventtitle withProperties:(NSDictionary <NSString *,NSString *> *)info;
+ (NSString *)getErrorDescriptionFromErrorResponse:(NSError *)error;
@end

NS_ASSUME_NONNULL_END
