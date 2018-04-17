//
//  ListExporter.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/05/09.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "ListExporter.h"
#import "Utility.h"
#import "AppDelegate.h"
#import "Keychain.h"

@implementation ListExporter
- (IBAction)exportAnimeList:(id)sender {
    // Export Anime List to MyAnimeList XML Format
    // Note that not all fields can be exported since some fields are not exposed by the API
    if ([Utility checkifFileExists:@"mal-animelist.json" appendPath:@""]){
        NSSavePanel * sp = [NSSavePanel savePanel];
        sp.title = @"Export Anime List";
        sp.allowedFileTypes = @[@"xml", @"Extended Markup Language File"];
        sp.message = @"Where do you want to export your Anime List?";
        sp.nameFieldStringValue = @"animelist.xml";
        [sp beginWithCompletionHandler:^(NSInteger result) {
            if (result == NSFileHandlingPanelCancelButton) {
                return;
            }
            NSURL *url = sp.URL;
            // Load List
            NSError *error;
            NSMutableArray *XMLArray = [[NSMutableArray alloc] init];
            NSDictionary *animelist = [Utility loadJSON:@"mal-animelist.json" appendpath:@""];
            NSArray *list = animelist[@"anime"];
            // Generate XML from Anime List
            for (NSDictionary *d in list) {
                [XMLArray addObject:@{@"series_animedb_id":d[@"id"], @"series_title":d[@"title"],@"series_type":d[@"type"], @"series_episodes":d[@"episodes"], @"my_watched_episodes":d[@"watched_episodes"], @"my_score":d[@"score"], @"my_status":d[@"watched_status"], @"my_tags":[d[@"personal_tags"] componentsJoinedByString:@","], @"update_on_import":@(0)}];
            }
            //Write XML to file
            BOOL wresult = [[self generateAnimeListXML:XMLArray] writeToURL:url
                                       atomically:YES
                                         encoding:NSUTF8StringEncoding
                                            error:&error];
            if (! wresult) {
                NSLog(@"Export Failed: %@", error);
            }
        }];
    }
    else {
        // USer not logged in, show login notice
        AppDelegate *delegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
        [delegate showloginnotice];
    }
}

- (IBAction)exportMangaList:(id)sender {
    // Export Manga List to MyAnimeList XML Format
    // Note that not all fields can be exported since some fields are not exposed by the API
    if ([Utility checkifFileExists:@"mal-mangalist.json" appendPath:@""]){
        NSSavePanel * sp = [NSSavePanel savePanel];
        sp.title = @"Export Manga List";
        sp.allowedFileTypes = @[@"xml", @"Extended Markup Language File"];
        sp.message = @"Where do you want to export your Manga List?";
        sp.nameFieldStringValue = @"Mangalist.xml";
        [sp beginWithCompletionHandler:^(NSInteger result) {
            if (result == NSFileHandlingPanelCancelButton) {
                return;
            }
            NSURL *url = sp.URL;
            // Load List
            NSError *error;
            NSMutableArray *XMLArray = [[NSMutableArray alloc] init];
            NSDictionary *animelist = [Utility loadJSON:@"mal-mangalist.json" appendpath:@""];
            NSArray *list = animelist[@"manga"];
            // Generate XML from Manga List
            for (NSDictionary *d in list) {
                [XMLArray addObject:@{@"manga_mangadb_id":d[@"id"], @"manga_title":d[@"title"], @"manga_volumes":d[@"volumes"], @"manga_chapters":d[@"chapters"], @"my_read_volumes":d[@"volumes_read"],@"my_read_chapters":d[@"chapters_read"], @"my_score":d[@"score"], @"my_status":d[@"read_status"], @"my_tags":[d[@"personal_tags"] componentsJoinedByString:@","], @"update_on_import":@(0)}];
            }
            //Write XML to file
            BOOL wresult = [[self generateMangaListXML:XMLArray] writeToURL:url
                                                                 atomically:YES
                                                                   encoding:NSUTF8StringEncoding
                                                                      error:&error];
            if (! wresult) {
                NSLog(@"Export Failed: %@", error);
            }
        }];
    }
    else {
        // USer not logged in, show login notice
        AppDelegate *delegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
        [delegate showloginnotice];
    }
}

