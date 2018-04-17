//
//  OtherHistoryView.m
//  Shukofukuro
//
//  Created by 桐間紗路 on 2017/10/17.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "OtherHistoryView.h"
#import "NSTableViewAction.h"
#import "MainWindow.h"
//#import "MyAnimeList.h"
#import "listservice.h"
#import "AppDelegate.h"

@interface OtherHistoryView ()

@end

@implementation OtherHistoryView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (void)loadHistory:(NSString *)username {
    [self clearHistory];
    [listservice retriveUpdateHistory:username completion:^(id response){
        [self populateHistory:response];
    }error:^(NSError *error){
        NSLog(@"%@", error.userInfo);
    }];
}

- (void)clearHistory{
    NSMutableArray *a = self.historyarraycontroller.content;
    [a removeAllObjects];
    [self.historytb reloadData];
    [self.historytb deselectAll:self];
}

- (IBAction)historydoubleclick:(id)sender {
    if (self.historytb.selectedRow >=0) {
        if (self.historytb.selectedRow >-1) {
            NSDictionary *d = self.historyarraycontroller.selectedObjects[0];
            NSNumber *idnum = d[@"id"];
            NSString *type = d[@"type"];
            int typenum = 0;
            if ([type isEqualToString:@"anime"]) {
                typenum = 0;
            }
            else {
                typenum = 1;
            }
            MainWindow *mwc = ((AppDelegate *)NSApplication.sharedApplication.delegate).mainwindowcontroller;
            [mwc loadinfo:idnum type:typenum changeView:YES];
            [mwc.window makeKeyAndOrderFront:self];
        }
    }
}
@end
