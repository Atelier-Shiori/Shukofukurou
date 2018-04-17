//
//  OtherUserListScoreFormatter.h
//  Shukofukuro
//
//  Created by 小鳥遊六花 on 2/26/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherUserListScoreFormatter : NSValueTransformer
+ (Class)transformedValueClass;
- (id)transformedValue:(id)value;
@end
