//
//  SearchView.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "SearchView.h"
#import <AFNetworking/AFNetworking.h>
#import "MainWindow.h"
#import "Utility.h"

@interface SearchView ()

@end

@implementation SearchView

- (id)init
{
    return [super initWithNibName:@"SearchView" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)performsearch:(id)sender {
    if ([_searchtitlefield.stringValue length] > 0){
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:[NSString stringWithFormat:@"https://malapi.ateliershiori.moe/2.1/anime/search?q=%@",[Utility urlEncodeString:_searchtitlefield.stringValue]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [mw populatesearchtb:responseObject];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    else{
        [mw clearsearchtb];
    }
}

- (IBAction)searchtbdoubleclick:(id)sender {
    if ([_searchtb clickedRow] >=0){
        if ([_searchtb clickedRow] >-1){
            NSDictionary *d = [[_searcharraycontroller selectedObjects] objectAtIndex:0];
            NSNumber * idnum = d[@"id"];
            [mw loadanimeinfo:idnum];
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([[_searcharraycontroller selectedObjects] count] > 0){
        [_addtitleitem setEnabled:YES];
    }
    else {
        [_addtitleitem setEnabled:NO];
    }
}

@end
