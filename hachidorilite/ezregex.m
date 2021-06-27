//
//  ezregex.h
//  Detectstream
//
//  Created by Tail Red on 2/06/15.
//  Copyright 2014-2020 Atelier Shiori, James Moy. All rights reserved. Code licensed under MIT License.
//

#import "ezregex.h"

@implementation ezregex

-(BOOL)checkMatch:(NSString *)string pattern:(NSString *)pattern{
    if (string == nil)
        return false; // Can't check a match of a nil string.
    NSError *errRegex = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&errRegex];
    NSRange  searchrange = NSMakeRange(0, [string length]);
    NSRange matchRange = [regex rangeOfFirstMatchInString:string options:NSMatchingReportProgress range:searchrange];
    if (matchRange.location != NSNotFound)
        return true;
        else
        return false;
}
-(NSString *)searchreplace:(NSString *)string pattern:(NSString *)pattern{
    if (string == nil)
        return @""; // Can't check a match of a nil string.
    NSError *errRegex = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&errRegex];
    NSString * newString = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
    return newString;
}
-(NSString *)findMatch:(NSString *)string pattern:(NSString *)pattern rangeatindex:(NSUInteger)ri{
    if (string == nil)
        return @""; // Can't check a match of a nil string.
    NSError *errRegex = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&errRegex];
    NSRange  searchrange = NSMakeRange(0, [string length]);
    NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range: searchrange];
    NSRange matchRange = [regex rangeOfFirstMatchInString:string options:NSMatchingReportProgress range:searchrange];
    if (matchRange.location != NSNotFound){
        return [string substringWithRange:[match rangeAtIndex:ri]];
    }
    return @"";
}
-(NSArray *)findMatches:(NSString *)string pattern:(NSString *)pattern {
    if (string == nil)
        return [NSArray new]; // Can't check a match of a nil string.
    NSError *errRegex = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&errRegex];
    NSRange  searchrange = NSMakeRange(0, [string length]);
    NSArray * a = [regex matchesInString:string options:0 range:searchrange];
    NSMutableArray * results = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult * result in a ) {
        [results addObject:[string substringWithRange:[result rangeAtIndex:0]]];
    }
    return results;
}
@end
