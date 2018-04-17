//
//  RecommendedTitleView.h
//  Shukofukuro
//
//  Created by 天々座理世 on 2017/04/24.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class NSTableViewAction;
@class MainWindow;

@interface RecommendedTitleView : NSViewController
@property (strong) MainWindow *mw;
@property int selectedid;
@property int selectedtype;
@property (strong) IBOutlet NSTextField *popovertitle;
@property (strong) IBOutlet NSTableViewAction *tb;
@property (strong) IBOutlet NSPopover *popover;

- (void)loadTitles:(id)data selectedid:(int)selid type:(int)type;


@end
