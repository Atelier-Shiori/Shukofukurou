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
#import "KitsuImportPrompt.h"

@interface ListImport ()
@property (strong) NSArray *listimport;
@property (strong) NSMutableArray *kitsumalidmapping;
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
@property (strong) KitsuImportPrompt *importprompt;
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
        if (_kitsumalidmapping) {
            // Save mappings and clear kitsu mapping array.
            [Utility saveJSON:_kitsumalidmapping withFilename:@"KitsuMALMappings.json" appendpath:@"" replace:true];
            _kitsumalidmapping = nil;
        }
        _importprompt = nil;
        _metadata = nil;
    }
    else {
        if ([_listtype isEqualToString:@"myanimelist"]) {
            [self performtMALListImport];
        }
        else if([_listtype isEqualToString:@"kitsu"]) {
            [self performKitsuImport];
        }
    }
}
#pragma mark MyAnimeList Import
- (IBAction)importMALList:(id)sender{
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
                           if (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"]).boolValue) {
                           _importlisttype = MALManga;
                           _listimport = d[@"manga"];
                           _existinglist = [Utility loadJSON:@"mangalist.json" appendpath:@""][@"manga"];
                           }
                           else {
                               [Utility showsheetmessage:@"Unable to import list." explaination:@"Manga import requires a donation key." window:[_del getMainWindowController].window];
                               return;
                           }
                       }
                       if (![_listimport isKindOfClass:[NSArray class]]){
                           // Import only contains one object, put it in an array.
                           _listimport = [NSArray arrayWithObject:_listimport];
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
        if ([self checkiftitleisonlist:((NSString *)d[@"series_animedb_id"][@"text"]).intValue]) {
            if (_replaceexisting || ((NSString *)d[@"update_on_import"][@"text"]).intValue == 1) {
                [MyAnimeList updateAnimeTitleOnList:[(NSString *)d[@"series_animedb_id"][@"text"] intValue] withEpisode:[(NSString *)d[@"my_watched_episodes"][@"text"] intValue] withStatus:(NSString *)d[@"my_status"][@"text"] withScore:[(NSString *)d[@"my_score"][@"text"] intValue]  completion:^(id responseobject){
                    [self incrementProgress:nil withTitle:nil];
                }error:^(NSError *error){
                    [self incrementProgress:d withTitle:d[@"series_title"][@"text"]];
                }];
            }
            else {
                [self incrementProgress:nil withTitle:nil];
            }
        }
        else {
            [MyAnimeList addAnimeTitleToList:[(NSString *)d[@"series_animedb_id"][@"text"] intValue] withEpisode:[(NSString *)d[@"my_watched_episodes"][@"text"] intValue] withStatus:(NSString *)d[@"my_status"][@"text"] withScore:[(NSString *)d[@"my_score"][@"text"] intValue]  completion:^(id responseobject){
                [self incrementProgress:nil withTitle:nil];
            }error:^(NSError *error){
                [self incrementProgress:d withTitle:d[@"series_title"][@"text"]];
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
                    [self incrementProgress:nil withTitle:nil];
                }error:^(NSError *error){
                    [self incrementProgress:d withTitle:d[@"manga_title"][@"text"]];
                }];
            }
            else {
                [self incrementProgress:nil withTitle:nil];
            }
        }
        else {
            [MyAnimeList addMangaTitleToList:((NSString *)d[@"manga_mangadb_id"][@"text"]).intValue withChapter:((NSString *)d[@"my_read_chapters"][@"text"]).intValue withVolume:((NSString *)d[@"my_read_volumes"][@"text"]).intValue withStatus:(NSString *)d[@"my_status"][@"text"] withScore:((NSString *)d[@"my_score"][@"text"]).intValue completion:^(id responseObject){
                [self incrementProgress:nil withTitle:nil];
            }error:^(NSError *error){
                [self incrementProgress:d withTitle:d[@"manga_title"][@"text"]];
            }];
        }
    }
}



