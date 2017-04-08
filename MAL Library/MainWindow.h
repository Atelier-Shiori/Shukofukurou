//
//  MainWindow.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/02/28.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PXSourceList/PXSourceList.h>
#import <AFNetworking/AFNetworking.h>

@class AppDelegate;
@class NSTextFieldNumber;
@class MSWeakTimer;
@class AddTitle;
@class EditTitle;
@class ListView;
@class NotLoggedIn;
@class SearchView;
@class SeasonView;
@class InfoView;
@class AdvancedSearch;
@class HistoryView;
@class AiringView;

@interface MainWindow : NSWindowController < PXSourceListDataSource, PXSourceListDelegate>{
    IBOutlet NSWindow *w;
    IBOutlet PXSourceList *sourceList;
    int selectededitid;
    bool selectedaired;
    bool selectedaircompleted;
    NSDictionary * selecteditem;
}
@property (strong) IBOutlet NSView *mainview;
@property (strong) IBOutlet NSToolbar *toolbar;
@property (strong) IBOutlet NSTextField *loggedinuser;

@property (nonatomic, assign, getter=getDelegate) AppDelegate *appdel;
//Anime List View
@property (strong) IBOutlet ListView * listview;
// Not Logged In View
@property (strong) IBOutlet NotLoggedIn * notloggedin;
//Search View
@property (strong) IBOutlet SearchView * searchview;
@property (strong) IBOutlet NSPopover *advsearchpopover;
    @property (strong) IBOutlet AdvancedSearch *advancedsearchcontroller;
// Info View
@property (strong) IBOutlet NSVisualEffectView *progressview;
@property (strong) IBOutlet NSProgressIndicator *progressindicator;
@property (strong) IBOutlet NSView *noinfoview;
@property (strong) IBOutlet InfoView *infoview;

// History View
@property (strong) IBOutlet HistoryView *historyview;

//Season View
@property (strong) IBOutlet SeasonView * seasonview;

// Edit Popover
@property (strong) IBOutlet NSPopover *minieditpopover;
@property (strong) IBOutlet EditTitle *editviewcontroller;

// Add Popover
@property (strong) IBOutlet NSPopover *addpopover;
@property (strong) IBOutlet AddTitle * addtitlecontroller;

@property (strong) IBOutlet NSVisualEffectView *requireslicense;

@property (strong, nonatomic) dispatch_queue_t privateQueue;
@property (strong, nonatomic) MSWeakTimer * refreshtimer;

// Airing View
@property (strong) IBOutlet AiringView *airingview;


//Public Methods
- (void)setDelegate:(AppDelegate*) adelegate;
- (IBAction)sharetitle:(id)sender;
- (void)loadmainview;
- (void)setAppearance;
- (void)startTimer;
- (void)stopTimer;
- (void)fireTimer;
- (void)refreshloginlabel;
- (void)loadinfo:(NSNumber *) idnum type:(int)type;
- (void)populatesearchtb:(id)json type:(int)type;
- (void)clearsearchtb;
- (bool)checkiftitleisonlist:(int)idnum type:(int)type;
- (void)loadlist:(NSNumber *)refresh type:(int)type;
- (void)clearlist;
- (void)createToolbar;

// Modify Popover
- (IBAction)performmodifytitle:(id)sender;

// Add Title
- (IBAction)showaddpopover:(id)sender;

@end
