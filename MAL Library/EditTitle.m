//
//  EditTitle.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "AniListScoreConvert.h"
#import "EditTitle.h"
#import "NSTextFieldNumber.h"
#import "MainWindow.h"
#import "MyListView.h"
#import "listservice.h"
#import "AtarashiiListCoreData.h"

@interface EditTitle ()

// Common
@property (strong) IBOutlet NSPopUpButton *minipopoverstatus;
@property (strong) IBOutlet NSPopUpButton *minipopoverscore;
@property (strong) IBOutlet NSProgressIndicator *minipopoverindicator;
@property (strong) IBOutlet NSButton *minipopovereditbtn;
@property (strong) IBOutlet NSButton *animeadvancededit;
@property (strong) IBOutlet NSView *segmentview;
@property (strong) IBOutlet NSTextField *advancedscorefield;
@property (strong) IBOutlet NSNumberFormatter *advancedscoreformat;
@property (strong) MyListView *mlv;

// Anime
@property (strong) IBOutlet NSView *animeeditview;
@property (strong) IBOutlet NSTextFieldNumber *minipopoverepfield;
@property (strong) IBOutlet NSTextField *minipopovertotalep;
@property (strong) IBOutlet NSNumberFormatter *minieditpopovernumformat;
@property (strong) IBOutlet NSStepper *minipopovereditepstep;


// Manga
@property (strong) IBOutlet NSView *mangaeditview;
@property (strong) IBOutlet NSTextFieldNumber *mangapopoverchapfield;
@property (strong) IBOutlet NSTextField *mangapopovertotalchap;
@property (strong) IBOutlet NSNumberFormatter *mangaeditpopoverchapnumformat;
@property (strong) IBOutlet NSTextFieldNumber *mangapopovervolfield;
@property (strong) IBOutlet NSTextField *mangapopovertotalvol;
@property (strong) IBOutlet NSNumberFormatter *mangaeditpopovervolnumformat;
@property (strong) IBOutlet NSStepper *mangapopovereditchapstep;
@property (strong) IBOutlet NSStepper *mangapopovereditvolstep;

@end

@implementation EditTitle

