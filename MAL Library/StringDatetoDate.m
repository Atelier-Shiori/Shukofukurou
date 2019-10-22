//
//  StringDatetoDate.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2017/04/25.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "StringDatetoDate.h"

@implementation StringDatetoDate
+ (Class)transformedValueClass {
    return [NSDate class];
}

- (id)transformedValue:(id)value {
    if (value == nil) return nil;

    if ([[value className] isEqualToString:@"__NSCFString"]) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init] ;
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSDate *finaldate = [dateFormatter dateFromString:value];
        if (finaldate) {
            return finaldate;
        }
        else {
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
            finaldate = [dateFormatter dateFromString:value];
            if (finaldate) {
                return finaldate;
            }
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
            finaldate = [dateFormatter dateFromString:value];
            if (finaldate) {
                return finaldate;
            }
        }
    }
    return nil;
}
@end
