//
//  EditTitle.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "EditTitle.h"
#import "NSTextFieldNumber.h"
#import "MainWindow.h"
#import "MyAnimeList.h"

@interface EditTitle ()
// Anime
@property (strong) IBOutlet NSView *animeeditview;
@property (strong) IBOutlet NSTextFieldNumber *minipopoverepfield;
@property (strong) IBOutlet NSTextField *minipopovertotalep;
@property (strong) IBOutlet NSPopUpButton *minipopoverstatus;
@property (strong) IBOutlet NSPopUpButton *minipopoverscore;
@property (strong) IBOutlet NSTextField *minipopoverstatustext;
@property (strong) IBOutlet NSProgressIndicator *minipopoverindicator;
@property (strong) IBOutlet NSButton *minipopovereditbtn;
@property (strong) IBOutlet NSNumberFormatter *minieditpopovernumformat;
@property (strong) IBOutlet NSStepper *minipopovereditepstep;
@property (strong) IBOutlet NSTokenField *animetags;

// Manga
@property (strong) IBOutlet NSView *mangaeditview;
@property (strong) IBOutlet NSTextFieldNumber *mangapopoverchapfield;
@property (strong) IBOutlet NSTextField *mangapopovertotalchap;
@property (strong) IBOutlet NSNumberFormatter *mangaeditpopoverchapnumformat;
@property (strong) IBOutlet NSTextFieldNumber *mangapopovervolfield;
@property (strong) IBOutlet NSTextField *mangapopovertotalvol;
@property (strong) IBOutlet NSNumberFormatter *mangaeditpopovervolnumformat;
@property (strong) IBOutlet NSPopUpButton *mangapopoverstatus;
@property (strong) IBOutlet NSPopUpButton *mangapopoverscore;
@property (strong) IBOutlet NSTextField *mangapopoverstatustext;
@property (strong) IBOutlet NSProgressIndicator *mangapopoverindicator;
@property (strong) IBOutlet NSButton *mangapopovereditbtn;
@property (strong) IBOutlet NSStepper *mangapopovereditchapstep;
@property (strong) IBOutlet NSStepper *mangapopovereditvolstep;
@property (strong) IBOutlet NSTokenField *mangatags;

@end

@implementation EditTitle

- (instancetype)init {
    return [super initWithNibName:@"EditTitle" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.view addSubview:_animeeditview];
    [self view];
}

