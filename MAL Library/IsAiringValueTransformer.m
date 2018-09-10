//
//  IsAiringValueTransformer.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/09/10.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "IsAiringValueTransformer.h"

@implementation IsAiringValueTransformer
+ (Class)transformedValueClass {
    return [NSNumber class];
}

- (id)transformedValue:(id)value {
    if (!value) return @NO;
    
    if ([value isKindOfClass:[NSString class]]) {
        NSString *status = (NSString *)value;
        if ([status isEqualToString:@"currently airing"]||[status isEqualToString:@"publishing"]) {
            return @YES;
        }
        return @NO;
    }
    return @NO;
}
@end
