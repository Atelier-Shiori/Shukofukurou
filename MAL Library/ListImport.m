//
//  ListImport.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/05/10.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved.
//

#import "ListImport.h"
#import "AppDelegate.h"
#import "MainWindow.h"
#import "listservice.h"
#import "Utility.h"
#import "ImportPrompt.h"
#import "Keychain.h"
#import "TitleIdConverter.h"
#import "XMLReader.h"
#import "RatingTwentyConvert.h"

@interface ListImport ()
@property (strong) NSArray *listimport;
@property (strong) NSMutableArray *tmplist;
@property (strong) NSMutableArray *metadata;
@property (strong) NSArray *existinglist;
@property (strong) IBOutlet NSArrayController *failedarraycontroller;
@property int progress;
@property int importlisttype;
@property int imported;
@property bool replaceexisting;
@property (strong) IBOutlet NSProgressIndicator *progressbar;
@property (strong) IBOutlet NSTextField *progresspercentage;
@property (strong) NSString *listtype;
@property (strong) ImportPrompt *importprompt;
@property (strong) IBOutlet NSWindow *failedw;
@property (strong) IBOutlet NSTableView *failedtb;
@end

@implementation ListImport
- (instancetype)init{
    self = [super initWithWindowNibName:@"ListImport"];
    if (!self)
        return nil;
    return self;
}

