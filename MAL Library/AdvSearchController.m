//
//  AdvSearchController.m
//  Shukofukurou
//
//  Created by 香風智乃 on 5/7/19.
//  Copyright © 2019 Atelier Shiori. All rights reserved.
//

#import "AdvSearchController.h"
#import "listservice.h"

@interface AdvSearchController ()
@property (strong) IBOutlet NSView *mangaadvsearchview;
@property (strong) IBOutlet NSView *animeadvsearchview;
@property (strong) IBOutlet NSMenu *kitsumangaformat;
@property (strong) IBOutlet NSMenu *animeformat;
@property (strong) IBOutlet NSMenu *kitsustatus;
@property (strong) IBOutlet NSMenu *anilistformat;
@property (strong) IBOutlet NSMenu *aniliststatus;

@property (strong) IBOutlet NSPopUpButton *mangastatuspopover;
@property (strong) IBOutlet NSPopUpButton *mangaformatpopover;

@property (strong) IBOutlet NSPopUpButton *animefromyear;
@property (strong) IBOutlet NSPopUpButton *animetoyear;
@property (strong) IBOutlet NSPopUpButton *animeseasonpopover;
@property (strong) IBOutlet NSPopUpButton *animestatus;
@property (strong) IBOutlet NSPopUpButton *animeformatpopover;
@end

@implementation AdvSearchController

- (instancetype)init {
    return [super initWithNibName:@"AdvSearchController" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self generateYearMenu:_animetoyear];
    [self generateYearMenu:_animefromyear];
    _currentadvsearch = -1;
}

- (void)loadViewForType:(int)type {
    if (_currentadvsearch == type && _currentlistservice == [listservice.sharedInstance getCurrentServiceID]) {
        return;
    }
    _currentadvsearch = type;
    _currentlistservice = [listservice.sharedInstance getCurrentServiceID];
    if (type == 0) {
        _animeadvsearchview.hidden = NO;
        _mangaadvsearchview.hidden = YES;
        switch (_currentlistservice) {
            case 2:
                _animeformatpopover.menu = _animeformat;
                _animestatus.menu = _kitsustatus;
                break;
            case 3:
                _animeformatpopover.menu = _animeformat;
                _animestatus.menu = _aniliststatus;
                break;
            default:
                break;
        }
    }
    else {
        _animeadvsearchview.hidden = YES;
        _mangaadvsearchview.hidden = NO;
        switch (_currentlistservice) {
            case 2:
                _mangaformatpopover.menu = _kitsumangaformat;
                _mangastatuspopover.menu = _kitsustatus;
                break;
            case 3:
                _mangaformatpopover.menu = _anilistformat;
                _mangastatuspopover.menu = _aniliststatus;
                break;
            default:
                break;
        }
    }
}

- (IBAction)reset:(id)sender {
    if (_currentadvsearch == 0) {
        [self resetanime];
    }
    else {
        [self resetmanga];
    }
}

- (void)resetanime {
    [_animefromyear selectItemAtIndex:0];
    [_animetoyear selectItemAtIndex:0];
    [_animeseasonpopover selectItemAtIndex:0];
    [_animestatus selectItemAtIndex:0];
    [_animeformatpopover selectItemAtIndex:0];
    _animeadvsearchoptions = nil;
}

- (void)resetmanga {
    [_mangastatuspopover selectItemAtIndex:0];
    [_mangaformatpopover selectItemAtIndex:0];
    _mangaadvsearchoptions = nil;
}

- (void)generateYearMenu:(NSPopUpButton *)popupbutton {
    [popupbutton addItemWithTitle:@"-"];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    int currentyear = 1990;
    while (currentyear <= components.year) {
        [popupbutton addItemWithTitle:@(currentyear).stringValue];
        currentyear++;
    }
    [popupbutton selectItemAtIndex:0];
}

