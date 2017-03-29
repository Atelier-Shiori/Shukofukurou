//
//  EditTitle.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "EditTitle.h"
#import "NSTextFieldNumber.h"
#import "MainWindow.h"
#import <AFNetworking/AFNetworking.h>
#import "Keychain.h"

@interface EditTitle ()
@property (strong) IBOutlet NSTextFieldNumber *minipopoverepfield;
@property (strong) IBOutlet NSTextField *minipopovertotalep;
@property (strong) IBOutlet NSPopUpButton *minipopoverstatus;
@property (strong) IBOutlet NSTextField *minipopoverscore;
@property (strong) IBOutlet NSTextField *minipopoverstatustext;
@property (strong) IBOutlet NSProgressIndicator *minipopoverindicator;
@property (strong) IBOutlet NSButton *minipopovereditbtn;
@property (strong) IBOutlet NSNumberFormatter *minieditpopovernumformat;
@end

@implementation EditTitle

- (id)init
{
    return [super initWithNibName:@"EditTitle" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)showEditPopover:(NSDictionary *)d showRelativeToRec:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)rectedge{
    [self view];
    selecteditem = d;
    [_minieditpopovernumformat setMaximum:d[@"episodes"]];
    NSString *airingstatus = d[@"status"];
    if ([airingstatus isEqualToString:@"finished airing"]){
        selectedaircompleted = true;
    }
    else{
        selectedaircompleted = false;
    }
    if ([airingstatus isEqualToString:@"finished airing"]||[airingstatus isEqualToString:@"currently airing"]){
        selectedaired = true;
    }
    else{
        selectedaired = false;
    }
    [_minipopoverepfield setIntValue:[(NSNumber *)d[@"watched_episodes"] intValue]];
    [_minipopovertotalep setIntValue:[(NSNumber *)d[@"episodes"] intValue]];
    [_minipopoverstatus selectItemWithTitle:d[@"watched_status"]];
    [_minipopoverscore setFloatValue:[(NSNumber *)d[@"score"] floatValue]];
    [_minipopoverstatustext setStringValue:@""];
    selectededitid = [(NSNumber *)d[@"id"] intValue];
    [_minieditpopover showRelativeToRect:rect ofView:view preferredEdge:rectedge];
}

- (IBAction)performupdatetitle:(id)sender {
    [self performupdate];
}

- (void)performupdate{
    [_minipopovereditbtn setEnabled:false];
    [_minipopoverstatustext setStringValue:@""];
    if(![_minipopoverstatus.title isEqual:@"completed"] && _minipopoverepfield.intValue == _minipopovertotalep.intValue && selectedaircompleted){
        [_minipopoverstatus selectItemWithTitle:@"completed"];
    }
    if(!selectedaired && (![_minipopoverstatus.title isEqual:@"plan to watch"] ||_minipopoverepfield.intValue > 0)){
        // Invalid input, mark it as such
        [_minipopovereditbtn setEnabled:true];
        [_minipopoverstatustext setStringValue:@"Invalid update."];
        [_minieditpopover setBehavior:NSPopoverBehaviorTransient];
        [_minipopoverindicator stopAnimation:nil];
        return;
    }
    if (_minipopoverepfield.intValue == _minipopovertotalep.intValue && _minipopovertotalep.intValue != 0 && selectedaircompleted && selectedaired){
        [_minipopoverstatus selectItemWithTitle:@"completed"];
        [_minipopoverepfield setIntValue:[_minipopovertotalep intValue]];
    }
    [_minieditpopover setBehavior:NSPopoverBehaviorApplicationDefined];
    [_minipopoverindicator startAnimation:nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [Keychain getBase64]] forHTTPHeaderField:@"Authorization"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager PUT:[NSString stringWithFormat:@"https://malapi.ateliershiori.moe/2.1/animelist/anime/%@", @(selectededitid)] parameters:@{ @"status":_minipopoverstatus.title, @"score":@(_minipopoverscore.intValue), @"episodes":@(_minipopoverepfield.intValue)} success:^(NSURLSessionTask *task, id responseObject) {
        [mw loadlist:@(true)];
        [_minipopovereditbtn setEnabled:true];
        [_minieditpopover setBehavior:NSPopoverBehaviorTransient];
        [_minipopoverindicator stopAnimation:nil];
        [_minieditpopover close];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [_minipopovereditbtn setEnabled:true];
        [_minieditpopover setBehavior:NSPopoverBehaviorTransient];
        [_minipopoverindicator stopAnimation:nil];
        NSLog(@"%@", error);
        [_minipopoverstatustext setStringValue:@"Error"];
    }];
}

@end
