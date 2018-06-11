//
//  ExportProgressWindow.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/06/05.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindow.h"
#import "ExportProgressWindow.h"
#import "Utility.h"
#import "TitleIdConverter.h"
#import "listservice.h"
#import "RatingTwentyConvert.h"

@interface ExportProgressWindow ()
@property (strong) NSMutableArray *tmplist;
@property (strong) NSArray *origlist;
@property int position;
@property (strong) IBOutlet NSProgressIndicator *progress;
@property int type;
@property NSMutableDictionary *currententry;
@property (strong) MainWindow *mw;
@property (strong) IBOutlet NSWindow *failwindow;
@property (strong) IBOutlet NSArrayController *faillistcontroller;
@property (strong) IBOutlet NSTableView *tb;
@property (strong) IBOutlet NSTextField *progresslabel;
@property dispatch_queue_t queue;
@end

@implementation ExportProgressWindow
- (instancetype)init {
    self = [super initWithWindowNibName:@"ExportProgressWindow"];
    if (!self) {
        return nil;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    AppDelegate *del = NSApplication.sharedApplication.delegate;
    _mw = [del getMainWindowController];
    _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

- (void)checklist:(int)type {
    // Initalize Translation
    [NSApp beginSheet:self.window modalForWindow:_mw.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
    NSDictionary *list = [Utility loadJSON:[listservice retrieveListFileName:type] appendpath:@""];
    if (type == MALAnime) {
        _origlist = list[@"anime"];
    }
    else {
        _origlist = list[@"manga"];
    }
    _tmplist = [NSMutableArray new];
    _position = 0;
    _progress.doubleValue = _position;
    _progress.maxValue = _origlist.count;
    _type = type;
    
    [TitleIdConverter setImportStatus:true];
    
    // Start Conversion
    dispatch_async(_queue, ^{
        [self performentryconversion];
    });
}

- (void)performentryconversion {
    // Update UI
    if (_position == (int)_origlist.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Finish callback.
            [NSApp endSheet:self.window returnCode:0];
            [self.window close];
            if (((NSArray *)_faillistcontroller.arrangedObjects).count > 0) {
                [_tb reloadData];
                [NSApp beginSheet:_failwindow
                   modalForWindow:_mw.window modalDelegate:self
                   didEndSelector:nil
                      contextInfo:nil];
            }
            else {
                [self performcompletion];
            }
        });
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        _progress.doubleValue = _position;
        _progresslabel.stringValue = [NSString stringWithFormat:@"%i%%",(int)(_progress.doubleValue/_progress.maxValue*100)];
        });
    // Convert entries and ids to MyAnimeList format
    _currententry = [[NSMutableDictionary alloc] initWithDictionary:_origlist[_position]];
    switch ([listservice getCurrentServiceID]) {
        case 2:
            [self convertKitsuEntrytoMAL];
            break;
        case 3:
            [self convertAniListEntrytoMAL];
            break;
        default:
            break;
    }
}
- (void)convertKitsuEntrytoMAL {
    // Converts Kitsu entries to MyAnimeList
    [TitleIdConverter getMALIDFromKitsuId:((NSNumber *)_currententry[@"id"]).intValue withTitle:_currententry[@"title"] titletype:_currententry[@"type"] withType:_type completionHandler:^(int malid) {
        // Convert
        _currententry[@"id"] = @(malid);
        _currententry[@"score"] = @([RatingTwentyConvert translateKitsuTwentyScoreToMAL:((NSNumber *)_currententry[@"score"]).intValue]);
        [_tmplist addObject:_currententry.copy];
        _position++;
        [self performentryconversion];
    } error:^(NSError *error) {
        [_faillistcontroller addObject:_currententry.copy];
        _position++;
        [self performentryconversion];
    }];
}

- (void)convertAniListEntrytoMAL {
    // Converts AniList entries to MyAnimeList
    [TitleIdConverter getMALIDFromAniListID:((NSNumber *)_currententry[@"id"]).intValue withTitle:_currententry[@"title"] titletype:_currententry[@"type"] withType:_type completionHandler:^(int malid) {
        // Convert
        _currententry[@"id"] = @(malid);
        _currententry[@"score"] = @((((NSNumber *)_currententry[@"score"]).intValue)/10);
        [_tmplist addObject:_currententry.copy];
        _position++;
        [self performentryconversion];
    } error:^(NSError *error) {
        [_faillistcontroller addObject:_currententry.copy];
        _position++;
        [self performentryconversion];
    }];
}

- (IBAction)dialogsavefaillist:(id)sender {
    // Save the json file containing titles
    NSSavePanel * sp = [NSSavePanel savePanel];
    sp.title = @"Save Failed Export Titles";
    sp.allowedFileTypes = @[@"json", @"Javascript Object Notation File"];
    sp.nameFieldStringValue = @"failed.json";
    [sp beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelCancelButton) {
            return;
        }
        NSURL *url = sp.URL;
        //Create JSON string from array controller
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_faillistcontroller.content
                                                           options:0
                                                             error:&error];
        if (!jsonData) {
            return;
        } else {
            NSString *JSONString = [[NSString alloc] initWithBytes:jsonData.bytes length:jsonData.length encoding:NSUTF8StringEncoding];
            
            
            //write JSON to file
            BOOL wresult = [JSONString writeToURL:url
                                       atomically:YES
                                         encoding:NSUTF8StringEncoding
                                            error:&error];
            if (! wresult) {
                NSLog(@"Export Failed: %@", error);
            }
            
            [self clearfailedlist];
            [NSApp endSheet:self.failwindow returnCode:0];
            [_failwindow close];
            [self performcompletion];
        }
    }];
}
- (IBAction)dialogcontinue:(id)sender {
    [self clearfailedlist];
    [NSApp endSheet:self.failwindow returnCode:0];
    [_failwindow close];
    [self performcompletion];
}

- (void)clearfailedlist {
    NSMutableArray * a = [_faillistcontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_tb reloadData];
    [_tb deselectAll:self];
}

- (void)performcompletion {
    // Prepares a NSDictionary of converted list to pass to the completion handler.
    NSDictionary *final;
    // Generate Atarashii compatible list JSON
    if (_type == MALAnime) {
        final = @{@"anime" : _tmplist.copy};
    }
    else {
        final = @{@"manga" : _tmplist.copy};
    }
    // Cleanup
    [TitleIdConverter setImportStatus:false];
    _tmplist = nil;
    _origlist = nil;
    _position = 0;
    _currententry = nil;
    // Perform completion
    _completion(final, _type);
}

@end
