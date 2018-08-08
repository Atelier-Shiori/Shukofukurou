//
//  ShouldHidePatreonMenuValueTransformer.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/08/08.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "ShouldHidePatreonMenuValueTransformer.h"

@implementation ShouldHidePatreonMenuValueTransformer
+ (Class)transformedValueClass {
    return [NSNumber class];
}

- (id)transformedValue:(id)value {
    if (!value) return nil;
    
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"activepatron"]) return @NO;
    
    if ([value respondsToSelector:@selector(boolValue)]) {
        bool shoudldhide = [value intValue];
        return @(shoudldhide);
    }
    return nil;
}
@end
