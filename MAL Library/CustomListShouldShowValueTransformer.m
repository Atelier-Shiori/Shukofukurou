//
//  CustomListShouldShowValueTransformer.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/07/25.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "CustomListShouldShowValueTransformer.h"

@implementation CustomListShouldShowValueTransformer
+ (Class)transformedValueClass {
    return [NSNumber class];
}

- (id)transformedValue:(id)value {
    if (!value) return nil;
    
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"donated"]) return @YES;
    
    if ([value respondsToSelector:@selector(integerValue)]) {
        int service = [value intValue];
        switch (service) {
            case 1:
            case 2:
                return @YES;
            case 3:
                return @NO;
            default:
                break;
        }
    }
    return nil;
}
@end
