//
//  imagecachetransformer.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/05/18.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved.
//

#import "imagecachetransformer.h"
#import "Utility.h"

@implementation imagecachetransformer
+ (Class)transformedValueClass {
    return [NSImage class];
}

- (id)transformedValue:(id)value {
    if (value == nil) return nil;
    
    if ([value respondsToSelector:@selector(stringByReplacingOccurrencesOfString:withString:)]) {
        NSString *url = value;
        return [Utility loadImage:[NSString stringWithFormat:@"%@.jpg",[[url stringByReplacingOccurrencesOfString:@"https://myanimelist.cdn-dena.com/images/" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@"-"]] withAppendPath:@"imgcache" fromURL:[NSURL URLWithString:url]];
    }
    return nil;
}

@end
