//
//  ESCssParser.h
//  Tests
//
//  Created by TracyYih on 13-8-23.
//  Copyright (c) 2013年 EsoftMobile.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESCssParser : NSObject

- (NSDictionary *)parseText:(NSString *)cssText;

@end