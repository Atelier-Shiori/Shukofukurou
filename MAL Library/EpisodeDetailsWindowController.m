//
//  EpisodeDetailsWindowController.m
//  Shukofukurou
//
//  Created by 香風智乃 on 12/4/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "EpisodeDetailsWindowController.h"
#import "EpisodeDetailViewController.h"
#import "listservice.h"
#import "Utility.h"

@interface EpisodeDetailsWindowController ()
@property (strong) IBOutlet NSVisualEffectView *loadingview;
@property (strong) IBOutlet NSProgressIndicator *progressindicator;
@property (strong) IBOutlet NSVisualEffectView *noselectionview;
@property (strong) IBOutlet EpisodeDetailViewController *episodedetailvc;
@property (strong) IBOutlet NSArrayController *arraycontroller;
@property (strong) IBOutlet NSSplitView *splitview;
@property (strong) IBOutlet NSTableView *tableview;
@property (strong) IBOutlet NSView *contentview;
@end

@implementation EpisodeDetailsWindowController

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)init {
    return [super initWithWindowNibName:@"EpisodeDetailsWindowController"];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    _loadingview.wantsLayer = YES;
    _loadingview.layer.cornerRadius = 15.0;
    [_noselectionview setFrameOrigin:NSMakePoint(0, 0)];
    [_episodedetailvc.view setFrameOrigin:NSMakePoint(0, 0)];
    _noselectionview.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    _episodedetailvc.view.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    
    [_contentview addSubview:_noselectionview];
    _noselectionview.frame = _contentview.frame;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recieveNotification:) name:@"TitleDetailsChanged" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recieveNotification:) name:@"ServiceChanged" object:nil];
}

- (void)recieveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"TitleDetailsChanged"] || [notification.name isEqualToString:@"ServiceChanged"]) {
        [self.window close];
    }
}

- (void)showloading:(bool)loading {
    if (loading) {
        _loadingview.hidden = NO;
        [_progressindicator startAnimation:self];
    }
    else {
        _loadingview.hidden = YES;
        [_progressindicator stopAnimation:self];
    }
}

- (void)loadEpisodeData:(int)titleid {
    [self showloading:YES];
    [_arraycontroller.content removeAllObjects];
    [_tableview reloadData];
    [Kitsu retrieveEpisodesList:titleid completion:^(id responseObject) {
        [_arraycontroller addObjects:responseObject];
        [_tableview reloadData];
        [_tableview deselectAll:self];
        [self showloading:NO];
    } error:^(NSError *error) {
        NSLog(@"Can't load episode details");
        [Utility showsheetmessage:@"Can't load episode details." explaination:error.localizedDescription window:self.window];
        [self showloading:NO];
    }];
}

#pragma mark splitview

- (void) splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
    if (splitView == _splitview)
    {
        CGFloat dividerPos = NSHeight((splitView.subviews[0]).frame);
        CGFloat height = NSHeight(splitView.frame);
        
        if (dividerPos < 0)
            dividerPos = 0;
        if (height - dividerPos < 300 + splitView.dividerThickness)
            dividerPos = height - (300 + splitView.dividerThickness);
        
        [splitView adjustSubviews];
        [splitView setPosition:dividerPos ofDividerAtIndex:0];
    }
}

- (CGFloat) splitView:(NSSplitView *) splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (splitView == _splitview)
    {
        CGFloat height = NSHeight(splitView.frame);
        
        if (ABS(300 - proposedPosition) <= 8)
            proposedPosition = 300;
        if (proposedPosition < 0)
            proposedPosition = 0;
        if (height - proposedPosition < 300 + splitView.dividerThickness)
            proposedPosition = height - (300 + splitView.dividerThickness);
    }
    return proposedPosition;
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification {
    [self.window setFrame:self.window.frame display:false];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (_tableview.selectedRow > -1) {
        NSDictionary *episodedetail = _arraycontroller.selectedObjects[0];
        [self showloading:YES];
        [Kitsu retrieveEpisodeDetails:((NSNumber *)episodedetail[@"episodeId"]).intValue completion:^(id responseObject) {
            [_contentview replaceSubview:_contentview.subviews[0] with:_episodedetailvc.view];
            _episodedetailvc.view.frame = _contentview.frame;
            [_episodedetailvc.view setFrameOrigin:NSMakePoint(0, 0)];
            [_episodedetailvc populateEpisodeDetails:responseObject];
            [self showloading:NO];
        } error:^(NSError *error) {
            [_contentview replaceSubview:_contentview.subviews[0] with:_noselectionview];
            _noselectionview.frame = _contentview.frame;
            [_noselectionview setFrameOrigin:NSMakePoint(0, 0)];
            [self showloading:NO];
        }];
    }
    else {
        [_contentview replaceSubview:_contentview.subviews[0] with:_noselectionview];
        _noselectionview.frame = _contentview.frame;
        [_noselectionview setFrameOrigin:NSMakePoint(0, 0)];
    }
}

@end
