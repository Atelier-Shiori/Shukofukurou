//
//  advancededitdialog.m
//  MAL Library
//
//  Created by 小鳥遊六花 on 3/20/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "advancededitdialog.h"
#import "listservice.h"

@interface advancededitdialog ()
@property (strong) IBOutlet NSView *editview;

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
}
- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)setupeditwindow:(NSDictionary *)d type:(int)type {
    _selecteditem = d;

    [self setuplistservicefields];
    _title.stringValue = d[@"title"];
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
        _tagsfield.stringValue = ((NSArray *)d[@"personal_tags"]).count > 0 ? [((NSArray *)d[@"personal_tags"]) componentsJoinedByString:@","] : @"";
        [_status selectItemWithTitle:d[@"watched_status"]];
        [_score selectItemWithTag:((NSNumber *)d[@"score"]).intValue];
        _reconsuming.state = ((NSNumber *)d[@"rewatching"]).boolValue;
        if (!_privatecheck.hidden) {
            _privatecheck.state = ((NSNumber *)d[@"private"]).boolValue;
            if (d[@"personal_comments"] != [NSNull null]) {
                _notesfield.stringValue = ((NSString *)d[@"personal_comments"]);
            }
            else {
                _notesfield.stringValue = @"";
            }
        }
        else {
            [self setMALdates];
        }
        //_minipopoverstatustext.stringValue = @"";
        if (((NSNumber *)d[@"episodes"]).intValue > 0) {
            _episodefieldnumberformat.maximum = d[@"episodes"];
        }
        else {
            [_episodefieldnumberformat setMaximum:@(9999999)];
        }
        _episodestepper.maxValue = _episodefieldnumberformat.maximum.doubleValue;
        switch ([listservice getCurrentServiceID]) {
            case 1:
                _selectededitid = ((NSNumber *)d[@"id"]).intValue;
                break;
            case 2:
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
            [_chaptersnumformat setMaximum:@(9999999)];
        }
        _volumesfield.intValue = ((NSNumber *)d[@"volumes_read"]).intValue;
        _volumestepper.intValue = ((NSNumber *)d[@"volumes_read"]).intValue;
        _totalvolumes.intValue = ((NSNumber *)d[@"volumes"]).intValue;
        _tagsfield.stringValue = ((NSArray *)d[@"personal_tags"]).count > 0 ? [((NSArray *)d[@"personal_tags"]) componentsJoinedByString:@","] : @"";
        if (((NSNumber *)d[@"volumes"]).intValue > 0) {
            _volumesformatter.maximum = d[@"volumes"];
        }
        else {
            [_volumesformatter setMaximum:@(9999999)];
        }
        _volumestepper.maxValue = _volumesformatter.maximum.doubleValue;
        _chaptertepper.maxValue = _chaptersnumformat.maximum.doubleValue;
        [_status selectItemWithTitle:d[@"read_status"]];
        [_score selectItemWithTag:((NSNumber *)d[@"score"]).intValue];
        _reconsuming.state = ((NSNumber *)d[@"rereading"]).boolValue;
        if (!_privatecheck.hidden) {
            _privatecheck.state = ((NSNumber *)d[@"private"]).boolValue;
            if (d[@"personal_comments"] != [NSNull null]) {
                _notesfield.stringValue = ((NSString *)d[@"personal_comments"]);
            }
            else {
                _notesfield.stringValue = @"";
            }
        }
        else {
            [self setMALdates];
        }
        //_mangapopoverstatustext.stringValue = @"";
        switch ([listservice getCurrentServiceID]) {
            case 1:
                _selectededitid = ((NSNumber *)d[@"id"]).intValue;
                break;
            case 2:
                _selectededitid = ((NSNumber *)d[@"entryid"]).intValue;
                break;
            default:
                break;
        }
        _selectedtype = type;
    }
}

- (IBAction)editaction:(id)sender {
}

- (IBAction)cancel:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
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
    switch ([listservice getCurrentServiceID]) {
        case 1:
            _score.menu = _malscoremenu;
            [_listservicefields replaceSubview:_listservicefields.subviews[0] with:_malfieldsview];
            _privatecheck.hidden = YES;
            break;
        case 2: {
            [_listservicefields replaceSubview:_listservicefields.subviews[0] with:_kitsufieldsview];
            _privatecheck.hidden = NO;
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
        }
        default:
            break;
    }
}

- (void)setMALdates {
    NSDateFormatter *dateformat = [NSDateFormatter new];
    dateformat.dateFormat = @"yyyy-MM-dd";
    if (_selectedtype == MALAnime) {
        if (_selecteditem[@"watching_start"] && _selecteditem[@"watching_start"] != [NSNull null]) {
            _startdatepicker.dateValue = [dateformat dateFromString:[(NSString *)_selecteditem[@"watching_start"] substringToIndex:10]];
            _setstartdatecheck.state = true;
        }
        else {
            _startdatepicker.dateValue = [NSDate date];
            _setstartdatecheck.state = false;
        }
        if (_selecteditem[@"watching_end"]  && _selecteditem[@"watching_end"] != [NSNull null]) {
            _enddatepicker.dateValue = [dateformat dateFromString:[(NSString *)_selecteditem[@"watching_end"] substringToIndex:10]];
            _setenddatecheck.state = true;
        }
        else {
            _enddatepicker.dateValue = [NSDate date];
            _setenddatecheck.state = false;
        }
    }
    else {
        if (_selecteditem[@"reading_start"] && _selecteditem[@"reading_start"] != [NSNull null]) {
            _startdatepicker.dateValue = [dateformat dateFromString:[(NSString *)_selecteditem[@"reading_start"] substringToIndex:10]];
            _setstartdatecheck.state = true;
        }
        else {
            _startdatepicker.dateValue = [NSDate date];
            _setstartdatecheck.state = false;
        }
        if (_selecteditem[@"reading_end"]  && _selecteditem[@"reading_end"] != [NSNull null]) {
            _enddatepicker.dateValue = [dateformat dateFromString:[(NSString *)_selecteditem[@"reading_end"] substringToIndex:10]];
            _setenddatecheck.state = true;
        }
        else {
            _enddatepicker.dateValue = [NSDate date];
            _setenddatecheck.state = false;
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
@end
