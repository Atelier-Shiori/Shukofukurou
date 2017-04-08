//
//  EditTitle.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import "EditTitle.h"
#import "NSTextFieldNumber.h"
#import "MainWindow.h"
#import <AFNetworking/AFNetworking.h>
#import "Keychain.h"

@interface EditTitle ()
// Anime
@property (strong) IBOutlet NSView *animeeditview;
@property (strong) IBOutlet NSTextFieldNumber *minipopoverepfield;
@property (strong) IBOutlet NSTextField *minipopovertotalep;
@property (strong) IBOutlet NSPopUpButton *minipopoverstatus;
@property (strong) IBOutlet NSTextField *minipopoverscore;
@property (strong) IBOutlet NSTextField *minipopoverstatustext;
@property (strong) IBOutlet NSProgressIndicator *minipopoverindicator;
@property (strong) IBOutlet NSButton *minipopovereditbtn;
@property (strong) IBOutlet NSNumberFormatter *minieditpopovernumformat;

// Manga
@property (strong) IBOutlet NSView *mangaeditview;
@property (strong) IBOutlet NSTextFieldNumber *mangapopoverchapfield;
@property (strong) IBOutlet NSTextField *mangapopovertotalchap;
@property (strong) IBOutlet NSNumberFormatter *mangaeditpopoverchapnumformat;
@property (strong) IBOutlet NSTextFieldNumber *mangapopovervolfield;
@property (strong) IBOutlet NSTextField *mangapopovertotalvol;
@property (strong) IBOutlet NSNumberFormatter *mangaeditpopovervolnumformat;
@property (strong) IBOutlet NSPopUpButton *mangapopoverstatus;
@property (strong) IBOutlet NSTextField *mangapopoverscore;
@property (strong) IBOutlet NSTextField *mangapopoverstatustext;
@property (strong) IBOutlet NSProgressIndicator *mangapopoverindicator;
@property (strong) IBOutlet NSButton *mangapopovereditbtn;

@end

@implementation EditTitle

- (id)init
{
    return [super initWithNibName:@"EditTitle" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.view addSubview:_animeeditview];
    [self view];
}

- (void)showEditPopover:(NSDictionary *)d showRelativeToRec:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)rectedge type:(int)type{
    selecteditem = d;
    if (type == 0){
        [self.view replaceSubview:[self.view.subviews objectAtIndex:0] with:_animeeditview];
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
        if ([(NSNumber *)d[@"episodes"] intValue] > 0){
            [_minieditpopovernumformat setMaximum:d[@"episodes"]];
        }
        else {
            [_minieditpopovernumformat setMaximum:nil];
        }
        selectededitid = [(NSNumber *)d[@"id"] intValue];
        [_minieditpopover showRelativeToRect:rect ofView:view preferredEdge:rectedge];
        selectedtype = type;
    }
    else{
        [self.view replaceSubview:[self.view.subviews objectAtIndex:0] with:_mangaeditview];
        NSString *publishtatus = selecteditem[@"status"];
        if ([publishtatus isEqualToString:@"finished"]){
            selectedfinished = true;
        }
        else{
            selectedfinished = false;
        }
        if ([publishtatus isEqualToString:@"finished"]||[publishtatus isEqualToString:@"publishing"]){
            selectedpublished = true;
        }
        else{
            selectedpublished = false;
        }
        [_mangapopoverchapfield setIntValue:[(NSNumber *)d[@"chapters_read"] intValue]];
        [_mangapopovertotalchap setIntValue:[(NSNumber *)d[@"chapters"] intValue]];
        if ([(NSNumber *)d[@"chapters"] intValue] > 0){
            [_mangaeditpopoverchapnumformat setMaximum:d[@"chapters"]];
        }
        else {
            [_mangaeditpopoverchapnumformat setMaximum:nil];
        }
        [_mangapopovervolfield setIntValue:[(NSNumber *)d[@"volumes_read"] intValue]];
        [_mangapopovertotalvol setIntValue:[(NSNumber *)d[@"volumes"] intValue]];
        if ([(NSNumber *)d[@"volumes"] intValue] > 0){
            [_mangaeditpopovervolnumformat setMaximum:d[@"volumes"]];
        }
        else {
            [_mangaeditpopovervolnumformat setMaximum:nil];
        }
        [_mangapopoverstatus selectItemWithTitle:d[@"read_status"]];
        [_mangapopoverscore setFloatValue:[(NSNumber *)d[@"score"] floatValue]];
        [_mangapopoverstatustext setStringValue:@""];
        selectededitid = [(NSNumber *)d[@"id"] intValue];
        [_minieditpopover showRelativeToRect:rect ofView:view preferredEdge:rectedge];
        selectedtype = type;
    }
}

