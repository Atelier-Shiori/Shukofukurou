//
//  AniListSeasonListGenerator.h
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/07/12.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AniListSeasonListGenerator : NSObject
+ (void)retrieveSeasonDataWithSeason:(NSString *)season withYear:(int)year refresh:(bool)refresh completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
@end
