//
//  ListExporter.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/05/09.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "ListExporter.h"
#import "listservice.h"
#import "Utility.h"
#import "AppDelegate.h"
#import "Keychain.h"
#import "ExportProgressWindow.h"
#import "AtarashiiListCoreData.h"

@interface ListExporter ()
@property ExportProgressWindow *epw;
@end

@implementation ListExporter
- (instancetype)init {
    if (![super init]) {
        return nil;
    }
    _epw = [ExportProgressWindow new];
    __weak ListExporter *weakself = self;
    _epw.completion = ^(NSDictionary *list, int listType) {
        NSSavePanel * sp = [NSSavePanel savePanel];
        sp.title = @"Export Converted List";
        sp.allowedFileTypes = @[@"xml", @"Extended Markup Language File"];
        sp.message = @"Where do you want to export your List?";
        sp.nameFieldStringValue = listType == MALAnime ? @"animelist.xml" : @"mangalist.xml";
        [sp beginWithCompletionHandler:^(NSInteger result) {
            if (result == NSFileHandlingPanelCancelButton) {
                return;
            }
            [weakself writeListXML:list withFileURL:sp.URL withType:listType];
        }];
    };
    return self;
}
- (IBAction)exportAnimeList:(id)sender {
    // Export Anime List to MyAnimeList XML Format
    // Note that not all fields can be exported since some fields are not exposed by the API
    if ([listservice checkAccountForCurrentService]) {
        NSSavePanel * sp = [NSSavePanel savePanel];
        sp.title = @"Export Anime List";
        sp.allowedFileTypes = @[@"xml", @"Extended Markup Language File"];
        sp.message = @"Where do you want to export your Anime List?";
        sp.nameFieldStringValue = @"animelist.xml";
        [sp beginWithCompletionHandler:^(NSInteger result) {
            if (result == NSFileHandlingPanelCancelButton) {
                return;
            }
          [self writeListXML:[AtarashiiListCoreData retrieveEntriesForUserName:[listservice getCurrentServiceUsername] withService:[listservice getCurrentServiceID] withType:MALAnime] withFileURL:sp.URL withType:MALAnime];
        }];
    }
    else {
        // User not logged in, show login notice
        AppDelegate *delegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
        [delegate showloginnotice];
    }
}

- (IBAction)exportMangaList:(id)sender {
    // Export Manga List to MyAnimeList XML Format
    // Note that not all fields can be exported since some fields are not exposed by the API
    if ([listservice checkAccountForCurrentService]) {
        NSSavePanel * sp = [NSSavePanel savePanel];
        sp.title = @"Export Manga List";
        sp.allowedFileTypes = @[@"xml", @"Extended Markup Language File"];
        sp.message = @"Where do you want to export your Manga List?";
        sp.nameFieldStringValue = @"Mangalist.xml";
        [sp beginWithCompletionHandler:^(NSInteger result) {
            if (result == NSFileHandlingPanelCancelButton) {
                return;
            }
            [self writeListXML:[AtarashiiListCoreData retrieveEntriesForUserName:[listservice getCurrentServiceUsername] withService:[listservice getCurrentServiceID] withType:MALManga] withFileURL:sp.URL withType:MALManga];
        }];
    }
    else {
        // User not logged in, show login notice
        AppDelegate *delegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
        [delegate showloginnotice];
    }
}

- (IBAction)exportconvertedAnimeList:(id)sender {
    if ([listservice checkAccountForCurrentService]) {
        [_epw checklist:MALAnime];
    }
    else {
        // User not logged in, show login notice
        AppDelegate *delegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
        [delegate showloginnotice];
    }
}

- (IBAction)exportconvertedMangaList:(id)sender {
    if ([listservice checkAccountForCurrentService]) {
        [_epw checklist:MALManga];
    }
    else {
        // User not logged in, show login notice
        AppDelegate *delegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
        [delegate showloginnotice];
    }
}

