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
#import "listservice.h"

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

- (void)checkifdataexists:(int)titleid completion:(void (^)(bool exists))completionHandler {
    [StreamDataRetriever retrieveSitesForTitle:titleid completion:^(id responseObject) {
        if (((NSArray *)responseObject).count > 0) {
            [self loadTitles:responseObject];
            _streamsexist = true;
        }
        else {
            NSMutableArray *a = [_arraycontroller mutableArrayValueForKey:@"content"];
            [a removeAllObjects];
            _streamsexist = false;
        }
        completionHandler(self.streamsexist);
    }];
}

- (void)loadTitles:(NSArray *)sites {
    NSMutableArray *a = [_arraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_arraycontroller addObjects:sites];
    [_tb reloadData];
    [_tb deselectAll:self];
    _streamsexist = (a.count > 0);
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
