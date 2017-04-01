//
//  AddTitle.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "AddTitle.h"
#import "MainWindow.h"
#import <AFNetworking/AFNetworking.h>
#import "Keychain.h"

@interface AddTitle ()
@property (strong) IBOutlet NSView *popoveraddtitleexistsview;
// Anime
@property (strong) IBOutlet NSView *addtitleview;
@property (strong) IBOutlet NSTextField *addepifield;
@property (strong) IBOutlet NSNumberFormatter *addnumformat;
@property (strong) IBOutlet NSTextField *addtotalepisodes;
@property (strong) IBOutlet NSTextField *addscorefiled;
@property (strong) IBOutlet NSPopUpButton *addstatusfield;
@property (strong) IBOutlet NSButton *addfield;

// Manga
@property (strong) IBOutlet NSView *addmangaview;
@property (strong) IBOutlet NSTextField *addchapfield;
@property (strong) IBOutlet NSNumberFormatter *addchapnumformat;
@property (strong) IBOutlet NSTextField *addvolfield;
@property (strong) IBOutlet NSNumberFormatter *addvolnumformat;
@property (strong) IBOutlet NSTextField *addtotalchap;
@property (strong) IBOutlet NSTextField *addtotalvol;
@property (strong) IBOutlet NSTextField *addmangascorefiled;
@property (strong) IBOutlet NSPopUpButton *addmangastatusfield;
@property (strong) IBOutlet NSButton *addmangabtn;

@end

@implementation AddTitle

- (id)init
{
    return [super initWithNibName:@"AddTitle" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.view addSubview:[NSView new]];
}

