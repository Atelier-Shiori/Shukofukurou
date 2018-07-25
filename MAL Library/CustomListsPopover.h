//
//  CustomListsPopover.h
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/07/25.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomListsPopover : NSViewController
typedef void (^caction)(NSString *customlistname);
@property caction actionblock;
@property (strong) IBOutlet NSArrayController *customlistarraycontroller;
@property (strong) IBOutlet NSTableView *tableview;
- (void)populateandshowCustomLists:(NSArray *)clistarray;
@end
