//
//  advancededitdialog.h
//  MAL Library
//
//  Created by 小鳥遊六花 on 3/20/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSTextFieldNumber.h"
#import "NSNumberFormatterNumberOnly.h"

@interface advancededitdialog : NSWindowController <NSTextFieldDelegate>
@property int selectededitid;
@property int selectedtype;
@property bool selectedaired;
@property bool selectedaircompleted;
@property bool selectedfinished;
@property bool selectedpublished;
@property (strong) NSDictionary *selecteditem;

// MyAnimeList fields
@property (strong) IBOutlet NSView *malfieldsview;
@property (strong) IBOutlet NSButton *setstartdatecheck;
@property (strong) IBOutlet NSButton *setenddatecheck;
@property (strong) IBOutlet NSTokenField *tagsfield;
@property (strong) IBOutlet NSDatePicker *startdatepicker;
@property (strong) IBOutlet NSDatePicker *enddatepicker;

// Kitsu Fields
@property (strong) IBOutlet NSView *kitsufieldsview;
@property (strong) IBOutlet NSTextField *notesfield;

// Anime View
@property (strong) IBOutlet NSView *episodeview;
@property (strong) IBOutlet NSTextFieldNumber *episodefield;
@property (strong) IBOutlet NSNumberFormatterNumberOnly *episodefieldnumberformat;
@property (strong) IBOutlet NSStepper *episodestepper;
@property (strong) IBOutlet NSTextField *totalepisodes;

// Manga View
@property (strong) IBOutlet NSView *chapterview;
@property (strong) IBOutlet NSTextFieldNumber *chaptersfield;
@property (strong) IBOutlet NSNumberFormatterNumberOnly *chaptersnumformat;
@property (strong) IBOutlet NSStepper *chaptertepper;
@property (strong) IBOutlet NSTextField *totalchapters;
@property (strong) IBOutlet NSTextFieldNumber *volumesfield;
@property (strong) IBOutlet NSNumberFormatterNumberOnly *volumesformatter;
@property (strong) IBOutlet NSStepper *volumestepper;
@property (strong) IBOutlet NSTextField *totalvolumes;
@property (strong) IBOutlet NSMenu *animestatusmenu;
@property (strong) IBOutlet NSMenu *mangastatusmenu;

// Menus
@property (strong) IBOutlet NSMenu *malscoremenu;
@property (strong) IBOutlet NSMenu *kitsusimplerating;
@property (strong) IBOutlet NSMenu *kitsustandardrating;
@property (strong) IBOutlet NSMenu *kitsuadvancedrating;
@property (strong) IBOutlet NSMenu *AniListThreeScoreMenu;
@property (strong) IBOutlet NSMenu *AniListFiveScoreMenu;

// Main Controls
@property (strong) IBOutlet NSPopUpButton *status;
@property (strong) IBOutlet NSTextField *advancedscore;
@property (strong) IBOutlet NSNumberFormatter *advancedscoreformat;
@property (strong) IBOutlet NSPopUpButton *score;
@property (strong) IBOutlet NSButton *reconsuming;
@property (strong) IBOutlet NSButton *privatecheck;
@property (strong) IBOutlet NSView *segmentfield;
@property (strong) IBOutlet NSView *listservicefields;
@property (strong) IBOutlet NSTextField *title;
@property (strong) IBOutlet NSProgressIndicator *progressindicator;
@property (strong) IBOutlet NSButton *editbtn;
@property (strong) IBOutlet NSButton *closebtn;

- (void)setupeditwindow:(NSDictionary *)d type:(int)type;
@end
