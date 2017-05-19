//
//  ListStatistics.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/05/19.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import "ListStatistics.h"
#import "ratingchartview.h"
#import "Utility.h"

@interface ListStatistics ()
@property (strong) ratingchartview *ratingstats;
@property (strong) IBOutlet NSTextField *dayspentanime;
@property (strong) ratingchartview *mangastats;
@property (strong) IBOutlet NSTextField *daysspentonmanga;
@property (strong) IBOutlet NSView *mangastatsview;
@property (strong) IBOutlet NSView *animestatsview;

@end

@implementation ListStatistics

- (instancetype)init{
    self = [super initWithWindowNibName:@"ListStatistics"];
    _ratingstats = [ratingchartview new];
    _mangastats = [ratingchartview new];
    if (!self)
        return nil;
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [_animestatsview addSubview:_ratingstats.view];
    [_mangastatsview addSubview:_mangastats.view];
    _ratingstats.view.frame = _animestatsview.frame;
    [_ratingstats.view setFrameOrigin:NSMakePoint(0, 0)];
    _mangastats.view.frame = _mangastatsview.frame;
    [_mangastats.view setFrameOrigin:NSMakePoint(0, 0)];
}

-(void)populateValues {
    if ([Utility checkifFileExists:@"animelist.json" appendPath:@""]) {
        NSDictionary *anime = [Utility loadJSON:@"animelist.json" appendpath:@""];
        [_ratingstats populateView:anime[@"anime"]];
        _dayspentanime.stringValue = anime[@"statistics"][@"days"];
    }
    if ([Utility checkifFileExists:@"mangalist.json" appendPath:@""]) {
        NSDictionary *manga = [Utility loadJSON:@"mangalist.json" appendpath:@""];
        [_mangastats populateView:manga[@"manga"]];
        _daysspentonmanga.stringValue = manga[@"statistics"][@"days"];
    }
}

@end
