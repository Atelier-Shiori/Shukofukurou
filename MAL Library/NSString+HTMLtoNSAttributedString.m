//
//  NSString+HTMLtoNSAttributedString.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import "NSString+HTMLtoNSAttributedString.h"

@implementation NSString (HTMLtoNSAttributedString)
- (NSAttributedString *)convertHTMLtoAttStr{
    NSString * style = @"<meta charset=\"UTF-8\"><style> body { font-family: -apple-system; }</style>";
    // Convert HTML to attributed string
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType };
    
    NSString * combined = [NSString stringWithFormat:@"%@%@", style, self];
    
    NSAttributedString * stringwithHTML = [[NSAttributedString alloc] initWithData:[combined dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:NULL error:NULL];
    return stringwithHTML;
}
@end
