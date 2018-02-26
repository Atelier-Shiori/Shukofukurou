//
//  RatingTwentyConvert.m
//  MAL Library
//
//  Created by 小鳥遊六花 on 2/26/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "RatingTwentyConvert.h"

@implementation RatingTwentyConvert
+ (NSString *)convertRatingTwentyToActualScore:(int)twentyrating scoretype:(int)scoretype {
    switch (scoretype) {
        case 0:
            return [self twentyRatingtoSimple:twentyrating];
        case 1:
            return [self twentyRatingtoStandard:twentyrating];
        case 2:
            return [self ratingTwentytoAdvancedScore:twentyrating];
        default:
            return @(twentyrating).stringValue;
    }
}

+ (NSString *)twentyRatingtoSimple:(int)twentyrating {
    switch (twentyrating) {
        case 2:
        case 3:
        case 4:
        case 5:
            return @"🙁";
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
            return @"😐";
        case 11:
        case 12:
        case 13:
        case 14:
        case 15:
            return @"🙂";
        case 16:
        case 17:
        case 18:
        case 19:
        case 20:
            return @"😍";
        default:
            return @"-";
    }
}

+ (NSString *)twentyRatingtoStandard:(int)twentyrating {
    double standardrating = 0;
        switch (twentyrating) {
            case 2:
            case 3:
                standardrating = 0.5;
                break;
            case 4:
            case 5:
                standardrating = 1.0;
                break;
            case 6:
            case 7:
                standardrating = 1.5;
                break;
            case 8:
            case 9:
                standardrating = 2.0;
                break;
            case 10:
            case 11:
                standardrating = 2.5;
                break;
            case 12:
            case 13:
                standardrating = 3.0;
                break;
            case 14:
            case 15:
                standardrating = 3.5;
                break;
            case 16:
            case 17:
                standardrating = 4.0;
                break;
            case 18:
            case 19:
                standardrating = 4.5;
                break;
            case 20:
                standardrating = 5.0;
                break;
        }
    return @(standardrating).stringValue;
}

+ (NSString *)ratingTwentytoAdvancedScore:(int)twentyrating {
    double advrating = 0.0;
    switch (twentyrating) {
        case 2:
            advrating = 1.0;
            break;
        case 3:
            advrating = 1.5;
            break;
        case 4:
            advrating = 2.0;
            break;
        case 5:
            advrating = 2.5;
            break;
        case 6:
            advrating = 3.0;
            break;
        case 7:
            advrating = 3.5;
            break;
        case 8:
            advrating = 4.0;
            break;
        case 9:
            advrating = 4.5;
            break;
        case 10:
            advrating = 5.0;
            break;
        case 11:
            advrating = 5.5;
            break;
        case 12:
            advrating = 6.0;
            break;
        case 13:
            advrating = 6.5;
            break;
        case 14:
            advrating = 7.0;
            break;
        case 15:
            advrating = 7.5;
            break;
        case 16:
            advrating = 8.0;
            break;
        case 17:
            advrating = 8.5;
            break;
        case 18:
            advrating = 9.0;
            break;
        case 19:
            advrating = 9.5;
            break;
        case 20:
            advrating = 10.0;
            break;
    }
    return @(advrating).stringValue;
}
+ (int)translateKitsuTwentyScoreToMAL:(int)rating {
    // Translates Kitsu's scoring system to MAL Scoring System
    // Awful (2-5) > 1-3, Meh (6-10) > 3-5, Good (11-15) > 6-8, Great (16-20) > 8-10
    // Advanced Ratings are rounded up.
    switch (rating) {
        case 2:
            return 1;
        case 3:
        case 4:
            return 2;
        case 5:
        case 6:
            return 3;
        case 7:
        case 8:
            return 4;
        case 9:
        case 10:
            return 5;
        case 11:
        case 12:
            return 6;
        case 13:
        case 14:
            return 7;
        case 15:
        case 16:
            return 8;
        case 17:
        case 18:
            return 9;
        case 19:
        case 20:
            return 10;
        default:
            return 0;
    }
    return 0;
}
+ (int)translatestandardKitsuRatingtoRatingTwenty:(double)score {
    if (score == 0.5) {
        return 2;
    }
    else if (score == 1) {
        return 4;
    }
    else if (score == 1.5) {
        return 6;
    }
    else if (score == 2.0) {
        return 8;
    }
    else if (score == 2.5) {
        return 10;
    }
    else if (score == 3.0) {
        return 12;
    }
    else if (score == 3.5) {
        return 14;
    }
    else if (score == 4.0) {
        return 16;
    }
    else if (score == 4.5) {
        return 18;
    }
    else if (score == 5.0) {
        return 20;
    }
    return 0;
}
+ (int)translateadvancedKitsuRatingtoRatingTwenty:(double)score {
    if (score == 1.0) {
        return 2;
    }
    else if (score == 1.5) {
        return 3;
    }
    else if (score == 2.0) {
        return 4;
    }
    else if (score == 2.5) {
        return 5;
    }
    else if (score == 3.0) {
        return 6;
    }
    else if (score == 3.5) {
        return 7;
    }
    else if (score == 4.0) {
        return 8;
    }
    else if (score == 4.5) {
        return 9;
    }
    else if (score == 5.0) {
        return 10;
    }
    else if (score == 5.5) {
        return 11;
    }
    else if (score == 6.0) {
        return 12;
    }
    else if (score == 6.5) {
        return 13;
    }
    else if (score == 7.0) {
        return 14;
    }
    else if (score == 7.5) {
        return 15;
    }
    else if (score == 8.0) {
        return 16;
    }
    else if (score == 8.5) {
        return 17;
    }
    else if (score == 9.0) {
        return 18;
    }
    else if (score == 9.5) {
        return 19;
    }
    else if (score == 10.0) {
        return 20;
    }
    return 0;
}
@end
