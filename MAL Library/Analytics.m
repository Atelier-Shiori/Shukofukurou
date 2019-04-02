//
//  Analytics.m
//  Shukofukurou
//
//  Created by 香風智乃 on 4/2/19.
//  Copyright © 2019 Atelier Shiori. All rights reserved.
//

#import "Analytics.h"
#import "listservice.h"
#if defined(OSS)
#else
@import AppCenterAnalytics;
#endif

@implementation Analytics
+ (void)sendAnalyticsWithEventTitle:(NSString *)eventtitle withProperties:(NSDictionary <NSString *,NSString *> *)info {
#if defined(OSS)
#else
    [MSAnalytics trackEvent:eventtitle withProperties:info];
#endif
}

+ (NSString *)getErrorDescriptionFromErrorResponse:(NSError *)error {
    NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
    NSError *jerror;
    NSString *errorDescription = @"None";
    id errorobj = [NSJSONSerialization JSONObjectWithData:[errResponse dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jerror];
    if (!jerror && errorobj) {
        switch ([listservice.sharedInstance getCurrentServiceID]) {
            case 2:
                if (errorobj[@"errors"][0]) {
                    errorDescription = [NSString stringWithFormat:@"%@ - %@", errorobj[@"errors"][0][@"title"], errorobj[@"errors"][0][@"detail"]];
                }
                break;
            case 3:
                if (errorobj[@"errors"][0]) {
                    errorDescription = errorobj[@"errors"][0][@"message"];
                }
                break;
            default:
                break;
        }
    }
    return errorDescription;
}
@end
