//
//  AniListScoreConvert.h
//  Shukofukurou
//
//  Created by 小鳥遊六花 on 4/5/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AniListScoreConvert : NSObject
+ (NSString *)convertAniListScoreToActualScore: (int)score withScoreType:(NSString *)scoretype;
+ (int)convertScoretoScoreRaw:(double)score withScoreType:(NSString *)scoretype;
+ (NSNumber *)convertScoreToRawActualScore:(int)score withScoreType:(NSString *)scoretype;
@end
