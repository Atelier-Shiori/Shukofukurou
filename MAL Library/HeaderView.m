//
//  HeaderView.m
//  Shukofukurou
//
//  Created by 香風智乃 on 11/27/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "HeaderView.h"

@implementation HeaderView

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor controlBackgroundColor] set];
    NSRectFill([self bounds]);
}

@end