- (IBAction)performupdatetitle:(id)sender {
    [self performupdate];
}

- (void)performupdate{
    if (selectedtype == 0){
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
        [manager PUT:[NSString stringWithFormat:@"%@/2.1/animelist/anime/%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"], @(selectededitid)] parameters:@{ @"status":_minipopoverstatus.title, @"score":@(_minipopoverscore.intValue), @"episodes":@(_minipopoverepfield.intValue)} success:^(NSURLSessionTask *task, id responseObject) {
            [mw loadlist:@(true) type:selectedtype];
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
    else {
        [_mangapopovereditbtn setEnabled:false];
        [_mangapopoverstatustext setStringValue:@""];
        if(![_mangapopoverstatus isEqual:@"completed"] && _mangapopoverchapfield.intValue == _mangapopovertotalchap.intValue && _mangapopovertotalvol.intValue == _mangapopovertotalvol.intValue && selectedfinished){
            [_mangapopoverstatus selectItemWithTitle:@"completed"];
        }
        if(!selectedpublished && (![_mangapopoverstatus.title isEqual:@"plan to read"] ||_mangapopoverchapfield.intValue > 0 || _mangapopovertotalvol.intValue > 0)){
            // Invalid input, mark it as such
            [_mangapopovereditbtn setEnabled:true];
            [_mangapopoverstatustext setStringValue:@"Invalid update."];
            [_minieditpopover setBehavior:NSPopoverBehaviorTransient];
            [_mangapopoverindicator stopAnimation:nil];
            return;
        }
        if (((_mangapopoverchapfield.intValue == _mangapopovertotalchap.intValue && _mangapopoverchapfield.intValue != 0) || (_mangapopovervolfield.intValue == _mangapopovertotalvol.intValue && _mangapopovertotalvol.intValue != 0)) && selectedfinished && selectedpublished){
            [_mangapopoverstatus selectItemWithTitle:@"completed"];
            [_mangapopoverchapfield setIntValue:[_mangapopovertotalchap intValue]];
            [_mangapopovertotalvol setIntValue:[_mangapopovertotalvol intValue]];
        }

        [_minieditpopover setBehavior:NSPopoverBehaviorApplicationDefined];
        [_mangapopoverindicator startAnimation:nil];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [Keychain getBase64]] forHTTPHeaderField:@"Authorization"];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager PUT:[NSString stringWithFormat:@"%@/2.1/mangalist/manga/%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"], @(selectededitid)] parameters:@{ @"status":_mangapopoverstatus.title, @"score":@(_mangapopoverscore.intValue), @"chapters":@(_mangapopoverchapfield.intValue),@"volumes":@(_mangapopovervolfield.intValue)} success:^(NSURLSessionTask *task, id responseObject) {
            [mw loadlist:@(true) type:selectedtype];
            [mw loadlist:@(true) type:2];
            [_mangapopovereditbtn setEnabled:true];
            [_minieditpopover setBehavior:NSPopoverBehaviorTransient];
            [_mangapopoverindicator stopAnimation:nil];
            [_minieditpopover close];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            [_mangapopovereditbtn setEnabled:true];
            [_minieditpopover setBehavior:NSPopoverBehaviorTransient];
            [_mangapopoverindicator stopAnimation:nil];
            NSLog(@"%@", error);
            [_mangapopoverstatustext setStringValue:@"Error"];
        }];
    }
}

@end