- (void)showEditPopover:(NSDictionary *)d showRelativeToRec:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)rectedge type:(int)type{
    _selecteditem = d;
    if (type == 0) {
        [self.view replaceSubview:(self.view.subviews)[0] with:_animeeditview];
        NSString *airingstatus = d[@"status"];
        if ([airingstatus isEqualToString:@"finished airing"]) {
            _selectedaircompleted = true;
        }
        else {
            _selectedaircompleted = false;
        }
        if ([airingstatus isEqualToString:@"finished airing"]||[airingstatus isEqualToString:@"currently airing"]) {
            _selectedaired = true;
        }
        else {
            _selectedaired = false;
        }
        _minipopoverepfield.intValue = ((NSNumber *)d[@"watched_episodes"]).intValue;
        _minipopovereditepstep.intValue = ((NSNumber *)d[@"watched_episodes"]).intValue;
        _minipopovertotalep.intValue = ((NSNumber *)d[@"episodes"]).intValue;
        _animetags.stringValue = ((NSArray *)d[@"personal_tags"]).count > 0 ? [((NSArray *)d[@"personal_tags"]) componentsJoinedByString:@","] : @"";
        [_minipopoverstatus selectItemWithTitle:d[@"watched_status"]];
        [_minipopoverscore selectItemWithTag:((NSNumber *)d[@"score"]).intValue];
        _minipopoverstatustext.stringValue = @"";
        if (((NSNumber *)d[@"episodes"]).intValue > 0) {
            _minieditpopovernumformat.maximum = d[@"episodes"];
        }
        else {
            [_minieditpopovernumformat setMaximum:nil];
        }
        _selectededitid = ((NSNumber *)d[@"id"]).intValue;
        [_minieditpopover showRelativeToRect:rect ofView:view preferredEdge:rectedge];
        _selectedtype = type;
    }
    else {
        [self.view replaceSubview:(self.view.subviews)[0] with:_mangaeditview];
        NSString *publishtatus = _selecteditem[@"status"];
        if ([publishtatus isEqualToString:@"finished"]) {
            _selectedfinished = true;
        }
        else {
            _selectedfinished = false;
        }
        if ([publishtatus isEqualToString:@"finished"]||[publishtatus isEqualToString:@"publishing"]) {
            _selectedpublished = true;
        }
        else {
            _selectedpublished = false;
        }
        _mangapopoverchapfield.intValue = ((NSNumber *)d[@"chapters_read"]).intValue;
        _mangapopovereditchapstep.intValue = ((NSNumber *)d[@"chapters_read"]).intValue;
        _mangapopovertotalchap.intValue = ((NSNumber *)d[@"chapters"]).intValue;
        if (((NSNumber *)d[@"chapters"]).intValue > 0) {
            _mangaeditpopoverchapnumformat.maximum = d[@"chapters"];
        }
        else {
            [_mangaeditpopoverchapnumformat setMaximum:nil];
        }
        _mangapopovervolfield.intValue = ((NSNumber *)d[@"volumes_read"]).intValue;
        _mangapopovereditvolstep.intValue = ((NSNumber *)d[@"volumes_read"]).intValue;
        _mangapopovertotalvol.intValue = ((NSNumber *)d[@"volumes"]).intValue;
        _mangatags.stringValue = ((NSArray *)d[@"personal_tags"]).count > 0 ? [((NSArray *)d[@"personal_tags"]) componentsJoinedByString:@","] : @"";
        if (((NSNumber *)d[@"volumes"]).intValue > 0) {
            _mangaeditpopovervolnumformat.maximum = d[@"volumes"];
        }
        else {
            [_mangaeditpopovervolnumformat setMaximum:nil];
        }
        [_mangapopoverstatus selectItemWithTitle:d[@"read_status"]];
        [_mangapopoverscore selectItemWithTag:((NSNumber *)d[@"score"]).intValue];
        _mangapopoverstatustext.stringValue = @"";
        _selectededitid = ((NSNumber *)d[@"id"]).intValue;
        [_minieditpopover showRelativeToRect:rect ofView:view preferredEdge:rectedge];
        _selectedtype = type;
    }
}

- (IBAction)performupdatetitle:(id)sender {
    [self performupdate];
}

- (void)performupdate {
    if (_selectedtype == 0) {
        [self updateanimeentry];
    }
    else {
        [self updatemangaentry];
    }
}

