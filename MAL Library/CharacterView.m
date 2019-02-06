//
//  CharacterView.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/07/26.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "CharacterView.h"
#import "CharactersBrowser.h"
#import "Utility.h"
#import "MainWindow.h"
#import "AppDelegate.h"
#import "NSTableViewAction.h"
#import "NSString_stripHtml.h"
#import "listservice.h"
#import "TitleIdConverter.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface CharacterView ()
@property (strong) IBOutlet NSTextView *details;
@property (strong) IBOutlet NSTextField *tableview_first_heading;
@property (strong) IBOutlet NSBox *tableview_first_line;
@property (strong) IBOutlet NSImageView *posterimage;
@property (weak) MainWindow *mw;
@property (strong) IBOutlet NSPopUpButton *popupfilter;
@property (strong) IBOutlet NSArrayController *arraycontroller;
@property (strong) IBOutlet NSTableViewAction *tb;
@property (strong) IBOutlet NSButton *viewhomepage;
@property (strong) IBOutlet NSMenuItem *filtervoiceactingroles;
@property (strong) IBOutlet NSMenuItem *filterstaffpositions;
@property (strong) IBOutlet NSMenuItem *filterpublishedmanga;
@property (strong) IBOutlet NSMenuItem *filtervoiceactors;
@property (strong) IBOutlet NSMenuItem *filteranimeappearences;
@property (strong) IBOutlet NSMenuItem *filtermangaappearences;
@end

@implementation CharacterView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _mw = ((AppDelegate *)[NSApplication sharedApplication].delegate).mainwindowcontroller;
}

- (void)populateStaffInformation:(NSDictionary *)d {
    NSMutableString *tmpstr = [NSMutableString new];
    _charactername.stringValue = d[@"name"];
    [self loadPosterImageWithURL:d[@"image_url"]];
    if (d[@"native_name"]) {
        [tmpstr appendFormat:@"Native name: %@\n",d[@"native_name"]];
        _nativename = d[@"native_name"];
    }
    else if (d[@"given_name"] && d[@"family_name"]) {
        [tmpstr appendFormat:@"%@, %@\n",d[@"family_name"], d[@"given_name"]];
        _nativename = [NSString stringWithFormat:@"%@ %@\n",d[@"family_name"], d[@"given_name"]];
    }
    else {
        _nativename = @"";
    }
    if (((NSArray *)d[@"alternate_names"]).count > 0 ) {
        [tmpstr appendFormat:@"Other Names: %@\n",[Utility appendstringwithArray:d[@"alternate_names"]]];
    }
    if (d[@"birthday"]) {
        [tmpstr appendFormat:@"Birthday: %@\n",d[@"birthday"]];
    }
    if (d[@"more_details"]) {
        [tmpstr appendFormat:@"%@\n",[(NSString *)d[@"more_details"] stripHtml]];
    }
    if (d[@"favorited_count"]) {
        [tmpstr appendFormat:@"Favorited: %@\n",d[@"favorited_count"]];
    }
    if (d[@"website_url"]) {
        if (((NSString *)d[@"website_url"]).length > 0){
            _personhomepage = d[@"website_url"];
            _viewhomepage.hidden = NO;
        }
    }
    else {
        _personhomepage = @"";
        _viewhomepage.hidden = YES;
    }
    _details.string = tmpstr;
    _details.textColor = NSColor.controlTextColor;
    _selectedid = ((NSNumber *)d[@"id"]).intValue;
    [self clearArrayController];
    _tableview_first_heading.stringValue = @"Positions";
    switch (self.persontype) {
        case PersonStaff:
            _filtervoiceactors.hidden = true;
            _filteranimeappearences.hidden = true;
            _filtermangaappearences.hidden = true;
            [self populatetableview:d[@"voice_acting_roles"] type:voiceactingroles];
            [self populatetableview:d[@"anime_staff_positions"] type:staffpositions];
            [self populatetableview:d[@"published_manga"] type:publishedmanga];
            break;
        case PersonCharacter:
            _filterstaffpositions.hidden = true;
            _filtervoiceactingroles.hidden = true;
            _filterpublishedmanga.hidden = true;
            [self populatetableview:d[@"actors"] type:actors];
            [self populatetableview:d[@"appeared_anime"] type:appearedanime];
            [self populatetableview:d[@"appeared_manga"] type:appearedmanga];
            break;
        default:
            break;
    }

    _popupfilter.hidden = NO;
    [self reloadtableview];
    [_popupfilter selectItemAtIndex:[self getNonHiddenFilterIndex]];
    [self filtertableview];
}

