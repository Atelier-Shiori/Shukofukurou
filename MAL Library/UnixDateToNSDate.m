//
//  UnixDateToNSDate.m
//  Shukofukurou
//
//  Created by 香風智乃 on 2/23/20.
//  Copyright © 2020 Atelier Shiori. All rights reserved.
//

#import "UnixDateToNSDate.h"

@implementation UnixDateToNSDate
+ (Class)transformedValueClass {
    return [NSDate class];
}

- (id)transformedValue:(id)value {
    if (value == nil) return nil;
    if ([[value className] isEqualToString:@"__NSCFNumber"]) {
            return [NSDate dateWithTimeIntervalSince1970:((NSNumber *)value).intValue];
    }
    return nil;
}
@end
