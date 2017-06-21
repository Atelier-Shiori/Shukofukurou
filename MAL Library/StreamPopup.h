//
//  StreamPopup.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/06/20.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StreamPopup : NSViewController
@property (strong) IBOutlet NSPopover *popover;
- (bool)checkifdataexists:(NSString *)title;
@end
