//
//  ListStatistics.h
//  Shukofukuro
//
//  Created by 桐間紗路 on 2017/05/19.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ListStatistics : NSWindowController
- (void)populateValues;
- (void)populateValues:(id)list type:(int)type;
@end
