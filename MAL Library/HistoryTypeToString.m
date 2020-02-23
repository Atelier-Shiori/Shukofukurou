//
//  HistoryTypeToString.m
//  Shukofukurou
//
//  Created by 香風智乃 on 2/23/20.
//  Copyright © 2020 Atelier Shiori. All rights reserved.
//

#import "HistoryTypeToString.h"

@implementation HistoryTypeToString
+ (Class)transformedValueClass {
    return [NSString class];
}

- (id)transformedValue:(id)value {
    if (value == nil) return nil;
    
    if ([value respondsToSelector:@selector(integerValue)]) {
        int status = [value intValue];
        switch (status){
            case 0:
                return @"Added Title";
            case 1:
                return @"Updated Title";
            case 2:
                return @"Incremented";
            case 3:
                return @"Deleted Title";
            case 4:
                return @"Scrobbled Title";
            case 5:
                return @"Updated Custom List";
            default:
                break;
        }
    }
    return nil;
}

@end
