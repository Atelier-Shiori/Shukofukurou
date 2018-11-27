//
//  TitleCollectionView.m
//  Shukofukurou
//
//  Created by 香風智乃 on 11/27/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "TitleCollectionView.h"

@implementation TitleCollectionView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    if (theEvent.clickCount > 1)
    {
        [NSApplication.sharedApplication sendAction:@selector(collectionItemViewDoubleClick:) to:nil from:self];
    }
}
- (void)keyUp:(NSEvent *)event {
    if ((event.keyCode == 36) || event.keyCode == 76) {
        [NSApplication.sharedApplication sendAction:@selector(collectionItemViewDoubleClick:) to:nil from:self];
    }
}

- (BOOL)performKeyEquivalent:(NSEvent *)event {
    if((event.keyCode == 36) || event.keyCode == 76) {
        return YES;
    }
    return NO;
}

@end
