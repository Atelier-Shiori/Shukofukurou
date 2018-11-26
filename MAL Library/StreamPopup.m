//
//  StreamPopup.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/06/20.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved.
//

#import "StreamPopup.h"
#import "NSTableViewAction.h"
#import "Utility.h"
#import <CocoaOniguruma/OnigRegexp.h>
#import <CocoaOniguruma/OnigRegexpUtility.h>
#import "StreamDataRetriever.h"

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
    NSDictionary * data = [StreamDataRetriever retrieveSitesForTitle:title];
    if (data.count > 0) {
        [self loadTitles:[self convertNSDictionaryData:data]];
        return true;
    }
    NSMutableArray *a = [_arraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    _streamsexist = false;
    return false;
}

- (void)loadTitles:(NSArray *)sites {
    NSMutableArray *a = [_arraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_arraycontroller addObjects:sites];
    [_tb reloadData];
    [_tb deselectAll:self];
    _streamsexist = (a.count > 0);
}

- (NSArray *)convertNSDictionaryData:(NSDictionary *)dict {
    NSMutableArray *final = [NSMutableArray new];
    for (int i = 0; i < dict.count; i++) {
        NSString *site = dict.allKeys[i];
        site = site.capitalizedString;
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

- (NSString *)sanitizetitle:(NSString *)title {
    NSString *tmpstr = title;
    // Remove seasons
    OnigRegexp *regex = [OnigRegexp compile:@"\\s(((\\d+(st|nd|rd|th)|first|second|third|fourth|fifth|sixth|seventh|eighth|nineth|tenth) season)|\\d+|(X|VIII|VII|VI|V|IV|III|II|I))" options:OnigOptionIgnorecase];
    tmpstr = [tmpstr replaceByRegexp:regex with:@""];
    return tmpstr;
}
@end
