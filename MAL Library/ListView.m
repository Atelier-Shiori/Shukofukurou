//
//  ListView.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import "ListView.h"
#import "MainWindow.h"
#import "EditTitle.h"
#import "Keychain.h"
#import "MyAnimeList.h"
#import "Utility.h"

@interface ListView ()
// Filter Save
@property (strong) NSString * animelisttitlefilterstring;
@property (strong) NSString * mangalisttitlefilterstring;
@end

@implementation ListView

- (instancetype)init
{
    return [super initWithNibName:@"ListView" bundle:nil];
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
}

- (void)loadList:(int)list{
    if (list == 0){
        _mangalisttitlefilterstring = _animelistfilter.stringValue;
        _animelistfilter.stringValue = _animelisttitlefilterstring;
        [self.view replaceSubview:(self.view).subviews[0] with:_animelistview];
        currentlist = list;
        [self setToolbarButtonState];
    }
    else {
        _animelisttitlefilterstring = _animelistfilter.stringValue;
        _animelistfilter.stringValue = _mangalisttitlefilterstring;
        [self.view replaceSubview:(self.view).subviews[0] with:_mangalistview];
        currentlist = list;
        [self setToolbarButtonState];
    }
}

- (void)populateList:(id)object type:(int)type{
    NSNumber *selectedAnimeID = nil;
    if (type == 0){
        // Populates list
        if (_animelisttb.selectedRow >= 0) {
            selectedAnimeID = _animelistarraycontroller.selectedObjects[0][@"id"];
        }
        NSMutableArray *a = [_animelistarraycontroller mutableArrayValueForKey:@"content"];
        [a removeAllObjects];
        NSDictionary *data = object;
        NSArray *list;
        if (data[@"anime"]){
            list = data[@"anime"];
            [_animelistarraycontroller addObjects:list];
        }
        else {
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
                else if (index == a.count - 1){
                    [_animelisttb deselectAll:self];
                }
            }
            if (a.count == 0){
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
        if (data[@"manga"]){
            list = data[@"manga"];
            [_mangalistarraycontroller addObjects:list];
        }
        else {
            [_mangalisttb reloadData];
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
                else if (index == a.count - 1){
                    [_mangalisttb deselectAll:self];
                }
            }
            if (a.count == 0){
                [_mangalisttb deselectAll:self];
            }
        }
        else {
            [_mangalisttb deselectAll:self];
        }
        [self performfilter:type];
    }
    [self setToolbarButtonState];
}
- (void)populatefiltercounts:(NSArray *)a type:(int)type{
    // Generates item counts for each status filter
    NSArray *arg = [[NSProcessInfo processInfo] arguments];
    if (arg.count > 1){
        if ([(NSString *)[arg objectAtIndex:[arg count]-1] isEqualToString:@"testing"]){
            return;
        }
    }
    NSArray *filtered;
    if (type == 0){
        NSNumber *watching;
        NSNumber *completed;
        NSNumber *onhold;
        NSNumber *dropped;
        NSNumber *plantowatch;
        for (int i = 0; i < 5; i++){
            switch(i){
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
        for (int i = 0; i < 5; i++){
            switch(i){
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
    if (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"filtersastabs"]).boolValue && [sender isKindOfClass:[NSButton class]]){
        [self filterStatusAsTabs:(NSButton *)sender];
    }
    [self performfilter:currentlist];
}

- (void)filterStatusAsTabs:(NSButton *)btn{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (currentlist == 0){
        if (_watchingfilter != btn){
            [defaults setValue:@(0) forKey:@"watchingfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"watchingfilter"];
        }
        if (_completedfilter != btn){
            [defaults setValue:@(0) forKey:@"completedfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"completedfilter"];
        }
        if (_droppedfilter != btn){
            [defaults setValue:@(0) forKey:@"droppedfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"droppedfilter"];
        }
        if (_onholdfilter != btn){
            [defaults setValue:@(0) forKey:@"onholdfilter"];
        }
        else{
            [defaults setValue:@(1) forKey:@"onholdfilter"];
        }
        if (_plantowatchfilter != btn){
            [defaults setValue:@(0) forKey:@"plantowatchfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"plantowatchfilter"];
        }
    }
    else {
        if (_readingfilter != btn){
            [defaults setValue:@(0) forKey:@"readingfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"readingfilter"];
        }
        if (_mangacompletedfilter != btn){
            [defaults setValue:@(0) forKey:@"mcompletedfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"mcompletedfilter"];
        }
        if (_mangadroppedfilter != btn){
            [defaults setValue:@(0) forKey:@"mdroppedfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"mdroppedfilter"];
        }
        if (_mangaonholdfilter != btn){
            [defaults setValue:@(0) forKey:@"monholdfilter"];
        }
        else{
            [defaults setValue:@(1) forKey:@"monholdfilter"];
        }
        if (_plantoreadfilter != btn){
            [defaults setValue:@(0) forKey:@"plantoreadfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"plantoreadfilter"];
        }
    }
}

- (void)performfilter:(int)type{
    // This method generates a predicate rule to use as a filter
    NSMutableArray *predicateformat = [NSMutableArray new];
    NSMutableArray *predicateobjects = [NSMutableArray new];
    bool titlefilterused = false;
    if (_animelistfilter.stringValue.length > 0){
        [predicateformat addObject: @"(title CONTAINS [cd] %@)"];
        [predicateobjects addObject: _animelistfilter.stringValue];
        titlefilterused = true;
    }
    NSArray *filterstatus = [self obtainfilterstatus:type];
    if (type == 0){
        
        for (int i=0; i < filterstatus.count; i++){
            NSDictionary *d = filterstatus[i];
            if (filterstatus.count == 1){
                [predicateformat addObject:@"(watched_status ==[cd] %@)"];
                
            }
            else if (i == filterstatus.count-1){
                [predicateformat addObject:@"watched_status ==[cd] %@)"];
            }
            else if (i == 0){
                [predicateformat addObject:@"(watched_status ==[cd] %@ OR "];
            }
            else{
                [predicateformat addObject:@"watched_status ==[cd] %@ OR "];
            }
            [predicateobjects addObject:d.allKeys[0]];
        }
    }
    else {
        for (int i=0; i < filterstatus.count; i++){
            NSDictionary *d = filterstatus[i];
            if (filterstatus.count == 1){
                [predicateformat addObject:@"(read_status ==[cd] %@)"];
                
            }
            else if (i == filterstatus.count-1){
                [predicateformat addObject:@"read_status ==[cd] %@)"];
            }
            else if (i == 0){
                [predicateformat addObject:@"(read_status ==[cd] %@ OR "];
            }
            else{
                [predicateformat addObject:@"read_status ==[cd] %@ OR "];
            }
            [predicateobjects addObject:d.allKeys[0]];
        }
    }
    if (predicateformat.count ==0 || filterstatus.count == 0){
        // Empty filter predicate
        if (type == 0){
            _animelistarraycontroller.filterPredicate = [NSPredicate predicateWithFormat:@"watched_status == %@",@""];
        }
        else {
            _mangalistarraycontroller.filterPredicate = [NSPredicate predicateWithFormat:@"read_status == %@",@""];
        }
    }
    else{
        // Build Predicate rules
        NSMutableString *predicaterule = [NSMutableString new];
        for (int i=0; i < predicateformat.count; i++){
            NSString *format = predicateformat[i];
            if (titlefilterused && i==0){
                if (predicateformat.count == 1) {
                    [predicaterule appendString:format];
                    continue;
                }
                else{
                    [predicaterule appendFormat:@"%@ AND ", format];
                    continue;
                }
            }
            [predicaterule appendString:format];
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicaterule argumentArray:predicateobjects];
        if (type == 0){
            _animelistarraycontroller.filterPredicate = predicate;
        }
        else {
            _mangalistarraycontroller.filterPredicate = predicate;
        }
    }
}

- (IBAction)animelistdoubleclick:(id)sender {
    if (currentlist == 0){
        if (_animelisttb.selectedRow >=0){
            if (_animelisttb.selectedRow >-1){
                NSString *action = [[NSUserDefaults standardUserDefaults] valueForKey: @"listdoubleclickaction"];
                NSDictionary *d = _animelistarraycontroller.selectedObjects[0];
                if ([action isEqualToString:@"View Info"]||[action isEqualToString:@"View Anime Info"]){
                    NSNumber *idnum = d[@"id"];
                    [mw loadinfo:idnum type:0];
                }
                else if([action isEqualToString:@"Modify Title"]){
                    [mw.editviewcontroller showEditPopover:d showRelativeToRec:[_animelisttb frameOfCellAtColumn:0 row:_animelisttb.selectedRow] ofView:_animelisttb preferredEdge:0 type:currentlist];
                }
            }
        }
    }
    else {
        if (_mangalisttb.selectedRow >=0){
            if (_mangalisttb.selectedRow >-1){
                NSString *action = [[NSUserDefaults standardUserDefaults] valueForKey: @"listdoubleclickaction"];
                NSDictionary *d = _mangalistarraycontroller.selectedObjects[0];
                if ([action isEqualToString:@"View Info"]||[action isEqualToString:@"View Anime Info"]){
                    NSNumber *idnum = d[@"id"];
                    [mw loadinfo:idnum type:currentlist];
                }
                else if([action isEqualToString:@"Modify Title"]){
                    [mw.editviewcontroller showEditPopover:d showRelativeToRec:[_mangalisttb frameOfCellAtColumn:0 row:_mangalisttb.selectedRow] ofView:_mangalisttb preferredEdge:0 type:currentlist];
                }
            }
        }
    }
}

- (IBAction)deletetitle:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init] ;
    NSDictionary *d;
    if (currentlist == 0){
        d = _animelistarraycontroller.selectedObjects[0];
    }
    else {
        d = _mangalistarraycontroller.selectedObjects[0];
    }
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    alert.messageText = [NSString stringWithFormat:@"Are you sure you want to delete %@ from your list?", d[@"title"]];
    alert.informativeText = @"Once you delete this title, this cannot be undone.";
    alert.alertStyle = NSAlertStyleWarning;
    [alert beginSheetModalForWindow:mw.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode== NSAlertFirstButtonReturn) {
            [self deletetitle];
        }
    }];
}
- (NSArray *)obtainfilterstatus:(int)type{
    // Generates an array of selected filters
    NSMutableArray *a = [NSMutableArray new];
    NSMutableArray *final = [NSMutableArray new];
    if (type == 0){
        [a addObject:@{@"watching":@(_watchingfilter.intValue)}];
        [a addObject:@{@"completed":@(_completedfilter.state)}];
        [a addObject:@{@"on-hold":@(_onholdfilter.state)}];
        [a addObject:@{@"dropped":@(_droppedfilter.state)}];
        [a addObject:@{@"plan to watch":@(_plantowatchfilter.state)}];
        for (NSDictionary *d in a){
            NSNumber *add = d[d.allKeys[0]];
            if (add.boolValue){
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
        for (NSDictionary *d in a){
            NSNumber *add = d[d.allKeys[0]];
            if (add.boolValue){
                [final addObject:d];
            }
        }
    }
    return final;
}
- (void)deletetitle{
    NSDictionary *d;
    NSNumber *selid;
    if (currentlist == 0){
        d = _animelistarraycontroller.selectedObjects[0];
        selid = d[@"id"];
    }
    else {
        d = _mangalistarraycontroller.selectedObjects[0];
        selid = d[@"id"];
    }
    [MyAnimeList removeTitleFromList:selid.intValue withType:currentlist completion:^(id responseobject){
        [mw loadlist:@(true) type:currentlist];
    }error:^(NSError *error){
        NSLog(@"%@",error);
    }];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self setToolbarButtonState];
}
- (void)setToolbarButtonState{
    if (currentlist == 0){
        if (_animelistarraycontroller.selectedObjects.count > 0){
            [_edittitleitem setEnabled:YES];
            [_deletetitleitem setEnabled:YES];
            [_shareitem setEnabled:YES];
        }
        else {
            [_edittitleitem setEnabled:NO];
            [_deletetitleitem setEnabled:NO];
            [_shareitem setEnabled:NO];
        }
    }
    else {
        if (_mangalistarraycontroller.selectedObjects.count > 0){
            [_edittitleitem setEnabled:YES];
            [_deletetitleitem setEnabled:YES];
            [_shareitem setEnabled:YES];
        }
        else {
            [_edittitleitem setEnabled:NO];
            [_deletetitleitem setEnabled:NO];
            [_shareitem setEnabled:NO];
        }
    }
}

@end
