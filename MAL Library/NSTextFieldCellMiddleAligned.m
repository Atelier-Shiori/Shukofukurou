//
//  NSTextFieldCellMiddleAligned.m
//  Shukofukuro
//
//  Created by 天々座理世 on 2017/04/24.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "NSTextFieldCellMiddleAligned.h"

@implementation NSTextFieldCellMiddleAligned
- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect titleFrame = [super titleRectForBounds:theRect];
    NSSize titleSize = [self.attributedStringValue size];
    titleFrame.origin.y = theRect.origin.y - .5 + (theRect.size.height - titleSize.height) / 2.0;
    return titleFrame;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSRect titleRect = [self titleRectForBounds:cellFrame];
    [self.attributedStringValue drawInRect:titleRect];
}
@end