#pragma mark Import Methods
- (void)importsetup {
    _progress = 0;
    _imported = 0;
    _progresspercentage.stringValue = @"0%";
    _progressbar.doubleValue = 0;
    [NSApp beginSheet:self.window modalForWindow:[_del getMainWindowController].window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (void)incrementProgress:( NSDictionary * _Nullable )d withTitle:(NSString * _Nullable) title {
    _progress++;
    _progressbar.maxValue = _listimport.count;
    _progressbar.doubleValue = _progress;
    _progresspercentage.stringValue = [NSString stringWithFormat:@"%i%%",(int)(_progressbar.doubleValue/_progressbar.maxValue*100)];
    [TitleIdConverter setImportStatus:true];
    // Wait Time
    switch ([listservice getCurrentServiceID]) {
        case 3:
            [NSThread sleepForTimeInterval:0.5f];
            break;
        default:
            break;
    }
    if (d && title) {
        [_failedarraycontroller addObject:@{@"title":title, @"data":d}];
    }
    else if (d) {
    }
    else {
        _imported++;
    }
    if (_progress == _listimport.count) {
        [NSApp endSheet:self.window returnCode:0];
        [self.window close];
        [TitleIdConverter setImportStatus:false];
        if ([(NSArray *)_failedarraycontroller.content count] > 0) {
            [_failedtb reloadData];
            [NSApp beginSheet:_failedw
               modalForWindow:[_del getMainWindowController].window modalDelegate:self
               didEndSelector:nil
                  contextInfo:nil];
        }
        else {
            [Utility showsheetmessage:@"Import Completed." explaination:[NSString stringWithFormat:@"%i entries have been imported",_imported] window:[_del getMainWindowController].window];
        }
        [[_del getMainWindowController] loadlist:@(true) type:MALAnime];
        [[_del getMainWindowController] loadlist:@(true) type:MALManga];
        [[_del getMainWindowController] loadlist:@(true) type:2];
        // Cleanup
        _listimport = nil;
        _existinglist = nil;
        _listtype = nil;
        _importprompt = nil;
        _metadata = nil;
    }
    else {
        if ([_listtype isEqualToString:@"myanimelist"]) {
            [self performtMALListImport];
        }
        else if ([_listtype isEqualToString:@"kitsu"]) {
            [self performKitsuImport];
        }
        else if ([_listtype isEqualToString:@"anidb"]) {
            [self performAniDBListImport];
        }
        else if ([_listtype isEqualToString:@"anilist"]) {
            [self performAnilistImport];
        }
    }
}
#pragma mark MyAnimeList Import
- (IBAction)importMALList:(id)sender{
    if ([Utility checkifFileExists:[listservice retrieveListFileName:0] appendPath:@""] && [Utility checkifFileExists:[listservice retrieveListFileName:1] appendPath:@""]) {
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
                       if (!d[@"myanimelist"]) {
                            [Utility showsheetmessage:@"Invalid list." explaination:@"This is not a MyAnimeList XML formatted list. Please select a valid XML file and try again." window:[_del getMainWindowController].window];
                           return;
                       }
                       d = d[@"myanimelist"];
                       if (d[@"anime"]) {
                           _importlisttype = MALAnime;
                           _listimport = d[@"anime"];
                           _existinglist = [Utility loadJSON:[listservice retrieveListFileName:0] appendpath:@""][@"anime"];
                       }
                       else if (d[@"manga"]) {
                           if (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"]).boolValue) {
                           _importlisttype = MALManga;
                           _listimport = d[@"manga"];
                           _existinglist = [Utility loadJSON:[listservice retrieveListFileName:1] appendpath:@""][@"manga"];
                           }
                           else {
                               [Utility showsheetmessage:@"Unable to import list." explaination:@"Manga import requires a donation key." window:[_del getMainWindowController].window];
                               return;
                           }
                       }
                       if (![_listimport isKindOfClass:[NSArray class]]){
                           // Import only contains one object, put it in an array.
                           _listimport = @[_listimport];
                       }
                       _replaceexisting = (((NSButton*)op.accessoryView).state == NSOnState);
                       _listtype = @"myanimelist";
                       [self importsetup];
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
        switch ([listservice getCurrentServiceID]) {
            case 1: {
                if ([self checkiftitleisonlist:((NSString *)d[@"series_animedb_id"][@"text"]).intValue]) {
                    if (_replaceexisting || ((NSString *)d[@"update_on_import"][@"text"]).intValue == 1) {
                        [self performanimetitleupdate:((NSString *)d[@"series_animedb_id"][@"text"]).intValue withEpisode:((NSString *)d[@"my_watched_episodes"][@"text"]).intValue withStatus:((NSString *)d[@"my_status"][@"text"]).lowercaseString withTags:d[@"my_tags"][@"text"] ? d[@"my_tags"][@"text"] : @"" withScore:((NSString *)d[@"my_score"][@"text"]).intValue withDictionary:d withTitle:d[@"series_title"][@"text"]];
                    }
                    else {
                        [self incrementProgress:nil withTitle:nil];
                    }
                }
                else {
                    [self performanimetitleadd:((NSString *)d[@"series_animedb_id"][@"text"]).intValue withEpisode:((NSString *)d[@"my_watched_episodes"][@"text"]).intValue withStatus:((NSString *)d[@"my_status"][@"text"]).lowercaseString withTags:d[@"my_tags"][@"text"] ? d[@"my_tags"][@"text"] : @"" withScore:((NSString *)d[@"my_score"][@"text"]).intValue withDictionary:d withTitle:d[@"series_title"][@"text"]];
                }
				break;
            }
            case 2: {
                [TitleIdConverter getKitsuIDFromMALId:((NSString *)d[@"series_animedb_id"][@"text"]).intValue withTitle:d[@"series_title"][@"text"] titletype:d[@"series_type"][@"text"] withType:MALAnime completionHandler:^(int kitsuid) {
                    if ([self checkiftitleisonlist:kitsuid]) {
                        if (_replaceexisting || ((NSString *)d[@"update_on_import"][@"text"]).intValue == 1) {
                            [self performanimetitleupdate:[self retrieveentryidfortitleid:kitsuid] withEpisode:((NSString *)d[@"my_watched_episodes"][@"text"]).intValue withStatus:((NSString *)d[@"my_status"][@"text"]).lowercaseString withTags:d[@"my_tags"][@"text"] ? d[@"my_tags"][@"text"] : @"" withScore:[RatingTwentyConvert translateadvancedKitsuRatingtoRatingTwenty:((NSString *)d[@"my_score"][@"text"]).intValue] withDictionary:d withTitle:d[@"series_title"][@"text"]];
                        }
                        else {
                            [self incrementProgress:nil withTitle:nil];
                        }
                    }
                    else {
                        [self performanimetitleadd:kitsuid withEpisode:((NSString *)d[@"my_watched_episodes"][@"text"]).intValue withStatus:((NSString *)d[@"my_status"][@"text"]).lowercaseString withTags:d[@"my_tags"][@"text"] ? d[@"my_tags"][@"text"] : @"" withScore:[RatingTwentyConvert translateadvancedKitsuRatingtoRatingTwenty:((NSString *)d[@"my_score"][@"text"]).intValue] withDictionary:d withTitle:d[@"series_title"][@"text"]];
                    }
                } error:^(NSError *error) {
                    [self incrementProgress:d withTitle:d[@"series_title"][@"text"]];
                }];
                break;
            }
            case 3: {
                [TitleIdConverter getAniIDFromMALListID:((NSString *)d[@"series_animedb_id"][@"text"]).intValue withTitle:d[@"series_title"][@"text"] titletype:d[@"series_type"][@"text"] withType:MALAnime completionHandler:^(int anilistid) {
                    if ([self checkiftitleisonlist:anilistid]) {
                        if (_replaceexisting || ((NSString *)d[@"update_on_import"][@"text"]).intValue == 1) {
                            [self performanimetitleupdate:[self retrieveentryidfortitleid:anilistid] withEpisode:((NSString *)d[@"my_watched_episodes"][@"text"]).intValue withStatus:((NSString *)d[@"my_status"][@"text"]).lowercaseString withTags:d[@"my_tags"][@"text"] ? d[@"my_tags"][@"text"] : @"" withScore:((NSString *)d[@"my_score"][@"text"]).intValue * 10 withDictionary:d withTitle:d[@"series_title"][@"text"]];
                        }
                        else {
                            [self incrementProgress:nil withTitle:nil];
                        }
                    }
                    else {
                        [self performanimetitleadd:anilistid withEpisode:((NSString *)d[@"my_watched_episodes"][@"text"]).intValue withStatus:((NSString *)d[@"my_status"][@"text"]).lowercaseString withTags:d[@"my_tags"][@"text"] ? d[@"my_tags"][@"text"] : @"" withScore:((NSString *)d[@"my_score"][@"text"]).intValue * 10 withDictionary:d withTitle:d[@"series_title"][@"text"]];
                    }
                } error:^(NSError *error) {
                    [self incrementProgress:d withTitle:d[@"series_title"][@"text"]];
                }];
                break;
            }
            default:
                break;
		}
    }
}

- (void)importMangaMALEntry {
    if (_listimport.count > 0) {
        NSDictionary *d = _listimport[_progress];
        switch ([listservice getCurrentServiceID]) {
            case 1: {
                if ([self checkiftitleisonlist:((NSString *)d[@"manga_mangadb_id"][@"text"]).intValue]) {
                    if (_replaceexisting || ((NSString *)d[@"update_on_import"][@"text"]).intValue == 1) {
                        [self performmangatitleupdate:((NSString *)d[@"manga_mangadb_id"][@"text"]).intValue withChapter:((NSString *)d[@"my_read_chapters"][@"text"]).intValue withVolumes:((NSString *)d[@"my_read_volumes"][@"text"]).intValue withStatus:((NSString *)d[@"my_status"][@"text"]).lowercaseString withTags:d[@"my_tags"][@"text"] ? d[@"my_tags"][@"text"] : @"" withScore:((NSString *)d[@"my_score"][@"text"]).intValue withDictionary:d withTitle:d[@"manga_title"][@"text"]];
                    }
                    else {
                        [self incrementProgress:nil withTitle:nil];
                    }
                }
                else {
                    [self performmangatitleadd:((NSString *)d[@"manga_mangadb_id"][@"text"]).intValue withChapter:((NSString *)d[@"my_read_chapters"][@"text"]).intValue withVolumes:((NSString *)d[@"my_read_volumes"][@"text"]).intValue withStatus:((NSString *)d[@"my_status"][@"text"]).lowercaseString withTags:d[@"my_tags"][@"text"] ? d[@"my_tags"][@"text"] : @"" withScore:((NSString *)d[@"my_score"][@"text"]).intValue withDictionary:d withTitle:d[@"manga_title"][@"text"]];
                }
                break;
            }
            case 2: {
                [TitleIdConverter getKitsuIDFromMALId:((NSString *)d[@"manga_mangadb_id"][@"text"]).intValue withTitle:d[@"manga_title"][@"text"] titletype:@""  withType:MALManga completionHandler:^(int kitsuid) {
                    if ([self checkiftitleisonlist:kitsuid]) {
                        if (_replaceexisting || ((NSString *)d[@"update_on_import"][@"text"]).intValue == 1) {
                            [self performmangatitleupdate:[self retrieveentryidfortitleid:kitsuid] withChapter:((NSString *)d[@"my_read_chapters"][@"text"]).intValue withVolumes:((NSString *)d[@"my_read_volumes"][@"text"]).intValue withStatus:((NSString *)d[@"my_status"][@"text"]).lowercaseString withTags:d[@"my_tags"][@"text"] ? d[@"my_tags"][@"text"] : @"" withScore:[RatingTwentyConvert translateadvancedKitsuRatingtoRatingTwenty:((NSString *)d[@"my_score"][@"text"]).intValue] withDictionary:d withTitle:d[@"manga_title"][@"text"]];
                        }
                        else {
                            [self incrementProgress:nil withTitle:nil];
                        }
                    }
                    else {
                        [self performmangatitleadd:kitsuid withChapter:((NSString *)d[@"my_read_chapters"][@"text"]).intValue withVolumes:((NSString *)d[@"my_read_volumes"][@"text"]).intValue withStatus:((NSString *)d[@"my_status"][@"text"]).lowercaseString withTags:d[@"my_tags"][@"text"] ? d[@"my_tags"][@"text"] : @"" withScore:[RatingTwentyConvert translateadvancedKitsuRatingtoRatingTwenty:((NSString *)d[@"my_score"][@"text"]).intValue] withDictionary:d withTitle:d[@"manga_title"][@"text"]];
                    }
                } error:^(NSError *error) {
                    [self incrementProgress:d withTitle:d[@"manga_title"][@"text"]];
                }];
                break;
            }
            case 3: {
                [TitleIdConverter getAniIDFromMALListID:((NSString *)d[@"manga_mangadb_id"][@"text"]).intValue withTitle:d[@"manga_title"][@"text"] titletype:@""  withType:MALManga completionHandler:^(int anilistid) {
                    if ([self checkiftitleisonlist:anilistid]) {
                        if (_replaceexisting || ((NSString *)d[@"update_on_import"][@"text"]).intValue == 1) {
                            [self performmangatitleupdate:[self retrieveentryidfortitleid:anilistid] withChapter:((NSString *)d[@"my_read_chapters"][@"text"]).intValue withVolumes:((NSString *)d[@"my_read_volumes"][@"text"]).intValue withStatus:((NSString *)d[@"my_status"][@"text"]).lowercaseString withTags:d[@"my_tags"][@"text"] ? d[@"my_tags"][@"text"] : @"" withScore:((NSString *)d[@"my_score"][@"text"]).intValue * 10 withDictionary:d withTitle:d[@"manga_title"][@"text"]];
                        }
                        else {
                            [self incrementProgress:nil withTitle:nil];
                        }
                    }
                    else {
                        [self performmangatitleadd:anilistid withChapter:((NSString *)d[@"my_read_chapters"][@"text"]).intValue withVolumes:((NSString *)d[@"my_read_volumes"][@"text"]).intValue withStatus:((NSString *)d[@"my_status"][@"text"]).lowercaseString withTags:d[@"my_tags"][@"text"] ? d[@"my_tags"][@"text"] : @"" withScore:((NSString *)d[@"my_score"][@"text"]).intValue * 10 withDictionary:d withTitle:d[@"manga_title"][@"text"]];
                    }
                } error:^(NSError *error) {
                    [self incrementProgress:d withTitle:d[@"manga_title"][@"text"]];
                }];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark Anidb Import
- (IBAction)importAniDBList:(id)sender {
    if ([Utility checkifFileExists:[listservice retrieveListFileName:0] appendPath:@""]) {
        NSOpenPanel * op = [NSOpenPanel openPanel];
        op.allowedFileTypes = @[@"XML", @"Extended Markup File file"];
        op.message = @"Please select the exported AniDB XML List file to import.";
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
                        _replaceexisting = (((NSButton*)op.accessoryView).state == NSOnState);
                       NSError *error = nil;
                    NSDictionary *d = [XMLReader dictionaryForXMLString:str options:XMLReaderOptionsProcessNamespaces error:&error];
                       if (d[@"mylist"]) {
                           if (d[@"mylist"][@"anime"]) {
                               _listimport = d[@"mylist"][@"anime"];
                               if (![_listimport isKindOfClass:[NSArray class]]){
                                   // Import only contains one object, put it in an array.
                                   _listimport = @[_listimport];
                               }
                               _listtype = @"anidb";
                               _importlisttype = MALAnime;
                               _existinglist = [Utility loadJSON:[listservice retrieveListFileName:0] appendpath:@""][@"anime"];
                               [self importsetup];
                               [self performAniDBListImport];
                           }
                       }
                       else {
                           [Utility showsheetmessage:@"Invalid list." explaination:@"This is not a AniDB XML formatted list. Please select a valid XML file and try again." window:[_del getMainWindowController].window];
                       }
                   }];
    }
    else {
        [_del showloginnotice];
    }
    
}
- (void)performAniDBListImport {
    NSDictionary *entry = _listimport[_progress];
    NSString *type = entry[@"type_name"][@"text"];
    type = [type stringByReplacingOccurrencesOfString:@" Series" withString:@""];
    if ([type isEqualToString:@"Web"]) {
        type = @"ONA";
    }
    if ([type isEqualToString:@"TV Special"]) {
        type = @"Special";
    }
    if ([type isEqualToString:@"Music Video"]) {
        type = @"Music";
    }
    switch ([listservice getCurrentServiceID]) {
        case 1: {
            [TitleIdConverter getMALIDFromServiceID:((NSString *)entry[@"animenfoid"][@"text"]).intValue withTitle:entry[@"name"][@"text"] titletype:type withType:MALAnime fromServiceID:4 completionHandler:^(int malid) {
                [self performMALUpdatefromAniDBEntry:entry withMALID:malid];
            } error:^(NSError *error) {
                [self incrementProgress:entry withTitle:entry[@"name"][@"text"]];
            }];
             break;
        }
        case 2: {
            [TitleIdConverter getKitsuIdFromAniID:((NSString *)entry[@"animenfoid"][@"text"]).intValue withTitle:entry[@"name"][@"text"] titletype:type withType:MALAnime completionHandler:^(int kitsuid) {
                [self performMALUpdatefromAniDBEntry:entry withMALID:kitsuid];
            } error:^(NSError *error) {
                [self incrementProgress:entry withTitle:entry[@"name"][@"text"]];
            }];
        }
        case 3: {
            [TitleIdConverter getMALIDFromServiceID:((NSString *)entry[@"animenfoid"][@"text"]).intValue withTitle:entry[@"name"][@"text"] titletype:type withType:MALAnime fromServiceID:4 completionHandler:^(int malid) {
                [TitleIdConverter getAniIDFromMALListID:malid withTitle:entry[@"name"][@"text"] titletype:type withType:AniListAnime completionHandler:^(int anilistid) {
                    [self performMALUpdatefromAniDBEntry:entry withMALID:anilistid];
                } error:^(NSError *error) {
                    [self incrementProgress:entry withTitle:entry[@"name"][@"text"]];
                }];
            } error:^(NSError *error) {
                [self incrementProgress:entry withTitle:entry[@"name"][@"text"]];
            }];
            break;
        }
        default:
             break;
    }
}
- (void)performMALUpdatefromAniDBEntry:(NSDictionary *)entry withMALID:(int)malid {
    NSString *status;
    int watchedeps = 0;
    if (entry[@"my_watchedeps"][@"text"]) {
        watchedeps = ((NSNumber *)entry[@"my_watchedeps"][@"text"]).intValue;
    }
    if (watchedeps == ((NSString *)entry[@"eps"][@"text"]).intValue || entry[@"complete"]) {
        status = @"completed";
    }
    else if (watchedeps == 0) {
        status = @"plan to watch";
    }
    else {
        status = @"watching";
    }
    if ([self checkiftitleisonlist:malid]) {
        if (_replaceexisting) {
            int tmpid = 0;
            switch ([listservice getCurrentServiceID]) {
                case 1:
                    tmpid = malid;
                    break;
                case 2:
                case 3:
                    tmpid = [self retrieveentryidfortitleid:malid];
                    break;
                default:
                    break;
            }
            [listservice updateAnimeTitleOnList:tmpid withEpisode:watchedeps withStatus:status withScore:0 withTags:nil withExtraFields:nil completion:^(id responseObject){
                [self incrementProgress:nil withTitle:nil];
            }error:^(id error){
                [self incrementProgress:entry withTitle:entry[@"name"][@"text"]];
            }];
        }
        else {
            [self incrementProgress:nil withTitle:nil];
        }
    }
    else {
        [listservice addAnimeTitleToList:malid withEpisode:watchedeps withStatus:status withScore:0 completion:^(id responseObject){
            [self incrementProgress:nil withTitle:nil];
        }error:^(id error){
            [self incrementProgress:entry withTitle:entry[@"name"][@"text"]];
        }];
    }
}

#pragma mark Kitsu Import
- (IBAction)importKitsu:(id)sender {
    if ([Utility checkifFileExists:[listservice retrieveListFileName:0] appendPath:@""]) {
        if (!_importprompt){
            _importprompt = [ImportPrompt new];
        }
        [NSApp beginSheet:_importprompt.window
       modalForWindow:[_del getMainWindowController].window modalDelegate:self
       didEndSelector:@selector(KitsuPromptEnd:returnCode:contextInfo:)
          contextInfo:(void *)nil];
        [_importprompt setImportType:ImportKitsu];
    }
    else {
        [_del showloginnotice];
    }
}
- (void)KitsuPromptEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == 1) {
        [self startKitsuImport:_importprompt.usernamefield.stringValue];
    }
    else {
        [_importprompt.window close];
        _importprompt = nil;
    }
}


- (void)startKitsuImport:(NSString *)username {
    [Kitsu retrieveList:username listType:KitsuAnime completion:^(id responseObject) {
        _listimport = responseObject[@"anime"];
        _tmplist = nil;
        _listtype = @"kitsu";
        _importlisttype = MALAnime;
        _replaceexisting = (_importprompt.replaceexisting.state == NSOnState);
        _existinglist = [Utility loadJSON:[listservice retrieveListFileName:0] appendpath:@""][@"anime"];
        [self importsetup];
        [self performKitsuImport];
    } error:^(NSError *error) {
        [Utility showsheetmessage:@"Unable to retrieve Kitsu library." explaination:@"Make sure the username is correct." window:[_del getMainWindowController].window];
    }];
}
- (void)performKitsuImport {
    NSDictionary *entry = _listimport[_progress];
    switch ([listservice getCurrentServiceID]) {
        case 1: {
            [TitleIdConverter getMALIDFromKitsuId:((NSNumber *)entry[@"id"]).intValue withTitle:entry[@"title"] titletype:entry[@"type"]  withType:_importlisttype completionHandler:^(int malid) {
                [self performListServiceUpdateFromKitsuEntry:entry withID:malid];
            } error:^(NSError *error) {
                [self incrementProgress:entry withTitle:entry[@"title"]];
            }];
            break;
        }
        case 3: {
            [TitleIdConverter getAniIDFromKitsuID:((NSNumber *)entry[@"id"]).intValue withTitle:entry[@"title"] titletype:entry[@"type"] withType:_importlisttype completionHandler:^(int anilistid) {
                [self performListServiceUpdateFromKitsuEntry:entry withID:anilistid];
            } error:^(NSError *error) {
                [self incrementProgress:entry withTitle:entry[@"title"]];
            }];
            break;
        }
        default:
            break;
    }
}
- (void)performListServiceUpdateFromKitsuEntry:(NSDictionary *)entry withID:(int)titleid{
    int score = 0;
    int currentservice = [listservice getCurrentServiceID];
    int tmpid = titleid;
    NSString *status = entry[@"watched_status"];
    if (entry[@"score"] > 0) {
        switch ([listservice getCurrentServiceID]) {
            case 1:
                score = [self translateKitsuTwentyScoreToMAL:((NSNumber *)entry[@"score"]).intValue];
                break;
            case 3:
                score = [self translateKitsuTwentyScoreToMAL:((NSNumber *)entry[@"score"]).intValue] * 10;
                break;
            default:
                score = ((NSNumber *)entry[@"score"]).intValue;
                break;
        }
    }
    if ([self checkiftitleisonlist:tmpid]) {
        if (_replaceexisting) {
            if (currentservice == 3) {
                tmpid = [self retrieveentryidfortitleid:tmpid];
            }
            [listservice updateAnimeTitleOnList:tmpid withEpisode:((NSNumber *)entry[@"watched_episodes"]).intValue withStatus:status withScore:score withTags:nil withExtraFields:nil completion:^(id responseObject){
                [self incrementProgress:nil withTitle:nil];
            }error:^(id error){
                [self incrementProgress:entry withTitle:entry[@"title"]];
            }];
        }
        else {
            [self incrementProgress:nil withTitle:nil];
        }
    }
    else {
        [listservice addAnimeTitleToList:titleid withEpisode:((NSNumber *)entry[@"watched_episodes"]).intValue withStatus:status withScore:score completion:^(id responseObject){
            [self incrementProgress:nil withTitle:nil];
        }error:^(id error){
            [self incrementProgress:entry withTitle:entry[@"title"]];
        }];
    }
}

#pragma mark -
#pragma mark Window Delegate
- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark Failed Window
- (IBAction)closefailedwindow:(id)sender {
    [self clearfailedlist];
    [NSApp endSheet:self.failedw returnCode:0];
    [_failedw close];
}

- (IBAction)savefailedlist:(id)sender {
    // Save the json file containing titles
    NSSavePanel * sp = [NSSavePanel savePanel];
    sp.title = @"Save Failed Import Titles";
    sp.allowedFileTypes = @[@"json", @"Javascript Object Notation File"];
    sp.nameFieldStringValue = @"failed.json";
    [sp beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelCancelButton) {
            return;
        }
        NSURL *url = [sp URL];
        //Create JSON string from array controller
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_failedarraycontroller.content
                                                           options:0
                                                             error:&error];
        if (!jsonData) {
            return;
        } else {
            NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
            
            
            //write JSON to file
            BOOL wresult = [JSONString writeToURL:url
                                       atomically:YES
                                         encoding:NSUTF8StringEncoding
                                            error:&error];
            if (! wresult) {
                NSLog(@"Export Failed: %@", error);
            }
            
            [self clearfailedlist];
            [NSApp endSheet:self.failedw returnCode:0];
            [_failedw close];
        }
    }];

}
- (void)clearfailedlist {
    NSMutableArray * a = [_failedarraycontroller mutableArrayValueForKey:@"content"];
    [a removeAllObjects];
    [_failedtb reloadData];
    [_failedtb deselectAll:self];
}

