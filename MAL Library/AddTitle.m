//
//  AddTitle.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "AddTitle.h"
#import "MainWindow.h"
#import "MyAnimeList.h"
#import "Utility.h"

@interface AddTitle ()
@property (strong) IBOutlet NSView *popoveraddtitleexistsview;
// Anime
@property (strong) IBOutlet NSView *addtitleview;
@property (strong) IBOutlet NSTextField *addepifield;
@property (strong) IBOutlet NSNumberFormatter *addnumformat;
@property (strong) IBOutlet NSTextField *addtotalepisodes;
@property (strong) IBOutlet NSPopUpButton *addscorefiled;
@property (strong) IBOutlet NSPopUpButton *addstatusfield;
@property (strong) IBOutlet NSButton *addfield;
@property (strong) IBOutlet NSStepper *addepstepper;
@property (strong) IBOutlet NSProgressIndicator *mangaprogresswheel;

// Manga
@property (strong) IBOutlet NSView *addmangaview;
@property (strong) IBOutlet NSTextField *addchapfield;
@property (strong) IBOutlet NSNumberFormatter *addchapnumformat;
@property (strong) IBOutlet NSTextField *addvolfield;
@property (strong) IBOutlet NSNumberFormatter *addvolnumformat;
@property (strong) IBOutlet NSTextField *addtotalchap;
@property (strong) IBOutlet NSTextField *addtotalvol;
@property (strong) IBOutlet NSPopUpButton *addmangascorefiled;
@property (strong) IBOutlet NSPopUpButton *addmangastatusfield;
@property (strong) IBOutlet NSButton *addmangabtn;
@property (strong) IBOutlet NSStepper *addchapstepper;
@property (strong) IBOutlet NSStepper *addvolstepper;
@property (strong) IBOutlet NSProgressIndicator *animeprogresswheel;

@end

@implementation AddTitle

- (instancetype)init {
    return [super initWithNibName:@"AddTitle" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.view addSubview:[NSView new]];
}

