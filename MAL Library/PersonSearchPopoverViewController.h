//
//  PersonSearchPopoverViewController.h
//  Shukofukurou
//
//  Created by 香風智乃 on 12/10/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PersonSearchPopoverViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
@property (strong) IBOutlet NSTableView *tableview;
@property (weak) IBOutlet NSPopover *popover;
- (void)performsearch:(NSString *)searchterm;
@end

NS_ASSUME_NONNULL_END
