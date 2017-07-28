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

@interface CharacterView ()
@property (strong) IBOutlet NSTextField *charactername;
@property (strong) IBOutlet NSTextView *details;
@property (strong) IBOutlet NSTextField *tableview_first_heading;
@property (strong) IBOutlet NSBox *tableview_first_line;
@property (strong) IBOutlet NSTextField *tableview_second_heading;
@property (strong) IBOutlet NSBox *tableview_second_line;
@property (strong) IBOutlet NSImageView *posterimage;
@property (weak) MainWindow *mw;
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
    _tableview_first_line.hidden = true;
    _tableview_first_heading.hidden = true;
    _tableview_second_line.hidden = true;
    _tableview_second_heading.hidden = true;
    _selectedid = ((NSNumber *)d[@"id"]).intValue;
    _persontype = PersonCharacter;
}

@end
