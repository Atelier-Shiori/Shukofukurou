//
//  HistoryView.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/07.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class NSTableViewAction;
@class MainWindow;
@interface HistoryView : NSViewController
@property (strong) IBOutlet MainWindow * mw;
@property (strong) IBOutlet NSTableViewAction *historytb;
@property (strong) IBOutlet NSArrayController *historyarraycontroller;
- (void)loadHistory:(NSNumber *)refresh;
- (void)clearHistory;
@end
