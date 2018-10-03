//
//  NSTextView+SetHTMLAttributedText.h
//  Shukofukurou
//
//  Created by 香風智乃 on 10/3/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTextView (SetHTMLAttributedText)
- (void)setTextToHTML:(NSString *)html withLoadingText:(nullable NSString *)loadingtext completion:(void (^)(NSAttributedString *astr)) completionHandler;
@end

NS_ASSUME_NONNULL_END
