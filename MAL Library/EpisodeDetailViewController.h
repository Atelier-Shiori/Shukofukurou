//
//  EpisodeDetailViewController.h
//  Shukofukurou
//
//  Created by 香風智乃 on 12/4/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpisodeDetailViewController : NSViewController
@property (strong) IBOutlet NSTextField *episodetitle;
@property (strong) IBOutlet NSImageView *image;
@property (strong) IBOutlet NSTextView *textview;
- (void)populateEpisodeDetails:(NSDictionary *)details;
@end

NS_ASSUME_NONNULL_END
