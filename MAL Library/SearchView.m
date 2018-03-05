//
//  SearchView.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "SearchView.h"
#import "MainWindow.h"
//#import "MyAnimeList.h"
#import "listservice.h"

@interface SearchView ()

@end

@implementation SearchView

- (instancetype)init
{
    return [super initWithNibName:@"SearchView" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [_addtitleitem setEnabled:NO];
    [self view];
    // Set Resizing Mask
    _animesearch.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    _mangasearch.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    // Add Placeholder Subview
    [self.view addSubview:_animesearch];
    _AnimeSearchTerm = @"";
    _MangaSearchTerm = @"";
}
- (void)loadsearchView:(int)type{
    switch (type){
        case AnimeSearch:
            _MangaSearchTerm = _searchtitlefield.stringValue;
            _searchtitlefield.stringValue = _AnimeSearchTerm;
            _currentsearch = type;
            [self.view replaceSubview:(self.view).subviews[0] with:_animesearch];
            [self setToolbarButtonStatus];
            break;
        case MangaSearch:
            _AnimeSearchTerm = _searchtitlefield.stringValue;
            _searchtitlefield.stringValue = _MangaSearchTerm;
            _currentsearch = type;
            [self.view replaceSubview:(self.view).subviews[0] with:_mangasearch];
            [self setToolbarButtonStatus];
            break;
    }
}

- (IBAction)performsearch:(id)sender {
    if ((_searchtitlefield.stringValue).length > 0){
        [listservice searchTitle:_searchtitlefield.stringValue withType:_currentsearch completion:^(id responseObject){
            [_mw populatesearchtb:responseObject type:_currentsearch];
        }error:^(NSError *error){
            NSLog(@"Error: %@", error);
        }];
    }
    else{
        [self clearsearchtb];
    }
}

- (IBAction)searchtbdoubleclick:(id)sender {
    if (_currentsearch == AnimeSearch){
        if (_searchtb.selectedRow >=0){
            if (_searchtb.selectedRow >-1){
                NSDictionary *d = _searcharraycontroller.selectedObjects[0];
                NSNumber *idnum = d[@"id"];
                [_mw loadinfo:idnum type:AnimeSearch changeView:YES];
            }
        }
    }
    else{
        if (_mangasearchtb.selectedRow >=0){
            if (_mangasearchtb.selectedRow >-1){
                NSDictionary *d = _mangasearcharraycontroller.selectedObjects[0];
                NSNumber *idnum = d[@"id"];
                [_mw loadinfo:idnum type:MangaSearch changeView:YES];
            }
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self setToolbarButtonStatus];
}
- (void)setToolbarButtonStatus{
    if (_currentsearch == AnimeSearch){
        if (_searcharraycontroller.selectedObjects.count > 0){
            [_addtitleitem setEnabled:YES];
        }
        else {
            [_addtitleitem setEnabled:NO];
        }
    }
    else if (_currentsearch == MangaSearch){
        if (_mangasearcharraycontroller.selectedObjects.count > 0){
            [_addtitleitem setEnabled:YES];
        }
        else {
            [_addtitleitem setEnabled:NO];
        }
    }
}
- (void)clearsearchtb{
    if (_currentsearch == AnimeSearch){
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
- (void)clearallsearch {
    [[_searcharraycontroller mutableArrayValueForKey:@"content"] removeAllObjects];
    [_searchtb reloadData];
    [_searchtb deselectAll:self];
    [[_mangasearcharraycontroller mutableArrayValueForKey:@"content"] removeAllObjects];
    [_mangasearchtb reloadData];
    [_mangasearchtb deselectAll:self];
    _AnimeSearchTerm = @"";
    _MangaSearchTerm = @"";
    _searchtitlefield.stringValue = @"";
}
@end
