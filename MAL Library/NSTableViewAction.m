//
//  NSTableViewAction.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/30.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "NSTableViewAction.h"

@implementation NSTableViewAction

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}
- (void)keyUp:(NSEvent *)event {
    if(([event keyCode] == 36) || [event keyCode] == 76){
        [NSApp sendAction:[self doubleAction] to:nil from:self];
    }
}
- (BOOL)performKeyEquivalent:(NSEvent *)event{
    if(([event keyCode] == 36) || [event keyCode] == 76){
        return YES;
    }
    return NO;
}
@end