- (void)updateanimeentry {
    [_minipopovereditbtn setEnabled:false];
    _minipopoverstatustext.stringValue = @"";
    _minipopoverindicator.hidden = false;
    [_minipopoverindicator startAnimation:self];
    if(![_minipopoverstatus.title isEqual:@"completed"] && _minipopoverepfield.intValue == _minipopovertotalep.intValue && _selectedaircompleted) {
        [_minipopoverstatus selectItemWithTitle:@"completed"];
    }
    if(!_selectedaired && (![_minipopoverstatus.title isEqual:@"plan to watch"] ||_minipopoverepfield.intValue > 0)) {
        // Invalid input, mark it as such
        [_minipopovereditbtn setEnabled:true];
        _minipopoverstatustext.stringValue = @"Invalid update.";
        _minieditpopover.behavior = NSPopoverBehaviorTransient;
        _minipopoverindicator.hidden = true;
        [_minipopoverindicator stopAnimation:nil];
        return;
    }
    if (_minipopoverepfield.intValue == _minipopovertotalep.intValue && _minipopovertotalep.intValue != 0 && _selectedaircompleted && _selectedaired) {
        [_minipopoverstatus selectItemWithTitle:@"completed"];
        _minipopoverepfield.stringValue = _minipopovertotalep.stringValue;
    }
    if ([_minipopoverstatus.title isEqual:@"completed"] && _minipopovertotalep.intValue != 0 && _minipopoverepfield.intValue != _minipopovertotalep.intValue && _selectedaircompleted) {
        _minipopoverepfield.stringValue = _minipopovertotalep.stringValue;
    }
    NSString *tags = @"";
    if (((NSArray *)_animetags.objectValue).count > 0){
        tags = [(NSArray *)_animetags.objectValue componentsJoinedByString:@","];
    }
    _minieditpopover.behavior = NSPopoverBehaviorApplicationDefined;
    [_minipopoverindicator startAnimation:nil];
    [MyAnimeList updateAnimeTitleOnList:_selectededitid withEpisode:_minipopoverepfield.intValue withStatus:_minipopoverstatus.title withScore:(int)_minipopoverscore.selectedTag withTags:tags completion:^(id responseobject) {
        [_mw loadlist:@(true) type:_selectedtype];
        [_minipopovereditbtn setEnabled:true];
        _minieditpopover.behavior = NSPopoverBehaviorTransient;
        _minipopoverindicator.hidden = true;
        [_minipopoverindicator stopAnimation:nil];
        [_minieditpopover close];
    }
  error:^(NSError * error) {
     [_minipopovereditbtn setEnabled:true];
     _minieditpopover.behavior = NSPopoverBehaviorTransient;
      _minipopoverindicator.hidden = true;
      [_minipopoverindicator stopAnimation:nil];
      NSLog(@"%@", error);
      _minipopoverstatustext.stringValue = @"Error";
  }];
}

- (void)updatemangaentry {
    [_mangapopovereditbtn setEnabled:false];
    _mangapopoverstatustext.stringValue = @"";
    _mangapopoverindicator.hidden = false;
    [_mangapopoverindicator startAnimation:self];
    if(![_mangapopoverstatus.title isEqual:@"completed"] && _mangapopoverchapfield.intValue == _mangapopovertotalchap.intValue && _mangapopovertotalvol.intValue == _mangapopovertotalvol.intValue && _selectedfinished) {
        [_mangapopoverstatus selectItemWithTitle:@"completed"];
    }
    if(!_selectedpublished && (![_mangapopoverstatus.title isEqual:@"plan to read"] ||_mangapopoverchapfield.intValue > 0 || _mangapopovertotalvol.intValue > 0)) {
        // Invalid input, mark it as such
        [_mangapopovereditbtn setEnabled:true];
        _mangapopoverstatustext.stringValue = @"Invalid update.";
        _minieditpopover.behavior = NSPopoverBehaviorTransient;
        _mangapopoverindicator.hidden = true;
        [_mangapopoverindicator stopAnimation:nil];
        return;
    }
    if (((_mangapopoverchapfield.intValue == _mangapopovertotalchap.intValue && _mangapopoverchapfield.intValue != 0) || (_mangapopovervolfield.intValue == _mangapopovertotalvol.intValue && _mangapopovertotalvol.intValue != 0)) && _selectedfinished && _selectedpublished) {
        [_mangapopoverstatus selectItemWithTitle:@"completed"];
        _mangapopoverchapfield.stringValue = _mangapopovertotalchap.stringValue;
        _mangapopovertotalvol.stringValue = _mangapopovertotalvol.stringValue;
    }
    if([_mangapopoverstatus.title isEqual:@"completed"] && ((_mangapopoverchapfield.intValue != _mangapopovertotalchap.intValue && _mangapopoverchapfield.intValue != 0) || (_mangapopovervolfield.intValue != _mangapopovertotalvol.intValue && _mangapopovertotalvol.intValue != 0)) && _selectedfinished) {
        _mangapopoverchapfield.stringValue = _mangapopovertotalchap.stringValue;
        _mangapopovertotalvol.stringValue = _mangapopovertotalvol.stringValue;
    }
    NSString *tags = @"";
    if (((NSArray *)_mangatags.objectValue).count > 0){
        tags = [(NSArray *)_mangatags.objectValue componentsJoinedByString:@","];
    }
    _minieditpopover.behavior = NSPopoverBehaviorApplicationDefined;
    [_mangapopoverindicator startAnimation:nil];
    [MyAnimeList updateMangaTitleOnList:_selectededitid withChapter:_mangapopoverchapfield.intValue withVolume:_mangapopovervolfield.intValue withStatus:_mangapopoverstatus.title withScore:(int)_mangapopoverscore.selectedTag withTags:tags completion:^(id responseobject) {
        [_mw loadlist:@(true) type:_selectedtype];
        [_mw loadlist:@(true) type:2];
        [_mangapopovereditbtn setEnabled:true];
        _minieditpopover.behavior = NSPopoverBehaviorTransient;
        _mangapopoverindicator.hidden = true;
        [_mangapopoverindicator stopAnimation:nil];
        [_minieditpopover close];
    }error:^(NSError * error) {
        [_mangapopovereditbtn setEnabled:true];
        _minieditpopover.behavior = NSPopoverBehaviorTransient;
        _mangapopoverindicator.hidden = true;
        [_mangapopoverindicator stopAnimation:nil];
        NSLog(@"%@", error);
        _mangapopoverstatustext.stringValue = @"Error";
    }];
}

