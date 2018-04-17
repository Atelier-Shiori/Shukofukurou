//
//  ratingchartview.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/05/19.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved.
//

#import "ratingchartview.h"
#import "RatingTwentyConvert.h"
#import "AniListScoreConvert.h"

@interface ratingchartview ()
@property (strong) IBOutlet NSLevelIndicator *scoretenbar;
@property (strong) IBOutlet NSLevelIndicator *scoreninebar;
@property (strong) IBOutlet NSLevelIndicator *scoreeightbar;
@property (strong) IBOutlet NSLevelIndicator *scoresevenbar;
@property (strong) IBOutlet NSLevelIndicator *scoresixbar;
@property (strong) IBOutlet NSLevelIndicator *scorefivebar;
@property (strong) IBOutlet NSLevelIndicator *scorefourbar;
@property (strong) IBOutlet NSLevelIndicator *scorethreebar;
@property (strong) IBOutlet NSLevelIndicator *scoretwobar;
@property (strong) IBOutlet NSLevelIndicator *scoreonebar;
@property (strong) IBOutlet NSTextField *avgscore;
@property (strong) IBOutlet NSTextField *standarddev;
@property (strong) IBOutlet NSTextField *numofentries;

@end

@implementation ratingchartview
- (instancetype)init
{
    return [super initWithNibName:@"ratingchartview" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)populateView:(NSArray *)list withService:(int)service {
    _numofentries.stringValue = [NSString stringWithFormat:@"%li",list.count];
    NSMutableArray *scores = [NSMutableArray new];
    for (NSDictionary *d in list) {
        switch (service) {
            case 1: {
                if (((NSNumber *)d[@"score"]).intValue > 0) {
                    [scores addObject:d[@"score"]];
                }
                break;
            }
            case 2: {
                if (((NSNumber *)d[@"score"]).intValue > 0) {
                    [scores addObject:@([RatingTwentyConvert translateKitsuTwentyScoreToMAL:((NSNumber *)d[@"score"]).intValue])];
                }
                break;
            }
            case 3: {
                if (((NSNumber *)d[@"score"]).intValue > 0) {
                    [scores addObject:[AniListScoreConvert convertScoreToRawActualScore:((NSNumber *)d[@"score"]).intValue withScoreType:@"POINT_10"]];
                }
                break;
            }
            default:
                break;
        }
    }
    if (scores.count > 0) {
        _standarddev.stringValue = [self standardDeviationOf:scores].stringValue;
        _avgscore.stringValue = [self meanOf:scores].stringValue;
    }
    else {
        _standarddev.stringValue = @"0";
        _avgscore.stringValue = @"0";
    }
    NSDictionary *scoredist = [self countscores:scores];
    [self setChart:scoredist];
}

- (void)setChart:(NSDictionary *)scoredistribution {
    // Set Max Value
    _scoretenbar.maxValue = ((NSNumber *)scoredistribution[@"count"]).intValue;
    _scoreninebar.maxValue = ((NSNumber *)scoredistribution[@"count"]).intValue;
    _scoreeightbar.maxValue = ((NSNumber *)scoredistribution[@"count"]).intValue;
    _scoresevenbar.maxValue = ((NSNumber *)scoredistribution[@"count"]).intValue;
    _scoresixbar.maxValue = ((NSNumber *)scoredistribution[@"count"]).intValue;
    _scorefivebar.maxValue = ((NSNumber *)scoredistribution[@"count"]).intValue;
    _scorefourbar.maxValue = ((NSNumber *)scoredistribution[@"count"]).intValue;
    _scorethreebar.maxValue = ((NSNumber *)scoredistribution[@"count"]).intValue;
    _scoretwobar.maxValue = ((NSNumber *)scoredistribution[@"count"]).intValue;
    _scoreonebar.maxValue = ((NSNumber *)scoredistribution[@"count"]).intValue;
    // Set Values
    _scoretenbar.intValue = ((NSNumber *)scoredistribution[@"10"]).intValue;
    _scoreninebar.intValue = ((NSNumber *)scoredistribution[@"9"]).intValue;
    _scoreeightbar.intValue = ((NSNumber *)scoredistribution[@"8"]).intValue;
    _scoresevenbar.intValue = ((NSNumber *)scoredistribution[@"7"]).intValue;
    _scoresixbar.intValue = ((NSNumber *)scoredistribution[@"6"]).intValue;
    _scorefivebar.intValue = ((NSNumber *)scoredistribution[@"5"]).intValue;
    _scorefourbar.intValue = ((NSNumber *)scoredistribution[@"4"]).intValue;
    _scorethreebar.intValue = ((NSNumber *)scoredistribution[@"3"]).intValue;
    _scoretwobar.intValue = ((NSNumber *)scoredistribution[@"2"]).intValue;
    _scoreonebar.intValue = ((NSNumber *)scoredistribution[@"1"]).intValue;
}

- (NSDictionary *)countscores:(NSArray *)scores {
    NSMutableDictionary *scoredistribution = [NSMutableDictionary new];
    for (int i = 1; i <=10; i++) {
        int scorecount = 0;
        for (NSNumber *score in scores) {
            if (score.intValue == i) {
                scorecount++;
            }
        }
        [scoredistribution setValue:@(scorecount) forKey:@(i).stringValue];
    }
    [scoredistribution setValue:@(scores.count) forKey:@"count"];
    return scoredistribution;
}

#pragma mark Helpers

- (NSNumber *)meanOf:(NSArray *)array
{
    double runningTotal = 0.0;
    
    for(NSNumber *number in array) {
        runningTotal += number.doubleValue;
    }
    
    return @(runningTotal / array.count);
}

- (NSNumber *)standardDeviationOf:(NSArray *)array {
    if(!array.count) return nil;
    
    double mean = [self meanOf:array].doubleValue;
    double sumOfSquaredDifferences = 0.0;
    
    for(NSNumber *number in array) {
        double valueOfNumber = number.doubleValue;
        double difference = valueOfNumber - mean;
        sumOfSquaredDifferences += difference * difference;
    }
    
    return @(sqrt(sumOfSquaredDifferences / array.count));
}

@end
