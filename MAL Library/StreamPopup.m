//
//  StreamPopup.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/06/20.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import "StreamPopup.h"
#import "NSTableViewAction.h"
#import "Utility.h"

@interface StreamPopup ()
@property (strong) IBOutlet NSTableViewAction *tb;
@property (strong) IBOutlet NSArrayController *arraycontroller;
@end

@implementation StreamPopup

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self view];
}

- (bool)checkifdataexists:(NSString *)title {
    NSDictionary *data = [Utility loadJSON:@"streamdata.json" appendpath:@""];
    if (data[@"shows"]) {
        NSArray *shows = data[@"shows"];
        for (NSDictionary *d in shows) {
            if ([(NSString *)d[@"name"] isEqualToString:title]) {
                [self loadTitles:[self convertNSDictionaryData:d[@"sites"]]];
                return true;
            }
            else if (d[@"alt"]) {
                if ([(NSString *)d[@"alt"] isEqualToString:title]) {
                    [self loadTitles:[self convertNSDictionaryData:d[@"sites"]]];
                    return true;
                }
            }
        }
    }
    return false;
}

- (void)loadTitles:(NSArray *)sites {
    NSMutableArray *a = [_arraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_arraycontroller addObjects:sites];
    [_tb reloadData];
    [_tb deselectAll:self];
}

- (NSArray *)convertNSDictionaryData:(NSDictionary *)dict {
    NSMutableArray *final = [NSMutableArray new];
    for (int i = 0; i < [dict count]; i++) {
        NSString *site = dict.allKeys[i];
        NSString *url = dict.allValues[i];
        [final addObject:@{@"site":site, @"url":url}];
    }
    return final;
}

- (IBAction)loadtitle:(id)sender {
    if (_tb.selectedRow >=0){
        if (_tb.selectedRow >-1){
            [_popover close];
            NSDictionary *d = _arraycontroller.selectedObjects[0];
            NSString * URL = d[@"url"];
                    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:URL]];
        }
    }
}


@end