- (void)generateadvsearchdictionary {
    NSMutableDictionary *tmpdict = [NSMutableDictionary new];
    if (_currentadvsearch == 0) {
        switch ([listservice.sharedInstance getCurrentServiceID]) {
            case 2:
                //_animeadvsearchoptions = @{@"season" : self.animeseasonpopover.title, @"subtype" : self.animeformat.title, @"status" : _kitsustatus.title, @"seasonYear" : }
                if (![_animeseasonpopover.title isEqualToString:@"No Selection"]) {
                    tmpdict[@"season"] = _animeseasonpopover.title.lowercaseString;
                }
                if (![_animeformatpopover.title isEqualToString:@"No Selection"]) {
                    tmpdict[@"subtype"] = _animeformatpopover.title;
                }
                if (![_animestatus.title isEqualToString:@"No Selection"]) {
                    tmpdict[@"status"] = _animestatus.title.lowercaseString;
                }
                if (![_animefromyear.title isEqualToString:@"-"]) {
                    int fromyear = _animefromyear.title.intValue;
                    int toyear;
                    if ([_animetoyear.title isEqualToString:@"-"]) {
                        toyear = [self currentYear];
                    }
                    else {
                        toyear = _animetoyear.title.intValue;
                    }
                    if (fromyear <= toyear) {
                        NSMutableArray *yeararray = [NSMutableArray new];
                        for (int i = fromyear; i <= toyear; i++) {
                            [yeararray addObject:@(i).stringValue];
                        }
                        tmpdict[@"seasonYear"] = [yeararray componentsJoinedByString:@","];
                    }
                }
                _animeadvsearchoptions = tmpdict;
                break;
            case 3:
                if (![_animeseasonpopover.title isEqualToString:@"No Selection"]) {
                    tmpdict[@"season"] = _animeseasonpopover.title.uppercaseString;
                }
                if (![_animeformatpopover.title isEqualToString:@"No Selection"]) {
                    tmpdict[@"format"] = [_animeformatpopover.title.uppercaseString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                }
                if (![_animestatus.title isEqualToString:@"No Selection"]) {
                    tmpdict[@"status"] = [_animestatus.title.uppercaseString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                }
                if (![_animefromyear.title isEqualToString:@"-"]) {
                    int fromyear = _animefromyear.title.intValue;
                    int toyear;
                    if ([_animetoyear.title isEqualToString:@"-"]) {
                        toyear = [self currentYear];
                    }
                    else {
                        toyear = _animetoyear.title.intValue;
                    }
                    if (fromyear <= toyear) {
                        int startdate = [NSString stringWithFormat:@"%i0101", fromyear].intValue;
                        int enddate = [NSString stringWithFormat:@"%i0101", toyear].intValue;
                        tmpdict[@"startDate_greater"] = @(startdate);
                        tmpdict[@"endDate_lesser"] = @(enddate);
                    }
                }
                _animeadvsearchoptions = tmpdict;
                break;
            default:
                break;
        }
    }
    else {
        switch ([listservice.sharedInstance getCurrentServiceID]) {
            case 2:
                //_animeadvsearchoptions = @{@"season" : self.animeseasonpopover.title, @"subtype" : self.animeformat.title, @"status" : _kitsustatus.title, @"seasonYear" : }
                if (![_mangaformatpopover.title isEqualToString:@"No Selection"]) {
                    tmpdict[@"subtype"] = _mangaformatpopover.title.lowercaseString;
                }
                if (![_mangastatuspopover.title isEqualToString:@"No Selection"]) {
                    tmpdict[@"status"] = _mangastatuspopover.title.lowercaseString;
                }
                _mangaadvsearchoptions = tmpdict;
                break;
            case 3:
                if (![_mangaformatpopover.title isEqualToString:@"No Selection"]) {
                    tmpdict[@"format"] = [_mangaformatpopover.title.uppercaseString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                }
                if (![_mangastatuspopover.title isEqualToString:@"No Selection"]) {
                    tmpdict[@"status"] = [_mangastatuspopover.title.uppercaseString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                }
                _mangaadvsearchoptions = tmpdict;
                break;
            default:
                break;
        }
    }
}

- (int)currentYear {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    return (int)components.year;
}

- (NSDictionary *)getAdvSearchOptionsForType:(int)type {
    if (type == 0) {
        if (_currentlistservice != [listservice.sharedInstance getCurrentServiceID]) {
            _animeadvsearchoptions = nil;
        }
        return _animeadvsearchoptions;
    }
    else {
        if (_currentlistservice != [listservice.sharedInstance getCurrentServiceID]) {
            _mangaadvsearchoptions = nil;
        }
        return _mangaadvsearchoptions;
    }
}
@end
