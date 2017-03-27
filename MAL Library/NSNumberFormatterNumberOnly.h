//
//  NSNumberFormatterNumberOnly.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/03/05.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumberFormatterNumberOnly : NSNumberFormatter
-(BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **) error ;
@end
