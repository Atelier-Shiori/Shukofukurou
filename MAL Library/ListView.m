//
//  ListView.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "ListView.h"
#import "MainWindow.h"
#import "AppDelegate.h"
#import "Keychain.h"
//#import "MyAnimeList.h"
#import "listservice.h"
#import "Utility.h"
#import "MyListScoreFormatter.h"

@interface ListView ()

@end

@implementation ListView

- (instancetype)init {
    return [super initWithNibName:@"ListView" bundle:nil];
}

- (MainWindow *)_mw {
    return [(AppDelegate *)[NSApplication sharedApplication].delegate getMainWindowController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here
    [self view];
    [self.view addSubview:_animelistview];
    _animelistview.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    _mangalistview.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    _animelisttitlefilterstring = @"";
    _mangalisttitlefilterstring = @"";
    id transformer = [MyListScoreFormatter new];
    NSMutableDictionary *bindingOptions = [NSMutableDictionary dictionary];
    [bindingOptions setObject: transformer
                       forKey:NSValueTransformerBindingOption];
    
    [self.animescorecol bind:@"value" toObject:self.animelistarraycontroller
                 withKeyPath:@"arrangedObjects.score" options:bindingOptions];
    [self.mangascorecol bind:@"value" toObject:self.mangalistarraycontroller withKeyPath:@"arrangedObjects.score" options:bindingOptions];
}

- (void)loadList:(int)list {
    if (list == 0) {
        _mangalisttitlefilterstring = _animelistfilter.stringValue;
        _animelistfilter.stringValue = _animelisttitlefilterstring;
        [self.view replaceSubview:(self.view).subviews[0] with:_animelistview];
        _currentlist = list;
    }
    else {
        _animelisttitlefilterstring = _animelistfilter.stringValue;
        _animelistfilter.stringValue = _mangalisttitlefilterstring;
        [self.view replaceSubview:(self.view).subviews[0] with:_mangalistview];
        _currentlist = list;
    }
}

- (void)populateList:(id)object type:(int)type {
    NSNumber *selectedAnimeID = nil;
    if (type == 0) {
        // Populates list
        if (_animelisttb.selectedRow >= 0) {
            selectedAnimeID = _animelistarraycontroller.selectedObjects[0][@"id"];
        }
        NSMutableArray *a = [_animelistarraycontroller mutableArrayValueForKey:@"content"];
        [a removeAllObjects];
        NSDictionary *data = object;
        NSArray *list;
        @try {
            if (data[@"anime"]) {
                list = data[@"anime"];
                [_animelistarraycontroller addObjects:list];
            }
            else {
                [_animelisttb reloadData];
                return;
            }
        }
        @catch (NSException *e) {
            NSLog(@"Cannot populate data: %@",e);
            NSLog(@"Copy this output and file a bug report: %@", data);
            [_animelisttb reloadData];
            return;
        }
        [self populatefiltercounts:list type:type];
        [_animelisttb reloadData];
        if (selectedAnimeID != nil) {
            for (NSUInteger index = 0; index < a.count; index++) {
                if ([_animelistarraycontroller mutableArrayValueForKey:@"content"][index][@"id"] == selectedAnimeID) {
                    [_animelistarraycontroller setSelectionIndex:index];
                    break;
                }
                else if (index == a.count - 1) {
                    [_animelisttb deselectAll:self];
                }
            }
            if (a.count == 0) {
                [_animelisttb deselectAll:self];
            }
        }
        else {
            [_animelisttb deselectAll:self];
        }
        [self performfilter:type];
    }
    else {
        // Populates list
        if (_mangalisttb.selectedRow >= 0) {
            selectedAnimeID = _mangalistarraycontroller.selectedObjects[0][@"id"];
        }
        NSMutableArray *a = [_mangalistarraycontroller mutableArrayValueForKey:@"content"];
        [a removeAllObjects];
        NSDictionary *data = object;
        NSArray *list;
        @try {
            if (data[@"manga"]) {
                list = data[@"manga"];
                [_mangalistarraycontroller addObjects:list];
            }
            else {
                [_mangalisttb reloadData];
                return;
            }
        }
        @catch (NSException *e) {
            NSLog(@"Cannot populate data: %@",e);
            NSLog(@"Copy this output and file a bug report: %@", data);
            [_animelisttb reloadData];
            return;
        }
        [self populatefiltercounts:list type:type];
        [_mangalisttb reloadData];
        if (selectedAnimeID != nil) {
            for (NSUInteger index = 0; index < a.count; index++) {
                if ([_mangalistarraycontroller mutableArrayValueForKey:@"content"][index][@"id"] == selectedAnimeID) {
                    [_mangalistarraycontroller setSelectionIndex:index];
                    break;
                }
                else if (index == a.count - 1) {
                    [_mangalisttb deselectAll:self];
                }
            }
            if (a.count == 0) {
                [_mangalisttb deselectAll:self];
            }
        }
        else {
            [_mangalisttb deselectAll:self];
        }
        [self performfilter:type];
    }
}
- (void)populatefiltercounts:(NSArray *)a type:(int)type{
    // Generates item counts for each status filter
    NSArray *arg = [NSProcessInfo processInfo].arguments;
    if (arg.count > 1) {
        if ([(NSString *)arg[arg.count-1] isEqualToString:@"testing"]) {
            return;
        }
    }
    NSArray *filtered;
    if (type == 0) {
        NSNumber *watching;
        NSNumber *completed;
        NSNumber *onhold;
        NSNumber *dropped;
        NSNumber *plantowatch;
        for (int i = 0; i < 5; i++) {
            switch(i) {
                case 0:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"watching"]];
                    watching = @(filtered.count);
                    break;
                case 1:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"completed"]];
                    completed = @(filtered.count);
                    break;
                case 2:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"on-hold"]];
                    onhold = @(filtered.count);
                    break;
                case 3:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"dropped"]];
                    dropped = @(filtered.count);
                    break;
                case 4:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"plan to watch"]];
                    plantowatch = @(filtered.count);
                    break;
            }
        }
        _watchingfilter.title = [NSString stringWithFormat:@"Watching (%i)",watching.intValue];
        _completedfilter.title = [NSString stringWithFormat:@"Completed (%i)",completed.intValue];
        _onholdfilter.title = [NSString stringWithFormat:@"On Hold (%i)",onhold.intValue];
        _droppedfilter.title = [NSString stringWithFormat:@"Dropped (%i)",dropped.intValue];
        _plantowatchfilter.title = [NSString stringWithFormat:@"Plan to watch (%i)",plantowatch.intValue];
    }
    else {
        NSNumber *reading;
        NSNumber *completed;
        NSNumber *onhold;
        NSNumber *dropped;
        NSNumber *plantoread;
        for (int i = 0; i < 5; i++) {
            switch(i) {
                case 0:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"reading"]];
                    reading = @(filtered.count);
                    break;
                case 1:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"completed"]];
                    completed = @(filtered.count);
                    break;
                case 2:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"on-hold"]];
                    onhold = @(filtered.count);
                    break;
                case 3:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"dropped"]];
                    dropped = @(filtered.count);
                    break;
                case 4:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"plan to read"]];
                    plantoread = @(filtered.count);
                    break;
            }
        }
        _readingfilter.title = [NSString stringWithFormat:@"Reading (%i)",reading.intValue];
        _mangacompletedfilter.title = [NSString stringWithFormat:@"Completed (%i)",completed.intValue];
        _mangaonholdfilter.title = [NSString stringWithFormat:@"On Hold (%i)",onhold.intValue];
        _mangadroppedfilter.title = [NSString stringWithFormat:@"Dropped (%i)",dropped.intValue];
        _plantoreadfilter.title = [NSString stringWithFormat:@"Plan to read (%i)",plantoread.intValue];
    }
}
- (IBAction)filterperform:(id)sender {
    if ([sender isKindOfClass:[NSButton class]]) {
        [self filterStatusAsTabs:(NSButton *)sender];
    }
    [self performfilter:_currentlist];
}

