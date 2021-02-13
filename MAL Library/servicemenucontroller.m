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
            _malserviceitem.state = NSControlStateValueOn;
            _kitsuserviceitem.state = NSControlStateValueOff;
            _anilistserviceitem.state = NSControlStateValueOff;
            break;
        }
        case 2: {
            _malserviceitem.state = NSControlStateValueOff;
            _kitsuserviceitem.state = NSControlStateValueOn;
            _anilistserviceitem.state = NSControlStateValueOff;
            break;
        }
        case 3: {
            _malserviceitem.state = NSControlStateValueOff;
            _kitsuserviceitem.state = NSControlStateValueOff;
            _anilistserviceitem.state = NSControlStateValueOn;
            break;
        default:
            [NSUserDefaults.standardUserDefaults setInteger:1 forKey:@"currentservice"];
            _malserviceitem.state = NSControlStateValueOn;
            _kitsuserviceitem.state = NSControlStateValueOff;
            _anilistserviceitem.state = NSControlStateValueOff;
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
    [NSNotificationCenter.defaultCenter postNotificationName:@"ServiceChanged" object:nil];
    if (_actionblock) {
        _actionblock(tag, previousservice);
    }
}

- (void)setServiceWithServiceId:(int)serviceid {
    int previousservice = (int)[NSUserDefaults.standardUserDefaults integerForKey:@"currentservice"];
    if (previousservice == serviceid) {
        return;
    }
    [NSUserDefaults.standardUserDefaults setInteger:serviceid forKey:@"currentservice"];
    [self setmenuitemvaluefromdefaults];
    if (_actionblock) {
        _actionblock(serviceid, previousservice);
    }
}

- (void)enableservicemenuitems:(bool)enable {
    _anilistserviceitem.enabled = enable;
    _malserviceitem.enabled = enable;
    _kitsuserviceitem.enabled = enable;
}

@end
