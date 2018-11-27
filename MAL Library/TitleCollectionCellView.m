//
//  TitleCollectionCellView.m
//  Shukofukurou
//
//  Created by 香風智乃 on 11/27/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "TitleCollectionCellView.h"

@implementation TitleCollectionCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    if (_selected) {
        [[NSColor alternateSelectedControlColor] set];
        NSRectFill([self bounds]);
    }
}

@end
