//
//  AniListScoreConvert.m
//  MAL Library
//
//  Created by 小鳥遊六花 on 4/5/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "AniListScoreConvert.h"

@implementation AniListScoreConvert
+ (NSString *)convertAniListScoreToActualScore: (int)score withScoreType:(NSString *)scoretype {
    NSNumber *rawscore = [self convertScoreToRawActualScore:score withScoreType:scoretype];
    return [self convertRawActualScoreToDisplayScore:rawscore withScoreTyp:scoretype];
    
}
+ (NSNumber *)convertScoreToRawActualScore:(int)score withScoreType:(NSString *)scoretype {
    if ([scoretype isEqualToString:@"POINT_100"]) {
        return @(score);
    }
    else if ([scoretype isEqualToString:@"POINT_10_DECIMAL"]) {
        return @((double)score/10);
    }
    else if ([scoretype isEqualToString:@"POINT_10"]) {
        long rounded = roundl((double)score/10);
        return @(rounded);
    }
    else if ([scoretype isEqualToString:@"POINT_5"]) {
        long rounded = roundl((double)score/10);
        rounded = roundl((double)rounded/2);
        return @(rounded);
    }
    else if ([scoretype isEqualToString:@"POINT_3"]) {
        int finalscore = 0;
        if (score > 0 && score <= 33) {
            finalscore = 1;
        }
        else if (score > 33 && score <=67) {
            finalscore = 2;
        }
        else if (score > 67 && score <= 100) {
            finalscore = 3;
        }
        return @(finalscore);
    }
    return @(score);
}
+ (NSString *)convertRawActualScoreToDisplayScore:(NSNumber *)rawscore withScoreTyp:(NSString *)scoretype {
    if ([scoretype isEqualToString:@"POINT_100"] || [scoretype isEqualToString:@"POINT_10_DECIMAL"] || [scoretype isEqualToString:@"POINT_10"]) {
        return rawscore.stringValue;
    }
    else if ([scoretype isEqualToString:@"POINT_5"]) {
        return [NSString stringWithFormat:@"%i⭐️",rawscore.intValue];
    }
    else if ([scoretype isEqualToString:@"POINT_3"]) {
        switch (rawscore.intValue) {
            case 0:
                return @"-";
            case 1:
                return @"🙁";
            case 2:
                return @"😐";
            case 3:
                return @"🙂";
            default:
                break;
        }
    }
    return rawscore.stringValue;
}


@end
