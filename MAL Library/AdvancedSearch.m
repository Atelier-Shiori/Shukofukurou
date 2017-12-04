//
//  AdvancedSearch.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "AdvancedSearch.h"
#import "NSTextFieldNumber.h"
#import "MainWindow.h"
#import "MyAnimeList.h"
#import "Utility.h"


@interface AdvancedSearch (){
    int searchtype;
}
    // Anime
    @property (strong) NSString *animekeyword;
    @property (strong) NSString *animegenre;
    @property long animeexclude;
    @property long animeusestartdate;
    @property long animeuseenddate;
    @property (strong) NSDate *animestartdate;
    @property (strong) NSDate *animeenddate;
    @property (strong) NSString *animescore;
    @property long animestatus;
    @property long animerating;
    // Manga
    @property (strong) NSString *mangakeyword;
    @property (strong) NSString *mangagenre;
    @property long mangaexclude;
    @property long mangausestartdate;
    @property long mangauseenddate;
    @property (strong) NSDate *mangastartdate;
    @property (strong) NSDate *mangaenddate;
    @property (strong) NSString *mangascore;
    @property long mangastatus;
    @property long mangarating;
@end

@implementation AdvancedSearch
- (instancetype)init {
    return [super initWithNibName:@"AdvancedSearch" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    // Set dates
    [self resetdate];
    [self setDefaultValues];
    [self view];
    [self setSearchType:searchtype];

}
- (void)setSearchType:(int)type {
    [self saveSearchValuesForType:searchtype];
    if (type == 0){
        _airstatus.menu = _animestatusmenu;
        [_airstatus selectItemAtIndex:0];
        _searchfield.stringValue = _animekeyword;
        _genretokenfield.stringValue = _animegenre;
        _exclude.state = _animeexclude;
        _usestartdate.state = _animeusestartdate;
        _useenddate.state = _animeuseenddate;
        _minscore.stringValue = _animescore;
        _startdate.dateValue = _animestartdate;
        _enddate.dateValue = _animeenddate;
        [_airstatus selectItemAtIndex:_animestatus];
        [_rating selectItemAtIndex:_animerating];
    }
    else {
        _airstatus.menu = _mangastatusmenu;
        [_airstatus selectItemAtIndex:0];
        _searchfield.stringValue = _mangakeyword;
        _genretokenfield.stringValue = _mangagenre;
        _exclude.state = _mangaexclude;
        _usestartdate.state = _mangausestartdate;
        _useenddate.state = _mangauseenddate;
        _minscore.stringValue = _mangascore;
        _startdate.dateValue = _mangastartdate;
        _enddate.dateValue = _mangaenddate;
        [_airstatus selectItemAtIndex:_mangastatus];
        [_rating selectItemAtIndex:_mangarating];
    }
    if (_airstatus.title.length == 0){
        [_airstatus setTitle:@"All"];
    }
    searchtype = type;
}
- (IBAction)performadvancedsearch:(id)sender {
    __block NSButton *btn = sender;
    _popover.behavior = NSPopoverBehaviorApplicationDefined;
    [btn setEnabled:NO];
    NSDate *startDate = nil;
    NSDate *endDate = nil;
    NSString *genreslist = @"";
    if (((NSArray *)_genretokenfield.objectValue).count > 0){
        genreslist = [(NSArray *)_genretokenfield.objectValue componentsJoinedByString:@","];
    }
    if (_usestartdate.state == 1){
        startDate = _startdate.dateValue;
    }
    if (_useenddate.state == 1){
        endDate = _enddate.dateValue;
    }
    [MyAnimeList advsearchTitle:_searchfield.stringValue withType:searchtype withGenres:genreslist excludeGenres:_exclude.state startDate:startDate endDate:endDate minScore:_minscore.intValue rating:(int)_rating.selectedTag withStatus:(int)_airstatus.selectedTag completion:^(id responseObject){
        [_mw populatesearchtb:responseObject type:searchtype];
        [btn setEnabled:YES];
        _popover.behavior = NSPopoverBehaviorTransient;
        [_popover close];
        [self saveSearchValuesForType:searchtype];
    }error:^(NSError *error){
        NSLog(@"Error: %@", error);
        [_mw clearsearchtb];
        [btn setEnabled:YES];
        _popover.behavior = NSPopoverBehaviorTransient;
        [_popover close];
        [self saveSearchValuesForType:searchtype];
    }];
}
- (IBAction)usedaterange:(id)sender {
    if (_usestartdate.state == 0){
        [_startdate setEnabled:NO];
    }
    else {
        [_startdate setEnabled:YES];
    }
    if (_useenddate.state == 0){
        [_enddate setEnabled:NO];
    }
    else {
        [_enddate setEnabled:YES];
    }
}
- (IBAction)resetfields:(id)sender {
    _searchfield.stringValue = @"";
    _genretokenfield.stringValue = @"";
    _exclude.state = 0;
    _usestartdate.state = 0;
    _useenddate.state = 0;
    [self usedaterange:sender];
    _minscore.stringValue = @"0";
    [self resetdate];
    [_airstatus selectItemAtIndex:0];
    [_rating selectItemAtIndex:0];
    [_mw clearsearchtb];
}
- (void)resetdate{
    _startdate.dateValue = [[NSDate alloc] initWithTimeIntervalSinceNow:-315360000]; // Last 10 years from today's date
    _enddate.dateValue = [NSDate date];
}
- (void)saveSearchValuesForType:(int)type {
    if (type == 0) {
        _animekeyword = _searchfield.stringValue;
        _animegenre = _genretokenfield.stringValue;
        _animeexclude = _exclude.state;
        _animeusestartdate = _usestartdate.state;
        _animeuseenddate = _useenddate.state;
        _animestartdate = _startdate.dateValue;
        _animeenddate = _enddate.dateValue;
        _animescore = _minscore.stringValue;
        _animestatus = _airstatus.indexOfSelectedItem;
        _animerating = _rating.indexOfSelectedItem;
    }
    else {
        _mangakeyword = _searchfield.stringValue;
        _mangagenre = _genretokenfield.stringValue;
        _mangaexclude = _exclude.state;
        _mangausestartdate = _usestartdate.state;
        _mangauseenddate = _useenddate.state;
        _mangastartdate = _startdate.dateValue;
        _mangaenddate = _enddate.dateValue;
        _mangascore = _minscore.stringValue;
        _mangastatus = _airstatus.indexOfSelectedItem;
        _mangarating = _rating.indexOfSelectedItem;
    }
}
- (void)setDefaultValues {
    _animekeyword = _searchfield.stringValue;
    _animegenre = _genretokenfield.stringValue;
    _animeexclude = _exclude.state;
    _animeusestartdate = _usestartdate.state;
    _animeuseenddate = _useenddate.state;
    _animestartdate = _startdate.dateValue;
    _animeenddate = _enddate.dateValue;
    _animescore = _minscore.stringValue;
    _animestatus = _airstatus.indexOfSelectedItem;
    _animerating = _rating.indexOfSelectedItem;
    _mangakeyword = _searchfield.stringValue;
    _mangagenre = _genretokenfield.stringValue;
    _mangaexclude = _exclude.state;
    _mangausestartdate = _usestartdate.state;
    _mangauseenddate = _useenddate.state;
    _mangastartdate = _startdate.dateValue;
    _mangaenddate = _enddate.dateValue;
    _mangascore = _minscore.stringValue;
    _mangastatus = _airstatus.indexOfSelectedItem;
    _mangarating = _rating.indexOfSelectedItem;
}
@end
