//
//  messageswindow.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/24.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class messagecomposer;

@interface messageswindow : NSWindowController <NSTableViewDelegate, NSSplitViewDelegate>
@property (strong) messagecomposer *messagecomposerw;
- (void)cleartableview;
@end
