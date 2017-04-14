//
//  NSTableViewAction.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/30.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import "NSTableViewAction.h"

@implementation NSTableViewAction

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}
- (void)keyUp:(NSEvent *)event {
    if((event.keyCode == 36) || event.keyCode == 76) {
        [NSApp sendAction:self.doubleAction to:nil from:self];
    }
}
- (BOOL)performKeyEquivalent:(NSEvent *)event {
    if((event.keyCode == 36) || event.keyCode == 76) {
        return YES;
    }
    return NO;
}
@end
