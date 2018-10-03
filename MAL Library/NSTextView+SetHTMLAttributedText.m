//
//  NSTextViewSetHTMLAttributedText.m
//  Shukofukurou
//
//  Created by 香風智乃 on 10/3/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "NSTextView+SetHTMLAttributedText.h"
#import "NSString+HTMLtoNSAttributedString.h"

@implementation NSTextView (SetHTMLAttributedText)
- (void)setTextToHTML:(NSString *)html withLoadingText:(nullable NSString *)loadingtext completion:(void (^)(NSAttributedString *astr)) completionHandler {
        if (loadingtext) {
                // Set Loading Text
                self.string = loadingtext;
            }
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
                // Convert HTML to Attributed Text
                NSAttributedString *atrstr = [html convertHTMLtoAttStr];
                dispatch_async(dispatch_get_main_queue(), ^{
                        // Completion Handler Callback
                        [self.textStorage setAttributedString:atrstr];
                        completionHandler(atrstr);
                    });
            });
    }
@end
