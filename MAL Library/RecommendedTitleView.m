//
//  RecommendedTitleView.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2017/04/24.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "RecommendedTitleView.h"
#import "NSTableViewAction.h"
#import "MainWindow.h"
#import "AppDelegate.h"

@interface RecommendedTitleView ()
@property (strong) IBOutlet NSArrayController *recommendedarraycontroller;
@end

@implementation RecommendedTitleView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self view];
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    _mw = [delegate getMainWindowController];
}

- (void)loadTitles:(id)data selectedid:(int)selid type:(int)type {
    NSMutableArray *a = [_recommendedarraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_recommendedarraycontroller addObjects:data];
    [_tb reloadData];
    [_tb deselectAll:self];
    _selectedid = selid;
    _selectedtype = type;
}

- (IBAction)loadtitle:(id)sender {
    if (_tb.selectedRow >=0){
        if (_tb.selectedRow >-1){
            [_popover close];
            NSDictionary *d = _recommendedarraycontroller.selectedObjects[0];
            NSNumber *idnum;
            if (_selectedtype == 0){
                idnum = d[@"id"];
            }
            else {
                idnum = d[@"manga_id"];
            }
            [_mw loadinfo:idnum type:_selectedtype changeView:YES forcerefresh:NO];

        }
    }
}
@end
