//
//  AddTitle.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import <Cocoa/Cocoa.h>
@class MainWindow;
@interface AddTitle : NSViewController <NSTextFieldDelegate>
@property (strong)IBOutlet MainWindow *mw;
@property int selectededitid;
@property int selectedtype;
@property bool selectedaired;
@property bool selectedaircompleted;
@property bool selectedfinished;
@property bool selectedpublished;
@property (strong) NSDictionary *selecteditem;
@property (strong) IBOutlet NSPopover *addpopover;
- (void)showAddPopover:(NSDictionary *)d showRelativeToRec:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)rectedge type:(int)type;
@end
