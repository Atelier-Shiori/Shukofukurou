//
//  MyListView.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/10/06.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "MyListView.h"
#import "listservice.h"
#import "EditTitle.h"
#import "AtarashiiListCoreData.h"
#import "AiringNotificationManager.h"
#import "Utility.h"
#import "Analytics.h"

@interface MyListView ()
@property bool updating;
@property (strong) NSMenu *animecontextmenu;
@property (strong) NSMenu *mangacontextmenu;
@end

@implementation MyListView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here
    self.customlistmodifyviewcontroller.mw = self.mw;
    [self createpopupMenu];
    self.animelisttb.menu = _animecontextmenu;
    self.mangalisttb.menu = _mangacontextmenu;
}

- (void)loadList:(int)list {
    [super loadList:list];
    [self setToolbarButtonState];
}

- (void)populateList:(id)object type:(int)type {
    [super populateList:object type:type];
    [self setToolbarButtonState];
    if ([NSUserDefaults.standardUserDefaults integerForKey:@"airingnotification_service"] == [listservice.sharedInstance getCurrentServiceID] && type == 0) {
        [[AiringNotificationManager sharedAiringNotificationManager] checknotifications:^(bool success) {
            NSLog(@"Done fetching new air notifications");
        }];
    }
}

- (void)filterStatusAsTabs:(NSButton *)btn{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.currentlist == 0) {
        // Clear Custom List
        self.currentcustomlistanime = @"";
        [self setToolTipForType:0 shouldReset:true];
        if (self.watchingfilter != btn) {
            [defaults setValue:@(0) forKey:@"watchingfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"watchingfilter"];
        }
        if (self.completedfilter != btn) {
            [defaults setValue:@(0) forKey:@"completedfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"completedfilter"];
        }
        if (self.droppedfilter != btn) {
            [defaults setValue:@(0) forKey:@"droppedfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"droppedfilter"];
        }
        if (self.onholdfilter != btn) {
            [defaults setValue:@(0) forKey:@"onholdfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"onholdfilter"];
        }
        if (self.plantowatchfilter != btn) {
            [defaults setValue:@(0) forKey:@"plantowatchfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"plantowatchfilter"];
        }
    }
    else {
        // Clear Custom List
        self.currentcustomlistmanga = @"";
        [self setToolTipForType:1 shouldReset:true];
        if (self.readingfilter != btn) {
            [defaults setValue:@(0) forKey:@"readingfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"readingfilter"];
        }
        if (self.mangacompletedfilter != btn) {
            [defaults setValue:@(0) forKey:@"mcompletedfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"mcompletedfilter"];
        }
        if (self.mangadroppedfilter != btn) {
            [defaults setValue:@(0) forKey:@"mdroppedfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"mdroppedfilter"];
        }
        if (self.mangaonholdfilter != btn) {
            [defaults setValue:@(0) forKey:@"monholdfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"monholdfilter"];
        }
        if (self.plantoreadfilter != btn) {
            [defaults setValue:@(0) forKey:@"plantoreadfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"plantoreadfilter"];
        }
    }
}

- (IBAction)deletetitle:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init] ;
    NSDictionary *d;
    if (self.currentlist == 0) {
        if (self.animelistarraycontroller.selectedObjects.count > 0) {
            d = self.animelistarraycontroller.selectedObjects[0];
        }
        else {
            NSLog(@"Invalid Selection, aborting delete.");
            return;
        }
    }
    else {
        if (self.mangalistarraycontroller.selectedObjects.count > 0) {
            d = self.mangalistarraycontroller.selectedObjects[0];
        }
        else {
            NSLog(@"Invalid Selection, aborting delete.");
            return;
        }
    }
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    alert.messageText = [NSString stringWithFormat:@"Are you sure you want to delete %@ from your list?", d[@"title"]];
    alert.informativeText = @"Once you delete this title, this cannot be undone.";
    alert.alertStyle = NSAlertStyleWarning;
    [alert beginSheetModalForWindow:_mw.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode== NSAlertFirstButtonReturn) {
            [self deletetitle];
        }
    }];
}

- (void)deletetitle {
    __block NSDictionary *d;
    NSNumber *selid;
    if (self.currentlist == 0) {
        if (self.animelistarraycontroller.selectedObjects.count > 0) {
            d = self.animelistarraycontroller.selectedObjects[0];
            switch ([listservice.sharedInstance getCurrentServiceID]) {
                case 1:
                    selid = d[@"id"];
                    break;
                case 2:
                case 3:
                    selid = d[@"entryid"];
                    break;
                default:
                    break;
            }
        }
        else {
            NSLog(@"Invalid Selection, aborting delete.");
            return;
        }
    }
    else {
        if (self.mangalistarraycontroller.selectedObjects.count > 0) {
            d = self.mangalistarraycontroller.selectedObjects[0];
            switch ([listservice.sharedInstance getCurrentServiceID]) {
                case 1:
                    selid = d[@"id"];
                    break;
                case 2:
                case 3:
                    selid = d[@"entryid"];
                    break;
                default:
                    break;
            }
        }
        else {
            NSLog(@"Invalid Selection, aborting delete.");
            return;
        }
    }
    _deletetitleitem.enabled = NO;
    [self setUpdatingState:true];
    [listservice.sharedInstance removeTitleFromList:selid.intValue withType:self.currentlist completion:^(id responseobject) {
        switch ([listservice.sharedInstance getCurrentServiceID]) {
            case 1:
                [AtarashiiListCoreData removeSingleEntrywithUserName:[listservice.sharedInstance getCurrentServiceUsername] withService:[listservice.sharedInstance getCurrentServiceID] withType:self.currentlist withId:selid.intValue withIdType:0];
                break;
            case 2:
            case 3:
                [AtarashiiListCoreData removeSingleEntrywithUserId:[listservice.sharedInstance getCurrentUserID] withService:[listservice.sharedInstance getCurrentServiceID] withType:self.currentlist withId:selid.intValue withIdType:1];
                break;
            default:
                break;
        }
        [_mw loadlist:@(false) type:self.currentlist];
        [self setUpdatingState:false];
        [Analytics sendAnalyticsWithEventTitle:@"Entry Deletion Successful" withProperties:@{@"service" : [listservice.sharedInstance currentservicename], @"media_type" : self.currentlist == 0 ? @"anime" : @"manga"}];
        if ([NSUserDefaults.standardUserDefaults integerForKey:@"airingnotification_service"] == [listservice.sharedInstance getCurrentServiceID] && self.currentlist == 0) {
            [[AiringNotificationManager sharedAiringNotificationManager] removeNotifyingTitle:((NSNumber *)d[@"id"]).intValue withService:[listservice.sharedInstance getCurrentServiceID]];
        }
    }error:^(NSError *error) {
        NSLog(@"%@",error);
        _deletetitleitem.enabled = YES;
        [self setUpdatingState:false];
        [Analytics sendAnalyticsWithEventTitle:@"Entry Deletion Failed" withProperties:@{@"service" : [listservice.sharedInstance currentservicename], @"localized_error" : error.localizedDescription, @"error_description" : [Analytics getErrorDescriptionFromErrorResponse:error], @"media_type" : self.currentlist == 0 ? @"anime" : @"manga"}];
    }];
}

- (IBAction)animelistdoubleclick:(id)sender {
    if (self.currentlist == 0) {
        if (self.animelisttb.selectedRow >=0) {
            if (self.animelisttb.selectedRow >-1) {
                NSString *action = [[NSUserDefaults standardUserDefaults] valueForKey: @"listdoubleclickaction"];
                NSDictionary *d = self.animelistarraycontroller.selectedObjects[0];
                if ([action isEqualToString:@"View Info"]||[action isEqualToString:@"View Anime Info"]) {
                    NSNumber *idnum = d[@"id"];
                    [NSNotificationCenter.defaultCenter postNotificationName:@"LoadTitleInfo" object:@{@"id" : idnum, @"type" : @(0)}];
                }
                else if([action isEqualToString:@"Modify Title"]) {
                    [_mw.editviewcontroller showEditPopover:d showRelativeToRec:[self.animelisttb frameOfCellAtColumn:0 row:self.animelisttb.selectedRow] ofView:self.animelisttb preferredEdge:0 type:self.currentlist];
                }
            }
        }
    }
    else {
        if (self.mangalisttb.selectedRow >=0) {
            if (self.mangalisttb.selectedRow >-1) {
                NSString *action = [[NSUserDefaults standardUserDefaults] valueForKey: @"listdoubleclickaction"];
                NSDictionary *d = self.mangalistarraycontroller.selectedObjects[0];
                if ([action isEqualToString:@"View Info"]||[action isEqualToString:@"View Anime Info"]) {
                    NSNumber *idnum = d[@"id"];
                    [NSNotificationCenter.defaultCenter postNotificationName:@"LoadTitleInfo" object:@{@"id" : idnum, @"type" : @(self.currentlist)}];
                }
                else if([action isEqualToString:@"Modify Title"]) {
                    [_mw.editviewcontroller showEditPopover:d showRelativeToRec:[self.mangalisttb frameOfCellAtColumn:0 row:self.mangalisttb.selectedRow] ofView:self.mangalisttb preferredEdge:0 type: self.currentlist];
                }
            }
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self setToolbarButtonState];
}

- (void)setToolbarButtonState{
    [self view];
    if (self.currentlist == 0) {
        if (self.animelistarraycontroller.selectedObjects.count > 0 && !_updating) {
            _edittitleitem.enabled = YES;
            _deletetitleitem.enabled = YES;
            _shareitem.enabled = YES;
            _titleinfoitem.enabled = YES;
            _incrementitem.enabled = YES;
            _customlistmodifyitem.enabled = YES;
        }
        else {
            _edittitleitem.enabled = NO;
            _deletetitleitem.enabled = NO;
            _shareitem.enabled = NO;
            _titleinfoitem.enabled = NO;
            _incrementitem.enabled = NO;
            _customlistmodifyitem.enabled = NO;
        }
    }
    else {
        if (self.mangalistarraycontroller.selectedObjects.count > 0 && !_updating) {
            _edittitleitem.enabled = YES;
            _deletetitleitem.enabled = YES;
            _shareitem.enabled = YES;
            _titleinfoitem.enabled = YES;
            _incrementitem.enabled = YES;
            _customlistmodifyitem.enabled = YES;
        }
        else {
            _edittitleitem.enabled = NO;
            _deletetitleitem.enabled = NO;
            _shareitem.enabled = NO;
            _titleinfoitem.enabled = NO;
            _incrementitem.enabled = NO;
            _customlistmodifyitem.enabled = NO;
        }
    }
}

- (IBAction)increment:(id)sender {
    if (self.currentlist == 0) {
        if (self.animelistarraycontroller.selectedObjects.count > 0) {
            [self animeincrement];
        }
    }
    else {
        if (self.mangalistarraycontroller.selectedObjects.count > 0) {
            [self mangaincrement:NO];
        }
    }
}

- (void)animeincrement {
    NSDictionary *d = self.animelistarraycontroller.selectedObjects[0];
    int currentservice = [listservice.sharedInstance getCurrentServiceID];
    int titleid = -1;
    switch (currentservice) {
        case 1:
            titleid = ((NSNumber *)d[@"id"]).intValue;
            break;
        case 2:
        case 3: {
            titleid = ((NSNumber *)d[@"entryid"]).intValue;
            break;
        }
        default:
            break;
    }
    
    bool rewatching = ((NSNumber *)d[@"rewatching"]).boolValue;
    NSString *airingstatus = d[@"status"];
    bool selectedaircompleted;
    bool selectedaired;
    NSString *watchstatus = d[@"watched_status"];
    int watchedepisodes = ((NSNumber *)d[@"watched_episodes"]).intValue+1;
    int episodes = ((NSNumber *)d[@"episodes"]).intValue;
    if ([airingstatus isEqualToString:@"finished airing"]) {
        selectedaircompleted = true;
    }
    else {
        selectedaircompleted = false;
    }
    if ([airingstatus isEqualToString:@"finished airing"]||[airingstatus isEqualToString:@"currently airing"]) {
        selectedaired = true;
    }
    else {
        selectedaired = false;
    }
    if (!selectedaired && (![watchstatus isEqual:@"plan to watch"] || watchedepisodes > 0)) {
        // Invalid input, mark it as such
        NSBeep();
        return;
    }
    else if (selectedaired && [watchstatus isEqual:@"plan to watch"])  {
        // Invalid input, mark it as such
        watchstatus = @"watching";
    }
    if (watchedepisodes == episodes && episodes != 0 && selectedaircompleted && selectedaired) {
        watchstatus = @"completed";
        watchedepisodes = episodes;
        rewatching = false;
    }
    else if (watchedepisodes > episodes && episodes > 0) {
        NSBeep();
        return;
    }
    NSDictionary * extraparameters = @{};
    switch (currentservice) {
        case 2:
        case 3: {
            extraparameters = @{@"reconsuming" : @(rewatching)};
            break;
        }
        default:
            break;
    }
    int score = ((NSNumber *)d[@"score"]).intValue;
    [self setUpdatingState:true];
    [listservice.sharedInstance updateAnimeTitleOnList:titleid withEpisode:watchedepisodes withStatus:watchstatus withScore:score withExtraFields:extraparameters completion:^(id responseobject) {
        NSDictionary *updatedfields = @{@"watched_episodes" : @(watchedepisodes), @"watched_status" : watchstatus, @"score" : @(score), @"rewatching" : @(rewatching), @"last_updated" : [Utility getLastUpdatedDateWithResponseObject:responseobject withService:[listservice.sharedInstance getCurrentServiceID]]};
        switch ([listservice.sharedInstance getCurrentServiceID]) {
            case 1:
                [AtarashiiListCoreData updateSingleEntry:updatedfields withUserName:[listservice.sharedInstance getCurrentServiceUsername] withService:[listservice.sharedInstance getCurrentServiceID] withType:0 withId:titleid withIdType:0];
                break;
            case 2:
            case 3:
                [AtarashiiListCoreData updateSingleEntry:updatedfields withUserId:[listservice.sharedInstance getCurrentUserID] withService:[listservice.sharedInstance getCurrentServiceID] withType:0 withId:titleid withIdType:1];
                break;
        }
        [_mw loadlist:@(false) type:MALAnime];
        [self setUpdatingState:false];
        [Analytics sendAnalyticsWithEventTitle:@"Increment Successful" withProperties:@{@"service" : [listservice.sharedInstance currentservicename], @"media_type" : @"anime"}];
    }
                                  error:^(NSError * error) {
                                      [self setUpdatingState:false];
                                      NSLog(@"%@", error.localizedDescription);
                                      NSLog(@"Content: %@", [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
                                    [Analytics sendAnalyticsWithEventTitle:@"Increment Failed" withProperties:@{@"service" : [listservice.sharedInstance currentservicename], @"localized_error" : error.localizedDescription, @"error_description" : [Analytics getErrorDescriptionFromErrorResponse:error], @"media_type" : @"anime"}];
    }];
}

- (void)mangaincrement:(bool)volumeincrement {
    NSDictionary *d = self.mangalistarraycontroller.selectedObjects[0];
    int currentservice = [listservice.sharedInstance getCurrentServiceID];
    int titleid = -1;
    switch (currentservice) {
        case 1:
            titleid = ((NSNumber *)d[@"id"]).intValue;
            break;
        case 2:
        case 3: {
            titleid = ((NSNumber *)d[@"entryid"]).intValue;
            break;
        }
        default:
            break;
    }
    
    bool rereading = ((NSNumber *)d[@"rereading"]).boolValue;
    NSString *publishstatus = d[@"status"];
    bool selectedfinished;
    bool selectedpublished;
    NSString *readstatus = d[@"read_status"];
    int readchapters = !volumeincrement ? ((NSNumber *)d[@"chapters_read"]).intValue+1 : ((NSNumber *)d[@"chapters_read"]).intValue;
    int readvolumes = volumeincrement ? ((NSNumber *)d[@"volumes_read"]).intValue+1 : ((NSNumber *)d[@"volumes_read"]).intValue;
    int chapters = ((NSNumber *)d[@"chapters"]).intValue;
    int volumes = ((NSNumber *)d[@"volumes"]).intValue;
    if ([publishstatus isEqualToString:@"finished"]) {
        selectedfinished = true;
    }
    else {
        selectedfinished = false;
    }
    if ([publishstatus isEqualToString:@"finished"]||[publishstatus isEqualToString:@"publishing"]) {
        selectedpublished = true;
    }
    else {
        selectedpublished = false;
    }
    if(!selectedpublished && (![readstatus isEqual:@"plan to read"] || readchapters > 0 || readvolumes > 0))  {
        // Invalid input, mark it as such
        NSBeep();
        return;
    }
    else if (selectedpublished && [readstatus isEqual:@"plan to read"])  {
        // Invalid input, mark it as such
        readstatus = @"reading";
    }
    if (readchapters == chapters && chapters != 0 && selectedpublished && selectedfinished) {
        readstatus = @"completed";
        readchapters = chapters;
        readvolumes = volumes;
        rereading = false;
    }
    else if (readchapters > chapters && chapters > 0) {
        NSBeep();
        return;
    }
    NSDictionary * extraparameters = @{};
    switch (currentservice) {
        case 2:
        case 3: {
            extraparameters = @{@"reconsuming" : @(rereading)};
            break;
        }
        default:
            break;
    }
    int score = ((NSNumber *)d[@"score"]).intValue;
    [self setUpdatingState:true];
    [listservice.sharedInstance updateMangaTitleOnList:titleid withChapter:readchapters withVolume:readvolumes withStatus:readstatus withScore:score withExtraFields:extraparameters completion:^(id responseObject) {
        NSDictionary *updatedfields = @{@"chapters_read" : @(readchapters), @"volumes_read" : @(readvolumes), @"read_status" : readstatus, @"score" : @(score), @"rereading" : @(rereading), @"last_updated" : [Utility getLastUpdatedDateWithResponseObject:responseObject withService:[listservice.sharedInstance getCurrentServiceID]]};
        switch ([listservice.sharedInstance getCurrentServiceID]) {
            case 1:
                [AtarashiiListCoreData updateSingleEntry:updatedfields withUserName:[listservice.sharedInstance getCurrentServiceUsername] withService:[listservice.sharedInstance getCurrentServiceID] withType:1 withId:titleid withIdType:0];
                break;
            case 2:
            case 3:
                [AtarashiiListCoreData updateSingleEntry:updatedfields withUserId:[listservice.sharedInstance getCurrentUserID] withService:[listservice.sharedInstance getCurrentServiceID] withType:1 withId:titleid withIdType:1];
                break;
        }
        [_mw loadlist:@(false) type:MALManga];
        [self setUpdatingState:false];
        [Analytics sendAnalyticsWithEventTitle:@"Increment Successful" withProperties:@{@"service" : [listservice.sharedInstance currentservicename], @"media_type" : @"manga"}];
    } error:^(NSError *error) {
        [self setUpdatingState:false];
        NSLog(@"%@", error.localizedDescription);
        NSLog(@"Content: %@", [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
        [Analytics sendAnalyticsWithEventTitle:@"Increment Failed" withProperties:@{@"service" : [listservice.sharedInstance currentservicename], @"localized_error" : error.localizedDescription, @"error_description" : [Analytics getErrorDescriptionFromErrorResponse:error], @"media_type" : @"manga"}];
    }];
}
- (IBAction)modifyCustomLists:(id)sender {
    NSDictionary *d;
    NSNumber *selid;
    if (self.currentlist == 0) {
        if (self.animelistarraycontroller.selectedObjects.count > 0) {
            d = self.animelistarraycontroller.selectedObjects[0];
            switch ([listservice.sharedInstance getCurrentServiceID]) {
                case 1:
                    selid = d[@"id"];
                    break;
                case 2:
                case 3:
                    selid = d[@"entryid"];
                    break;
                default:
                    break;
            }
        }
        else {
            NSLog(@"Invalid Selection, aborting delete.");
            return;
        }
    }
    else {
        if (self.mangalistarraycontroller.selectedObjects.count > 0) {
            d = self.mangalistarraycontroller.selectedObjects[0];
            switch ([listservice.sharedInstance getCurrentServiceID]) {
                case 1:
                    selid = d[@"id"];
                    break;
                case 2:
                case 3:
                    selid = d[@"entryid"];
                    break;
                default:
                    break;
            }
        }
        else {
            NSLog(@"Invalid Selection, aborting delete.");
            return;
        }
    }
    if (self.currentlist == 0){
        [self.customlistmodifypopover showRelativeToRect:[self.animelisttb frameOfCellAtColumn:0 row:self.animelisttb.selectedRow] ofView:self.animelisttb preferredEdge:0];
    }
    else {
        [self.customlistmodifypopover showRelativeToRect:[self.mangalisttb frameOfCellAtColumn:0 row:self.mangalisttb.selectedRow] ofView:self.mangalisttb preferredEdge:0];
    }
    [self.customlistmodifyviewcontroller populateCustomLists:d withCurrentType:self.currentlist withSelectedId:selid.intValue];
}
- (void)setUpdatingState:(bool)updating {
    _updating = updating;
    [self setToolbarButtonState];
}
#pragma mark Context Menu
- (void)createpopupMenu {
    _animecontextmenu = [NSMenu new];
    _mangacontextmenu = [NSMenu new];
    _animecontextmenu.autoenablesItems = NO;
    _mangacontextmenu.autoenablesItems = NO;
    NSMenuItem *incrementepisode = [[NSMenuItem alloc] initWithTitle:@"Increment Episode" action:@selector(rightClickIncrement:) keyEquivalent:@""];
    NSMenuItem *incrementChapter = [[NSMenuItem alloc] initWithTitle:@"Increment Chapter" action:@selector(rightClickIncrement:) keyEquivalent:@""];
    NSMenuItem *incrementVolume = [[NSMenuItem alloc] initWithTitle:@"Increment Volume" action:@selector(rightClickVolumeIncrement:) keyEquivalent:@""];
    NSMenuItem *editItem = [[NSMenuItem alloc] initWithTitle:@"Edit Entry…" action:@selector(editEntry:) keyEquivalent:@""];
    NSMenuItem *customListItem = [[NSMenuItem alloc] initWithTitle:@"Modify Custom Lists…" action:@selector(rightclickManageCustomLists:) keyEquivalent:@""];
    NSMenuItem *deleteItem = [[NSMenuItem alloc] initWithTitle:@"Delete Entry…" action:@selector(rightClickDeleteEntry:) keyEquivalent:@""];
    NSMenuItem *titleInfoItem = [[NSMenuItem alloc] initWithTitle:
                                 @"View Title Information" action:@selector(viewTitleInfo:) keyEquivalent:@""];
    _animecontextmenu.itemArray = @[incrementepisode.copy,editItem.copy ,customListItem.copy,deleteItem.copy,titleInfoItem.copy];
    _mangacontextmenu.itemArray = @[incrementChapter.copy,incrementVolume.copy,editItem.copy,customListItem.copy,deleteItem.copy,titleInfoItem.copy];
    _animecontextmenu.delegate = self;
    _mangacontextmenu.delegate = self;
}

- (void)rightClickIncrement:(id)sender {
    long rightClickSelectedRow = self.currentlist == 0 ? self.animelisttb.clickedRow : self.mangalisttb.clickedRow;
    if (self.currentlist == 0) {
        [self.animelisttb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rightClickSelectedRow] byExtendingSelection:NO];
    }
    else {
        [self.mangalisttb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rightClickSelectedRow] byExtendingSelection:NO];
    }
    [self increment:sender];
}

- (void)rightClickVolumeIncrement:(id)sender {
    long rightClickSelectedRow = self.mangalisttb.clickedRow;
    [self.mangalisttb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rightClickSelectedRow] byExtendingSelection:NO];
    if (self.mangalistarraycontroller.selectedObjects.count > 0) {
        [self mangaincrement:YES];
    }
}

- (void)rightClickDeleteEntry:(id)sender {
    long rightClickSelectedRow = self.currentlist == 0 ? self.animelisttb.clickedRow : self.mangalisttb.clickedRow;
    if (self.currentlist == 0) {
        [self.animelisttb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rightClickSelectedRow] byExtendingSelection:NO];
    }
    else {
        [self.mangalisttb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rightClickSelectedRow] byExtendingSelection:NO];
    }
    [self deletetitle:sender];
}

- (void)editEntry:(id)sender {
    long rightClickSelectedRow = self.currentlist == 0 ? self.animelisttb.clickedRow : self.mangalisttb.clickedRow;
    if (self.currentlist == 0) {
        [self.animelisttb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rightClickSelectedRow] byExtendingSelection:NO];
    }
    else {
        [self.mangalisttb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rightClickSelectedRow] byExtendingSelection:NO];
    }
    NSDictionary *d = self.currentlist == 0 ? self.animelistarraycontroller.selectedObjects[0] : self.mangalistarraycontroller.selectedObjects[0];
    [_mw.editviewcontroller showEditPopover:d showRelativeToRec:self.currentlist == 0 ? [self.animelisttb frameOfCellAtColumn:0 row:self.animelisttb.selectedRow] : [self.mangalisttb frameOfCellAtColumn:0 row:self.mangalisttb.selectedRow] ofView:self.currentlist == 0 ? self.animelisttb : self.mangalisttb preferredEdge:0 type:self.currentlist];
}

- (void)viewTitleInfo:(id)sender {
    long rightClickSelectedRow = self.currentlist == 0 ? self.animelisttb.clickedRow : self.mangalisttb.clickedRow;
    if (self.currentlist == 0) {
        [self.animelisttb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rightClickSelectedRow] byExtendingSelection:NO];
    }
    else {
        [self.mangalisttb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rightClickSelectedRow] byExtendingSelection:NO];
    }
    NSDictionary *d = self.currentlist == 0 ? self.animelistarraycontroller.selectedObjects[0] : self.mangalistarraycontroller.selectedObjects[0];
    NSNumber *idnum = d[@"id"];
    [NSNotificationCenter.defaultCenter postNotificationName:@"LoadTitleInfo" object:@{@"id" : idnum, @"type" : @(self.currentlist)}];
}

- (void)rightclickManageCustomLists:(id)sender {
    long rightClickSelectedRow = self.currentlist == 0 ? self.animelisttb.clickedRow : self.mangalisttb.clickedRow;
    if (self.currentlist == 0) {
        [self.animelisttb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rightClickSelectedRow] byExtendingSelection:NO];
    }
    else {
        [self.mangalisttb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rightClickSelectedRow] byExtendingSelection:NO];
    }
    [self modifyCustomLists:self];
}

