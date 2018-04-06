//
//  OtherListScoreFormatter.h
//  MAL Library
//
//  Created by 小鳥遊六花 on 4/6/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherListScoreFormatter : NSValueTransformer
+ (Class)transformedValueClass;
- (id)transformedValue:(id)value;

@end
