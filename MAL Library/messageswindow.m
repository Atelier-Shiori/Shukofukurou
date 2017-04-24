//
//  messageswindow.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/24.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "messageswindow.h"
#import "MyAnimeList.h"
#import "NSTableViewAction.h"
#import "Utility.h"
#import "messageview.h"
#import "AppDelegate.h"

@interface messageswindow ()
@property (strong) IBOutlet NSSplitView *splitview;
@property (strong) IBOutlet NSView *messagecontent;
@property (strong) IBOutlet NSTableViewAction *messagetb;
@property (strong) IBOutlet NSVisualEffectView *selectmessageview;
@property (strong) IBOutlet NSTextField *selectmessagelabel;
@property (strong) IBOutlet messageview *messageview;
@property int selectedid;
@property (strong) IBOutlet NSProgressIndicator *progresswheel;
@property (strong) IBOutlet NSArrayController *messagearraycontroller;
@property (strong) NSMutableArray *tmplist;
@property int tmppage;
@end

@implementation messageswindow

- (instancetype)init{
    self = [super initWithWindowNibName:@"messageswindow"];
    if (!self)
        return nil;
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [_messagecontent addSubview:_selectmessageview];
    _selectmessageview.frame = _messagecontent.frame;
    [_selectmessageview setFrameOrigin:NSMakePoint(0, 0)];
    _selectmessageview.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    _messageview.view.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    [self loadmessagelist:1 refresh:false];
}

- (void)loadmessagelist:(int)idnum refresh:(bool)refresh  {
    if (!refresh && [Utility checkifFileExists:@"messages.json" appendPath:@""]) {
        [self populatemessagelist:[Utility loadJSON:@"messages.json" appendpath:@""]];
    }
    else {
        _tmppage = 1;
        _tmplist = [NSMutableArray new];
        [self toggleprogresswheel:YES];
        [self generatemessagelist];
    }
}

- (void)generatemessagelist{
    [MyAnimeList retrievemessagelist:_tmppage completionHandler:^(id responseobject){
        if (responseobject[@"list"]){
            NSArray * messages = responseobject[@"list"];
            [_tmplist addObjectsFromArray:messages];
            NSNumber *pages = responseobject[@"pages"];
            if (_tmppage == pages.intValue){
                // Save messages list
                [Utility saveJSON:_tmplist withFilename:@"messages.json" appendpath:@"" replace:YES];
                [self populatemessagelist:[Utility loadJSON:@"messages.json" appendpath:@""]];
                [self toggleprogresswheel:NO];
            }
            else {
                _tmppage++;
                [self generatemessagelist];
            }
        }
    }error:^(NSError *error){
        [self toggleprogresswheel:NO];
    }];

}

- (void)toggleprogresswheel:(bool)state{
    if (state) {
        _selectmessagelabel.stringValue = @"Loading...";
        [_progresswheel startAnimation:nil];
        _progresswheel.hidden = false;
    }
    else {
        [_progresswheel stopAnimation:nil];
        _progresswheel.hidden = true;
    }
}

- (void)cleartableview{
    NSMutableArray *a = [_messagearraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_messagetb reloadData];
    [_messagetb deselectAll:self];
}

- (void)populatemessagelist:(id)data{
    [self cleartableview];
    [_messagearraycontroller addObjects:data];
    [_messagetb reloadData];
    [_messagetb deselectAll:self];
    if ([[_messagearraycontroller mutableArrayValueForKey:@"content"] count] > 0) {
        _selectmessagelabel.stringValue = @"Please select a message.";
    }
    else {
        _selectmessagelabel.stringValue = @"No messages.";
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (_messagetb.selectedRow >-1 && _messagearraycontroller.selectedObjects[0][@"id"]) {
        NSDictionary *d = _messagearraycontroller.selectedObjects[0];
        NSNumber *selectedid = d[@"id"];
        [self retrieveMessage:selectedid.intValue];
    }
    else {
        _selectedid = -1;
        [self toggleprogresswheel:NO];
        if ([[_messagearraycontroller mutableArrayValueForKey:@"content"] count] > 0) {
            _selectmessagelabel.stringValue = @"Please select a message.";
        }
        else {
            _selectmessagelabel.stringValue = @"No messages.";
        }
        [_messagecontent replaceSubview:_messagecontent.subviews[0] with:_selectmessageview];
        _selectmessageview.frame = _messagecontent.frame;
        [_selectmessageview setFrameOrigin:NSMakePoint(0, 0)];
    }
}

- (void)retrieveMessage:(int)messageid {
    if (_selectedid == messageid){
        return;
    }
    if ([Utility checkifFileExists:[NSString stringWithFormat:@"message-%i.json",messageid] appendPath:@"Messages"]){
        [self populateviewcontent:[Utility loadJSON:[NSString stringWithFormat:@"message-%i.json",messageid] appendpath:@"Messages"]];
    }
    else {
        [self toggleprogresswheel:true];
        [MyAnimeList retrievemessage:messageid completionHandler:^(id responseObject){
            [self toggleprogresswheel:false];
            [Utility saveJSON:responseObject withFilename:[NSString stringWithFormat:@"message-%i.json",messageid] appendpath:@"Messages" replace:YES];
            [self retrieveMessage:messageid];
            _selectedid = messageid;
        }error:^(NSError *error){
                [self toggleprogresswheel:false];
            _selectmessagelabel.stringValue = @"Couldn't load message.";
            [_messagecontent replaceSubview:_messagecontent.subviews[0] with:_selectmessageview];
            _selectmessageview.frame = _messagecontent.frame;
            [_selectmessageview setFrameOrigin:NSMakePoint(0, 0)];
        }];
    }
}

- (void)populateviewcontent:(id)data{
    [_messageview loadMessage:data];
    [_messagecontent replaceSubview:_messagecontent.subviews[0] with:_messageview.view];
    _messageview.view.frame = _messagecontent.frame;
    [_messageview.view setFrameOrigin:NSMakePoint(0, 0)];
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
- (IBAction)createmessage:(id)sender {
}

- (IBAction)refreshmessagelist:(id)sender {
    [self loadmessagelist:1 refresh:YES];
}

- (IBAction)reply:(id)sender {
}

- (IBAction)deletemessage:(id)sender {
}

- (IBAction)performfilter:(id)sender {
}

- (IBAction)addlicense:(id)sender {
    AppDelegate *appdel = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appdel enterDonationKey:sender];
}
@end