- (void)writeListXML:(NSDictionary *)animelist withFileURL:(NSURL *)fileURL withType:(int)type {
    NSURL *url = fileURL;
    // Load List
    NSError *error;
    NSMutableArray *XMLArray = [[NSMutableArray alloc] init];
    NSArray *list;
    if (type == MALAnime) {
        list = animelist[@"anime"];
    }
    else {
        list = animelist[@"manga"];
    }
    // Generate XML from list
    for (NSDictionary *d in list) {
        if (type == MALAnime) {
            [XMLArray addObject:@{@"series_animedb_id":d[@"id"], @"series_title":d[@"title"],@"series_type":d[@"type"], @"series_episodes":d[@"episodes"], @"my_watched_episodes":d[@"watched_episodes"], @"my_score":d[@"score"], @"my_status":d[@"watched_status"], @"my_tags":d[@"personal_tags"] && d[@"personal_tags"] != [NSNull null] ? [d[@"personal_tags"] componentsJoinedByString:@","] : @"", @"update_on_import":@(0), @"my_start_date" : d[@"watching_start"] && ((NSString *)d[@"watching_start"]).length > 0 ? d[@"watching_start"] : @"0000-00-00",  @"my_finish_date" : d[@"watching_end"] && ((NSString *)d[@"watching_end"]).length > 0 ? d[@"watching_end"] : @"0000-00-00", @"my_comments" : d[@"personal_comments"] && d[@"personal_comments"] != [NSNull null] ? d[@"personal_comments"] : @"", @"my_times_rewatched" : d[@"rewatch_count"] ? d[@"rewatch_count"]  : @(0), @"my_rewatching" : d[@"rewatching"]}];
        }
        else {
            [XMLArray addObject:@{@"manga_mangadb_id":d[@"id"], @"manga_title":d[@"title"], @"manga_volumes":d[@"volumes"], @"manga_chapters":d[@"chapters"], @"my_read_volumes":d[@"volumes_read"],@"my_read_chapters":d[@"chapters_read"], @"my_score":d[@"score"], @"my_status":d[@"read_status"], @"my_tags":d[@"personal_tags"]  && d[@"personal_tags"] != [NSNull null] ? [d[@"personal_tags"] componentsJoinedByString:@","] : @"", @"update_on_import":@(0), @"my_start_date" : d[@"reading_start"] && ((NSString *)d[@"reading_start"]).length > 0 ? d[@"reading_start"] : @"0000-00-00",  @"my_finish_date" : d[@"reading_end"] && ((NSString *)d[@"reading_end"]).length > 0 ? d[@"reading_end"] : @"0000-00-00", @"my_comments" : d[@"personal_comments"] && d[@"personal_comments"] != [NSNull null] ? d[@"personal_comments"] : @"", @"my_times_read" : d[@"reread_count"] ? d[@"reread_count"]  : @(0)}];
        }
    }
    //Write XML to file
    BOOL wresult;
    if (type == MALAnime) {
        wresult = [[self generateAnimeListXML:XMLArray] writeToURL:url
                                                         atomically:YES
                                                           encoding:NSUTF8StringEncoding
                                                              error:&error];
    }
    else {
        wresult = [[self generateMangaListXML:XMLArray] writeToURL:url
                                                             atomically:YES
                                                               encoding:NSUTF8StringEncoding
                                                                  error:&error];
    }
    if (! wresult) {
        NSLog(@"Export Failed: %@", error);
    }
}
- (NSString *)generateAnimeListXML:(NSArray *)a {
    NSString *headerstring = @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n\t<!--\n\tCreated by Shukofukurou\n\tProgrammed by MAL Updater OS X Group Software (James Moy), a division of Moy IT Solutions \n\tNote that not all values are exposed by the API and not all fields will be exported.\n\t--> \n\n\t<myanimelist>";
    NSString *footerstring = @"\n\n\t</myanimelist>";
    NSString *animepretag = @"\n\n\t\t<anime>";
    NSString *animeendtag = @"\n\t\t</anime>";
    NSString *tabformatting = @"\n\t\t\t";
    NSMutableString *output = [NSMutableString new];
    [output appendString:headerstring];
    [output appendString:@"\n\n\t<myinfo>"];
    switch ([listservice getCurrentServiceID]) {
        case 1:
            [output appendFormat:@"%@<username>%@</username>",tabformatting, [Keychain getusername]];
            break;
        case 2:
        case 3:
            [output appendFormat:@"%@<username>%@</username>",tabformatting, [listservice getCurrentServiceUsername]];
            break;
        default:
            break;
    }
    [output appendFormat:@"%@<user_export_type>1</user_export_type>",tabformatting];
    [output appendString:@"\n\t</myinfo>"];
    for (NSDictionary *d in a) {
        [output appendString:animepretag];
        [output appendFormat:@"%@<series_animedb_id>%@</series_animedb_id>",tabformatting,d[@"series_animedb_id"]];
        [output appendFormat:@"%@<series_title><![CDATA[%@]]></series_title>",tabformatting,d[@"series_title"]];
        [output appendFormat:@"%@<series_type>%@</series_type>",tabformatting,d[@"series_type"]];
        [output appendFormat:@"%@<series_episodes>%@</series_episodes>",tabformatting,d[@"series_episodes"]];
        [output appendFormat:@"%@<my_id>0</my_id>",tabformatting];
        [output appendFormat:@"%@<my_watched_episodes>%@</my_watched_episodes>",tabformatting,d[@"my_watched_episodes"]];
        [output appendFormat:@"%@<my_start_date>%@</my_start_date>", tabformatting, d[@"my_start_date"]];
        [output appendFormat:@"%@<my_finish_date>%@</my_finish_date>", tabformatting, d[@"my_finish_date"]];
        [output appendFormat:@"%@<my_rated></my_rated>",tabformatting];
        [output appendFormat:@"%@<my_score>%@</my_score>",tabformatting,d[@"my_score"]];
        [output appendFormat:@"%@<my_dvd></my_dvd>", tabformatting];
        [output appendFormat:@"%@<my_storage></my_storage>", tabformatting];
        [output appendFormat:@"%@<my_status>%@</my_status>",tabformatting,[self fixstatus:d[@"my_status"]]];
        [output appendFormat:@"%@<my_comments><![CDATA[%@]]></my_comments>",tabformatting, d[@"my_comments"]];
        [output appendFormat:@"%@<my_times_watched>%i</my_times_watched>",tabformatting, ((NSNumber *)d[@"rewatch_count"]).intValue];
        [output appendFormat:@"%@<my_rewatch_value></my_rewatch_value>",tabformatting];
        [output appendFormat:@"%@<my_tags><![CDATA[%@]]></my_tags>",tabformatting,d[@"my_tags"]];
        [output appendFormat:@"%@<my_rewatching>%i</my_rewatching>",tabformatting,((NSNumber *)d[@"my_rewatching"]).intValue];
        [output appendFormat:@"%@<my_rewatching_ep>0</my_rewatching_ep>", tabformatting];
        [output appendFormat:@"%@<update_on_import>%@</update_on_import>",tabformatting,d[@"update_on_import"]];
        [output appendString:animeendtag];
    }
    [output appendString:footerstring];
    return output;
}

