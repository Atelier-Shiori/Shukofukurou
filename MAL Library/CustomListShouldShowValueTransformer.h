//
//  CustomListShouldShowValueTransformer.h
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/07/25.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomListShouldShowValueTransformer : NSValueTransformer
+ (Class)transformedValueClass;
- (id)transformedValue:(id)value;
@end
