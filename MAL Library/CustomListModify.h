//
//  CustomListModify.h
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/07/25.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainWindow;
@interface CustomListModify : NSViewController
@property (strong) IBOutlet NSPopover *popover;
@property int entryid;
@property (strong) IBOutlet NSArrayController *customlistsarray;
@property (strong) IBOutlet NSButton *savebtn;
@property (strong) IBOutlet NSTableView *tableview;
@property (strong) MainWindow *mw;
@property int currenttype;

- (void)populateCustomLists:(NSDictionary *)entry withCurrentType:(int)type withSelectedId:(int)selid;

@end