- (NSString *)generateMangaListXML:(NSArray *)a {
    NSString *headerstring = @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n\t<!--\n\tCreated by Shukofukurou\n\tProgrammed by MAL Updater OS X Group (James Moy) \n\tNote that not all values are exposed by the API and not all fields will be exported.\n\t--> \n\n\t<myanimelist>";
    NSString *footerstring = @"\n\n\t</myanimelist>";
    NSString *mangapretag = @"\n\n\t\t<manga>";
    NSString *mangaendtag = @"\n\t\t</manga>";
    NSString *tabformatting = @"\n\t\t\t";
    NSMutableString *output = [NSMutableString new];
    [output appendString:headerstring];
    [output appendString:@"\n\n\t<myinfo>"];
    switch ([listservice getCurrentServiceID]) {
        case 1:
            [output appendFormat:@"%@<username>%@</username>",tabformatting, [Keychain getusername]];
            break;
        case 2:
        case 3:
            [output appendFormat:@"%@<username>%@</username>",tabformatting, [listservice getCurrentServiceUsername]];
            break;
        default:
            break;
    }
    [output appendFormat:@"%@<user_export_type>2</user_export_type>",tabformatting];
    [output appendString:@"\n\t</myinfo>"];
    for (NSDictionary *d in a) {
        [output appendString:mangapretag];
        [output appendFormat:@"%@<manga_mangadb_id>%@</manga_mangadb_id>",tabformatting,d[@"manga_mangadb_id"]];
        [output appendFormat:@"%@<manga_title><![CDATA[%@]]></manga_title>",tabformatting,d[@"manga_title"]];
        [output appendFormat:@"%@<manga_volumes>%@</manga_volumes>",tabformatting,d[@"manga_volumes"]];
        [output appendFormat:@"%@<manga_chapters>%@</manga_chapters>",tabformatting,d[@"manga_chapters"]];
        [output appendFormat:@"%@<my_id>0</my_id>",tabformatting];
        [output appendFormat:@"%@<my_read_volumes>%@</my_read_volumes>",tabformatting,d[@"my_read_volumes"]];
        [output appendFormat:@"%@<my_read_chapters>%@</my_read_chapters>",tabformatting,d[@"my_read_chapters"]];
        [output appendFormat:@"%@<my_start_date>%@</my_start_date>", tabformatting, d[@"my_start_date"]];
        [output appendFormat:@"%@<my_finish_date>%@</my_finish_date>", tabformatting, d[@"my_finish_date"]];
        [output appendFormat:@"%@<my_scanalation_group><![CDATA[]]></my_scanalation_group>",tabformatting];
        [output appendFormat:@"%@<my_score>%@</my_score>",tabformatting,d[@"my_score"]];
        [output appendFormat:@"%@<my_storage></my_storage>", tabformatting];
        [output appendFormat:@"%@<my_status>%@</my_status>",tabformatting,[self fixstatus:d[@"my_status"]]];
        [output appendFormat:@"%@<my_comments><![CDATA[%@]]></my_comments>",tabformatting, d[@"my_comments"]];
        [output appendFormat:@"%@<my_times_read>%i</my_times_read>",tabformatting,((NSNumber *)d[@"my_times_read"]).intValue];
        [output appendFormat:@"%@<my_tags><![CDATA[%@]]></my_tags>",tabformatting,d[@"my_tags"]];
        [output appendFormat:@"%@<my_reread_value></my_reread_value>", tabformatting];
        [output appendFormat:@"%@<update_on_import>%@</update_on_import>",tabformatting,d[@"update_on_import"]];
        [output appendString:mangaendtag];
    }
    [output appendString:footerstring];
    return output;
}

 - (NSString *)fixstatus:(NSString *)status {
     NSString *tmpstr = [status capitalizedString];
     tmpstr = [tmpstr stringByReplacingOccurrencesOfString:@" To " withString:@" to "];
     return tmpstr;
 }
             
@end
