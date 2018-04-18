//
//  servicemenucontroller.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/12/18.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
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
        default:
            [NSUserDefaults.standardUserDefaults setInteger:1 forKey:@"currentservice"];
            _malserviceitem.state = NSOnState;
            _kitsuserviceitem.state = NSOffState;
            _anilistserviceitem.state = NSOffState;
            break;
        }
    }
}

- (IBAction)setService:(id)sender {
    NSMenuItem *selectedmenuitem = (NSMenuItem *)sender;
    int previousservice = (int)[NSUserDefaults.standardUserDefaults integerForKey:@"currentservice"];
    int tag = (int)selectedmenuitem.tag;
    if (previousservice == tag) {
        return;
    }
    [NSUserDefaults.standardUserDefaults setInteger:tag forKey:@"currentservice"];
    [self setmenuitemvaluefromdefaults];
    if (_actionblock) {
        _actionblock(tag, previousservice);
    }
}

- (void)enableservicemenuitems:(bool)enable {
    _malserviceitem.enabled = enable;
    _kitsuserviceitem.enabled = enable;
}

@end
