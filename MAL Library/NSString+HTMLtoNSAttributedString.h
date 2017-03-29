//
//  NSString+HTMLtoNSAttributedString.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Appkit/Appkit.h>

@interface NSString (HTMLtoNSAttributedString)
- (NSAttributedString *)convertHTMLtoAttStr;
@end
