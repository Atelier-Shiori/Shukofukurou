//
//  NSNumberFormatterNumberOnly.h
//  Shukofukuro
//
//  Created by 桐間紗路 on 2017/03/05.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import <Foundation/Foundation.h>

@interface NSNumberFormatterNumberOnly : NSNumberFormatter
- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **) error ;
@end
