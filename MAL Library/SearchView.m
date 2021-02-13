//
//  SearchView.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "SearchView.h"
#import "MainWindow.h"
#import "listservice.h"
#import "Analytics.h"
#import "AdvSearchController.h"

@interface SearchView ()
@property (strong) IBOutlet NSMenuItem *addtitlemenuitem;
@property (strong) IBOutlet NSMenuItem *viewtitlemenuitem;
@property int animeNextPageOffset;
@property bool animeHasNextPage;
@property int mangaNextPageOffset;
@property bool mangaHasNextPage;
@property (strong) IBOutlet AdvSearchController *advsearchcontroller;
@property (strong) IBOutlet NSPopover *advpopover;

@end

@implementation SearchView

- (instancetype)init
{
    return [super initWithNibName:@"SearchView" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _searchtb.style = NSTableViewStylePlain;
    _mangasearchtb.style = NSTableViewStylePlain;
    [_addtitleitem setEnabled:NO];
    [self view];
    // Set Resizing Mask
    _animesearch.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    _mangasearch.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    // Add Placeholder Subview
    [self.view addSubview:_animesearch];
    _AnimeSearchTerm = @"";
    _MangaSearchTerm = @"";
    [self setMoreSearchState];
}
- (void)loadsearchView:(int)type{
    switch (type){
        case AnimeSearch:
            _MangaSearchTerm = _searchtitlefield.stringValue;
            _searchtitlefield.stringValue = _AnimeSearchTerm;
            _currentsearch = type;
            [self.view replaceSubview:(self.view).subviews[0] with:_animesearch];
            [self setToolbarButtonStatus];
            [self setMoreSearchState];
            break;
        case MangaSearch:
            _AnimeSearchTerm = _searchtitlefield.stringValue;
            _searchtitlefield.stringValue = _MangaSearchTerm;
            _currentsearch = type;
            [self.view replaceSubview:(self.view).subviews[0] with:_mangasearch];
            [self setToolbarButtonStatus];
            [self setMoreSearchState];
            break;
        default:
            break;
    }
}

- (IBAction)performsearch:(id)sender {
    if ((_searchtitlefield.stringValue).length > 0){
        [listservice.sharedInstance searchTitle:_searchtitlefield.stringValue withType:_currentsearch withSearchOptions:[_advsearchcontroller getAdvSearchOptionsForType:_currentsearch] completion:^(id responseObject, int nextoffset, bool hasnextpage){
            [self setPageInfo:nextoffset withHasNextPage:hasnextpage];
            [self setMoreSearchState];
            [_mw populatesearchtb:responseObject type:_currentsearch append:NO];
            [Analytics sendAnalyticsWithEventTitle:@"Search Successful" withProperties:@{@"service" : [listservice.sharedInstance currentservicename]}];
        }error:^(NSError *error){
            NSLog(@"Error: %@", error);
            [Analytics sendAnalyticsWithEventTitle:@"Search Failed" withProperties:@{@"service" : [listservice.sharedInstance currentservicename], @"localized_error" : error.localizedDescription, @"error_description" : [Analytics getErrorDescriptionFromErrorResponse:error]}];
            
            NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"%@",errResponse);
        }];
    }
    else{
        [self clearsearchtb];
        if (_currentsearch == 0) {
            if (_advsearchcontroller.viewLoaded) {
                [_advsearchcontroller resetanime];
            }
        }
        else {
            if (_advsearchcontroller.viewLoaded) {
                [_advsearchcontroller resetmanga];
            }
        }
    }
}

- (IBAction)performMoresearch:(id)sender {
    if ((_searchtitlefield.stringValue).length > 0){
        [listservice.sharedInstance searchTitle:_searchtitlefield.stringValue withType:_currentsearch withOffset:_currentsearch == 0 ? _animeNextPageOffset : _mangaNextPageOffset withSearchOptions:[_advsearchcontroller getAdvSearchOptionsForType:_currentsearch]
        completion:^(id responseObject, int nextoffset, bool hasnextpage){
            [self setPageInfo:nextoffset withHasNextPage:hasnextpage];
            [self setMoreSearchState];
            [_mw populatesearchtb:responseObject type:_currentsearch append:YES];
            [Analytics sendAnalyticsWithEventTitle:@"Search Successful" withProperties:@{@"service" : [listservice.sharedInstance currentservicename]}];
        }error:^(NSError *error){
            NSLog(@"Error: %@", error);
            [Analytics sendAnalyticsWithEventTitle:@"Search Failed" withProperties:@{@"service" : [listservice.sharedInstance currentservicename], @"localized_error" : error.localizedDescription, @"error_description" : [Analytics getErrorDescriptionFromErrorResponse:error]}];
        }];
    }
    else {
        if (_currentsearch == 0) {
            [_advsearchcontroller resetanime];
        }
        else {
            [_advsearchcontroller resetmanga];
        }
        [self clearsearchtb];
    }
}

