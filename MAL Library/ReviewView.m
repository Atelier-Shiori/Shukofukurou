//
//  ReviewView.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/23.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "ReviewView.h"
#import "NSString+HTMLtoNSAttributedString.h"
#import "Utility.h"

@interface ReviewView ()

@end

@implementation ReviewView

- (instancetype)init {
    return [super initWithNibName:@"ReviewView" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
}

- (void)loadReview:(NSDictionary *)review type:(int)type {
    _reviewerusername.stringValue = review[@"username"];
    _reviewerscore.stringValue = [NSString stringWithFormat:@"Score: %@", review[@"rating"]];
    _reviewdatelabel.stringValue = [NSString stringWithFormat:@"Reviewed on %@", review[@"date"]];
    if (type == 0) {
         _episodeswatched.stringValue = [NSString stringWithFormat:@"Episodes watched: %@", review[@"watched_episodes"]];
    }
    else {
         _episodeswatched.stringValue = [NSString stringWithFormat:@"Chapters read: %@", review[@"chapters_read"]];
    }
    if (review[@"helpful"]) {
        NSNumber *helpful = review[@"helpful"];
        if (helpful.intValue == 1) {
            _reviewhelpful.stringValue = [NSString stringWithFormat:@"%i user find this review helpful", helpful.intValue];
        }
        else {
            _reviewhelpful.stringValue = [NSString stringWithFormat:@"%i users find this review helpful", helpful.intValue];
        }
    }
    [_reviewtext.textStorage setAttributedString: [(NSString *)review[@"review"] convertHTMLtoAttStr]];
    [_reviewtext scrollToBeginningOfDocument:self];
    [_reviewtext scrollToBeginningOfDocument:self];
    _revieweravatar.image = [Utility loadImage:[NSString stringWithFormat:@"useravatar-%@.jpg",_reviewerusername.stringValue] withAppendPath:@"imgcache" fromURL:[NSURL URLWithString:review[@"avatar_url"]]];
}

- (IBAction)viewreviewerprofile:(id)sender {
}
@end
