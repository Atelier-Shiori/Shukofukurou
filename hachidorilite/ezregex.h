//
//  ezregex.h
//  Detectstream
//
//  Created by Tail Red on 2/06/15.
//  Copyright 2014-2020 Atelier Shiori, James Moy. All rights reserved. Code licensed under MIT License.
//

#import <Foundation/Foundation.h>

//
// This class is used to simplify regex
//
@interface ezregex : NSObject
-(BOOL)checkMatch:(NSString *)string pattern:(NSString *)pattern;
-(NSString *)searchreplace:(NSString *)string pattern:(NSString *)pattern;
-(NSString *)findMatch:(NSString *)string pattern:(NSString *)pattern rangeatindex:(NSUInteger)ri;
-(NSArray *)findMatches:(NSString *)string pattern:(NSString *)pattern;
@end