- (void)menuWillOpen:(NSMenu *)menu {
    [self setPopupMenuState];
}

- (void)setPopupMenuState {
    long rightClickSelectedRow = self.currentlist == 0 ? self.animelisttb.clickedRow : self.mangalisttb.clickedRow;
    if (self.currentlist == 0) {
        [self.animelisttb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rightClickSelectedRow] byExtendingSelection:NO];
    }
    else {
        [self.mangalisttb selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rightClickSelectedRow] byExtendingSelection:NO];
    }
    NSArray *menuArray = self.currentlist == 0 ? _animecontextmenu.itemArray : _mangacontextmenu.itemArray;
    for (NSMenuItem *item in menuArray) {
        if (self.currentlist == 0) {
            if (!_updating && self.animelisttb.clickedRow >= 0 && [item.title isEqualToString:@"Increment Episode"]) {
                item.enabled = [self checkclickeditemstate:0];
            }
            else {
                item.enabled = self.animelisttb.clickedRow >= 0 && !_updating;
            }
        }
        else {
            if (!_updating && self.mangalisttb.clickedRow >= 0 && [item.title isEqualToString:@"Increment Chapter"]) {
                item.enabled = [self checkclickeditemstate:0];
            }
            else if (!_updating && self.mangalisttb.clickedRow >= 0 && [item.title isEqualToString:@"Increment Volume"]) {
                item.enabled = [self checkclickeditemstate:1];
            }
            else {
                item.enabled = self.mangalisttb.clickedRow >= 0 && !_updating;
            }
        }
        if ([item.title localizedStandardContainsString:@"Custom List"]) {
            item.hidden = [listservice.sharedInstance getCurrentServiceID] != 3 || ![NSUserDefaults.standardUserDefaults boolForKey:@"donated"];
        }
    }
}