#pragma mark -
#pragma mark Helpers

- (bool)checkiftitleisonlist:(int)idnum {
    NSArray *list = [_existinglist filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
    if (list.count > 0) {
        return true;
    }
    return false;
}
- (int)retrieveentryidfortitleid:(int)idnum {
    NSArray *list = [_existinglist filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
    return list.count > 0 ? ((NSNumber *)list[0][@"entryid"]).intValue : -1;
}

- (int)translateKitsuTwentyScoreToMAL:(int)rating {
    // Translates Kitsu's scoring system to MAL Scoring System
    // Awful (2-5) > 1-3, Meh (6-10) > 3-5, Good (11-15) > 6-8, Great (16-20) > 8-10
    // Advanced Ratings are rounded up.
    switch (rating) {
        case 2:
            return 1;
        case 3:
        case 4:
            return 2;
        case 5:
        case 6:
            return 3;
        case 7:
        case 8:
            return 4;
        case 9:
        case 10:
            return 5;
        case 11:
        case 12:
            return 6;
        case 13:
        case 14:
            return 7;
        case 15:
        case 16:
            return 8;
        case 17:
        case 18:
            return 9;
        case 19:
        case 20:
            return 10;
        default:
            break;
    }
    return 0;
}

- (void)performanimetitleadd:(int)titleid withEpisode:(int)episodenum withStatus:(NSString *)status withTags:(NSString *)tags withScore:(int)score withDictionary:(NSDictionary *)d withTitle:(NSString *)title {
    [listservice addAnimeTitleToList:titleid withEpisode:episodenum withStatus:status withScore:score  completion:^(id responseobject){
        if (tags.length > 0 && [listservice getCurrentServiceID] == 1) {
            // Set Tags by updating the entry
            [listservice updateAnimeTitleOnList:titleid withEpisode:episodenum withStatus:status withScore:score withTags:tags withExtraFields:nil completion:^(id responseobject) {
                [self incrementProgress:nil withTitle:nil];
            }error:^(NSError *error){
                [self incrementProgress:nil withTitle:nil];
            }];
        }
        else {
            [self incrementProgress:nil withTitle:nil];
        }
    }error:^(NSError *error){
        NSLog(@"%@", error.localizedDescription);
        [self incrementProgress:d withTitle:title];
    }];
}
- (void)performanimetitleupdate:(int)titleid withEpisode:(int)episodenum withStatus:(NSString *)status withTags:(NSString *)tags withScore:(int)score withDictionary:(NSDictionary *)d withTitle:(NSString *)title {
    [listservice updateAnimeTitleOnList:titleid withEpisode:episodenum withStatus:status withScore:score withTags:tags withExtraFields:nil completion:^(id responseobject) {
        [self incrementProgress:nil withTitle:nil];
    }error:^(NSError *error){
        NSLog(@"%@", error.localizedDescription);
        [self incrementProgress:d withTitle:title];
    }];
}

- (void)performmangatitleadd:(int)titleid withChapter:(int)chapters withVolumes:(int)volumes withStatus:(NSString *)status withTags:(NSString *)tags withScore:(int)score withDictionary:(NSDictionary *)d withTitle:(NSString *)title {
    [listservice addMangaTitleToList:titleid withChapter:chapters withVolume:volumes withStatus:status withScore:score completion:^(id responseObject){
        if (d[@"my_tags"][@"text"] && [listservice getCurrentServiceID] == 1) {
            // Set Tags by updating the entry
            [listservice updateMangaTitleOnList:((NSString *)d[@"manga_mangadb_id"][@"text"]).intValue withChapter:((NSString *)d[@"my_read_chapters"][@"text"]).intValue withVolume:((NSString *)d[@"my_read_volumes"][@"text"]).intValue withStatus:((NSString *)d[@"my_status"][@"text"]).lowercaseString withScore:((NSString *)d[@"my_score"][@"text"]).intValue withTags:d[@"my_tags"][@"text"] ? d[@"my_tags"][@"text"] : @"" withExtraFields:nil completion:^(id responseObject){
                [self incrementProgress:nil withTitle:nil];
            }error:^(NSError *error){
                [self incrementProgress:nil withTitle:nil];
            }];
        }
        else {
            [self incrementProgress:nil withTitle:nil];
        }
    }error:^(NSError *error){
        [self incrementProgress:d withTitle:title];
    }];
}
- (void)performmangatitleupdate:(int)titleid withChapter:(int)chapters withVolumes:(int)volumes withStatus:(NSString *)status withTags:(NSString *)tags withScore:(int)score withDictionary:(NSDictionary *)d withTitle:(NSString *)title {
    [listservice updateMangaTitleOnList:titleid withChapter:chapters withVolume:volumes withStatus:status withScore:score withTags:tags withExtraFields:nil completion:^(id responseObject){
        [self incrementProgress:nil withTitle:nil];
    }error:^(NSError *error){
        [self incrementProgress:d withTitle:title];
    }];
}

#pragma mark AniList
- (IBAction)importAnilist:(id)sender {
    if ([Utility checkifFileExists:[listservice retrieveListFileName:0] appendPath:@""]) {
        if (!_importprompt){
            _importprompt = [ImportPrompt new];
        }
        [NSApp beginSheet:_importprompt.window
           modalForWindow:[_del getMainWindowController].window modalDelegate:self
           didEndSelector:@selector(AnilistPromptEnd:returnCode:contextInfo:)
              contextInfo:(void *)nil];
        [_importprompt setImportType:ImportAniList];
    }
    else {
        [_del showloginnotice];
    }
}
- (void)AnilistPromptEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == 1) {
        [self startAnilist:_importprompt.usernamefield.stringValue];
    }
    else {
        [_importprompt.window close];
        _importprompt = nil;
    }
}
    
    
- (void)startAnilist:(NSString *)username {
    [AniList retrieveList:username listType:AniListAnime completion:^(id responseObject) {
        _listimport = responseObject[@"anime"];
        _listtype = @"anilist";
        _importlisttype = MALAnime;
        _replaceexisting = (_importprompt.replaceexisting.state == NSOnState);
        _existinglist = [Utility loadJSON:[listservice retrieveListFileName:0] appendpath:@""][@"anime"];
        [self importsetup];
        [self performAnilistImport];
    } error:^(NSError *error) {
        NSLog(@"%@",error);
        [Utility showsheetmessage:@"Unable to retrieve AniList library." explaination:@"Make sure you entered a valid user name and try again." window:[_del getMainWindowController].window];
    }];
}
- (void)performAnilistImport {
    __block NSDictionary *entry = _listimport[_progress];
    switch ([listservice getCurrentServiceID]) {
        case 1: {
            [TitleIdConverter getMALIDFromAniListID:((NSNumber *)entry[@"id"]).intValue withTitle:entry[@"title"] titletype:entry[@"type"] withType:_importlisttype completionHandler:^(int malid) {
                [self performMALUpdateFromAnilistEntry:entry withMALID:malid];
            } error:^(NSError *error) {
                [self incrementProgress:entry withTitle:entry[@"title"]];
            }];
            break;
        }
        case 2: {
            [TitleIdConverter getKitsuIdFromAniID:((NSNumber *)entry[@"id"]).intValue withTitle:entry[@"title"] titletype:entry[@"type"] withType:_importlisttype completionHandler:^(int kitsuid) {
                [self performMALUpdateFromAnilistEntry:entry withMALID:kitsuid];
            } error:^(NSError *error) {
                [self incrementProgress:entry withTitle:entry[@"title"]];
            }];
            break;
        }
        default:
            break;
    }
}
- (void)performMALUpdateFromAnilistEntry:(NSDictionary *)entry withMALID:(int)malid{
    int score = 0;
    NSString *status = entry[@"watched_status"];
    if (entry[@"score"]) {
        switch ([listservice getCurrentServiceID]) {
            case 1:
                score = ((NSNumber *)entry[@"score"]).intValue/10;
                break;
            case 2:
                score = [RatingTwentyConvert translateadvancedKitsuRatingtoRatingTwenty:((NSNumber *)entry[@"score"]).intValue/10];
                break;
            default:
                break;
        }
    }
    if ([self checkiftitleisonlist:malid]) {
        if (_replaceexisting) {
            int tmpid = 0;
            switch ([listservice getCurrentServiceID]) {
                case 1:
                    tmpid = malid;
                    break;
                case 2:
                    tmpid = [self retrieveentryidfortitleid:malid];
                    break;
                default:
                    break;
            }
            [listservice updateAnimeTitleOnList:tmpid withEpisode:((NSNumber *)entry[@"watched_episodes"]).intValue withStatus:status withScore:score withTags:nil withExtraFields:nil completion:^(id responseObject){
                [self incrementProgress:nil withTitle:nil];
            }error:^(id error){
                [self incrementProgress:entry withTitle:entry[@"title"]];
            }];
        }
        else {
            [self incrementProgress:nil withTitle:nil];
        }
    }
    else {
        [listservice addAnimeTitleToList:malid withEpisode:((NSNumber *)entry[@"watched_episodes"]).intValue withStatus:status withScore:score completion:^(id responseObject){
            [self incrementProgress:nil withTitle:nil];
        }error:^(id error){
            [self incrementProgress:entry withTitle:entry[@"title"]];
        }];
    }
}

@end
