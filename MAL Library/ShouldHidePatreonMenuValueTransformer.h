//
//  ShouldHidePatreonMenuValueTransformer.h
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/08/08.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShouldHidePatreonMenuValueTransformer : NSValueTransformer
+ (Class)transformedValueClass;
- (id)transformedValue:(id)value;
@end
