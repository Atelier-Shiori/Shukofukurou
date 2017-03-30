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
}
#pragma mark Anime List
-(void)populateList:(id)object{
    // Populates list
    NSMutableArray * a = [_animelistarraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    NSDictionary * data = object;
    NSArray * list=data[@"anime"];
    [_animelistarraycontroller addObjects:list];
    [self populatefiltercounts:list];
    [_animelisttb reloadData];
    [_animelisttb deselectAll:self];
    [self performfilter];
}
-(void)populatefiltercounts:(NSArray *)a{
    // Generates item counts for each status filter
    NSArray * filtered;
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
- (IBAction)filterperform:(id)sender {
    [self performfilter];
}
-(void)performfilter{
    // This method generates a predicate rule to use as a filter
    NSMutableArray * predicateformat = [NSMutableArray new];
    NSMutableArray * predicateobjects = [NSMutableArray new];
    bool titlefilterused = false;
    if (_animelistfilter.stringValue.length > 0){
        [predicateformat addObject: @"(title CONTAINS [cd] %@)"];
        [predicateobjects addObject: _animelistfilter.stringValue];
        titlefilterused = true;
    }
    NSArray * filterstatus = [self obtainfilterstatus];
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
    if ([predicateformat count] ==0 || [filterstatus count] == 0){
        // Empty filter predicate
        _animelistarraycontroller.filterPredicate = [NSPredicate predicateWithFormat:@"watched_status == %@",@""];
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
        _animelistarraycontroller.filterPredicate = predicate;
    }
}

- (IBAction)animelistdoubleclick:(id)sender {
    if ([_animelisttb selectedRow] >=0){
        if ([_animelisttb selectedRow] >-1){
            NSString *action = [[NSUserDefaults standardUserDefaults] valueForKey: @"listdoubleclickaction"];
            NSDictionary *d = [[_animelistarraycontroller selectedObjects] objectAtIndex:0];
            if ([action isEqualToString:@"View Anime Info"]){
                NSNumber * idnum = d[@"id"];
                [mw loadanimeinfo:idnum];
            }
            else if([action isEqualToString:@"Modify Title"]){
                [mw.editviewcontroller showEditPopover:d showRelativeToRec:[_animelisttb frameOfCellAtColumn:0 row:[_animelisttb selectedRow]] ofView:_animelisttb preferredEdge:0];
            }
        }
    }
}

- (IBAction)deletetitle:(id)sender {
    NSAlert * alert = [[NSAlert alloc] init] ;
    NSDictionary *d = [[_animelistarraycontroller selectedObjects] objectAtIndex:0];
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
-(NSArray *)obtainfilterstatus{
    // Generates an array of selected filters
    NSMutableArray * a = [NSMutableArray new];
    NSMutableArray * final = [NSMutableArray new];
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
    return final;
}
-(void)deletetitle{
    NSDictionary *d = [[_animelistarraycontroller selectedObjects] objectAtIndex:0];
    NSNumber * selid = d[@"id"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [Keychain getBase64]] forHTTPHeaderField:@"Authorization"];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager DELETE:[NSString stringWithFormat:@"https://malapi.ateliershiori.moe/2.1/animelist/anime/%i", selid.intValue] parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
        [mw loadlist:@(true)];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
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


@end