#pragma mark Kitsu Import
- (IBAction)importKitsu:(id)sender {
    if ([Utility checkifFileExists:@"animelist.json" appendPath:@""]) {
        if (!_importprompt){
            _importprompt = [KitsuImportPrompt new];
        }
        [NSApp beginSheet:_importprompt.window
       modalForWindow:[_del getMainWindowController].window modalDelegate:self
       didEndSelector:@selector(KitsuPromptEnd:returnCode:contextInfo:)
          contextInfo:(void *)nil];
    }
    else {
        [_del showloginnotice];
    }
}
- (void)KitsuPromptEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == 1) {
        [self startKitsuImport:_importprompt.kitsuusernamefield.stringValue];
    }
    else {
        [_importprompt.window close];
        _importprompt = nil;
    }
}


- (void)startKitsuImport:(NSString *)username {
    [self getKitsuidfromUserName:username completionHandler:^(id responseObject) {
        NSArray *data = responseObject[@"data"];
        if (data.count > 0) {
            NSDictionary *d = data[0];
            [self retrieveKitsuLibrary:((NSNumber *)d[@"id"]).intValue atPage:0 completionHandler:^(id responseObject) {
                _listimport = [_tmplist copy];
                _tmplist = nil;
                _listtype = @"kitsu";
                _importlisttype = MALAnime;
                _replaceexisting = (_importprompt.kitsureplaceexisting.state == NSOnState);
                _existinglist = [Utility loadJSON:@"animelist.json" appendpath:@""][@"anime"];
                if (!_kitsumalidmapping) {
                    _kitsumalidmapping = [NSMutableArray new];
                }
                if ([Utility checkifFileExists:@"KitsuMALMappings.json" appendPath:@""]) {
                    [_kitsumalidmapping addObjectsFromArray:[Utility loadJSON:@"KitsuMALMappings.json" appendpath:@""]];
                }
                [self importsetup];
                [self performKitsuImport];
            } error:^(NSError *error){
                NSLog(@"%@",error);
                [Utility showsheetmessage:@"Unable to retrieve Kitsu library." explaination:@"Please try again." window:[_del getMainWindowController].window];
            }];
        }
        else {
            [Utility showsheetmessage:@"Unable to retrieve Kitsu library." explaination:@"Make sure the username is correct." window:[_del getMainWindowController].window];
        }
    }error:^(NSError *error){
        NSLog(@"%@",error);
        [Utility showsheetmessage:@"Unable to retrieve Kitsu library." explaination:@"Please try again." window:[_del getMainWindowController].window];
    }];
}
- (void)performKitsuImport {
    NSDictionary *entry = _listimport[_progress];
    if (entry[@"relationships"][@"anime"][@"data"] != [NSNull null]) {
        NSNumber *malid = [self checkifmappingexists:((NSNumber *)entry[@"relationships"][@"anime"][@"id"]).intValue];
        if (!malid) {
            [self retrieveMALID:entry[@"relationships"][@"anime"][@"data"][@"id"] completionHandler:^(int amalid) {
                [_kitsumalidmapping addObject:@{@"kitsu_id":entry[@"relationships"][@"anime"][@"data"][@"id"], @"mal_id":@(amalid)}];
                [self performMALUpdateFromKitsuEntry:entry withMALID:amalid];
            }error:^(NSError *error) {
                [self incrementProgress:entry withTitle:[self retrieveTitlefromKitsuID:((NSNumber *)entry[@"relationships"][@"anime"][@"data"][@"id"]).intValue]];
            }];
        }
        else {
            [self performMALUpdateFromKitsuEntry:entry withMALID:malid.intValue];
        }
    }
    else {
        [self incrementProgress:entry withTitle:nil];
    }
}
- (void)performMALUpdateFromKitsuEntry:(NSDictionary *)entry withMALID:(int)malid{
    int score = 0;
    NSDictionary *attributes = entry[@"attributes"];
    NSString *status = attributes[@"status"];
    if ([status isEqualToString:@"on_hold"]) {
        status = @"onhold";
    }
    else if ([status isEqualToString:@"planned"]) {
        status = @"plan to watch";
    }
    if (attributes[@"ratingTwenty"] != [NSNull null]) {
        NSNumber *ratingtwenty = attributes[@"ratingTwenty"];
        score = [self translateKitsuTwentyScoreToMAL:ratingtwenty.intValue];
    }
    else if (attributes[@"rating"] != [NSNull null]) {
        score = (int)roundf(((NSNumber *)attributes[@"rating"]).floatValue);
    }
    if ([self checkiftitleisonlist:malid]) {
        if (_replaceexisting) {
            [MyAnimeList updateAnimeTitleOnList:malid withEpisode:((NSNumber *)attributes[@"progress"]).intValue withStatus:status withScore:score completion:^(id responseObject){
                [self incrementProgress:nil withTitle:nil];
            }error:^(id error){
                [self incrementProgress:entry withTitle:[self retrieveTitlefromKitsuID:((NSNumber *)entry[@"relationships"][@"anime"][@"data"][@"id"]).intValue]];
            }];
        }
        else {
            [self incrementProgress:nil withTitle:nil];
        }
    }
    else {
        [MyAnimeList addAnimeTitleToList:malid withEpisode:((NSNumber *)attributes[@"progress"]).intValue withStatus:status withScore:score completion:^(id responseObject){
            [self incrementProgress:nil withTitle:nil];
        }error:^(id error){
            [self incrementProgress:entry withTitle:[self retrieveTitlefromKitsuID:((NSNumber *)entry[@"relationships"][@"anime"][@"data"][@"id"]).intValue]];
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

- (bool)checkiftitleisonlist:(int)idnum{
    NSArray *list = [_existinglist filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", idnum]];
    if (list.count > 0) {
        return true;
    }
    return false;
}
     
- (NSNumber*)checkifmappingexists:(int)idnum{
 NSArray *list = [_kitsumalidmapping filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"kitsu_id == %i", idnum]];
 if (list.count > 0) {
     return list[0][@"mal_id"];
 }
 return nil;
}

- (NSString *)retrieveTitlefromKitsuID:(int)kitsuid {
    NSArray *list = [_metadata filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %i", kitsuid]];
    if (list.count > 0) {
        return list[0][@"attributes"][@"canonicalTitle"];
    }
    return nil;
}

- (void)getKitsuidfromUserName:(NSString *)username completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.api+json"];
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/users?filter[name]=%@",[Utility urlEncodeString:username]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        errorHandler(error);
    }];
}

- (void)retrieveKitsuLibrary:(int)userID atPage:(int)pagenum completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.api+json"];
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/library-entries?filter[userId]=%i&include=anime&page[limit]=500&page[offset]=%i",userID, pagenum] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (responseObject[@"data"]){
            if (!_tmplist){
                _tmplist = [NSMutableArray new];
            }
                
            [_tmplist addObjectsFromArray:responseObject[@"data"]];
            if (responseObject[@"included"]){
                [_metadata addObjectsFromArray:responseObject[@"included"]];
            }
            if (responseObject[@"links"][@"next"]) {
                int nextPage = pagenum+1;
                [self retrieveKitsuLibrary:userID atPage:nextPage completionHandler:completionHandler error:errorHandler];
            }
            else {
                completionHandler(responseObject);
            }
        }
        else {
            completionHandler(responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        errorHandler(error);
    }];
}

- (void)retrieveMALID:(NSNumber *)kitsuid completionHandler:(void (^)(int malid)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.api+json"];
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/anime/%@/mappings", kitsuid] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSArray * mappings = responseObject[@"data"];
        for (NSDictionary *m in mappings) {
            if ([[NSString stringWithFormat:@"%@",[m[@"attributes"] valueForKey:@"externalSite"]] isEqualToString:@"myanimelist/anime"]) {
                NSString *MALID = [NSString stringWithFormat:@"%@",[m[@"attributes"] valueForKey:@"externalId"]];
                completionHandler(MALID.intValue);
                return;
            }
        }
        completionHandler(0);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        errorHandler(error);
    }];
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
            return 0;
    }
    return 0;
}
@end