- (void)filterStatusAsTabs:(NSButton *)btn{
    if (_currentlist == 0) {
        if (_watchingfilter != btn) {
            _watchingfilter.state = 0;
        }
        else {
            _watchingfilter.state = 1;
        }
        if (_completedfilter != btn) {
            _completedfilter.state = 0;
        }
        else {
            _completedfilter.state = 1;
        }
        if (_droppedfilter != btn) {
            _droppedfilter.state = 0;
        }
        else {
            _droppedfilter.state = 1;
        }
        if (_onholdfilter != btn) {
            _onholdfilter.state = 0;
        }
        else {
            _onholdfilter.state = 1;
        }
        if (_plantowatchfilter != btn) {
            _plantowatchfilter.state = 0;
        }
        else {
            _plantowatchfilter.state = 1;
        }
    }
    else {
        if (_readingfilter != btn) {
            _readingfilter.state = 0;
        }
        else {
            _readingfilter.state = 1;
        }
        if (_mangacompletedfilter != btn) {
            _mangacompletedfilter.state = 0;
        }
        else {
            _mangacompletedfilter.state = 1;
        }
        if (_mangadroppedfilter != btn) {
            _mangadroppedfilter.state = 0;
        }
        else {
            _mangadroppedfilter.state = 1;
        }
        if (_mangaonholdfilter != btn) {
            _mangaonholdfilter.state = 0;
        }
        else {
            _mangaonholdfilter.state = 1;
        }
        if (_plantoreadfilter != btn) {
            _plantoreadfilter.state = 0;
        }
        else {
            _plantoreadfilter.state = 1;
        }
    }
}

