//
//  EditTitle.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import <Cocoa/Cocoa.h>
@class  MainWindow;
@interface EditTitle : NSViewController <NSTextFieldDelegate>{
    IBOutlet MainWindow *mw;
    int selectededitid;
    int selectedtype;
    bool selectedaired;
    bool selectedaircompleted;
    bool selectedfinished;
    bool selectedpublished;
    NSDictionary *selecteditem;
}
@property (strong) IBOutlet NSPopover *minieditpopover;
- (void)showEditPopover:(NSDictionary *)d showRelativeToRec:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)rectedge type:(int)type;
@end
