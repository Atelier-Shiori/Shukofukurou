//
//  ListImporterExporter.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/05/09.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import "ListImporterExporter.h"
#import "XMLDictionary.h"
#import "Utility.h"
#import "AppDelegate.h"

@implementation ListImporterExporter
- (IBAction)exportAnimeList:(id)sender {
    // Export Anime List to MyAnimeList XML Format
    // Note that not all fields can be exported since some fields are not exposed by the API
    if ([Utility checkifFileExists:@"animelist.json" appendPath:@""]){
        NSSavePanel * sp = [NSSavePanel savePanel];
        [sp setAllowedFileTypes:@[@"XML", @"Extended Markup Language File"]];
        [sp setMessage:@"Where do you want to export your Anime List?"];
        [sp setNameFieldStringValue:@"animelist.xml"];
        [sp beginWithCompletionHandler:^(NSInteger result) {
            if (result == NSFileHandlingPanelCancelButton) {
                return;
            }
            NSURL *url = [sp URL];
            // Load List
            NSError *error;
            NSMutableArray *XMLArray = [[NSMutableArray alloc] init];
            NSDictionary *animelist = [Utility loadJSON:@"animelist.json" appendpath:@""];
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
        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        [delegate showloginnotice];
    }
}
- (IBAction)exportMangaList:(id)sender {
    
}

- (NSString *)generateAnimeListXML:(NSArray *)a {
    NSString *headerstring = @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n\t<!--\n\tCreated by MAL Library\n\tProgrammed by Atelier Shiori (James Moy) \n\tNote that not all values are exposed by the API and not all fields will be exported.\n\t--> \n\n\t<myanimelist>";
    NSString *footerstring = @"\n\n\t</myanimelist>";
    NSString *animepretag = @"\n\n\t\t<anime>";
    NSString *animeendtag = @"\n\t\t</anime>";
    NSString *tabformatting = @"\n\t\t\t";
    NSMutableString *output = [NSMutableString new];
    [output appendString:headerstring];
    for (NSDictionary *d in a) {
        [output appendString:animepretag];
        [output appendFormat:@"%@<series_animedb_id>%@</series_animedb_id>",tabformatting,d[@"series_animedb_id"]];
        [output appendFormat:@"%@<series_title><![CDATA[%@]]></series_title>",tabformatting,d[@"series_title"]];
        [output appendFormat:@"%@<series_type>%@</series_type>",tabformatting,d[@"series_type"]];
        [output appendFormat:@"%@<series_episodes>%@</series_episodes>",tabformatting,d[@"series_episodes"]];
        [output appendFormat:@"%@<my_watched_episodes>%@</my_watched_episodes>",tabformatting,d[@"my_watched_episodes"]];
        [output appendFormat:@"%@<my_score>%@</my_score",tabformatting,d[@"my_score"]];
        [output appendFormat:@"%@<my_status>%@</my_status>",tabformatting,d[@"my_status"]];
        [output appendFormat:@"%@<my_tags><![CDATA[%@]]></my_tags>",tabformatting,d[@"my_tags"]];
        [output appendFormat:@"%@<update_on_import>%@</update_on_import>",tabformatting,d[@"update_on_import"]];
        [output appendString:animeendtag];
    }
    [output appendString:footerstring];
    return output;
}

@end
