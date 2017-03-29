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

@interface MainWindow : NSWindowController < PXSourceListDataSource, PXSourceListDelegate>{
    IBOutlet NSWindow *w;
    IBOutlet PXSourceList *sourceList;
    AppDelegate *appdel;
    IBOutlet NSSearchField *searchtitlefield;
    IBOutlet NSArrayController *searcharraycontroller;
    IBOutlet NSTableView *searchtb;
    // Title Info
    int selectedid;
    int selectededitid;
    bool selectedaired;
    bool selectedaircompleted;
    NSDictionary * selecteditem;
    NSDictionary * selectedanimeinfo;

}
@property (strong) IBOutlet NSTextField *loggedinuser;
//Anime List View
@property (strong) IBOutlet NSArrayController *animelistarraycontroller;
@property (strong) IBOutlet NSTableView *animelisttb;
@property (strong) IBOutlet NSButton *watchingfilter;
@property (strong) IBOutlet NSButton *completedfilter;
@property (strong) IBOutlet NSButton *onholdfilter;
@property (strong) IBOutlet NSButton *droppedfilter;
@property (strong) IBOutlet NSButton *plantowatchfilter;
@property (strong) IBOutlet NSSearchField *animelistfilter;
@property (strong) IBOutlet NSVisualEffectView *filterbarview;

//Search View
@property (strong) IBOutlet NSToolbar *toolbar;
@property (strong) IBOutlet NSView *mainview;
@property (nonatomic, assign) AppDelegate *app;
@property (strong) IBOutlet NSVisualEffectView *animeinfoview;
@property (strong) IBOutlet NSView *animelistview;
@property (strong) IBOutlet NSVisualEffectView *progressview;
@property (strong) IBOutlet NSView *searchview;
@property (strong) IBOutlet NSView *seasonview;
@property (strong) IBOutlet NSVisualEffectView *notloggedinview;
@property (strong) IBOutlet NSPopover *advsearchpopover;
// Info View
@property (strong) IBOutlet NSProgressIndicator *progressindicator;
@property (strong) IBOutlet NSView *noinfoview;
@property (strong) IBOutlet NSTextField *infoviewtitle;
@property (strong) IBOutlet NSTextField *infoviewalttitles;
@property (strong) IBOutlet NSTextView *infoviewdetailstextview;
@property (strong) IBOutlet NSTextView *infoviewsynopsistextview;
@property (strong) IBOutlet NSImageView *infoviewposterimage;
@property (strong) IBOutlet NSTextView *infoviewbackgroundtextview;
// Edit Popover
@property (strong) IBOutlet NSPopover *minieditpopover;
@property (strong) IBOutlet EditTitle *editviewcontroller;

// Add Popover
@property (strong) IBOutlet NSPopover *addpopover;
@property (strong) IBOutlet AddTitle * addtitlecontroller;
    
// Season View
@property (strong) IBOutlet NSPopUpButton *seasonyrpicker;
@property (strong) IBOutlet NSPopUpButton *seasonpicker;
@property (strong) IBOutlet NSArrayController *seasonarraycontroller;
@property (strong) IBOutlet NSTableView *seasontableview;

@property (strong, nonatomic) dispatch_queue_t privateQueue;
@property (strong, nonatomic) MSWeakTimer * refreshtimer;

//Public Methods
-(void)setDelegate:(AppDelegate*) adelegate;
- (IBAction)performlogin:(id)sender;
- (IBAction)sharetitle:(id)sender;
-(void)loadmainview;
-(void)setAppearence;
-(void)startTimer;
-(void)stopTimer;
-(void)fireTimer;
-(void)refreshloginlabel;
-(void)loadanimeinfo:(NSNumber *) idnum;
-(void)populatesearchtb:(id)json;
-(void)clearsearchtb;
-(bool)checkiftitleisonlist:(int)idnum;
-(void)loadlist:(NSNumber *)refresh;

//Anime List View
- (IBAction)refreshlist:(id)sender;
- (IBAction)animelistdoubleclick:(id)sender;
- (IBAction)deletetitle:(id)sender;
-(void)clearlist;
- (IBAction)filterperform:(id)sender;
//Search View
- (IBAction)performsearch:(id)sender;
- (IBAction)searchtbdoubleclick:(id)sender;
// Info View
- (IBAction)viewonmal:(id)sender;
// Modify Popover
- (IBAction)performmodifytitle:(id)sender;

// Add Title
- (IBAction)showaddpopover:(id)sender;

- (IBAction)seasondoubleclick:(id)sender;
- (IBAction)yearchange:(id)sender;
- (IBAction)seasonchange:(id)sender;

@end
