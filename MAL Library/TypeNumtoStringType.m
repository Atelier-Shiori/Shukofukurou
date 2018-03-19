//
//  TypeNumtoStringType.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/27.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "TypeNumtoStringType.h"

@implementation TypeNumtoStringType : NSValueTransformer
+ (Class)transformedValueClass {
    return [NSString class];
}

- (id)transformedValue:(id)value {
    if (value == nil) return nil;
    
    if ([value respondsToSelector:@selector(integerValue)]) {
        int status = [value intValue];
        switch (status){
            case 1:
                return @"TV";
            case 2:
                return @"OVA";
            case 3:
                return @"Movie";
            case 4:
                return @"Special";
            case 5:
                return @"ONA";
            case 6:
                return @"Music";
            default:
                break;
        }
    }
    return nil;
}

@end
