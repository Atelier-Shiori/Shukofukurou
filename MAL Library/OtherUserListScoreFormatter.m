//
//  OtherUserListScoreFormatter.m
//  MAL Library
//
//  Created by 小鳥遊六花 on 2/26/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "OtherUserListScoreFormatter.h"
#import "listservice.h"
#import "RatingTwentyConvert.h"

@implementation OtherUserListScoreFormatter
+ (Class)transformedValueClass {
    return [NSString class];
}

- (id)transformedValue:(id)value {
    if (value == nil) return nil;
    
    if ([value respondsToSelector:@selector(integerValue)]) {
        int rating = [value intValue];
        switch ([listservice getCurrentServiceID]) {
            case 1:
                return @(rating).stringValue;
                break;
            case 2:
                return [RatingTwentyConvert convertRatingTwentyToActualScore:rating scoretype:(int)[NSUserDefaults.standardUserDefaults integerForKey:@"kitsu-otheruser-ratingtype"]];
            default:
                break;
        }
    }
    return nil;
}
@end
