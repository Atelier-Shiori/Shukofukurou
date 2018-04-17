//
//  OtherListScoreFormatter.h
//  Shukofukuro
//
//  Created by 小鳥遊六花 on 4/6/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherListScoreFormatter : NSValueTransformer
+ (Class)transformedValueClass;
- (id)transformedValue:(id)value;

@end
