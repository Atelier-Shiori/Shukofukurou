//
//  AiringView.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/07.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class NSTableViewAction;
@class MainWindow;
@interface AiringView : NSViewController <NSTableViewDelegate>;
@property (strong) IBOutlet MainWindow * mw;
@property (strong) IBOutlet NSArrayController *airingarraycontroller;
@property (strong) IBOutlet NSTableViewAction *airingtb;
@property (strong) IBOutlet NSPopUpButton * day;
@property (strong) IBOutlet NSToolbarItem *addtitleitem;
- (void)loadAiring:(NSNumber *)refresh;

@end
