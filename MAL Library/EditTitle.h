//
//  EditTitle.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import <Cocoa/Cocoa.h>
@class  MainWindow;
@interface EditTitle : NSViewController <NSTextFieldDelegate>
@property (strong) IBOutlet MainWindow *mw;
@property int selectededitid;
@property int selectedtype;
@property bool selectedaired;
@property bool selectedaircompleted;
@property bool selectedfinished;
@property bool selectedpublished;
@property (strong) NSDictionary *selecteditem;
@property (strong) IBOutlet NSPopover *minieditpopover;

// Score Menus
@property (strong) IBOutlet NSMenu *malscoremenu;
@property (strong) IBOutlet NSMenu *kitsustandardscoremenu;
@property (strong) IBOutlet NSMenu *kitsuadavancedscoremenu;
@property (strong) IBOutlet NSMenu *kitsusimplescoremenu;


- (void)showEditPopover:(NSDictionary *)d showRelativeToRec:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)rectedge type:(int)type;
@end