- (void)clearArrayController {
    NSMutableArray *a = [_arraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    _arraycontroller.filterPredicate = nil;
}

- (void)populatetableview:(NSArray *)arraycontent type:(int)arraytype {
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *d in arraycontent) {
        switch (arraytype) {
            case actors: {
                [tmparray addObject:@{@"id":d[@"id"],@"image":d[@"image"],@"title":[NSString stringWithFormat:@"%@\n%@",d[@"name"],d[@"language"]], @"type" : @"Voice Actors"}];
                break;
            }
            case appearedmanga:
            case appearedanime:
                [tmparray addObject:@{@"id":d[@"id"],@"image":d[@"image"],@"title":[NSString stringWithFormat:@"%@\n%@",d[@"title"],d[@"role"]], @"type" : arraytype == appearedanime ? @"Anime Appearences" : @"Manga Appearences"}];
                break;
            case staffpositions: {
                [tmparray addObject:@{@"id":d[@"anime"][@"id"],@"image":d[@"anime"][@"image_url"],@"title":[NSString stringWithFormat:@"%@\n%@",d[@"anime"][@"title"],d[@"position"]], @"type":@"Staff Positions"}];
                break;
            }
            case voiceactingroles: {
                NSString * role;
                if (((NSNumber *)d[@"main_role"]).boolValue) {
                    role = @"Main role";
                }
                else {
                    role = @"Supporting role";
                }
                [tmparray addObject:@{@"id":d[@"id"],@"image":d[@"image_url"],@"title":[NSString stringWithFormat:@"%@\n%@\n%@",d[@"name"],d[@"anime"][@"title"],role], @"type":@"Voice Acting Roles"}];
                break;
            }
            case publishedmanga: {
                [tmparray addObject:@{@"id":d[@"manga"][@"id"],@"image":d[@"manga"][@"image_url"],@"title":[NSString stringWithFormat:@"%@\n%@",d[@"manga"][@"title"],d[@"position"]], @"type":@"Published Manga"}];
                break;
            }
            default: {
                break;
            }
        }
    }
    if (tmparray.count > 0) {
        [_arraycontroller addObjects:tmparray];
        [self addremovefilter:arraytype hide:false];
    }
    else {
        [self addremovefilter:arraytype hide:true];
    }
}

- (void)addremovefilter:(int)type hide:(bool)hide {
    switch (type) {
        case actors: {
            _filtervoiceactors.hidden = hide;
            break;
        }
        case appearedanime: {
            _filteranimeappearences.hidden = hide;
            break;
        }
        case appearedmanga: {
            _filtermangaappearences.hidden = hide;
            break;
        }
        case staffpositions: {
            _filterstaffpositions.hidden = hide;
            break;
        }
        case voiceactingroles: {
            _filtervoiceactingroles.hidden = hide;
        }
        case publishedmanga: {
            _filterpublishedmanga.hidden = hide;
        }
        default: {
            break;
        }
    }
}

- (int)getNonHiddenFilterIndex {
    if (!_filtervoiceactingroles.hidden) {
        return 0;
    }
    else if (!_filterstaffpositions.hidden) {
        return 1;
    }
    else if (!_filterpublishedmanga.hidden) {
        return 2;
    }
    else if (!_filtervoiceactors.hidden) {
        return 3;
    }
    else if (!_filteranimeappearences.hidden) {
        return 4;
    }
    else if (!_filtermangaappearences.hidden) {
        return 5;
    }
    return 0;
}

- (void)reloadtableview {
    [_tb reloadData];
    [_tb deselectAll:self];
}

- (void)filtertableview {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type ==[cd] %@",_popupfilter.selectedItem.title];
    _arraycontroller.filterPredicate = predicate;
}

- (IBAction)performfilter:(id)sender {
    [self filtertableview];
}

- (IBAction)tbdoubleclick:(id)sender {
    if (_tb.selectedRow >=0){
        if (_tb.selectedRow >-1){
            NSDictionary *d = _arraycontroller.selectedObjects[0];
            if (_persontype == PersonCharacter) {
                if ([(NSString *)d[@"type"] isEqualToString:@"Voice Actors"]) {
                    [_cb retrievestaffinformation:((NSNumber *)d[@"id"]).intValue];
                }
                else {
                    int loadtype = [(NSString *)d[@"type"] isEqualToString:@"Anime Appearences"] ? 0 : 1;
                    [NSNotificationCenter.defaultCenter postNotificationName:@"LoadTitleInfo" object:@{@"id" : d[@"id"], @"type" : @(loadtype)}];
                }
            }
            else {
                int loadtype = [(NSString *)d[@"type"] isEqualToString:@"Published Manga"] ? 1 : 0;
                switch ([listservice getCurrentServiceID]) {
                    case 1:
                    case 3:
                        [_cb retrievecharacterinformation:((NSNumber *)d[@"id"]).intValue];
                        break;
                    case 2: {
                        [MyAnimeList retrieveTitleInfo:((NSNumber *)d[@"id"]).intValue withType:loadtype useAccount:NO completion:^(id responseObject) {
                            [TitleIdConverter getKitsuIDFromMALId:((NSNumber *)d[@"id"]).intValue withTitle:responseObject[@"title"] titletype:responseObject[@"type"] withType:loadtype completionHandler:^(int kitsuid) {
                                [NSNotificationCenter.defaultCenter postNotificationName:@"LoadTitleInfo" object:@{@"id" : @(kitsuid), @"type" : @(loadtype)}];
                            } error:^(NSError *error) {}];
                        } error:^(NSError *error) {
                            
                        }];
                    }
                    default:
                        break;
                }
            }
        }
    }
}

- (IBAction)openhomepage:(id)sender {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:_personhomepage]];
}

- (void)cleanup {
    [_arraycontroller.content removeAllObjects];
    [_tb reloadData];
    _selectedid = 0;
    _persontype = 0;
    _details.string = @"";
    _charactername.stringValue = @"";
    _posterimage.image = nil;
}

- (void)loadPosterImageWithURL:(NSString *)url {
    if (url.length > 0) {
        [_posterimage sd_setImageWithURL:[NSURL URLWithString:url]];
    }
    else {
        _posterimage.image = [NSImage imageNamed:@"noimage"];
    }
}
@end
