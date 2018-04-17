//
//  imagecachetransformer.m
//  Shukofukuro
//
//  Created by 桐間紗路 on 2017/05/18.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved.
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
        if ([url isEqualToString:@"/images/original/missing.png"] || url.length == 0) {
            return [NSImage imageNamed:@"noimage"];
        }
        return [Utility loadImage:[NSString stringWithFormat:@"%@.jpg",[[url stringByReplacingOccurrencesOfString:@"https://" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@"-"]] withAppendPath:@"imgcache" fromURL:[NSURL URLWithString:url]];
    }
    return nil;
}

@end