- (void)showAddPopover:(NSDictionary *)d showRelativeToRec:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)rectedge type:(int)type {
    [self view];
    NSNumber *idnum = d[@"id"];
    if (type == 0) {
        if (![_mw checkiftitleisonlist:idnum.intValue type:0]) {
            [self.view replaceSubview:(self.view.subviews)[0] with:_addtitleview];
                _selecteditem = d;
            if (((NSNumber *)d[@"episodes"]).intValue > 0) {
                _addnumformat.maximum = d[@"episodes"];
            }
            else {
                [_addnumformat setMaximum:nil];
            }
            if (d[@"status"]) {
                [self checkStatus:d[@"status"] type:type];
            }
            else if (d[@"start_date"]||d[@"end_date"]) {
                [self checkStatus:[Utility statusFromDateRange:d[@"start_date"] toDate:d[@"end_date"]] type:type];
            }
            else {
                [MyAnimeList retrieveTitleInfo:idnum.intValue withType:MALAnime useAccount:NO completion:^(id responseObject) {
                    NSDictionary * d = responseObject;
                    [self checkStatus:d[@"status"] type: 0];
                }error:^(NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
            }
            _addepifield.intValue = 0;
            _addepstepper.intValue = 0;
            _addtotalepisodes.intValue = ((NSNumber *)d[@"episodes"]).intValue;
            [_addstatusfield selectItemWithTitle:@"watching"];
            [_addscorefiled selectItemAtIndex:0];
            _selectededitid = ((NSNumber *)d[@"id"]).intValue;
        }
        else {
            [self.view replaceSubview:(self.view.subviews)[0] with:_popoveraddtitleexistsview];
        }
        if (view.window == nil) {
            return;
        }
        [_addpopover showRelativeToRect:rect ofView:view preferredEdge:rectedge];
        _selectedtype = type;
    }
    else {
        if (![_mw checkiftitleisonlist:idnum.intValue type:1]) {
            [self.view replaceSubview:(self.view.subviews)[0] with:_addmangaview];
            _selecteditem = d;
            if (((NSNumber *)d[@"chapters"]).intValue > 0) {
                _addchapnumformat.maximum = d[@"chapters"];
            }
            else {
                [_addchapnumformat setMaximum:nil];
            }
            if (((NSNumber *)d[@"volumes"]).intValue > 0) {
                _addvolnumformat.maximum = d[@"chapters"];
            }
            else {
                [_addvolnumformat setMaximum:nil];
            }
            if (_selecteditem[@"status"]) {
                [self checkStatus:_selecteditem[@"status"] type:1];
            }
            else {
                [MyAnimeList retrieveTitleInfo:idnum.intValue withType:MALManga useAccount:NO completion:^(id responseObject) {
                    NSDictionary * d = responseObject;
                    [self checkStatus:d[@"status"] type: MALManga];
                }error:^(NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
            }
            _addchapfield.intValue = 0;
            _addchapstepper.intValue = 0;
            _addtotalchap.intValue = ((NSNumber *)d[@"chapters"]).intValue;
            _addvolfield.intValue = 0;
            _addvolstepper.intValue = 0;
            _addtotalvol.intValue = ((NSNumber *)d[@"volumes"]).intValue;
            [_addmangastatusfield selectItemWithTitle:@"reading"];
            [_addmangascorefiled  selectItemAtIndex:0];
            _selectededitid = ((NSNumber *)d[@"id"]).intValue;
        }
        else {
            [self.view replaceSubview:(self.view.subviews)[0] with:_popoveraddtitleexistsview];
        }
        [_addpopover showRelativeToRect:rect ofView:view preferredEdge:rectedge];
        _selectedtype = type;
    }
    
}

- (void)checkStatus:(NSString *)status type:(int)type {
    if (type == 0) {
         if ([status isEqualToString:@"finished airing"]) {
             _selectedaircompleted = true;
         }
         else {
             _selectedaircompleted = false;
         }
         if ([status isEqualToString:@"finished airing"]||[status isEqualToString:@"currently airing"]) {
             _selectedaired = true;
         }
         else {
             _selectedaired = false;
         }
    }
    else {
        if ([status isEqualToString:@"finished"]) {
            _selectedfinished = true;
        }
        else {
            _selectedfinished = false;
        }
        if ([status isEqualToString:@"finished"]||[status isEqualToString:@"publishing"]) {
            _selectedpublished = true;
        }
        else {
            _selectedpublished = false;
        }

    }
}

- (IBAction)PerformAddTitle:(id)sender {
    [self addtitletolist];
}

- (void)addtitletolist {
    if (_selectedtype == 0) {
        _animeprogresswheel.hidden = false;
        [_animeprogresswheel startAnimation:self];
        [_addfield setEnabled:false];
        if(![_addstatusfield.title isEqual:@"completed"] && _addepifield.intValue == _addtotalepisodes.intValue && _selectedaircompleted) {
            [_addstatusfield selectItemWithTitle:@"completed"];
        }
        if(!_selectedaired && (![_addstatusfield.title isEqual:@"plan to watch"] ||_addepifield.intValue > 0)) {
            // Invalid input, mark it as such
            [_addfield setEnabled:true];
            _addpopover.behavior = NSPopoverBehaviorTransient;
            [_animeprogresswheel stopAnimation:self];
            _animeprogresswheel.hidden = true;
            return;
        }
        if (_addepifield.intValue == _addtotalepisodes.intValue && _addtotalepisodes.intValue != 0 && _selectedaircompleted && _selectedaired) {
            [_addstatusfield selectItemWithTitle:@"completed"];
            _addepifield.stringValue = _addtotalepisodes.stringValue;
        }
        if([_addstatusfield.title isEqual:@"completed"] && _addtotalepisodes.intValue != 0 && _addepifield.intValue != _addtotalepisodes.intValue && _selectedaircompleted) {
            _addepifield.stringValue = _addtotalepisodes.stringValue;
        }
        _addpopover.behavior = NSPopoverBehaviorApplicationDefined;
        [MyAnimeList addAnimeTitleToList:_selectededitid withEpisode:_addepifield.intValue withStatus:_addstatusfield.title withScore:(int)_addscorefiled.selectedTag completion:^(id responseObject) {
            [_mw loadlist:@(true) type:0];
            [_mw loadlist:@(true) type:2];
            [_addfield setEnabled:true];
            _addpopover.behavior = NSPopoverBehaviorTransient;
            [_addpopover close];
            [_animeprogresswheel stopAnimation:self];
            _animeprogresswheel.hidden = true;
        }error:^(NSError * error) {
            NSLog(@"%@",error);
            NSData *errordata = error.userInfo [@"com.alamofire.serialization.response.error.data" ];
            NSLog(@"%@",[[NSString alloc] initWithData:errordata encoding:NSUTF8StringEncoding]);
            _addpopover.behavior = NSPopoverBehaviorTransient;
            [_addfield setEnabled:true];
            [_animeprogresswheel stopAnimation:self];
            _animeprogresswheel.hidden = true;
        }];
    }
    else {
        [_addmangabtn setEnabled:false];
        _mangaprogresswheel.hidden = false;
        [_mangaprogresswheel startAnimation:self];
        if(![_addstatusfield.title isEqual:@"completed"] && _addchapfield.intValue == _addtotalchap.intValue && _addvolfield.intValue == _addtotalvol.intValue && _selectedfinished) {
            [_addstatusfield selectItemWithTitle:@"completed"];
        }
        if(!_selectedpublished && (![_addstatusfield.title isEqual:@"plan to read"] ||_addchapfield.intValue > 0 || _addvolfield.intValue > 0)) {
            // Invalid input, mark it as such
            [_addmangabtn setEnabled:true];
            _addpopover.behavior = NSPopoverBehaviorTransient;
            _mangaprogresswheel.hidden = true;
            [_mangaprogresswheel stopAnimation:self];
            return;
        }
        if (((_addchapfield.intValue == _addtotalchap.intValue && _addchapfield.intValue != 0) || (_addvolfield.intValue == _addtotalvol.intValue && _addtotalvol.intValue != 0)) && _selectedfinished && _selectedpublished) {
            [_addmangastatusfield selectItemWithTitle:@"completed"];
            _addchapfield.stringValue = _addtotalchap.stringValue;
            _addvolfield.stringValue = _addtotalvol.stringValue;
        }
        if([_addstatusfield.title isEqual:@"completed"] && ((_addchapfield.intValue != _addtotalchap.intValue && _addchapfield.intValue != 0)|| (_addvolfield.intValue != _addtotalvol.intValue && _addtotalvol.intValue != 0)) && _selectedfinished) {
            _addchapfield.stringValue = _addtotalchap.stringValue;
            _addvolfield.stringValue = _addtotalvol.stringValue;
        }
        _addpopover.behavior = NSPopoverBehaviorApplicationDefined;
        [MyAnimeList addMangaTitleToList:_selectededitid withChapter:_addchapfield.intValue withVolume:_addvolfield.intValue withStatus:_addmangastatusfield.title withScore:(int)_addmangascorefiled.selectedTag completion:^(id responseData) {
            [_mw loadlist:@(true) type:1];
            [_mw loadlist:@(true) type:2];
            [_addmangabtn setEnabled:true];
            _addpopover.behavior = NSPopoverBehaviorTransient;
            [_addpopover close];
            _mangaprogresswheel.hidden = true;
            [_mangaprogresswheel stopAnimation:self];
        }error:^(NSError * error) {
            NSLog(@"%@",error);
            NSData *errordata = error.userInfo [@"com.alamofire.serialization.response.error.data" ];
            NSLog(@"%@",[[NSString alloc] initWithData:errordata encoding:NSUTF8StringEncoding]);
            _addpopover.behavior = NSPopoverBehaviorTransient;
            [_addmangabtn setEnabled:true];
            _mangaprogresswheel.hidden = true;
            [_mangaprogresswheel stopAnimation:self];

        }];
    }
}

- (IBAction)segmentstepclick:(id)sender {
    int segment = 0;
    int totalsegment = 0;
    NSStepper * stepper = (NSStepper *)sender;
    if (_selectedtype == 0) {
        if ((_addepifield.stringValue).length > 0) {
            segment = (_addepifield.stringValue).intValue;
        }
        totalsegment = (_addtotalepisodes.stringValue).intValue;
        segment = stepper.intValue;
        if ((segment <= totalsegment || totalsegment == 0) && segment >= 0) {
            _addepifield.stringValue = [NSString stringWithFormat:@"%i",segment];
        }
    }
    else {
        NSString * segmenttype;
        if ([stepper.identifier isEqualToString:@"chapterstepper"]) {
            segmenttype = @"chapters";
            if ((_addchapfield.stringValue).length > 0) {
                segment = (_addchapfield.stringValue).intValue;
            }
            totalsegment = (_addtotalchap.stringValue).intValue;
        }
        else {
            // Volumes
            segmenttype = @"volumes";
            if ((_addvolfield.stringValue).length > 0) {
                segment = (_addvolfield.stringValue).intValue;
            }
            totalsegment = (_addtotalvol.stringValue).intValue;
        }
        
        segment = stepper.intValue;
        if ((segment <= totalsegment || totalsegment == 0) && segment >= 0) {
            if ([segmenttype isEqualToString:@"chapters"]) {
                _addchapfield.stringValue = [NSString stringWithFormat:@"%i",segment];
            }
            else {
                _addvolfield.stringValue = [NSString stringWithFormat:@"%i",segment];
            }
        }
    }
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if ([aNotification.name isEqualToString:@"NSControlTextDidChangeNotification"]) {
        
        if ( aNotification.object == _addepifield ) {
            _addepstepper.intValue = _addepifield.intValue;
        }
        else if ( aNotification.object == _addchapfield ) {
            _addchapstepper.intValue = _addchapfield.intValue;
        }
        else if ( aNotification.object == _addvolfield ) {
            _addvolstepper.intValue = _addvolfield.intValue;
        }
    }
}

@end
