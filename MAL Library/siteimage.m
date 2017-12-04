//
//  siteimage.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/06/20.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved.
//

#import "siteimage.h"

@implementation siteimage
+ (Class)transformedValueClass {
    return [NSImage class];
}

- (id)transformedValue:(id)value {
    if (value == nil) return nil;
    
    if ([value respondsToSelector:@selector(stringByReplacingOccurrencesOfString:withString:)]) {
        NSString *sitename = value;
        return [NSImage imageNamed:sitename];
    }
    return nil;
}
@end