- (IBAction)searchtbdoubleclick:(id)sender {
    if (_currentsearch == AnimeSearch){
        if (_searchtb.selectedRow >=0){
            if (_searchtb.selectedRow >-1){
                NSDictionary *d = _searcharraycontroller.selectedObjects[0];
                NSNumber *idnum = d[@"id"];
                [self savesearch];
                [NSNotificationCenter.defaultCenter postNotificationName:@"LoadTitleInfo" object:@{@"id" : idnum, @"type" : @(AnimeSearch)}];
            }
        }
    }
    else{
        if (_mangasearchtb.selectedRow >=0){
            if (_mangasearchtb.selectedRow >-1){
                NSDictionary *d = _mangasearcharraycontroller.selectedObjects[0];
                NSNumber *idnum = d[@"id"];
                [self savesearch];
                [NSNotificationCenter.defaultCenter postNotificationName:@"LoadTitleInfo" object:@{@"id" : idnum, @"type" : @(MangaSearch)}];
            }
        }
    }
}

- (void)savesearch {
    switch (_currentsearch){
        case AnimeSearch:
            _AnimeSearchTerm = _searchtitlefield.stringValue;
            break;
        case MangaSearch:
            _MangaSearchTerm = _searchtitlefield.stringValue;
            break;
        default:
            break;
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
- (void)clearsearchtb {
    if (_currentsearch == AnimeSearch){
        [[_searcharraycontroller mutableArrayValueForKey:@"content"] removeAllObjects];
        [_searchtb reloadData];
        [_searchtb deselectAll:self];
        _animeHasNextPage = false;
        _animeNextPageOffset = 0;
    }
    else{
        [[_mangasearcharraycontroller mutableArrayValueForKey:@"content"] removeAllObjects];
        [_mangasearchtb reloadData];
        [_mangasearchtb deselectAll:self];
        _mangaHasNextPage = false;
        _mangaNextPageOffset = 0;
    }
    [self setMoreSearchState];
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

#pragma mark Context Menu
- (void)menuWillOpen:(NSMenu *)menu {
    long selected = self.currentsearch == 0 ? self.searchtb.clickedRow : self.mangasearchtb.clickedRow;
    if (selected >= 0) {
        _addtitlemenuitem.enabled = [listservice.sharedInstance checkAccountForCurrentService];
        _viewtitlemenuitem.enabled = true;
    }
    else {
        _addtitlemenuitem.enabled = false;
        _viewtitlemenuitem.enabled = false;
    }
}
- (IBAction)rightclickAddTitle:(id)sender {
    long selected = self.currentsearch == 0 ? self.searchtb.clickedRow : self.mangasearchtb.clickedRow;
    if (self.currentsearch == 0) {
        [self.searchtb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:selected] byExtendingSelection:NO];
    }
    else {
        [self.mangasearchtb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:selected] byExtendingSelection:NO];
    }
    [_mw showaddpopover:_addtitleitem];
}
- (IBAction)rightclickViewTitle:(id)sender {
    long selected = self.currentsearch == 0 ? self.searchtb.clickedRow : self.mangasearchtb.clickedRow;
    if (self.currentsearch == 0) {
        [self.searchtb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:selected] byExtendingSelection:NO];
    }
    else {
        [self.mangasearchtb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:selected] byExtendingSelection:NO];
    }
    [self searchtbdoubleclick:sender];
}

- (void)setPageInfo:(int)nextpage withHasNextPage:(bool)hasnextpage {
    if (_currentsearch == 0) {
        _animeNextPageOffset = nextpage;
        _animeHasNextPage = hasnextpage;
    }
    else {
        _mangaNextPageOffset = nextpage;
        _mangaHasNextPage = hasnextpage;
    }
}

- (void)setMoreSearchState {
    _moresearchitem.enabled = _currentsearch == 0 ? _animeHasNextPage : _mangaHasNextPage;
}

- (IBAction)viewAdvPopover:(id)sender {
    if (!_advsearchcontroller.viewLoaded) {
        [_advsearchcontroller viewDidLoad];
    }
    [_advpopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
    [_advsearchcontroller loadViewForType:_currentsearch];
}

- (void)popoverDidClose:(NSNotification *)notification {
    NSLog(@"Popover closed");
    [_advsearchcontroller generateadvsearchdictionary];
    if ((_searchtitlefield.stringValue).length > 0) {
        [self clearsearchtb];
        [self performsearch:_searchtitlefield];
    }
}

@end
