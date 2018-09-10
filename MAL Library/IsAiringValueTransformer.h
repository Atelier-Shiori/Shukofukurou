//
//  IsAiringValueTransformer.h
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/09/10.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IsAiringValueTransformer : NSValueTransformer
+ (Class)transformedValueClass;
- (id)transformedValue:(id)value;
@end

NS_ASSUME_NONNULL_END