- (NSString *)generateAnimeListXML:(NSArray *)a {
    NSString *headerstring = @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n\t<!--\n\tCreated by MAL Library\n\tProgrammed by Atelier Shiori Software (James Moy), a division of Moy IT Solutions \n\tNote that not all values are exposed by the API and not all fields will be exported.\n\t--> \n\n\t<myanimelist>";
    NSString *footerstring = @"\n\n\t</myanimelist>";
    NSString *animepretag = @"\n\n\t\t<anime>";
    NSString *animeendtag = @"\n\t\t</anime>";
    NSString *tabformatting = @"\n\t\t\t";
    NSMutableString *output = [NSMutableString new];
    [output appendString:headerstring];
    [output appendString:@"\n\n\t<myinfo>"];
    [output appendFormat:@"%@<username>%@</username>",tabformatting, [Keychain getusername]];
    [output appendFormat:@"%@<user_export_type>1</user_export_type>",tabformatting];
    [output appendString:@"\n\t</myinfo>"];
    for (NSDictionary *d in a) {
        [output appendString:animepretag];
        [output appendFormat:@"%@<series_animedb_id>%@</series_animedb_id>",tabformatting,d[@"series_animedb_id"]];
        [output appendFormat:@"%@<series_title><![CDATA[%@]]></series_title>",tabformatting,d[@"series_title"]];
        [output appendFormat:@"%@<series_type>%@</series_type>",tabformatting,d[@"series_type"]];
        [output appendFormat:@"%@<series_episodes>%@</series_episodes>",tabformatting,d[@"series_episodes"]];
        [output appendFormat:@"%@<my_watched_episodes>%@</my_watched_episodes>",tabformatting,d[@"my_watched_episodes"]];
        [output appendFormat:@"%@<my_score>%@</my_score>",tabformatting,d[@"my_score"]];
        [output appendFormat:@"%@<my_status>%@</my_status>",tabformatting,d[@"my_status"]];
        [output appendFormat:@"%@<my_tags><![CDATA[%@]]></my_tags>",tabformatting,d[@"my_tags"]];
        [output appendFormat:@"%@<update_on_import>%@</update_on_import>",tabformatting,d[@"update_on_import"]];
        [output appendString:animeendtag];
    }
    [output appendString:footerstring];
    return output;
}

- (NSString *)generateMangaListXML:(NSArray *)a {
    NSString *headerstring = @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n\t<!--\n\tCreated by MAL Library\n\tProgrammed by Atelier Shiori (James Moy) \n\tNote that not all values are exposed by the API and not all fields will be exported.\n\t--> \n\n\t<myanimelist>";
    NSString *footerstring = @"\n\n\t</myanimelist>";
    NSString *mangapretag = @"\n\n\t\t<manga>";
    NSString *mangaendtag = @"\n\t\t</manga>";
    NSString *tabformatting = @"\n\t\t\t";
    NSMutableString *output = [NSMutableString new];
    [output appendString:headerstring];
    [output appendString:@"\n\n\t<myinfo>"];
    [output appendFormat:@"%@<username>%@</username>",tabformatting, [Keychain getusername]];
    [output appendFormat:@"%@<user_export_type>2</user_export_type>",tabformatting];
    [output appendString:@"\n\t</myinfo>"];
    for (NSDictionary *d in a) {
        [output appendString:mangapretag];
        [output appendFormat:@"%@<manga_mangadb_id>%@</manga_mangadb_id>",tabformatting,d[@"manga_mangadb_id"]];
        [output appendFormat:@"%@<manga_title><![CDATA[%@]]></manga_title>",tabformatting,d[@"manga_title"]];
        [output appendFormat:@"%@<manga_volumes>%@</manga_volumes>",tabformatting,d[@"manga_volumes"]];
        [output appendFormat:@"%@<manga_chapters>%@</manga_chapters>",tabformatting,d[@"manga_chapters"]];
        [output appendFormat:@"%@<my_read_volumes>%@</my_read_volumes>",tabformatting,d[@"my_read_volumes"]];
        [output appendFormat:@"%@<my_read_chapters>%@</my_read_chapters>",tabformatting,d[@"my_read_chapters"]];
        [output appendFormat:@"%@<my_score>%@</my_score>",tabformatting,d[@"my_score"]];
        [output appendFormat:@"%@<my_status>%@</my_status>",tabformatting,d[@"my_status"]];
        [output appendFormat:@"%@<my_tags><![CDATA[%@]]></my_tags>",tabformatting,d[@"my_tags"]];
        [output appendFormat:@"%@<update_on_import>%@</update_on_import>",tabformatting,d[@"update_on_import"]];
        [output appendString:mangaendtag];
    }
    [output appendString:footerstring];
    return output;
}

@end