- (void)showAddPopover:(NSDictionary *)d showRelativeToRec:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)rectedge type:(int)type{
    [self view];
    NSNumber * idnum = d[@"id"];
    if (type == 0){
        if (![mw checkiftitleisonlist:idnum.intValue type:0]){
            [self.view replaceSubview:[self.view.subviews objectAtIndex:0] with:_addtitleview];
            selecteditem = d;
            if ([(NSNumber *)d[@"episodes"] intValue] > 0){
                [_addnumformat setMaximum:d[@"episodes"]];
            }
            else {
                [_addnumformat setMaximum:nil];
            }
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
            [_addepifield setIntValue:0];
            [_addtotalepisodes setIntValue:[(NSNumber *)d[@"episodes"] intValue]];
            [_addstatusfield selectItemWithTitle:@"watching"];
            [_addscorefiled setIntValue:0];
            selectededitid = [(NSNumber *)d[@"id"] intValue];
        }
        else {
            [self.view replaceSubview:[self.view.subviews objectAtIndex:0] with:_popoveraddtitleexistsview];
        }
        [_addpopover showRelativeToRect:rect ofView:view preferredEdge:rectedge];
        selectedtype = type;
    }
    else {
        if (![mw checkiftitleisonlist:idnum.intValue type:1]){
            [self.view replaceSubview:[self.view.subviews objectAtIndex:0] with:_addmangaview];
            selecteditem = d;
            if ([(NSNumber *)d[@"chapters"] intValue] > 0){
                [_addchapnumformat setMaximum:d[@"chapters"]];
            }
            else {
                [_addchapnumformat setMaximum:nil];
            }
            if ([(NSNumber *)d[@"volumes"] intValue] > 0){
                [_addvolnumformat setMaximum:d[@"chapters"]];
            }
            else {
                [_addvolnumformat setMaximum:nil];
            }
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager GET:[NSString stringWithFormat:@"https://malapi.ateliershiori.moe/2.1/manga/%i",idnum.intValue] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                selecteditem = responseObject;
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

            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            [_addchapfield setIntValue:0];
            [_addtotalchap setIntValue:[(NSNumber *)d[@"chapters"] intValue]];
            [_addvolfield setIntValue:0];
            [_addtotalvol setIntValue:[(NSNumber *)d[@"volumes"] intValue]];
            [_addmangastatusfield selectItemWithTitle:@"reading"];
            [_addmangascorefiled setIntValue:0];
            selectededitid = [(NSNumber *)d[@"id"] intValue];
        }
        else {
            [self.view replaceSubview:[self.view.subviews objectAtIndex:0] with:_popoveraddtitleexistsview];
        }
        [_addpopover showRelativeToRect:rect ofView:view preferredEdge:rectedge];
        selectedtype = type;
    }
    
}
- (IBAction)PerformAddTitle:(id)sender {
    [self addtitletolist];
}
- (void)addtitletolist{
    if (selectedtype == 0){
        [_addfield setEnabled:false];
        if(![_addstatusfield isEqual:@"completed"] && _addepifield.intValue == _addtotalepisodes.intValue && selectedaircompleted){
            [_addstatusfield selectItemWithTitle:@"completed"];
        }
        if(!selectedaired && (![_addstatusfield.title isEqual:@"plan to watch"] ||_addepifield.intValue > 0)){
            // Invalid input, mark it as such
            [_addfield setEnabled:true];
            [_addpopover setBehavior:NSPopoverBehaviorTransient];
            return;
        }
        if (_addepifield.intValue == _addtotalepisodes.intValue && _addtotalepisodes.intValue != 0 && selectedaircompleted && selectedaired){
            [_addstatusfield selectItemWithTitle:@"completed"];
            [_addepifield setIntValue:[_addtotalepisodes intValue]];
        }
        [_addpopover setBehavior:NSPopoverBehaviorApplicationDefined];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@",[Keychain getBase64]] forHTTPHeaderField:@"Authorization"];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:@"https://malapi.ateliershiori.moe/2.1/animelist/anime" parameters:@{@"anime_id":@(selectededitid), @"status":_addstatusfield.title, @"score":@(_addscorefiled.intValue), @"episodes_watched":@(_addepifield.intValue)} progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [mw loadlist:@(true) type:0];
            [_addfield setEnabled:true];
            [_addpopover setBehavior:NSPopoverBehaviorTransient];
            [_addpopover close];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"%@",error);
            NSData * errordata = [error userInfo] [@"com.alamofire.serialization.response.error.data" ];
            NSLog(@"%@",[[NSString alloc] initWithData:errordata encoding:NSUTF8StringEncoding]);
            [_addpopover setBehavior:NSPopoverBehaviorTransient];
            [_addfield setEnabled:true];
        }];
    }
    else {
        [_addmangabtn setEnabled:false];
        if(![_addstatusfield isEqual:@"completed"] && _addchapfield.intValue == _addtotalchap.intValue && _addvolfield.intValue == _addtotalvol.intValue && selectedfinished){
            [_addstatusfield selectItemWithTitle:@"completed"];
        }
        if(!selectedpublished && (![_addstatusfield.title isEqual:@"plan to read"] ||_addchapfield.intValue > 0 || _addvolfield.intValue > 0)){
            // Invalid input, mark it as such
            [_addmangabtn setEnabled:true];
            [_addpopover setBehavior:NSPopoverBehaviorTransient];
            return;
        }
        if (((_addchapfield.intValue == _addtotalchap.intValue && _addchapfield.intValue != 0) || (_addvolfield.intValue == _addtotalvol.intValue && _addtotalvol.intValue != 0)) && selectedfinished && selectedpublished){
            [_addmangastatusfield selectItemWithTitle:@"completed"];
            [_addchapfield setIntValue:[_addtotalchap intValue]];
            [_addvolfield setIntValue:[_addtotalvol intValue]];
        }
        [_addpopover setBehavior:NSPopoverBehaviorApplicationDefined];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@",[Keychain getBase64]] forHTTPHeaderField:@"Authorization"];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:@"https://malapi.ateliershiori.moe/2.1/mangalist/manga" parameters:@{@"manga_id":@(selectededitid), @"status":_addmangastatusfield.title, @"score":@(_addmangascorefiled.intValue), @"chapters":@(_addchapfield.intValue), @"volumes":@(_addvolfield.intValue)} progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [mw loadlist:@(true) type:1];
            [_addmangabtn setEnabled:true];
            [_addpopover setBehavior:NSPopoverBehaviorTransient];
            [_addpopover close];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"%@",error);
            NSData * errordata = [error userInfo] [@"com.alamofire.serialization.response.error.data" ];
            NSLog(@"%@",[[NSString alloc] initWithData:errordata encoding:NSUTF8StringEncoding]);
            [_addpopover setBehavior:NSPopoverBehaviorTransient];
            [_addmangabtn setEnabled:true];
        }];
    }
}

@end
