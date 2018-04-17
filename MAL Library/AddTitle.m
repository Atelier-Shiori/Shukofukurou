//
//  AddTitle.m
//  Shukofukuro
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "AddTitle.h"
#import "AniListScoreConvert.h"
#import "MainWindow.h"
//#import "MyAnimeList.h"
#import "listservice.h"
#import "Utility.h"

@interface AddTitle ()
@property (strong) IBOutlet NSView *popoveraddtitleexistsview;
// Anime
@property (strong) IBOutlet NSView *addtitleview;
@property (strong) IBOutlet NSTextField *addepifield;
@property (strong) IBOutlet NSNumberFormatter *addnumformat;
@property (strong) IBOutlet NSTextField *addtotalepisodes;
@property (strong) IBOutlet NSPopUpButton *addscorefiled;
@property (strong) IBOutlet NSNumberFormatter *addscorefieldformat;
@property (strong) IBOutlet NSTextField *addadvancedscore;
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
@property (strong) IBOutlet NSTextField *addmangaadvancescorefield;
@property (strong) IBOutlet NSNumberFormatter *addmangaadvancescoreformat;
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
    [self setScoreMenu:type];
    if (type == 0) {
        if (![_mw checkiftitleisonlist:idnum.intValue type:0]) {
            // Set Score Menu
            [self.view replaceSubview:(self.view.subviews)[0] with:_addtitleview];
                _selecteditem = d;
            if (((NSNumber *)d[@"episodes"]).intValue > 0) {
                _addnumformat.maximum = d[@"episodes"];
            }
            else {
                _addnumformat.maximum = @(9999999);
            }
            _addepstepper.maxValue = _addnumformat.maximum.doubleValue;
            if (d[@"status"]) {
                [self checkStatus:d[@"status"] type:type];
            }
            else if (d[@"start_date"]||d[@"end_date"]) {
                [self checkStatus:[Utility statusFromDateRange:d[@"start_date"] toDate:d[@"end_date"]] type:type];
            }
            else {
                [listservice retrieveTitleInfo:idnum.intValue withType:MALAnime useAccount:NO completion:^(id responseObject) {
                    NSDictionary *titleinfo = responseObject;
                    [self checkStatus:titleinfo[@"status"] type: 0];
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
                _addchapnumformat.maximum = @(9999999);
            }
            if (((NSNumber *)d[@"volumes"]).intValue > 0) {
                _addvolnumformat.maximum = d[@"chapters"];
            }
            else {
                _addvolnumformat.maximum = @(9999999);
            }
            _addchapstepper.maxValue = _addchapnumformat.maximum.doubleValue;
            _addvolstepper.maxValue = _addvolnumformat.maximum.doubleValue;
            if (_selecteditem[@"status"]) {
                [self checkStatus:_selecteditem[@"status"] type:1];
            }
            else {
                [listservice retrieveTitleInfo:idnum.intValue withType:MALManga useAccount:NO completion:^(id responseObject) {
                    NSDictionary *titleinfo = responseObject;
                    [self checkStatus:titleinfo[@"status"] type: MALManga];
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
        if ([_addstatusfield.title isEqual:@"completed"] && _addtotalepisodes.intValue != 0 && _addepifield.intValue != _addtotalepisodes.intValue && _selectedaircompleted) {
            _addepifield.stringValue = _addtotalepisodes.stringValue;
        }
        int score = 0;
        switch ([listservice getCurrentServiceID]) {
            case 1:
            case 2:
                score = (int)_addscorefiled.selectedTag;
                break;
            case 3: {
                NSString *scoretype = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-scoreformat"];
                if ([scoretype isEqualToString:@"POINT_100"] || [scoretype isEqualToString:@"POINT_10_DECIMAL"]) {
                    score = [AniListScoreConvert convertScoretoScoreRaw:_addadvancedscore.doubleValue withScoreType:scoretype];
                }
                else {
                    score = [AniListScoreConvert convertScoretoScoreRaw:_addscorefiled.selectedTag withScoreType:scoretype];
                }
            }
        }
        _addpopover.behavior = NSPopoverBehaviorApplicationDefined;
        [listservice addAnimeTitleToList:_selectededitid withEpisode:_addepifield.intValue withStatus:_addstatusfield.title withScore:score completion:^(id responseObject) {
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
        [listservice addMangaTitleToList:_selectededitid withChapter:_addchapfield.intValue withVolume:_addvolfield.intValue withStatus:_addmangastatusfield.title withScore:(int)_addmangascorefiled.selectedTag completion:^(id responseData) {
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
        if ((stepper.intValue <= totalsegment || totalsegment == 0) && stepper.intValue >= 0) {
            segment = stepper.intValue;
            _addepifield.stringValue = [NSString stringWithFormat:@"%i",segment];
        }
        else {
            stepper.intValue = segment;
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
        
        if ((stepper.intValue <= totalsegment || totalsegment == 0) && stepper.intValue >= 0) {
            segment = stepper.intValue;
            if ([segmenttype isEqualToString:@"chapters"]) {
                _addchapfield.stringValue = [NSString stringWithFormat:@"%i",segment];
            }
            else {
                _addvolfield.stringValue = [NSString stringWithFormat:@"%i",segment];
            }
        }
        else {
            stepper.intValue = segment;
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
- (void)setScoreMenu:(int)type {
    if (type == 0) {
        switch ([listservice getCurrentServiceID]) {
            case 1:
                _addadvancedscore.hidden = true;
                _addscorefiled.hidden = false;
                _addscorefiled.menu = _malscoremenu;
                break;
            case 2: {
                _addadvancedscore.hidden = true;
                _addscorefiled.hidden = false;
                switch ([NSUserDefaults.standardUserDefaults integerForKey:@"kitsu-ratingsystem"]) {
                    case 0:
                        _addscorefiled.menu = _kitsusimplescoremenu;
                        break;
                    case 1:
                        _addscorefiled.menu = _kitsustandardscoremenu;
                        break;
                    case 2:
                        _addscorefiled.menu = _kitsuadvancedscoremenu;
                        break;
                    default:
                        break;
                }
            }
            case 3: {
                NSString *scoretype = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-scoreformat"];
                if ([scoretype isEqualToString:@"POINT_100"] || [scoretype isEqualToString:@"POINT_10_DECIMAL"]) {
                    _addadvancedscore.hidden = false;
                    _addscorefiled.hidden = true;
                    if ([scoretype isEqualToString:@"POINT_100"]) {
                        _addscorefieldformat.maximum = @(100);
                    }
                    else {
                        _addscorefieldformat.maximum = @(10);
                    }
                    _addadvancedscore.intValue = 0;
                }
                else {
                    _addadvancedscore.hidden = true;
                    _addscorefiled.hidden = false;
                    if ([scoretype isEqualToString:@"POINT_10"]) {
                        _addscorefiled.menu = _malscoremenu;
                    }
                    else if ([scoretype isEqualToString:@"POINT_5"]) {
                        _addscorefiled.menu = _AniListFiveScoreMenu;
                    }
                    else if ([scoretype isEqualToString:@"POINT_3"]) {
                        _addscorefiled.menu = _AniListThreeScoreMenu;
                    }
                }
            }
            default:
                break;
        }
    }
    else {
        switch ([listservice getCurrentServiceID]) {
            case 1:
                _addmangaadvancescorefield.hidden = true;
                _addmangascorefiled.hidden = false;
                _addmangascorefiled.menu = _malscoremenu;
                break;
            case 2: {
                _addmangaadvancescorefield.hidden = true;
                _addmangascorefiled.hidden = false;
                switch ([NSUserDefaults.standardUserDefaults integerForKey:@"kitsu-ratingsystem"]) {
                    case 0:
                        _addmangascorefiled.menu = _kitsusimplescoremenu;
                        break;
                    case 1:
                        _addmangascorefiled.menu = _kitsustandardscoremenu;
                        break;
                    case 2:
                        _addmangascorefiled.menu = _kitsuadvancedscoremenu;
                        break;
                    default:
                        break;
                }
            }
            case 3: {
                NSString *scoretype = [NSUserDefaults.standardUserDefaults valueForKey:@"anilist-scoreformat"];
                if ([scoretype isEqualToString:@"POINT_100"] || [scoretype isEqualToString:@"POINT_10_DECIMAL"]) {
                    _addmangaadvancescorefield.hidden = false;
                    _addmangascorefiled.hidden = true;
                    if ([scoretype isEqualToString:@"POINT_100"]) {
                        _addmangaadvancescoreformat.maximum = @(100);
                    }
                    else {
                        _addmangaadvancescoreformat.maximum = @(10);
                    }
                    _addmangaadvancescorefield.intValue = 0;
                }
                else {
                    _addmangaadvancescorefield.hidden = true;
                    _addmangascorefiled.hidden = false;
                    if ([scoretype isEqualToString:@"POINT_10"]) {
                        _addmangascorefiled.menu = _malscoremenu;
                    }
                    else if ([scoretype isEqualToString:@"POINT_5"]) {
                        _addmangascorefiled.menu = _AniListFiveScoreMenu;
                    }
                    else if ([scoretype isEqualToString:@"POINT_3"]) {
                        _addmangascorefiled.menu = _AniListThreeScoreMenu;
                    }
                }
            }

            default:
                break;
        }
    }
}
@end