- (bool)checkclickeditemstate:(int)menutype {
    NSDictionary *clickeditem = self.currentlist == 0 ? self.animelistarraycontroller.arrangedObjects[self.animelisttb.clickedRow] : self.mangalistarraycontroller.arrangedObjects[self.mangalisttb.clickedRow];
    if (menutype == 0) { // Progress Increment
        if (self.currentlist == 0 && ((((NSNumber *)clickeditem[@"watched_episodes"]).intValue < ((NSNumber *)clickeditem[@"episodes"]).intValue && ((NSNumber *)clickeditem[@"episodes"]).intValue != 0) || ((NSNumber *)clickeditem[@"episodes"]).intValue == 0 )) {
            return true;
        }
        else if (self.currentlist == 1 && ((((NSNumber *)clickeditem[@"chapters_read"]).intValue < ((NSNumber *)clickeditem[@"chapters"]).intValue && ((NSNumber *)clickeditem[@"chapters"]).intValue != 0) || ((NSNumber *)clickeditem[@"chapters"]).intValue == 0)) {
            return true;
        }
    }
    else if (menutype == 1) {
        if (self.currentlist == 1 && ((((NSNumber *)clickeditem[@"volumes_read"]).intValue < ((NSNumber *)clickeditem[@"volumes"]).intValue && ((NSNumber *)clickeditem[@"volumes"]).intValue != 0) || ((NSNumber *)clickeditem[@"volumes"]).intValue == 0)) {
            return true;
        }
    }
    return false;
}
@end
