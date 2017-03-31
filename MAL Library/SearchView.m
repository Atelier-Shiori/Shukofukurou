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
    [_addtitleitem setEnabled:NO];
    [self view];
    // Set Resizing Mask
    [_animesearch setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_mangasearch setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    // Add Placeholder Subview
    [self.view addSubview:_animesearch];
    AnimeSearchTerm = @"";
    MangaSearchTerm = @"";
}
- (void)loadsearchView:(int)type{
    switch (type){
        case AnimeSearch:
            MangaSearchTerm = _searchtitlefield.stringValue;
            _searchtitlefield.stringValue = AnimeSearchTerm;
            currentsearch = type;
            [[self view] replaceSubview:[[self.view subviews] objectAtIndex:0] with:_animesearch];
            [self setToolbarButtonStatus];
            break;
        case MangaSearch:
            AnimeSearchTerm = _searchtitlefield.stringValue;
            _searchtitlefield.stringValue = MangaSearchTerm;
            currentsearch = type;
            [[self view] replaceSubview:[[self.view subviews] objectAtIndex:0] with:_mangasearch];
            [self setToolbarButtonStatus];
            break;
    }
}

- (IBAction)performsearch:(id)sender {
    if ([_searchtitlefield.stringValue length] > 0){
        if (currentsearch == AnimeSearch){
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager GET:[NSString stringWithFormat:@"https://malapi.ateliershiori.moe/2.1/anime/search?q=%@",[Utility urlEncodeString:_searchtitlefield.stringValue]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                [mw populatesearchtb:responseObject type:currentsearch];
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }
        else {
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager GET:[NSString stringWithFormat:@"https://malapi.ateliershiori.moe/2.1/manga/search?q=%@",[Utility urlEncodeString:_searchtitlefield.stringValue]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                [mw populatesearchtb:responseObject type: currentsearch];
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }
    }
    else{
        [self clearsearchtb];
    }
}

- (IBAction)searchtbdoubleclick:(id)sender {
    if (currentsearch == AnimeSearch){
        if ([_searchtb selectedRow] >=0){
            if ([_searchtb selectedRow] >-1){
                NSDictionary *d = [[_searcharraycontroller selectedObjects] objectAtIndex:0];
                NSNumber * idnum = d[@"id"];
                [mw loadinfo:idnum type:AnimeSearch];
            }
        }
    }
    else{
        if ([_mangasearchtb selectedRow] >=0){
            if ([_mangasearchtb selectedRow] >-1){
                NSDictionary *d = [[_mangasearcharraycontroller selectedObjects] objectAtIndex:0];
                NSNumber * idnum = d[@"id"];
                [mw loadinfo:idnum type:MangaSearch];
            }
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self setToolbarButtonStatus];
}
-(void)setToolbarButtonStatus{
    if (currentsearch == AnimeSearch){
        if ([[_searcharraycontroller selectedObjects] count] > 0){
            [_addtitleitem setEnabled:YES];
        }
        else {
            [_addtitleitem setEnabled:NO];
        }
    }
    else if (currentsearch == MangaSearch){
        if ([[_mangasearcharraycontroller selectedObjects] count] > 0){
            [_addtitleitem setEnabled:YES];
        }
        else {
            [_addtitleitem setEnabled:NO];
        }
    }
}
-(void)clearsearchtb{
    if (currentsearch == AnimeSearch){
        [[_searcharraycontroller mutableArrayValueForKey:@"content"] removeAllObjects];
        [_searchtb reloadData];
        [_searchtb deselectAll:self];
    }
    else{
        [[_mangasearcharraycontroller mutableArrayValueForKey:@"content"] removeAllObjects];
        [_mangasearchtb reloadData];
        [_mangasearchtb deselectAll:self];
    }
}
@end
