//
//  InfoView.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "InfoView.h"
#import "MainWindow.h"
#import "Utility.h"
#import "NSString+HTMLtoNSAttributedString.h"

@interface InfoView ()
@property (strong) IBOutlet NSTextField *infoviewtitle;
@property (strong) IBOutlet NSTextField *infoviewalttitles;
@property (strong) IBOutlet NSImageView *infoviewposterimage;
@end

@implementation InfoView

- (id)init
{
    return [super initWithNibName:@"InfoView" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
-(void)populateInfoView:(id)object{
    NSDictionary * d = object;
    NSMutableString *titles = [NSMutableString new];
    NSMutableString *details = [NSMutableString new];
    NSMutableString *genres = [NSMutableString new];
    NSAttributedString *background;
    [_infoviewtitle setStringValue:d[@"title"]];
    NSDictionary * dtitles =  d[@"other_titles"];
    NSMutableArray * othertitles = [NSMutableArray new];
    if (dtitles[@"english"] != nil){
        NSArray * e = dtitles[@"english"];
        for (NSString * etitle in e){
            [othertitles addObject:etitle];
        }
    }
    if (dtitles[@"japanese"] != nil){
        NSArray * j = dtitles[@"japanese"];
        for (NSString * jtitle in j){
            [othertitles addObject:jtitle];
        }
    }
    if (dtitles[@"synonyms"] != nil){
        NSArray * syn = dtitles[@"synonyms"];
        for (NSString * stitle in syn){
            [othertitles addObject:stitle];
        }
    }
    [titles appendString:[Utility appendstringwithArray:othertitles]];
    [_infoviewalttitles setStringValue:titles];
    if (d[@"genres"]!= nil){
        NSArray * genresa = d[@"genres"];
        [genres appendString:[Utility appendstringwithArray:genresa]];
    }
    else{
        [genres appendString:@"None"];
    }
    if (d[@"background"] != nil){
        background = [(NSString *)d[@"background"] convertHTMLtoAttStr];
    }
    else {
        background = [[NSAttributedString alloc] initWithString:@"None available"];
    }
    NSString * type = d[@"type"];
    NSNumber * score = d[@"members_score"];
    NSNumber * popularity = d[@"popularity_rank"];
    NSNumber * memberscount = d[@"members_count"];
    NSNumber *rank = d[@"rank"];
    NSNumber * favorites = d[@"favorited_count"];
    NSImage * posterimage = [Utility loadImage:[NSString stringWithFormat:@"%@.jpg",d[@"id"]] withAppendPath:@"imgcache" fromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",d[@"image_url"]]]];
    [_infoviewposterimage setImage:posterimage];
    [details appendString:[NSString stringWithFormat:@"Type: %@\n", type]];
    if (d[@"episodes"] == nil){
        if (d[@"duration"] == nil){
            [details appendString:@"Episodes: Unknown\n"];
        }
        else{
            [details appendString:[NSString stringWithFormat:@"Episodes: Unknown (%i mins per episode)\n", [(NSNumber *)d[@"duration"] intValue]]];
        }
    }
    else {
        if (d[@"duration"] == nil){
            [details appendString:[NSString stringWithFormat:@"Episodes: %i\n", [(NSNumber *)d[@"episodes"] intValue]]];
        }
        else{
            [details appendString:[NSString stringWithFormat:@"Episodes: %i (%i mins per episode)\n", [(NSNumber *)d[@"episodes"] intValue], [(NSNumber *)d[@"duration"] intValue]]];
        }
    }
    [details appendString:[NSString stringWithFormat:@"Status: %@\n", d[@"status"]]];
    [details appendString:[NSString stringWithFormat:@"Genre: %@\n", genres]];
    if (d[@"classification"] != nil){
        [details appendString:[NSString stringWithFormat:@"Classification: %@\n", d[@"classification"]]];
    }
    if (d[@"members_score"]!=nil){
        [details appendString:[NSString stringWithFormat:@"Score: %f (%i users, ranked %i)\n", score.floatValue, memberscount.intValue, rank.intValue]];
    }
    [details appendString:[NSString stringWithFormat:@"Popularity: %i\n", popularity.intValue]];
    [details appendString:[NSString stringWithFormat:@"Favorited: %i times\n", favorites.intValue]];
    NSString * synopsis = d[@"synopsis"];
    [_infoviewdetailstextview setString:details];
    [[_infoviewsynopsistextview textStorage] setAttributedString:[synopsis convertHTMLtoAttStr]];
    [[_infoviewbackgroundtextview  textStorage] setAttributedString:background];
    [mw loadmainview];
    _selectedanimeinfo = d;
}
- (IBAction)viewonmal:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/anime/%i",_selectedid]]];
}

@end
