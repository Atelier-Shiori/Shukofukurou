//
//  ReviewWindow.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/23.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "ReviewWindow.h"
//#import "MyAnimeList.h"
#import "listservice.h"
#import "NSTableViewAction.h"
#import "ReviewView.h"
#import "AppDelegate.h"

@interface ReviewWindow ()
@property (strong) IBOutlet NSArrayController *reviewarraycontroller;
@property (strong) IBOutlet NSTableViewAction *reviewtb;
@property (strong) IBOutlet NSVisualEffectView *selectreviewview;
@property (strong) IBOutlet NSTextField *selectreviewlabel;
@property (strong) IBOutlet ReviewView *reviewview;
@property (strong) IBOutlet NSView *reviewcontent;
@property int selectedid;
@property int selectedtype;
@property (strong) IBOutlet NSSplitView *splitview;
@property (strong) IBOutlet NSProgressIndicator *progresswheel;

@end

@implementation ReviewWindow

- (instancetype)init{
    self = [super initWithWindowNibName:@"ReviewWindow"];
    if (!self)
        return nil;
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [_reviewcontent addSubview:_selectreviewview];
    _selectreviewview.frame = _reviewcontent.frame;
    [_selectreviewview setFrameOrigin:NSMakePoint(0, 0)];
    _selectreviewview.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    _reviewview.view.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
}

- (void)loadReview:(int)idnum type:(int)type title:(NSString *)title {
    if (_selectedid == idnum && type == _selectedtype){
        return;
    }
    [self cleartableview];
    [self toggleprogresswheel:YES];
    [listservice retrieveReviewsForTitle:idnum withType:type completion:^(id responsedata) {
        _selectedid = idnum;
        _selectedtype = type;
        self.window.title = [NSString stringWithFormat:@"Reviews - %@", title];
        [self populateReviews:responsedata];
        [self toggleprogresswheel:NO];
    } error:^(NSError *error) {
        [self toggleprogresswheel:NO];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"Couldn't Load Reviews",nil)];
        [alert setInformativeText:NSLocalizedString(@"Make sure you are connected to the internet and try again.",nil)];
        // Set Message type to Warning
        alert.alertStyle = NSAlertStyleInformational;
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
                [self.window close];
        }];
    }];
}

- (void)toggleprogresswheel:(bool)state{
    if (state) {
        _selectreviewlabel.stringValue = @"Loading Reviews...";
        [_progresswheel startAnimation:nil];
        _progresswheel.hidden = false;
    }
    else {
        [_progresswheel stopAnimation:nil];
        _progresswheel.hidden = true;
    }
}
- (void)cleartableview{
    NSMutableArray *a = [_reviewarraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_reviewtb reloadData];
    [_reviewtb deselectAll:self];
    self.window.title = @"Reviews";
}

- (void)populateReviews:(id)data{
    [_reviewarraycontroller addObjects:data];
    [_reviewtb reloadData];
    [_reviewtb deselectAll:self];
    if ([[_reviewarraycontroller mutableArrayValueForKey:@"content"] count] > 0) {
        _selectreviewlabel.stringValue = @"Please select a review.";
    }
    else {
        _selectreviewlabel.stringValue = @"No reviews.";
    }
}

- (IBAction)viewreview:(id)sender {
    if (_reviewtb.selectedRow >=0) {
        if (_reviewtb.selectedRow >-1) {
            NSDictionary *d = _reviewarraycontroller.selectedObjects[0];
            [self populateviewcontent:d];
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (_reviewtb.selectedRow >-1) {
        NSDictionary *d = _reviewarraycontroller.selectedObjects[0];
        [self populateviewcontent:d];
    }
    else {
        [_reviewcontent replaceSubview:_reviewcontent.subviews[0] with:_selectreviewview];
        _selectreviewview.frame = _reviewcontent.frame;
        [_selectreviewview setFrameOrigin:NSMakePoint(0, 0)];
    }
}

- (void)populateviewcontent:(id)data{
    [_reviewview loadReview:data type:_selectedtype];
    [_reviewcontent replaceSubview:_reviewcontent.subviews[0] with:_reviewview.view];
    _reviewview.view.frame = _reviewcontent.frame;
    [_reviewview.view setFrameOrigin:NSMakePoint(0, 0)];
}


- (void) splitView:(NSSplitView*) splitView resizeSubviewsWithOldSize:(NSSize) oldSize
{
    if (splitView == _splitview)
    {
        CGFloat dividerPos = NSHeight([[[splitView subviews] objectAtIndex:0] frame]);
        CGFloat height = NSHeight([splitView frame]);
        
        if (dividerPos < 0)
            dividerPos = 0;
        if (height - dividerPos < 300 + [splitView dividerThickness])
            dividerPos = height - (300 + [splitView dividerThickness]);
        
        [splitView adjustSubviews];
        [splitView setPosition:dividerPos ofDividerAtIndex:0];
    }
}

- (CGFloat) splitView:(NSSplitView*) splitView constrainSplitPosition:(CGFloat) proposedPosition ofSubviewAt:(NSInteger) dividerIndex
{
    if (splitView == _splitview)
    {
        CGFloat height = NSHeight([splitView frame]);
        
        if (ABS(300 - proposedPosition) <= 8)
            proposedPosition = 300;
        if (proposedPosition < 0)
            proposedPosition = 0;
        if (height - proposedPosition < 300 + [splitView dividerThickness])
            proposedPosition = height - (300 + [splitView dividerThickness]);
    }
    return proposedPosition;
}
- (void)splitViewDidResizeSubviews:(NSNotification *)notification{
    [self.window setFrame:self.window.frame display:false];
}

@end
