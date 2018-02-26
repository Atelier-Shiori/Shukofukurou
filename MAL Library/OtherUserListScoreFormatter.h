//
//  OtherUserListScoreFormatter.h
//  MAL Library
//
//  Created by 小鳥遊六花 on 2/26/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherUserListScoreFormatter : NSValueTransformer
+ (Class)transformedValueClass;
- (id)transformedValue:(id)value;
@end
