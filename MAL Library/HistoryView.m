//
//  HistoryView.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2017/04/07.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "HistoryView.h"
#import "Utility.h"
#import "NSTableViewAction.h"
#import "MainWindow.h"
#import "listservice.h"
#import "HistoryManager.h"

@interface HistoryView ()

@end

@implementation HistoryView

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNotification:) name:@"ServiceChanged" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNotification:) name:@"UserLoggedIn" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNotification:) name:@"UserLoggedOut" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNotification:) name:@"HistoryEntryInserted" object:nil];
    [self populateHistory];
}

- (void)receiveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"UserLoggedIn"]|| [notification.name isEqualToString:@"ServiceChanged"] || [notification.name isEqualToString:@"HistoryEntryInserted"]) {
        NSLog(@"Reloading History");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self populateHistory];
        });
    }
    else if ([notification.name isEqualToString:@"UserLoggedOut"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[_historyarraycontroller mutableArrayValueForKey:@"content"] removeAllObjects];
            [self.historytb reloadData];
        });
    }
}

- (void)loadHistory:(NSNumber *)refresh{
    bool refreshlist = refresh.boolValue;
    if (refreshlist || [self needsRefresh]) {
        [HistoryManager.sharedInstance synchistory:^(NSArray * _Nonnull history) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self populateHistory];
            });
        }];
    }
    else {
        [self populateHistory];
    }
}

- (bool)needsRefresh {
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"synchistorytoicloud"]) {
        return false;
    }
    return [[[NSDate dateWithTimeIntervalSince1970:[NSUserDefaults.standardUserDefaults integerForKey:@"historysyncdate"]] dateByAddingTimeInterval:6*60*60] timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970];
}

- (void)populateHistory {
    // Populates history
    NSMutableArray *a = [_historyarraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_historyarraycontroller addObjects:[HistoryManager.sharedInstance retrieveHistoryList]];
    if (!((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"]).boolValue) {
        _historyarraycontroller.filterPredicate = [NSPredicate predicateWithFormat:@"mediatype == %i", 0];
    }
    else {
        [_historyarraycontroller setFilterPredicate:nil];
    }
    [_historytb reloadData];
    [_historytb deselectAll:self];
    [self applyHistoryFilter];
}

- (void)clearHistory {
    HistoryManager *historymgr = HistoryManager.sharedInstance;
    [historymgr removeAllHistoryRecords];
    [historymgr removeAlliCloudHistoryRecords:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self populateHistory];
        });
    }];
}

- (IBAction)clearHistory:(id)sender {
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"Clear History?";
    alert.informativeText = [NSUserDefaults.standardUserDefaults boolForKey:@"synchistorytoicloud"] ? @"Do you want to clear the history. This cannot be undone. History will clear on all devices connected to your iCloud account." : @"Do you want to clear the history. This cannot be undone.";
    [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertSecondButtonReturn) {
            [self clearHistory];
        }
    }];
}

- (IBAction)historydoubleclick:(id)sender {
    if (_historytb.selectedRow >=0) {
        if (_historytb.selectedRow >-1) {
            NSDictionary *d = _historyarraycontroller.selectedObjects[0];
            NSNumber *idnum = d[@"titleid"];
            NSNumber *mediatype = d[@"mediatype"];
            [NSNotificationCenter.defaultCenter postNotificationName:@"LoadTitleInfo" object:@{@"id" : idnum, @"type" : mediatype}];
        }
    }
}
- (IBAction)mediatypeselectorchanged:(id)sender {
    [self applyHistoryFilter];
}

- (void)applyHistoryFilter {
    dispatch_async(dispatch_get_main_queue(), ^{
        _historyarraycontroller.filterPredicate = [NSPredicate predicateWithFormat:@"mediatype == %li", _mediatypeselector.selectedSegment];
        [_historytb reloadData];
        [_historytb deselectAll:self];
    });
}
@end
