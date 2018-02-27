//
//  servicemenucontroller.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/12/18.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@interface servicemenucontroller : NSObject
@property (strong) IBOutlet NSMenu *servicemenu;
@property (strong) IBOutlet NSMenuItem *malserviceitem;
@property (strong) IBOutlet NSMenuItem *kitsuserviceitem;
@property (strong) IBOutlet NSMenuItem *anilistserviceitem;
@property (strong) IBOutlet NSMenuItem *servicemenuitem;
typedef void (^action)(int selected, int previousservice);
@property action actionblock;

- (void)setmenuitemvaluefromdefaults;

@end
