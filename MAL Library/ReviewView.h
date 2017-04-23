//
//  ReviewView.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/23.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface ReviewView : NSViewController
@property (strong) IBOutlet NSTextField *reviewhelpful;
@property (strong) IBOutlet NSTextField *episodeswatched;
@property (strong) IBOutlet NSTextField *reviewdatelabel;
@property (strong) IBOutlet NSImageView *revieweravatar;
@property (strong) IBOutlet NSTextField *reviewerusername;
@property (strong) IBOutlet NSTextField *reviewerscore;
@property (strong) IBOutlet NSTextView *reviewtext;
- (void)loadReview:(NSDictionary *)review type:(int)type;
- (IBAction)viewreviewerprofile:(id)sender;

@end
