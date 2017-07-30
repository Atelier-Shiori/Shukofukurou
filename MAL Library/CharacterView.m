//
//  CharacterView.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/07/26.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "CharacterView.h"
#import "Utility.h"
#import "MainWindow.h"
#import "AppDelegate.h"
#import "NSTableViewAction.h"

@interface CharacterView ()
@property (strong) IBOutlet NSTextField *charactername;
@property (strong) IBOutlet NSTextView *details;
@property (strong) IBOutlet NSTextField *tableview_first_heading;
@property (strong) IBOutlet NSBox *tableview_first_line;
@property (strong) IBOutlet NSImageView *posterimage;
@property (weak) MainWindow *mw;
@property (strong) IBOutlet NSPopUpButton *popupfilter;
@property (strong) IBOutlet NSArrayController *arraycontroller;
@property (strong) IBOutlet NSTableViewAction *tb;
@end

@implementation CharacterView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _mw = [((AppDelegate *)[NSApplication sharedApplication].delegate) getMainWindowController];
}

- (void)populateCharacterInfo:(NSDictionary *)d withTitle:(NSString *)title {
    _charactername.stringValue = d[@"name"];
    _posterimage.image = [Utility loadImage:[NSString stringWithFormat:@"%@.jpg",[[(NSString *)d[@"image"] stringByReplacingOccurrencesOfString:@"https://myanimelist.cdn-dena.com/images/" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@"-"]] withAppendPath:@"imgcache" fromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",d[@"image"]]]];
    _details.string = [NSString stringWithFormat:@"%@ character from %@. View more details on MyAnimeList.", d[@"role"], title];
    _selectedid = ((NSNumber *)d[@"id"]).intValue;
    _persontype = PersonCharacter;
    [self clearArrayController];
    _tableview_first_heading.stringValue = @"Voice Actors";
    if (d[@"actors"]) {
        [self populatetableview:d[@"actors"] type:actors];
    }
    _popupfilter.hidden = YES;
    [self reloadtableview];
    
}
- (void)clearArrayController {
    NSMutableArray *a = [_arraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
}

- (void)populatetableview:(NSArray *)arraycontent type:(int)arraytype {
    NSMutableArray *tmparray = [NSMutableArray new];
    for (NSDictionary *d in arraycontent) {
        switch (arraytype) {
            case actors: {
                [tmparray addObject:@{@"id":d[@"id"],@"image":d[@"image"],@"title":[NSString stringWithFormat:@"%@\n%@",d[@"name"],d[@"language"]]}];
                break;
            }
            default: {
                break;
            }
        }
    }
    if (tmparray.count > 0) {
        [_arraycontroller addObjects:tmparray];
    }
}

- (void)reloadtableview {
    [_tb reloadData];
    [_tb deselectAll:self];
}
@end
