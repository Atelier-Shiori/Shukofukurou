//
//  servicemenucontroller.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/12/18.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "servicemenucontroller.h"

@implementation servicemenucontroller
- (void)setmenuitemvaluefromdefaults {
    switch ([NSUserDefaults.standardUserDefaults integerForKey:@"currentservice"]) {
        case 1: {
            _malserviceitem.state = NSOnState;
            _kitsuserviceitem.state = NSOffState;
            _anilistserviceitem.state = NSOffState;
            break;
        }
        case 2: {
            _malserviceitem.state = NSOffState;
            _kitsuserviceitem.state = NSOnState;
            _anilistserviceitem.state = NSOffState;
            break;
        }
        case 3: {
            _malserviceitem.state = NSOffState;
            _kitsuserviceitem.state = NSOffState;
            _anilistserviceitem.state = NSOnState;
            break;
        }
    }
}

- (IBAction)setService:(id)sender {
    NSMenuItem *selectedmenuitem = (NSMenuItem *)sender;
    int tag = (int)selectedmenuitem.tag;
    [NSUserDefaults.standardUserDefaults setInteger:tag forKey:@"currentservice"];
    [self setmenuitemvaluefromdefaults];
    if (_actionblock) {
        _actionblock(tag);
    }
}

@end
