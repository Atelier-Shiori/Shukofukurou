//
//  StreamPopup.h
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/06/20.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StreamPopup : NSViewController
@property (strong) IBOutlet NSPopover *popover;
@property (readonly) bool streamsexist;
- (void)checkifdataexists:(int)titleid completion:(void (^)(bool exists))completionHandler;
@end
