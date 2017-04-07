//
//  ListView.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "ListView.h"
#import "MainWindow.h"
#import "EditTitle.h"
#import "Keychain.h"
#import <AFNetworking/AFNetworking.h>

@interface ListView ()

@end

@implementation ListView

- (id)init
{
    return [super initWithNibName:@"ListView" bundle:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here
    [self view];
    [self.view addSubview:_animelistview];
    [_animelistview setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_mangalistview setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
}

- (void)loadList:(int)list{
    if (list == 0){
        [[self view] replaceSubview:[[self.view subviews] objectAtIndex:0] with:_animelistview];
        currentlist = list;
        [self setToolbarButtonState];
    }
    else {
        [[self view] replaceSubview:[[self.view subviews] objectAtIndex:0] with:_mangalistview];
        currentlist = list;
        [self setToolbarButtonState];
    }
}

- (void)populateList:(id)object type:(int)type{
    if (type == 0){
        // Populates list
        NSMutableArray * a = [_animelistarraycontroller mutableArrayValueForKey:@"content"];
        [a removeAllObjects];
        NSDictionary * data = object;
        NSArray * list=data[@"anime"];
        [_animelistarraycontroller addObjects:list];
        [self populatefiltercounts:list type:type];
        [_animelisttb reloadData];
        [_animelisttb deselectAll:self];
        [self performfilter:type];
    }
    else {
        // Populates list
        NSMutableArray * a = [_mangalistarraycontroller mutableArrayValueForKey:@"content"];
        [a removeAllObjects];
        NSDictionary * data = object;
        NSArray * list = data[@"manga"];
        [_mangalistarraycontroller addObjects:list];
        [self populatefiltercounts:list type:type];
        [_mangalisttb reloadData];
        [_mangalisttb deselectAll:self];
        [self performfilter:type];
    }
    [self setToolbarButtonState];
}
- (void)populatefiltercounts:(NSArray *)a type:(int)type{
    // Generates item counts for each status filter
    NSArray * filtered;
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
    [self performfilter:currentlist];
}
- (void)performfilter:(int)type{
    // This method generates a predicate rule to use as a filter
    NSMutableArray * predicateformat = [NSMutableArray new];
    NSMutableArray * predicateobjects = [NSMutableArray new];
    bool titlefilterused = false;
    if (_animelistfilter.stringValue.length > 0){
        [predicateformat addObject: @"(title CONTAINS [cd] %@)"];
        [predicateobjects addObject: _animelistfilter.stringValue];
        titlefilterused = true;
    }
    NSArray * filterstatus = [self obtainfilterstatus:type];
    if (type == 0){
        for (int i=0; i < [filterstatus count]; i++){
            NSDictionary *d = [filterstatus objectAtIndex:i];
            if ([filterstatus count] == 1){
                [predicateformat addObject:@"(watched_status ==[cd] %@)"];
                
            }
            else if (i == [filterstatus count]-1){
                [predicateformat addObject:@"watched_status ==[cd] %@)"];
            }
            else if (i == 0){
                [predicateformat addObject:@"(watched_status ==[cd] %@ OR "];
            }
            else{
                [predicateformat addObject:@"watched_status ==[cd] %@ OR "];
            }
            [predicateobjects addObject:[[d allKeys] objectAtIndex:0]];
        }
    }
    else {
        for (int i=0; i < [filterstatus count]; i++){
            NSDictionary *d = [filterstatus objectAtIndex:i];
            if ([filterstatus count] == 1){
                [predicateformat addObject:@"(read_status ==[cd] %@)"];
                
            }
            else if (i == [filterstatus count]-1){
                [predicateformat addObject:@"read_status ==[cd] %@)"];
            }
            else if (i == 0){
                [predicateformat addObject:@"(read_status ==[cd] %@ OR "];
            }
            else{
                [predicateformat addObject:@"read_status ==[cd] %@ OR "];
            }
            [predicateobjects addObject:[[d allKeys] objectAtIndex:0]];
        }
    }
    if ([predicateformat count] ==0 || [filterstatus count] == 0){
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
        NSMutableString * predicaterule = [NSMutableString new];
        for (int i=0; i < [predicateformat count]; i++){
            NSString *format = [predicateformat objectAtIndex:i];
            if (titlefilterused && i==0){
                if ([predicateformat count] == 1) {
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
        NSPredicate * predicate = [NSPredicate predicateWithFormat:predicaterule argumentArray:predicateobjects];
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
        if ([_animelisttb selectedRow] >=0){
            if ([_animelisttb selectedRow] >-1){
                NSString *action = [[NSUserDefaults standardUserDefaults] valueForKey: @"listdoubleclickaction"];
                NSDictionary *d = [[_animelistarraycontroller selectedObjects] objectAtIndex:0];
                if ([action isEqualToString:@"View Info"]||[action isEqualToString:@"View Anime Info"]){
                    NSNumber * idnum = d[@"id"];
                    [mw loadinfo:idnum type:0];
                }
                else if([action isEqualToString:@"Modify Title"]){
                    [mw.editviewcontroller showEditPopover:d showRelativeToRec:[_animelisttb frameOfCellAtColumn:0 row:[_animelisttb selectedRow]] ofView:_animelisttb preferredEdge:0 type:currentlist];
                }
            }
        }
    }
    else {
        if ([_mangalisttb selectedRow] >=0){
            if ([_mangalisttb selectedRow] >-1){
                NSString *action = [[NSUserDefaults standardUserDefaults] valueForKey: @"listdoubleclickaction"];
                NSDictionary *d = [[_mangalistarraycontroller selectedObjects] objectAtIndex:0];
                if ([action isEqualToString:@"View Info"]||[action isEqualToString:@"View Anime Info"]){
                    NSNumber * idnum = d[@"id"];
                    [mw loadinfo:idnum type:currentlist];
                }
                else if([action isEqualToString:@"Modify Title"]){
                    [mw.editviewcontroller showEditPopover:d showRelativeToRec:[_mangalisttb frameOfCellAtColumn:0 row:[_mangalisttb selectedRow]] ofView:_mangalisttb preferredEdge:0 type:currentlist];
                }
            }
        }
    }
}

- (IBAction)deletetitle:(id)sender {
    NSAlert * alert = [[NSAlert alloc] init] ;
    NSDictionary *d;
    if (currentlist == 0){
        d = [[_animelistarraycontroller selectedObjects] objectAtIndex:0];
    }
    else {
        d = [[_mangalistarraycontroller selectedObjects] objectAtIndex:0];
    }
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert setMessageText:[NSString stringWithFormat:@"Are you sure you want to delete %@ from your list?", d[@"title"]]];
    [alert setInformativeText:@"Once you delete this title, this cannot be undone."];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:[mw window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode== NSAlertFirstButtonReturn) {
            [self deletetitle];
        }
    }];
}
- (NSArray *)obtainfilterstatus:(int)type{
    // Generates an array of selected filters
    NSMutableArray * a = [NSMutableArray new];
    NSMutableArray * final = [NSMutableArray new];
    if (type == 0){
        [a addObject:@{@"watching":@(_watchingfilter.state)}];
        [a addObject:@{@"completed":@(_completedfilter.state)}];
        [a addObject:@{@"on-hold":@(_onholdfilter.state)}];
        [a addObject:@{@"dropped":@(_droppedfilter.state)}];
        [a addObject:@{@"plan to watch":@(_plantowatchfilter.state)}];
        for (NSDictionary *d in a){
            NSNumber *add = [d objectForKey:[[d allKeys] objectAtIndex:0]];
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
            NSNumber *add = [d objectForKey:[[d allKeys] objectAtIndex:0]];
            if (add.boolValue){
                [final addObject:d];
            }
        }
    }
    return final;
}
- (void)deletetitle{
    NSDictionary *d;
    NSNumber * selid;
    NSString * deleteURL;
    if (currentlist == 0){
        d = [[_animelistarraycontroller selectedObjects] objectAtIndex:0];
        selid = d[@"id"];
        deleteURL = [NSString stringWithFormat:@"%@/2.1/animelist/anime/%i",[[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"], selid.intValue];
    }
    else {
        d = [[_mangalistarraycontroller selectedObjects] objectAtIndex:0];
        selid = d[@"id"];
        deleteURL = [NSString stringWithFormat:@"%@/2.1/mangalist/manga/%i", [[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"], selid.intValue];
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [Keychain getBase64]] forHTTPHeaderField:@"Authorization"];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager DELETE:deleteURL parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
        [mw loadlist:@(true) type:currentlist];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"%@",error);
    }];

}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self setToolbarButtonState];
}
- (void)setToolbarButtonState{
    if (currentlist == 0){
        if ([[_animelistarraycontroller selectedObjects] count] > 0){
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
        if ([[_mangalistarraycontroller selectedObjects] count] > 0){
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
