//
//  advancededitdialog.m
//  Shukofukurou
//
//  Created by 小鳥遊六花 on 3/20/18.
//  Copyright © 2018 MAL Updater OS X Group. All rights reserved.
//

#import "advancededitdialog.h"
#import "AniListScoreConvert.h"
#import "listservice.h"
#import "AppDelegate.h"
#import "MainWindow.h"
#import "MyListView.h"
#import "AtarashiiListCoreData.h"
#import "Utility.h"
#import "Analytics.h"

@interface advancededitdialog ()
@property (strong) IBOutlet NSView *editview;
@property (strong) MyListView *mlv;
@end

@implementation advancededitdialog
- (instancetype)init{
    self = [super initWithWindowNibName:@"advancededitdialog"];
    if (!self)
        return nil;
    return self;
}

- (void)awakeFromNib {
    [_segmentfield addSubview:[NSView new]];
    [_listservicefields addSubview:[NSView new]];
    _mlv = [self mw].listview;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (MainWindow *)mw {
    return ((AppDelegate *)NSApp.delegate).mainwindowcontroller;
}

- (void)setupeditwindow:(NSDictionary *)d type:(int)type {
    _selecteditem = d;

    [self setuplistservicefields];
    _title.stringValue = d[@"title"];
    [self setMALdates];
    if (type == 0) {
        [_segmentfield replaceSubview:_segmentfield.subviews[0] with:_episodeview];
        _status.menu = _animestatusmenu;
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
        _episodefield.intValue = ((NSNumber *)d[@"watched_episodes"]).intValue;
        _episodestepper.intValue = ((NSNumber *)d[@"watched_episodes"]).intValue;
        _totalepisodes.intValue = ((NSNumber *)d[@"episodes"]).intValue;
        _tagsfield.stringValue = d[@"personal_tags"] != [NSNull null] ? [((NSArray *)d[@"personal_tags"]) componentsJoinedByString:@","] : @"";
        [_status selectItemWithTitle:d[@"watched_status"]];
        [self setScoreMenu:d];
        _reconsuming.state = ((NSNumber *)d[@"rewatching"]).boolValue;
        _repeattimes.integerValue = ((NSNumber *)d[@"rewatch_count"]).integerValue;
        if (!_privatecheck.hidden) {
            _privatecheck.state = ((NSNumber *)d[@"private"]).boolValue;
            if (d[@"personal_comments"] != [NSNull null]) {
                _notesfield.stringValue = ((NSString *)d[@"personal_comments"]);
            }
            else {
                _notesfield.stringValue = @"";
            }
        }
        //_minipopoverstatustext.stringValue = @"";
        if (((NSNumber *)d[@"episodes"]).intValue > 0) {
            _episodefieldnumberformat.maximum = d[@"episodes"];
        }
        else {
            _episodefieldnumberformat.maximum = @(9999999);
        }
        _episodestepper.maxValue = _episodefieldnumberformat.maximum.doubleValue;
        switch ([listservice.sharedInstance getCurrentServiceID]) {
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
        _selectedtype = type;
    }
    else {
        [_segmentfield replaceSubview:_segmentfield.subviews[0] with:_chapterview];
        _status.menu = _mangastatusmenu;
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
        _chaptersfield.intValue = ((NSNumber *)d[@"chapters_read"]).intValue;
        _chaptertepper.intValue = ((NSNumber *)d[@"chapters_read"]).intValue;
        _totalchapters.intValue = ((NSNumber *)d[@"chapters"]).intValue;
        if (((NSNumber *)d[@"chapters"]).intValue > 0) {
            _chaptersnumformat.maximum = d[@"chapters"];
        }
        else {
            _chaptersnumformat.maximum = @(9999999);
        }
        _volumesfield.intValue = ((NSNumber *)d[@"volumes_read"]).intValue;
        _volumestepper.intValue = ((NSNumber *)d[@"volumes_read"]).intValue;
        _totalvolumes.intValue = ((NSNumber *)d[@"volumes"]).intValue;
        _tagsfield.stringValue = d[@"personal_tags"] != [NSNull null] ? [((NSArray *)d[@"personal_tags"]) componentsJoinedByString:@","] : @"";
        if (((NSNumber *)d[@"volumes"]).intValue > 0) {
            _volumesformatter.maximum = d[@"volumes"];
        }
        else {
            _volumesformatter.maximum = @(9999999);
        }
        _volumestepper.maxValue = _volumesformatter.maximum.doubleValue;
        _chaptertepper.maxValue = _chaptersnumformat.maximum.doubleValue;
        [_status selectItemWithTitle:d[@"read_status"]];
        [self setScoreMenu:d];
        _reconsuming.state = ((NSNumber *)d[@"rereading"]).boolValue;
        _repeattimes.integerValue = ((NSNumber *)d[@"reread_count"]).integerValue;
        if (!_privatecheck.hidden) {
            _privatecheck.state = ((NSNumber *)d[@"private"]).boolValue;
            if (d[@"personal_comments"] != [NSNull null]) {
                _notesfield.stringValue = ((NSString *)d[@"personal_comments"]);
            }
            else {
                _notesfield.stringValue = @"";
            }
        }
        //_mangapopoverstatustext.stringValue = @"";
        switch ([listservice.sharedInstance getCurrentServiceID]) {
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
        _selectedtype = type;
    }
}

- (IBAction)editaction:(id)sender {
    if (_selectedtype == 0) {
        [self updateanimeentry];
    }
    else {
        [self updatemangaentry];
    }
}

- (void)updateanimeentry {
    [self disableeditbuttons:false];
    _progressindicator.hidden = false;
    [_progressindicator startAnimation:self];
    if(![_status.title isEqual:@"completed"] && _episodefield.intValue == _totalepisodes.intValue && _selectedaircompleted) {
        [_status selectItemWithTitle:@"completed"];
        _reconsuming.state = NSControlStateValueOff;
    }
    if(!_selectedaired && (![_status.title isEqual:@"plan to watch"] ||_episodefield.intValue > 0)) {
        // Invalid input, mark it as such
        [self disableeditbuttons:true];
        _progressindicator.hidden = true;
        [_progressindicator stopAnimation:nil];
        return;
    }
    if (_episodefield.intValue == _totalepisodes.intValue && _totalepisodes.intValue != 0 && _selectedaircompleted && _selectedaired) {
        [_status selectItemWithTitle:@"completed"];
        _episodefield.stringValue = _totalepisodes.stringValue;
    }
    if ([_status.title isEqual:@"completed"] && _totalepisodes.intValue != 0 && _episodefield.intValue != _totalepisodes.intValue && _selectedaircompleted) {
        _episodefield.stringValue = _totalepisodes.stringValue;
    }
    NSDictionary *extrafields = [self generateExtraFieldsWithType:0];
    int currentlistservice = [listservice.sharedInstance getCurrentServiceID];
    int score = 0;
    switch (currentlistservice) {
        case 1:
        case 2:
            score = (int)_score.selectedTag;
            break;
        case 3: {
            NSString *scoretype = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-scoreformat"];
            if ([scoretype isEqualToString:@"POINT_100"]) {
                score = _advancedscore.intValue;
            }
            else if ([scoretype isEqualToString:@"POINT_10_DECIMAL"]) {
                score = [AniListScoreConvert convertScoretoScoreRaw:_advancedscore.doubleValue withScoreType:scoretype];
            }
            else {
                score = [AniListScoreConvert convertScoretoScoreRaw:_score.selectedTag withScoreType:scoretype];
            }
            break;
        }
    }
    [_mlv setUpdatingState:true];
    [_progressindicator startAnimation:nil];
    [listservice.sharedInstance updateAnimeTitleOnList:_selectededitid withEpisode:_episodefield.intValue withStatus:_status.title withScore:score withExtraFields:extrafields completion:^(id responseobject) {
        switch ([listservice.sharedInstance getCurrentServiceID]) {
            case 1:
                [AtarashiiListCoreData updateSingleEntry:[self generatelistentrywithScore:score withType:MALAnime withResponseObject:responseobject] withUserName:[listservice.sharedInstance getCurrentServiceUsername] withService:[listservice.sharedInstance getCurrentServiceID] withType:MALAnime withId:_selectededitid withIdType:0];
                break;
            case 2:
            case 3:
                [AtarashiiListCoreData updateSingleEntry:[self generatelistentrywithScore:score withType:MALAnime withResponseObject:responseobject] withUserId:[listservice.sharedInstance getCurrentUserID] withService:[listservice.sharedInstance getCurrentServiceID] withType:MALAnime withId:_selectededitid withIdType:1];
                break;
            default:
                break;
        }
        [self disableeditbuttons:true];
        _progressindicator.hidden = true;
        [_progressindicator stopAnimation:nil];
        [_mlv setUpdatingState:false];
        [Analytics sendAnalyticsWithEventTitle:@"Advanced Entry Edit Successful" withProperties:@{@"service" : [listservice.sharedInstance currentservicename], @"media_type" : self.selectedtype == 0 ? @"anime" : @"manga"}];
        [self updateissuccessful];
        _selecteditem = nil;
    }
                                  error:^(NSError * error) {
                                      [self disableeditbuttons:true];
                                      [_mlv setUpdatingState:false];
                                      _progressindicator.hidden = true;
                                      [_progressindicator stopAnimation:nil];
                                      NSLog(@"%@", error.localizedDescription);
                                      NSLog(@"Content: %@", [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
                                        [Analytics sendAnalyticsWithEventTitle:@"Advanced Entry Edit Failed" withProperties:@{@"service" : [listservice.sharedInstance currentservicename], @"localized_error" : error.localizedDescription, @"error_description" : [Analytics getErrorDescriptionFromErrorResponse:error], @"media_type" : self.selectedtype == 0 ? @"anime" : @"manga"}];
                                      //_minipopoverstatustext.stringValue = @"Error";
                                  }];
}

- (void)updatemangaentry {
    [self disableeditbuttons:false];
    //_mangapopoverstatustext.stringValue = @"";
    _progressindicator.hidden = false;
    [_progressindicator startAnimation:self];
    if(![_status.title isEqual:@"completed"] && _chaptersfield.intValue == _totalchapters.intValue && _volumesfield.intValue == _totalvolumes.intValue && _selectedfinished) {
        [_status selectItemWithTitle:@"completed"];
    }
    if(!_selectedpublished && (![_status.title isEqual:@"plan to read"] ||_chaptersfield.intValue > 0 || _totalvolumes.intValue > 0)) {
        // Invalid input, mark it as such
        [self disableeditbuttons:true];
        //_mangapopoverstatustext.stringValue = @"Invalid update.";
        _progressindicator.hidden = true;
        [_progressindicator stopAnimation:nil];
        return;
    }
    if (((_chaptersfield.intValue == _totalchapters.intValue && _chaptersfield.intValue != 0) || (_volumesfield.intValue == _totalvolumes.intValue && _totalvolumes.intValue != 0)) && _selectedfinished && _selectedpublished) {
        [_status selectItemWithTitle:@"completed"];
        _chaptersfield.stringValue = _totalchapters.stringValue;
        _totalvolumes.stringValue = _totalvolumes.stringValue;
    }
    if([_status.title isEqual:@"completed"] && ((_chaptersfield.intValue != _totalchapters.intValue && _chaptersfield.intValue != 0) || (_volumesfield.intValue != _totalvolumes.intValue && _totalvolumes.intValue != 0)) && _selectedfinished) {
        _chaptersfield.stringValue = _totalchapters.stringValue;
        _totalvolumes.stringValue = _totalvolumes.stringValue;
    }
    int currentlistservice = [listservice.sharedInstance getCurrentServiceID];
    NSDictionary *extrafields = [self generateExtraFieldsWithType:1];
    int score = 0;
    switch (currentlistservice) {
        case 1:
        case 2:
            score = (int)_score.selectedTag;
            break;
        case 3: {
            NSString *scoretype = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-scoreformat"];
            if ([scoretype isEqualToString:@"POINT_100"]) {
                score = _advancedscore.intValue;
            }
            else if ([scoretype isEqualToString:@"POINT_10_DECIMAL"]) {
                score = [AniListScoreConvert convertScoretoScoreRaw:_advancedscore.doubleValue withScoreType:scoretype];
            }
            else {
                score = [AniListScoreConvert convertScoretoScoreRaw:_score.selectedTag withScoreType:scoretype];
            }
            break;
        }
    }
    [_mlv setUpdatingState:true];
    [_progressindicator startAnimation:nil];
    [listservice.sharedInstance updateMangaTitleOnList:_selectededitid withChapter:_chaptersfield.intValue withVolume:_volumesfield.intValue withStatus:_status.title withScore:score withExtraFields:extrafields completion:^(id responseobject) {
        switch ([listservice.sharedInstance getCurrentServiceID]) {
            case 1:
                [AtarashiiListCoreData updateSingleEntry:[self generatelistentrywithScore:score withType:MALManga withResponseObject:responseobject] withUserName:[listservice.sharedInstance getCurrentServiceUsername] withService:[listservice.sharedInstance getCurrentServiceID] withType:MALManga withId:_selectededitid withIdType:0];
                break;
            case 2:
            case 3:
                [AtarashiiListCoreData updateSingleEntry:[self generatelistentrywithScore:score withType:MALManga withResponseObject:responseobject] withUserId:[listservice.sharedInstance getCurrentUserID] withService:[listservice.sharedInstance getCurrentServiceID] withType:MALManga withId:_selectededitid withIdType:1];
                break;
            default:
                break;
        }
        [self disableeditbuttons:true];
        _progressindicator.hidden = true;
        [_progressindicator stopAnimation:nil];
        [_mlv setUpdatingState:false];
        [Analytics sendAnalyticsWithEventTitle:@"Advanced Entry Edit Successful" withProperties:@{@"service" : [listservice.sharedInstance currentservicename], @"media_type" : self.selectedtype == 0 ? @"anime" : @"manga"}];
        [self updateissuccessful];
        _selecteditem = nil;
    }error:^(NSError * error) {
        [self disableeditbuttons:true];
        _progressindicator.hidden = true;
        [_progressindicator stopAnimation:nil];
        [_mlv setUpdatingState:false];
        NSLog(@"%@", error.localizedDescription);
        NSLog(@"Content: %@", [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
        [Analytics sendAnalyticsWithEventTitle:@"Advanced Entry Edit Failed" withProperties:@{@"service" : [listservice.sharedInstance currentservicename], @"localized_error" : error.localizedDescription, @"error_description" : [Analytics getErrorDescriptionFromErrorResponse:error], @"media_type" : self.selectedtype == 0 ? @"anime" : @"manga"}];
    }];
}

- (IBAction)cancel:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
    [self.window close];
}
- (void)updateissuccessful {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
    [self.window close];
}
#pragma mark steppers and text fields
- (void)controlTextDidChange:(NSNotification *)aNotification {
    if ([aNotification.name isEqualToString:@"NSControlTextDidChangeNotification"]) {
        
        if ( aNotification.object == _episodefield ) {
            _episodestepper.intValue = _episodefield.intValue;
        }
        else if ( aNotification.object == _chaptersfield ) {
            _chaptertepper.intValue = _chaptersfield.intValue;
        }
        else if ( aNotification.object == _volumesfield ) {
            _volumestepper.intValue = _volumesfield.intValue;
        }
    }
}
- (IBAction)segmentstepclick:(id)sender {
    int segment = 0;
    int totalsegment = 0;
    NSStepper * stepper = (NSStepper *)sender;
    if (_selectedtype == 0) {
        if ((_episodefield.stringValue).length > 0) {
            segment = (_episodefield.stringValue).intValue;
        }
        totalsegment = (_totalepisodes.stringValue).intValue;
        if ((stepper.intValue <= totalsegment || totalsegment == 0) && stepper.intValue >= 0) {
            segment = stepper.intValue;
            _episodefield.stringValue = @(segment).stringValue;
        }
        else {
            stepper.intValue = segment;
        }
    }
    else {
        NSString * segmenttype;
        if ([stepper.identifier isEqualToString:@"chapstepper"]) {
            segmenttype = @"chapters";
            if ((_chaptersfield.stringValue).length > 0) {
                segment = (_chaptersfield.stringValue).intValue;
            }
            totalsegment = (_totalchapters.stringValue).intValue;
        }
        else {
            // Volumes
            segmenttype = @"volumes";
            if ((_volumesfield.stringValue).length > 0) {
                segment = (_volumesfield.stringValue).intValue;
            }
            totalsegment = (_totalvolumes.stringValue).intValue;
        }
        
        if ((stepper.intValue <= totalsegment || totalsegment == 0) && stepper.intValue >= 0) {
            segment = stepper.intValue;
            if ([segmenttype isEqualToString:@"chapters"]) {
                _chaptersfield.stringValue = @(segment).stringValue;
            }
            else {
                _volumesfield.stringValue = @(segment).stringValue;
            }
        }
        else {
            stepper.intValue = segment;
        }
    }
}

- (void)setuplistservicefields {
    switch ([listservice.sharedInstance getCurrentServiceID]) {
        case 1:
            _score.menu = _malscoremenu;
            [_listservicefields replaceSubview:_listservicefields.subviews[0] with:_malfieldsview];
            _privatecheck.hidden = YES;
            _advancedscore.hidden = true;
            _score.hidden = false;
            break;
        case 2: {
            [_listservicefields replaceSubview:_listservicefields.subviews[0] with:_kitsufieldsview];
            _privatecheck.hidden = NO;
            _advancedscore.hidden = true;
            _score.hidden = false;
            switch ([NSUserDefaults.standardUserDefaults integerForKey:@"kitsu-ratingsystem"]) {
                case 0:
                    _score.menu = _kitsusimplerating;
                    break;
                case 1:
                    _score.menu = _kitsustandardrating;
                    break;
                case 2:
                    _score.menu = _kitsuadvancedrating;
                    break;
                default:
                    break;
            }
            break;
        }
        case 3: {
            [_listservicefields replaceSubview:_listservicefields.subviews[0] with:_kitsufieldsview];
            _privatecheck.hidden = NO;
            NSString *scoretype = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-scoreformat"];
            if ([scoretype isEqualToString:@"POINT_100"] || [scoretype isEqualToString:@"POINT_10_DECIMAL"]) {
                _advancedscore.hidden = false;
                _score.hidden = true;
                if ([scoretype isEqualToString:@"POINT_100"]) {
                    _advancedscoreformat.maximum = @(100);
                }
                else {
                    _advancedscoreformat.maximum = @(10);
                }
            }
            else {
                _advancedscore.hidden = true;
                _score.hidden = false;
                if ([scoretype isEqualToString:@"POINT_10"]) {
                    _score.menu = _malscoremenu;
                }
                else if ([scoretype isEqualToString:@"POINT_5"]) {
                    _score.menu = _AniListFiveScoreMenu;
                }
                else if ([scoretype isEqualToString:@"POINT_3"]) {
                    _score.menu = _AniListThreeScoreMenu;
                }
            }
            break;
        }
        default:
            break;
    }
}

- (void)setMALdates {
    NSDateFormatter *dateformat = [NSDateFormatter new];
    dateformat.dateFormat = @"yyyy-MM-dd";
    if (_selectedtype == MALAnime) {
        if (_selecteditem[@"watching_start"] && _selecteditem[@"watching_start"] != [NSNull null] && ((NSString *)_selecteditem[@"watching_start"]).length > 0) {
            _startdatepicker.dateValue = [dateformat dateFromString:[(NSString *)_selecteditem[@"watching_start"] substringToIndex:10]];
            _setstartdatecheck.state = true;
            _setstartdatecheck.enabled = false;
        }
        else {
            _startdatepicker.dateValue = [NSDate date];
            _setstartdatecheck.state = false;
            _setstartdatecheck.enabled = true;
        }
        if (_selecteditem[@"watching_end"]  && _selecteditem[@"watching_end"] != [NSNull null] && ((NSString *)_selecteditem[@"watching_end"]).length > 0) {
            _enddatepicker.dateValue = [dateformat dateFromString:[(NSString *)_selecteditem[@"watching_end"] substringToIndex:10]];
            _setenddatecheck.state = true;
            _setenddatecheck.enabled = false;
        }
        else {
            _enddatepicker.dateValue = [NSDate date];
            _setenddatecheck.state = false;
            _setenddatecheck.enabled = true;
        }
    }
    else {
        if (_selecteditem[@"reading_start"] && _selecteditem[@"reading_start"] != [NSNull null] && ((NSString *)_selecteditem[@"reading_start"]).length > 0) {
            _startdatepicker.dateValue = [dateformat dateFromString:[(NSString *)_selecteditem[@"reading_start"] substringToIndex:10]];
            _setstartdatecheck.state = true;
            _setstartdatecheck.enabled = false;
        }
        else {
            _startdatepicker.dateValue = [NSDate date];
            _setstartdatecheck.state = false;
            _setstartdatecheck.enabled = true;
        }
        if (_selecteditem[@"reading_end"]  && _selecteditem[@"reading_end"] != [NSNull null] && ((NSString *)_selecteditem[@"reading_end"]).length > 0) {
            _enddatepicker.dateValue = [dateformat dateFromString:[(NSString *)_selecteditem[@"reading_end"] substringToIndex:10]];
            _setenddatecheck.state = true;
            _setenddatecheck.enabled = false;
        }
        else {
            _enddatepicker.dateValue = [NSDate date];
            _setenddatecheck.state = false;
            _setenddatecheck.enabled = true;
        }
    }
    [self refreshdatepickerstate];
}

- (IBAction)dateCheckStateChanged:(id)sender {
    [self refreshdatepickerstate];
}

- (void)refreshdatepickerstate {
    _startdatepicker.enabled = @(_setstartdatecheck.state).boolValue;
    _enddatepicker.enabled = @(_setenddatecheck.state).boolValue;
}

-(void)disableeditbuttons:(bool)enable {
    _editbtn.enabled = enable;
    _closebtn.enabled = enable;
}

- (void)setScoreMenu:(NSDictionary *)d {
    switch ([listservice.sharedInstance getCurrentServiceID]) {
        case 1:
        case 2:
            [_score selectItemWithTag:((NSNumber *)d[@"score"]).intValue];
            break;
        case 3: {
            NSString *scoretype = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-scoreformat"];
            NSNumber *convertedScore = [AniListScoreConvert convertScoreToRawActualScore:((NSNumber *)d[@"score"]).intValue withScoreType:scoretype];
            if ([scoretype isEqualToString:@"POINT_100"]) {
                _advancedscore.intValue = convertedScore.intValue;
            }
            else if ([scoretype isEqualToString:@"POINT_10_DECIMAL"]) {
                _advancedscore.doubleValue = convertedScore.doubleValue;
            }
            else {
                [_score selectItemWithTag:convertedScore.intValue];
            }
            break;
        }
    }
}

- (NSDictionary *)generateExtraFieldsWithType:(int)type {
    NSMutableDictionary *extrafields = [NSMutableDictionary new];
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"yyyy-MM-dd";
    NSString *tags = @"";
    switch ([listservice.sharedInstance getCurrentServiceID]) {
        case 1: {
            if (((NSArray *)_tagsfield.objectValue).count > 0){
                tags = [(NSArray *)_tagsfield.objectValue componentsJoinedByString:@","];
                extrafields[@"tags"] = tags;
            }
            if (@(_setstartdatecheck.state).boolValue) {
                extrafields[@"start"] = [df stringFromDate:_startdatepicker.dateValue];
            }
            if (@(_setenddatecheck.state).boolValue) {
                extrafields[@"end"] = [df stringFromDate:_enddatepicker.dateValue];
            }
            if (type == 0) {
                extrafields[@"is_rewatching"] = @(_reconsuming.state);
                extrafields[@"rewatch_count"] = @(_repeattimes.intValue);
            }
            else {
                extrafields[@"is_rereading"] = @(_reconsuming.state);
                extrafields[@"reread_count"] = @(_repeattimes.intValue);
            }
            break;
        }
        case 2: {
            if (_notesfield.stringValue.length > 0) {
                extrafields[@"notes"] = _notesfield.stringValue;
            }
            else {
                extrafields[@"notes"] = [NSNull null];
            }
            if (@(_setstartdatecheck.state).boolValue) {
                extrafields[@"startedAt"] = [df stringFromDate:_startdatepicker.dateValue];
            }
            if (@(_setenddatecheck.state).boolValue) {
                extrafields[@"finishedAt"] = [df stringFromDate:_enddatepicker.dateValue];
            }
            extrafields[@"private"] = @(@(_privatecheck.state).boolValue);
            extrafields[@"reconsuming"] = @(_reconsuming.state);                     extrafields[@"reconsuming"] = @(@(_reconsuming.state).boolValue);
            extrafields[@"reconsumeCount"] = @(_repeattimes.intValue);
            break;
        }
        case 3:{
            if (_notesfield.stringValue.length > 0) {
                extrafields[@"notes"] = _notesfield.stringValue;
            }
            else {
                extrafields[@"notes"] = [NSNull null];
            }
            if (@(_setstartdatecheck.state).boolValue) {
                NSString *tmpstr = [df stringFromDate:_startdatepicker.dateValue];
                extrafields[@"startedAt"] = @{@"year" : [tmpstr substringWithRange:NSMakeRange(0, 4)], @"month" : [tmpstr substringWithRange:NSMakeRange(5, 2)], @"day" : [tmpstr substringWithRange:NSMakeRange(8, 2)]};
            }
            else {
                extrafields[@"startedAt"] = @{@"year" : @(0), @"month" : @(0), @"day" : @(0)};
            }
            if (@(_setenddatecheck.state).boolValue) {
                NSString *tmpstr = [df stringFromDate:_enddatepicker.dateValue];
                extrafields[@"completedAt"] = @{@"year" : [tmpstr substringWithRange:NSMakeRange(0, 4)], @"month" : [tmpstr substringWithRange:NSMakeRange(5, 2)], @"day" : [tmpstr substringWithRange:NSMakeRange(8, 2)]};
            }
            else {
                extrafields[@"completedAt"] = @{@"year" : @(0), @"month" : @(0), @"day" : @(0)};
            }
            extrafields[@"private"] = @(@(_privatecheck.state).boolValue);
            extrafields[@"reconsuming"] = @(_reconsuming.state);                     extrafields[@"reconsuming"] = @(@(_reconsuming.state).boolValue);
            extrafields[@"reconsumeCount"] = @(_repeattimes.intValue);
            break;
        }
        default:
            break;
    }
    return extrafields;
}
- (NSDictionary *)generatelistentrywithScore:(int)score withType:(int)type withResponseObject:(id)responseobject {
    NSMutableDictionary *nfields = [NSMutableDictionary new];
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"yyyy-MM-dd";
    nfields[@"score"] = @(score);
    if (((NSArray *)_tagsfield.objectValue).count > 0 && [listservice.sharedInstance getCurrentServiceID] == 1){
        nfields[@"personal_tags"] = [(NSArray *)_tagsfield.objectValue componentsJoinedByString:@","];
    }
    if ([listservice.sharedInstance getCurrentServiceID] == 2 && [listservice.sharedInstance getCurrentServiceID] == 3) {
        if (_notesfield.stringValue.length > 0) {
            nfields[@"personal_comments"] = _notesfield.stringValue;
        }
        else {
            nfields[@"personal_comments"] = @"";
        }
        nfields[@"private"] = @(@(_privatecheck.state).boolValue);
    }
    nfields[@"last_updated"] = [Utility getLastUpdatedDateWithResponseObject:responseobject withService:[listservice.sharedInstance getCurrentServiceID]];
    switch (type) {
        case 0: {
            [nfields addEntriesFromDictionary:@{@"watched_episodes" : @(_episodefield.intValue), @"watched_status" : _status.title}];
            if (@(_setstartdatecheck.state).boolValue) {
                nfields[@"watching_start"] = [df stringFromDate:_startdatepicker.dateValue];
            }
            if (@(_setenddatecheck.state).boolValue) {
                nfields[@"watching_end"] = [df stringFromDate:_enddatepicker.dateValue];
            }
            nfields[@"rewatching"] = @(_reconsuming.state);
            nfields[@"rewatch_count"] = @(_repeattimes.intValue);
            break;
        }
        case 1: {
            [nfields addEntriesFromDictionary:@{@"chapters_read" : @(_chaptersfield.intValue), @"volumes_read" : @(_volumesfield.intValue), @"read_status" : _status.title}];
            if (@(_setstartdatecheck.state).boolValue) {
                nfields[@"reading_start"] = [df stringFromDate:_startdatepicker.dateValue];
            }
            if (@(_setenddatecheck.state).boolValue) {
                nfields[@"reading_end"] = [df stringFromDate:_enddatepicker.dateValue];
            }
            nfields[@"rereading"] = @(_reconsuming.state);
            nfields[@"reread_count"] = @(_repeattimes.intValue);
            break;
        }
    }
    return nfields;
}
@end