- (IBAction)segmentstepclick:(id)sender {
    int segment = 0;
    int totalsegment = 0;
    NSStepper * stepper = (NSStepper *)sender;
    if (_selectedtype == 0) {
        if ((_minipopoverepfield.stringValue).length > 0) {
            segment = (_minipopoverepfield.stringValue).intValue;
        }
        totalsegment = (_minipopovertotalep.stringValue).intValue;
        segment = stepper.intValue;
        if ((segment <= totalsegment || totalsegment == 0) && segment >= 0) {
            _minipopoverepfield.stringValue = [NSString stringWithFormat:@"%i",segment];
        }
    }
    else {
        NSString * segmenttype;
        if ([stepper.identifier isEqualToString:@"chapstepper"]) {
            segmenttype = @"chapters";
            if ((_mangapopoverchapfield.stringValue).length > 0) {
                segment = (_mangapopoverchapfield.stringValue).intValue;
            }
            totalsegment = (_mangapopovertotalchap.stringValue).intValue;
        }
        else {
            // Volumes
            segmenttype = @"volumes";
            if ((_mangapopovervolfield.stringValue).length > 0) {
                segment = (_mangapopovervolfield.stringValue).intValue;
            }
            totalsegment = (_mangapopovertotalvol.stringValue).intValue;
        }
        
        segment = stepper.intValue;
        if ((segment <= totalsegment || totalsegment == 0) && segment >= 0) {
            if ([segmenttype isEqualToString:@"chapters"]) {
                _mangapopoverchapfield.stringValue = [NSString stringWithFormat:@"%i",segment];
            }
            else {
                _mangapopovervolfield.stringValue = [NSString stringWithFormat:@"%i",segment];
            }
        }
    }
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if ([aNotification.name isEqualToString:@"NSControlTextDidChangeNotification"]) {
        
        if ( aNotification.object == _minipopoverepfield ) {
            _minipopovereditepstep.intValue = _minipopoverepfield.intValue;
        }
        else if ( aNotification.object == _mangapopoverchapfield ) {
            _mangapopovereditchapstep.intValue = _mangapopoverchapfield.intValue;
        }
        else if ( aNotification.object == _mangapopovervolfield ) {
            _mangapopovereditvolstep.intValue = _mangapopovervolfield.intValue;
        }
    }
}

@end
