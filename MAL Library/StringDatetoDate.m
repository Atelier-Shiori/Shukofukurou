//
//  StringDatetoDate.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/25.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
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
        return [dateFormatter dateFromString:value];
    }
    return nil;
}
@end
