//
//  TypeNumtoStringType.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/27.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import "TypeNumtoStringType.h"

@implementation TypeNumtoStringType : NSValueTransformer
+ (Class)transformedValueClass
{
    return [NSString class];
}

- (id)transformedValue:(id)value{
    if (value == nil) return nil;
    
    if ([value respondsToSelector:@selector(integerValue)]){
        int status = [value intValue];
        switch (status){
            case 1:
                return @"TV";
                break;
            case 2:
                return @"OVA";
                break;
            case 3:
                return @"Movie";
                break;
            case 4:
                return @"Special";
                break;
            case 5:
                return @"ONA";
                break;
            case 6:
                return @"Music";
        }
    }
    return nil;
}

@end
