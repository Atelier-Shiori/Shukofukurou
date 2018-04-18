//
//  AiringView.h
//  Shukofukurou
//
//  Created by 天々座理世 on 2017/04/07.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import <Cocoa/Cocoa.h>
@class NSTableViewAction;
@class MainWindow;
@interface AiringView : NSViewController <NSTableViewDelegate>;
@property (strong) IBOutlet MainWindow *mw;
@property (strong) IBOutlet NSArrayController *airingarraycontroller;
@property (strong) IBOutlet NSTableViewAction *airingtb;
@property (strong) IBOutlet NSPopUpButton *day;
@property (strong) IBOutlet NSToolbarItem *addtitleitem;
- (void)loadAiring:(NSNumber *)refresh;

@end
