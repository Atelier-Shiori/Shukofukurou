//
//  NSNumberFormatterNumberOnly.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/03/05.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "NSNumberFormatterNumberOnly.h"

@implementation NSNumberFormatterNumberOnly
- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **) error {
    // Make sure we clear newString and error to ensure old values aren't being used
    if (newString) { *newString = nil;}
    if (error)     {*error = nil;}
    
    static NSCharacterSet *nonDecimalCharacters = nil;
    if (nonDecimalCharacters == nil) {
        nonDecimalCharacters = [NSCharacterSet decimalDigitCharacterSet].invertedSet ;
    }
    
    if (partialString.length == 0) {
        return YES; // The empty string is okay (the user might just be deleting everything and starting over)
    } else if ([partialString rangeOfCharacterFromSet:nonDecimalCharacters].location != NSNotFound) {
        return NO; // Non-decimal characters aren't cool!
    }
    
    return YES;
}
@end