- (instancetype)init {
    return [super initWithNibName:@"EditTitle" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [_segmentview addSubview:_animeeditview];
    _mlv= _mw.listview;
    [self view];
}


- (void)showEditPopover:(NSDictionary *)d showRelativeToRec:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)rectedge type:(int)type{
    _selecteditem = d;
    [self view];
    [self setScoreMenu:type];
    if (type == 0) {
        [_segmentview replaceSubview:(_segmentview.subviews)[0] with:_animeeditview];
        _minipopoverstatus.menu = _animestatusmenu;
        [_commonview setFrameOrigin:NSMakePoint(_commonview.frame.origin.x, 44)];
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
        [_minipopoverstatus selectItemWithTitle:d[@"watched_status"]];
        [self setScore:d];
    
        if (((NSNumber *)d[@"episodes"]).intValue > 0) {
            _minieditpopovernumformat.maximum = d[@"episodes"];
        }
        else {
            _minieditpopovernumformat.maximum = @(9999999);
        }
        _minipopovereditepstep.maxValue = _minieditpopovernumformat.maximum.doubleValue;
        switch ([listservice getCurrentServiceID]) {
            case 1:
                _selectededitid = ((NSNumber *)d[@"id"]).intValue;
                break;
            case 2:
            case 3:
                _selectededitid = ((NSNumber *)d[@"entryid"]).intValue;
                break;
            default:
                break;
        }
        [_minieditpopover showRelativeToRect:rect ofView:view preferredEdge:rectedge];
        _selectedtype = type;
    }
    else {
        [_segmentview replaceSubview:(_segmentview.subviews)[0] with:_mangaeditview];
        _minipopoverstatus.menu = _mangastatusmenu;
        [_commonview setFrameOrigin:NSMakePoint(_commonview.frame.origin.x, 18)];
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
            _mangaeditpopoverchapnumformat.maximum = @(9999999);
        }
        _mangapopovervolfield.intValue = ((NSNumber *)d[@"volumes_read"]).intValue;
        _mangapopovereditvolstep.intValue = ((NSNumber *)d[@"volumes_read"]).intValue;
        _mangapopovertotalvol.intValue = ((NSNumber *)d[@"volumes"]).intValue;
        if (((NSNumber *)d[@"volumes"]).intValue > 0) {
            _mangaeditpopovervolnumformat.maximum = d[@"volumes"];
        }
        else {
            _mangaeditpopovervolnumformat.maximum = @(9999999);
        }
        _mangapopovereditvolstep.maxValue = _mangaeditpopovervolnumformat.maximum.doubleValue;
        _mangapopovereditchapstep.maxValue = _mangaeditpopoverchapnumformat.maximum.doubleValue;
        [_minipopoverstatus selectItemWithTitle:d[@"read_status"]];
        [self setScore:d];
        switch ([listservice getCurrentServiceID]) {
            case 1:
                _selectededitid = ((NSNumber *)d[@"id"]).intValue;
                break;
            case 2:
            case 3:
                _selectededitid = ((NSNumber *)d[@"entryid"]).intValue;
                break;
            default:
                break;
        }
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
    [self disableeditbuttons:false];

    _minipopoverindicator.hidden = false;
    [_minipopoverindicator startAnimation:self];
    bool rewatching = ((NSNumber *)_selecteditem[@"rewatching"]).boolValue;
    if (![_minipopoverstatus.title isEqual:@"completed"] && _minipopoverepfield.intValue == _minipopovertotalep.intValue && _selectedaircompleted) {
        [_minipopoverstatus selectItemWithTitle:@"completed"];
        rewatching = false;
    }
    if(!_selectedaired && (![_minipopoverstatus.title isEqual:@"plan to watch"] ||_minipopoverepfield.intValue > 0)) {
        // Invalid input, mark it as such
        [self disableeditbuttons:true];
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
    NSDictionary * extraparameters = @{};
    int currentservice = [listservice getCurrentServiceID];
    switch (currentservice) {
        case 2:
        case 3: {
            extraparameters = @{@"reconsuming" : @(rewatching)};
            break;
        }
        default:
            break;
    }
    int score = 0;
    switch (currentservice) {
        case 1:
        case 2:
            score = (int)_minipopoverscore.selectedTag;
            break;
        case 3: {
            NSString *scoretype = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-scoreformat"];
            if ([scoretype isEqualToString:@"POINT_100"]) {
                score = _advancedscorefield.intValue;
            }
            else if ([scoretype isEqualToString:@"POINT_10_DECIMAL"]) {
                score = [AniListScoreConvert convertScoretoScoreRaw:_advancedscorefield.doubleValue withScoreType:scoretype];
            }
            else {
                score = [AniListScoreConvert convertScoretoScoreRaw:_minipopoverscore.selectedTag withScoreType:scoretype];
            }
            break;
        }
    }
    [_mlv setUpdatingState:true];
    _minieditpopover.behavior = NSPopoverBehaviorApplicationDefined;
    [_minipopoverindicator startAnimation:nil];
    [listservice updateAnimeTitleOnList:_selectededitid withEpisode:_minipopoverepfield.intValue withStatus:_minipopoverstatus.title withScore:score withExtraFields:extraparameters completion:^(id responseobject) {
        NSDictionary *updatedfields = @{@"watched_episodes" : @(_minipopoverepfield.intValue), @"watched_status" : _minipopoverstatus.title, @"score" : @(score), @"rewatching" : @(rewatching)};
        switch ([listservice getCurrentServiceID]) {
            case 1:
                [AtarashiiListCoreData updateSingleEntry:updatedfields withUserName:[listservice getCurrentServiceUsername] withService:[listservice getCurrentServiceID] withType:0 withId:_selectededitid withIdType:0];
                break;
            case 2:
            case 3:
                [AtarashiiListCoreData updateSingleEntry:updatedfields withUserId:[listservice getCurrentUserID] withService:[listservice getCurrentServiceID] withType:0 withId:_selectededitid withIdType:1];
                break;
        }
        [_mw loadlist:@(false) type:_selectedtype];
        [_mw loadlist:@(true) type:2];
        [self disableeditbuttons:true];
        _minieditpopover.behavior = NSPopoverBehaviorTransient;
        _minipopoverindicator.hidden = true;
        [_minipopoverindicator stopAnimation:nil];
        [_minieditpopover close];
        [self cleanup];
    }
  error:^(NSError * error) {
     [self disableeditbuttons:true];
     _minieditpopover.behavior = NSPopoverBehaviorTransient;
      _minipopoverindicator.hidden = true;
      [_mlv setUpdatingState:false];
      [_minipopoverindicator stopAnimation:nil];
      NSLog(@"%@", error.localizedDescription);
      NSLog(@"Content: %@", [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
  }];
}

- (void)updatemangaentry {
    [self disableeditbuttons:false];
    _minipopoverindicator.hidden = false;
    [_minipopoverindicator startAnimation:self];
    bool rereading = ((NSNumber *)_selecteditem[@"rereading"]).boolValue;
    if(![_minipopoverstatus.title isEqual:@"completed"] && _mangapopoverchapfield.intValue == _mangapopovertotalchap.intValue && _mangapopovertotalvol.intValue == _mangapopovertotalvol.intValue && _selectedfinished) {
        [_minipopoverstatus selectItemWithTitle:@"completed"];
        rereading = false;
    }
    if(!_selectedpublished && (![_minipopoverstatus.title isEqual:@"plan to read"] ||_mangapopoverchapfield.intValue > 0 || _mangapopovertotalvol.intValue > 0)) {
        // Invalid input, mark it as such
        [self disableeditbuttons:true];
        _minieditpopover.behavior = NSPopoverBehaviorTransient;
        _minipopoverindicator.hidden = true;
        [_minipopoverindicator stopAnimation:nil];
        return;
    }
    if (((_mangapopoverchapfield.intValue == _mangapopovertotalchap.intValue && _mangapopoverchapfield.intValue != 0) || (_mangapopovervolfield.intValue == _mangapopovertotalvol.intValue && _mangapopovertotalvol.intValue != 0)) && _selectedfinished && _selectedpublished) {
        [_minipopoverstatus selectItemWithTitle:@"completed"];
        _mangapopoverchapfield.stringValue = _mangapopovertotalchap.stringValue;
        _mangapopovertotalvol.stringValue = _mangapopovertotalvol.stringValue;
    }
    if ([_minipopoverstatus.title isEqual:@"completed"] && ((_mangapopoverchapfield.intValue != _mangapopovertotalchap.intValue && _mangapopoverchapfield.intValue != 0) || (_mangapopovervolfield.intValue != _mangapopovertotalvol.intValue && _mangapopovertotalvol.intValue != 0)) && _selectedfinished) {
        _mangapopoverchapfield.stringValue = _mangapopovertotalchap.stringValue;
        _mangapopovertotalvol.stringValue = _mangapopovertotalvol.stringValue;
    }
    NSDictionary * extraparameters = @{};
    int currentservice = [listservice getCurrentServiceID];
    switch ([listservice getCurrentServiceID]) {
        case 2:
        case 3: {
            extraparameters = @{@"reconsuming" : @(rereading)};
            break;
        }
        default:
            break;
    }
    int score = 0;
    switch (currentservice) {
        case 1:
        case 2:
            score = (int)_minipopoverscore.selectedTag;
            break;
        case 3: {
            NSString *scoretype = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-scoreformat"];
            if ([scoretype isEqualToString:@"POINT_100"]) {
                score = _advancedscorefield.intValue;
            }
            else if ([scoretype isEqualToString:@"POINT_10_DECIMAL"]) {
                score = [AniListScoreConvert convertScoretoScoreRaw:_advancedscorefield.doubleValue withScoreType:scoretype];
            }
            else {
                score = [AniListScoreConvert convertScoretoScoreRaw:_minipopoverscore.selectedTag withScoreType:scoretype];
            }
            break;
        }
    }
    [_mlv setUpdatingState:true];
    _minieditpopover.behavior = NSPopoverBehaviorApplicationDefined;
    [_minipopoverindicator startAnimation:nil];
    [listservice updateMangaTitleOnList:_selectededitid withChapter:_mangapopoverchapfield.intValue withVolume:_mangapopovervolfield.intValue withStatus:_minipopoverstatus.title withScore:score withExtraFields:extraparameters completion:^(id responseobject) {
        NSDictionary *updatedfields = @{@"chapters_read" : @(_mangapopoverchapfield.intValue), @"volumes_read" : @(_mangapopovervolfield.intValue), @"read_status" : _minipopoverstatus.title, @"score" : @(score), @"rereading" : @(rereading)};
        switch ([listservice getCurrentServiceID]) {
            case 1:
                [AtarashiiListCoreData updateSingleEntry:updatedfields withUserName:[listservice getCurrentServiceUsername] withService:[listservice getCurrentServiceID] withType:1 withId:_selectededitid withIdType:0];
                break;
            case 2:
            case 3:
                [AtarashiiListCoreData updateSingleEntry:updatedfields withUserId:[listservice getCurrentUserID] withService:[listservice getCurrentServiceID] withType:1 withId:_selectededitid withIdType:1];
                break;
        }
        [_mw loadlist:@(false) type:_selectedtype];
        [_mw loadlist:@(true) type:2];
        
        [self disableeditbuttons:true];
        _minieditpopover.behavior = NSPopoverBehaviorTransient;
        _minipopoverindicator.hidden = true;
        [_minipopoverindicator stopAnimation:nil];
        [_minieditpopover close];
        [self cleanup];
    }error:^(NSError * error) {
        [self disableeditbuttons:true];
        _minieditpopover.behavior = NSPopoverBehaviorTransient;
        _minipopoverindicator.hidden = true;
        [_mlv setUpdatingState:false];
        [_minipopoverindicator stopAnimation:nil];
        NSLog(@"%@", error.localizedDescription);
        NSLog(@"Content: %@", [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
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
        if ((stepper.intValue <= totalsegment || totalsegment == 0) && stepper.intValue >= 0) {
            segment = stepper.intValue;
            _minipopoverepfield.stringValue = [NSString stringWithFormat:@"%i",segment];
        }
        else {
            stepper.intValue = segment;
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

        if ((stepper.intValue <= totalsegment || totalsegment == 0) && stepper.intValue >= 0) {
            segment = stepper.intValue;
            if ([segmenttype isEqualToString:@"chapters"]) {
                _mangapopoverchapfield.stringValue = [NSString stringWithFormat:@"%i",segment];
            }
            else {
                _mangapopovervolfield.stringValue = [NSString stringWithFormat:@"%i",segment];
            }
        }
        else {
            stepper.intValue = segment;
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

- (void)setScoreMenu:(int)type {
    switch ([listservice getCurrentServiceID]) {
        case 1:
            _advancedscorefield.hidden = true;
            _minipopoverscore.hidden = false;
            _minipopoverscore.menu = _malscoremenu;
            break;
        case 2: {
            _advancedscorefield.hidden = true;
            _minipopoverscore.hidden = false;
            switch ([NSUserDefaults.standardUserDefaults integerForKey:@"kitsu-ratingsystem"]) {
                case 0:
                    _minipopoverscore.menu = _kitsusimplescoremenu;
                    break;
                case 1:
                    _minipopoverscore.menu = _kitsustandardscoremenu;
                    break;
                case 2:
                    _minipopoverscore.menu = _kitsuadavancedscoremenu;
                    break;
                default:
                    break;
            }
            break;
        }
        case 3: {
            NSString *scoretype = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-scoreformat"];
            if ([scoretype isEqualToString:@"POINT_100"] || [scoretype isEqualToString:@"POINT_10_DECIMAL"]) {
                _advancedscorefield.hidden = false;
                _minipopoverscore.hidden = true;
                if ([scoretype isEqualToString:@"POINT_100"]) {
                    _advancedscoreformat.maximum = @(100);
                }
                else {
                    _advancedscoreformat.maximum = @(10);
                }
            }
            else {
                _advancedscorefield.hidden = true;
                _minipopoverscore.hidden = false;
                if ([scoretype isEqualToString:@"POINT_10"]) {
                    _minipopoverscore.menu = _malscoremenu;
                }
                else if ([scoretype isEqualToString:@"POINT_5"]) {
                    _minipopoverscore.menu = _AniListFiveScoreMenu;
                }
                else if ([scoretype isEqualToString:@"POINT_3"]) {
                    _minipopoverscore.menu = _AniListThreeScoreMenu;
                }
            }
            break;
        }
        default:
            break;
    }
}

- (void)disableeditbuttons:(bool)enable {
    _minipopovereditbtn.enabled = enable;
    _animeadvancededit.enabled = enable;
    _minipopovereditbtn.enabled = enable;
    _animeadvancededit.enabled = enable;
}

- (void)cleanup {
    _selecteditem = nil;
}

- (IBAction)showadvanced:(id)sender {
    if (!_mw.ade) {
        _mw.ade = [advancededitdialog new];
    }
    [_mw.ade.window makeKeyAndOrderFront:self];
    [_mw.ade setupeditwindow:_selecteditem.copy type:_selectedtype];
    [_mw.ade.window close];
    [_minieditpopover close];
    [_mlv setUpdatingState:true];
    [_mw.window beginSheet:_mw.ade.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            [_mw loadlist:@(true) type:_selectedtype];
            [_mw loadlist:@(true) type:2];
        }
        else {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                sleep(1);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_mlv setUpdatingState:false];
                });
            });
        }
    }];
}

- (void)setScore:(NSDictionary *)d {
    switch ([listservice getCurrentServiceID]) {
        case 1:
        case 2:
            [_minipopoverscore selectItemWithTag:((NSNumber *)d[@"score"]).intValue];
            break;
        case 3: {
            NSString *scoretype = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-scoreformat"];
            NSNumber *convertedScore = [AniListScoreConvert convertScoreToRawActualScore:((NSNumber *)d[@"score"]).intValue withScoreType:scoretype];
            if ([scoretype isEqualToString:@"POINT_100"]) {
                _advancedscorefield.intValue = convertedScore.intValue;
            }
            else if ([scoretype isEqualToString:@"POINT_10_DECIMAL"]) {
                _advancedscorefield.doubleValue = convertedScore.doubleValue;
            }
            else {
                [_minipopoverscore selectItemWithTag:convertedScore.intValue];
            }
        }
    }
}
@end
