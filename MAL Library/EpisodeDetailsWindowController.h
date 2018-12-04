//
//  EpisodeDetailsWindowController.h
//  Shukofukurou
//
//  Created by 香風智乃 on 12/4/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpisodeDetailsWindowController : NSWindowController <NSSplitViewDelegate>
- (void)loadEpisodeData:(int)titleid;
@end

NS_ASSUME_NONNULL_END