- (void)performfilter:(int)type {
    // This method generates a predicate rule to use as a filter
    NSMutableArray *predicateformat = [NSMutableArray new];
    NSMutableArray *predicateobjects = [NSMutableArray new];
    bool titlefilterused = false;
    if (_animelistfilter.stringValue.length > 0) {
        [predicateformat addObject: @"(title CONTAINS [cd] %@)"];
        [predicateobjects addObject: _animelistfilter.stringValue];
        titlefilterused = true;
    }
    NSArray *filterstatus = [self obtainfilterstatus:type];
    if (type == 0) {
        
        for (int i=0; i < filterstatus.count; i++) {
            NSDictionary *d = filterstatus[i];
            if (filterstatus.count == 1) {
                [predicateformat addObject:@"(watched_status ==[cd] %@)"];
                
            }
            else if (i == filterstatus.count-1) {
                [predicateformat addObject:@"watched_status ==[cd] %@)"];
            }
            else if (i == 0) {
                [predicateformat addObject:@"(watched_status ==[cd] %@ OR "];
            }
            else {
                [predicateformat addObject:@"watched_status ==[cd] %@ OR "];
            }
            [predicateobjects addObject:d.allKeys[0]];
        }
    }
    else {
        for (int i=0; i < filterstatus.count; i++) {
            NSDictionary *d = filterstatus[i];
            if (filterstatus.count == 1) {
                [predicateformat addObject:@"(read_status ==[cd] %@)"];
                
            }
            else if (i == filterstatus.count-1) {
                [predicateformat addObject:@"read_status ==[cd] %@)"];
            }
            else if (i == 0) {
                [predicateformat addObject:@"(read_status ==[cd] %@ OR "];
            }
            else {
                [predicateformat addObject:@"read_status ==[cd] %@ OR "];
            }
            [predicateobjects addObject:d.allKeys[0]];
        }
    }
    if (predicateformat.count ==0 || filterstatus.count == 0) {
        // Empty filter predicate
        if (type == 0) {
            _animelistarraycontroller.filterPredicate = [NSPredicate predicateWithFormat:@"watched_status == %@",@""];
        }
        else {
            _mangalistarraycontroller.filterPredicate = [NSPredicate predicateWithFormat:@"read_status == %@",@""];
        }
    }
    else {
        // Build Predicate rules
        NSMutableString *predicaterule = [NSMutableString new];
        for (int i=0; i < predicateformat.count; i++) {
            NSString *format = predicateformat[i];
            if (titlefilterused && i==0) {
                if (predicateformat.count == 1) {
                    [predicaterule appendString:format];
                    continue;
                }
                else {
                    [predicaterule appendFormat:@"%@ AND ", format];
                    continue;
                }
            }
            [predicaterule appendString:format];
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicaterule argumentArray:predicateobjects];
        if (type == 0) {
            _animelistarraycontroller.filterPredicate = predicate;
        }
        else {
            _mangalistarraycontroller.filterPredicate = predicate;
        }
    }
}

