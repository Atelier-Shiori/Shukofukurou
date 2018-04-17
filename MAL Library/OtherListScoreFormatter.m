//
//  OtherListScoreFormatter.m
//  Shukofukuro
//
//  Created by 小鳥遊六花 on 4/6/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import "OtherListScoreFormatter.h"
#import "listservice.h"
#import "RatingTwentyConvert.h"
#import "AniListScoreConvert.h"

@implementation OtherListScoreFormatter
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
            case 2:
                return [RatingTwentyConvert convertRatingTwentyToActualScore:rating scoretype:(int)[NSUserDefaults.standardUserDefaults integerForKey:@"kitsu-ratingsystem"]];
            case 3:
                return [AniListScoreConvert convertAniListScoreToActualScore:rating withScoreType:[NSUserDefaults.standardUserDefaults valueForKey:@"anilist-otheruser-scoreformat"]];
            default:
                break;
        }
    }
    return nil;
}
@end
