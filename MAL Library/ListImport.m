//
//  ListImport.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/05/10.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import "ListImport.h"
#import "XMLReader.h"
#import "AppDelegate.h"
#import "MainWindow.h"
#import "MyAnimeList.h"
#import "Utility.h"

@interface ListImport ()
@property (strong) NSArray *listimport;
@property (strong) NSArray *existinglist;
@property (strong) IBOutlet NSArrayController *failedarraycontroller;
@property int progress;
@property int importlisttype;
@property int imported;
@property bool replaceexisting;
@property (strong) IBOutlet NSProgressIndicator *progressbar;
@property (strong) IBOutlet NSTextField *progresspercentage;
@end

@implementation ListImport
- (instancetype)init{
    self = [super initWithWindowNibName:@"ListImport"];
    if (!self)
        return nil;
    return self;
}

- (IBAction) importMALList:(id)sender{
    if ([Utility checkifFileExists:@"animelist.json" appendPath:@""] && [Utility checkifFileExists:@"mangalist.json" appendPath:@""]) {
        NSOpenPanel * op = [NSOpenPanel openPanel];
        op.allowedFileTypes = @[@"xml", @"Extended Markup Language file"];
        op.message = @"Please select a MAL XML List to import.";
        NSButton *button = [[NSButton alloc] init];
        [button setButtonType:NSSwitchButton];
        button.title = NSLocalizedString(@"Replace entries if exist", @"");
        [button sizeToFit];
        op.accessoryView = button;
        [op beginSheetModalForWindow:[_del getMainWindowController].window
     completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelCancelButton) {
            return;
        }
        [op close];
        NSURL *Url = op.URL;
        // read the file
        NSString * str = [NSString stringWithContentsOfURL:Url
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
        NSError *error = nil;
        
        NSDictionary *d = [XMLReader dictionaryForXMLString:str options:XMLReaderOptionsProcessNamespaces error:&error];
         d = d[@"myanimelist"];
         if (d[@"anime"]) {
             _importlisttype = MALAnime;
             _listimport = d[@"anime"];
             _existinglist = [Utility loadJSON:@"animelist.json" appendpath:@""][@"anime"];
         }
         else if (d[@"manga"]) {
             _importlisttype = MALManga;
             _listimport = d[@"manga"];
             _existinglist = [Utility loadJSON:@"mangalist.json" appendpath:@""][@"manga"];
         }
         if (![_listimport isKindOfClass:[NSArray class]]){
             // Import only contains one object, put it in an array.
             _listimport = [NSArray arrayWithObject:_listimport];
         }
         _replaceexisting = (((NSButton*)op.accessoryView).state == NSOnState);
         _progress = 0;
         _imported = 0;
         _progresspercentage.stringValue = @"0%";
         _progressbar.doubleValue = 0;
         [NSApp beginSheet:self.window modalForWindow:[_del getMainWindowController].window modalDelegate:nil didEndSelector:nil contextInfo:nil];
         [self performtMALListImport];
        }];
    }
    else {
        [_del showloginnotice];
    }
    
}

- (void)performtMALListImport {
    if (_importlisttype == 0) {
        [self importAnimeMALEntry];
    }
    else {
        [self importMangaMALEntry];
    }
}

- (void)importAnimeMALEntry {
    if (_listimport.count > 0) {
        NSDictionary *d = _listimport[_progress];
        if ([self checkiftitleisonlist:((NSString *)d[@"series_animedb_id"][@"text"]).intValue]) {
            if (_replaceexisting || ((NSString *)d[@"update_on_import"][@"text"]).intValue == 1) {
                [MyAnimeList updateAnimeTitleOnList:[(NSString *)d[@"series_animedb_id"][@"text"] intValue] withEpisode:[(NSString *)d[@"my_watched_episodes"][@"text"] intValue] withStatus:(NSString *)d[@"my_status"][@"text"] withScore:[(NSString *)d[@"my_score"][@"text"] intValue]  completion:^(id responseobject){
                    [self incrementProgress:nil];
                }error:^(NSError *error){
                    [self incrementProgress:d];
                }];
            }
            else {
                [self incrementProgress:nil];
            }
        }
        else {
            [MyAnimeList addAnimeTitleToList:[(NSString *)d[@"series_animedb_id"][@"text"] intValue] withEpisode:[(NSString *)d[@"my_watched_episodes"][@"text"] intValue] withStatus:(NSString *)d[@"my_status"][@"text"] withScore:[(NSString *)d[@"my_score"][@"text"] intValue]  completion:^(id responseobject){
                [self incrementProgress:nil];
            }error:^(NSError *error){
                [self incrementProgress:d];
            }];
        }
    }
}

- (void)importMangaMALEntry {
    if (_listimport.count > 0) {
        NSDictionary *d = _listimport[_progress];
        if ([self checkiftitleisonlist:((NSString *)d[@"manga_mangadb_id"][@"text"]).intValue]) {
            if (_replaceexisting || ((NSString *)d[@"update_on_import"][@"text"]).intValue == 1) {
                [MyAnimeList updateMangaTitleOnList:((NSString *)d[@"manga_mangadb_id"][@"text"]).intValue withChapter:((NSString *)d[@"my_read_chapters"][@"text"]).intValue withVolume:((NSString *)d[@"my_read_volumes"][@"text"]).intValue withStatus:(NSString *)d[@"my_status"][@"text"] withScore:((NSString *)d[@"my_score"][@"text"]).intValue completion:^(id responseObject){
                    [self incrementProgress:nil];
                }error:^(NSError *error){
                    [self incrementProgress:d];
                }];
            }
            else {
                [self incrementProgress:nil];
            }
        }
        else {
            [MyAnimeList addMangaTitleToList:((NSString *)d[@"manga_mangadb_id"][@"text"]).intValue withChapter:((NSString *)d[@"my_read_chapters"][@"text"]).intValue withVolume:((NSString *)d[@"my_read_volumes"][@"text"]).intValue withStatus:(NSString *)d[@"my_status"][@"text"] withScore:((NSString *)d[@"my_score"][@"text"]).intValue completion:^(id responseObject){
                [self incrementProgress:nil];
            }error:^(NSError *error){
                [self incrementProgress:d];
            }];
        }
    }
}


- (void)incrementProgress:( NSDictionary * _Nullable )d {
    _progress++;
    _progressbar.maxValue = _listimport.count;
    _progressbar.doubleValue = _progress;
    _progresspercentage.stringValue = [NSString stringWithFormat:@"%i%%",(int)(_progressbar.doubleValue/_progressbar.maxValue*100)];
    if (d) {
        [_failedarraycontroller addObject:@{@"title":d[@"title"], @"data":d}];
    }
    else {
        _imported++;
    }
    if (_progress == _listimport.count) {
        [NSApp endSheet:self.window returnCode:0];
        [self.window close];
        [Utility showsheetmessage:@"Import Completed." explaination:[NSString stringWithFormat:@"%i entries have been imported",_progress] window:[_del getMainWindowController].window];
        [[_del getMainWindowController] loadlist:@(true) type:MALAnime];
        [[_del getMainWindowController] loadlist:@(true) type:MALManga];
        [[_del getMainWindowController] loadlist:@(true) type:2];
    }
    else {
        [self performtMALListImport];
    }
}
- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (bool)checkiftitleisonlist:(int)idnum{
    NSArray *list = [_existinglist filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
    if (list.count > 0) {
        return true;
    }
    return false;
}

@end