- (IBAction)animelistdoubleclick:(id)sender {
    if (_currentlist == 0) {
        if (_animelisttb.selectedRow >=0) {
            if (_animelisttb.selectedRow >-1) {
                NSDictionary *d = _animelistarraycontroller.selectedObjects[0];
                NSNumber *idnum = d[@"id"];
                [[self _mw] loadinfo:idnum type:0 changeView:YES];
                [[self _mw].window makeKeyAndOrderFront:self];
            }
        }
    }
    else {
        if (_mangalisttb.selectedRow >=0) {
            if (_mangalisttb.selectedRow >-1) {
                NSDictionary *d = _mangalistarraycontroller.selectedObjects[0];
                NSNumber *idnum = d[@"id"];
                [[self _mw] loadinfo:idnum type:_currentlist changeView:YES];
                [[self _mw].window makeKeyAndOrderFront:self];
            }
        }
    }
}

- (NSArray *)obtainfilterstatus:(int)type {
    // Generates an array of selected filters
    NSMutableArray *a = [NSMutableArray new];
    NSMutableArray *final = [NSMutableArray new];
    if (type == 0) {
        [a addObject:@{@"watching":@(_watchingfilter.intValue)}];
        [a addObject:@{@"completed":@(_completedfilter.state)}];
        [a addObject:@{@"on-hold":@(_onholdfilter.state)}];
        [a addObject:@{@"dropped":@(_droppedfilter.state)}];
        [a addObject:@{@"plan to watch":@(_plantowatchfilter.state)}];
        for (NSDictionary *d in a) {
            NSNumber *add = d[d.allKeys[0]];
            if (add.boolValue) {
                [final addObject:d];
            }
        }
    }
    else {
        [a addObject:@{@"reading":@(_readingfilter.state)}];
        [a addObject:@{@"completed":@(_mangacompletedfilter.state)}];
        [a addObject:@{@"on-hold":@(_mangaonholdfilter.state)}];
        [a addObject:@{@"dropped":@(_mangadroppedfilter.state)}];
        [a addObject:@{@"plan to read":@(_plantoreadfilter.state)}];
        for (NSDictionary *d in a) {
            NSNumber *add = d[d.allKeys[0]];
            if (add.boolValue) {
                [final addObject:d];
            }
        }
    }
    return final;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  
}

- (IBAction)viewtitleinfo:(id)sender {
    NSDictionary *d;
    NSNumber *idnum = @(0);
    if (_currentlist == 0) {
        if (_animelisttb.selectedRow >=0) {
            if (_animelisttb.selectedRow >-1) {
                d = _animelistarraycontroller.selectedObjects[0];
                idnum = d[@"id"];
            }
        }
    }
    else {
        if (_mangalisttb.selectedRow >=0) {
                d = _mangalistarraycontroller.selectedObjects[0];
                idnum = d[@"id"];
        }
    }
    [[self _mw] loadinfo:idnum type:_currentlist changeView:YES];
}

- (void)removeAllFilterBindings {
    [_watchingfilter unbind:@"value"];
    [_completedfilter unbind:@"value"];
    [_droppedfilter unbind:@"value"];
    [_onholdfilter unbind:@"value"];
    [_plantowatchfilter unbind:@"value"];
    [_readingfilter unbind:@"value"];
    [_mangacompletedfilter unbind:@"value"];
    [_mangadroppedfilter unbind:@"value"];
    [_mangaonholdfilter unbind:@"value"];
    [_plantoreadfilter unbind:@"value"];
    _watchingfilter.state = 1;
    _completedfilter.state = 0;
    _droppedfilter.state = 0;
    _onholdfilter.state = 0;
    _plantowatchfilter.state = 0;
    _readingfilter.state = 1;
    _mangacompletedfilter.state = 0;
    _mangadroppedfilter.state = 0;
    _mangaonholdfilter.state = 0;
    _plantoreadfilter.state = 0;
}

- (void)clearalllists {
    NSMutableArray *a = [_animelistarraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_animelisttb reloadData];
    a = [_mangalistarraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_mangalisttb reloadData];
}
@end
