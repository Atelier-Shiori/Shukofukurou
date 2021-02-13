//
//  OtherFormatExport.m
//  Shukofukurou
//
//  Created by 香風智乃 on 4/15/19.
//  Copyright © 2019 Atelier Shiori. All rights reserved.
//

#import "AppDelegate.h"
#import "OtherFormatExport.h"
#import "listservice.h"
#import "AtarashiiListCoreData.h"
#import "RatingTwentyConvert.h"

@implementation OtherFormatExport
+ (instancetype)sharedManager {
    static OtherFormatExport *sharedManager = nil;
    static dispatch_once_t exporttoken;
    dispatch_once(&exporttoken, ^{
        sharedManager = [OtherFormatExport new];
    });
    return sharedManager;
}
- (NSString *)jsonListForType:(int)type {
    int listtype = type;
    listservice *lservice = listservice.sharedInstance;
    NSDictionary *list = [AtarashiiListCoreData retrieveEntriesForUserId:[lservice getCurrentUserID] withService:[lservice getCurrentServiceID] withType:listtype];
    NSMutableDictionary *finaldictionary = [NSMutableDictionary new];
    finaldictionary[@"userData"] = @{@"service" : lservice.currentservicename, @"user_id" : @(lservice.getCurrentUserID), @"username" : lservice.getCurrentServiceUsername, @"type" : listtype == 0 ? @"anime" : @"manga"};
    finaldictionary[@"list"] = listtype == 0 ? list[@"anime"] : list[@"manga"];
    NSError *error;
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:finaldictionary options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
}
- (NSString *)csvListForType:(int)type {
    int listtype = type;
    NSString *currentservicename = listservice.sharedInstance.currentservicename.lowercaseString;
    listservice *lservice = listservice.sharedInstance;
    NSDictionary *list = [AtarashiiListCoreData retrieveEntriesForUserId:[lservice getCurrentUserID] withService:[lservice getCurrentServiceID] withType:listtype];
    NSMutableString *csvoutput = [NSMutableString new];
    // Write CSV Header
    if (listtype == 0) {
        [csvoutput appendFormat:@"\"%@_title_id\",\"title\",\"episodes\",\"type\",\"current_status\",\"current_progress\",\"rating\",\"reconsume_count\",\"comments\",\"start_date\",\"end_date\"\n",currentservicename];
    }
    else {
        [csvoutput appendFormat:@"\"%@_title_id\",\"title\",\"chapters\",\"volumes\",\"type\",\"current_status\",\"current_progress\",\"current_progress_volumes\",\"rating\",\"reconsume_count\",\"comments\",\"start_date\",\"end_date\"\n",currentservicename];
    }
    NSArray *alist = listtype == 0 ? list[@"anime"] : list[@"manga"];
    for (NSDictionary *entry in alist) {
        int score = lservice.getCurrentServiceID == 2 ? [RatingTwentyConvert translateKitsuTwentyScoreToMAL:entry[@"score"] && entry[@"score"] != [NSNull null] ? ((NSNumber *)entry[@"score"]).intValue : 0] : lservice.getCurrentServiceID == 1 ? ((NSNumber *)entry[@"score"]).intValue * 10 : ((NSNumber *)entry[@"score"]).intValue;
        if (listtype == 0) {
            [csvoutput appendFormat:@"%@,\"%@\",%@,\"%@\",\"%@\",%@,%@,%@,\"%@\",\"%@\",\"%@\"\n", entry[@"id"],entry[@"title"],entry[@"episodes"],entry[@"type"], entry[@"watched_status"], entry[@"watched_episodes"], @(score), entry[@"rewatch_count"], entry[@"comments"] && entry[@"comments"] != [NSNull null] ? entry[@"comments"] : @"", entry[@"watching_start"] && entry[@"watching_start"] != [NSNull null] ? entry[@"watching_start"] : @"",entry[@"watching_end"] && entry[@"watching_end"] != [NSNull null] ? entry[@"watching_end"] : @""];
        }
        else {
            [csvoutput appendFormat:@"%@,\"%@\",%@,%@,\"%@\",\"%@\",%@,%@,%@,%@,\"%@\",\"%@\",\"%@\"\n", entry[@"id"],entry[@"title"],entry[@"chapters"],entry[@"volumes"],entry[@"type"], entry[@"read_status"], entry[@"chapters_read"], entry[@"volumes_read"], @(score), entry[@"reread_count"], entry[@"comments"] && entry[@"comments"] != [NSNull null] ? entry[@"comments"] : @"", entry[@"reading_start"] && entry[@"reading_start"] != [NSNull null] ? entry[@"reading_start"] : @"",entry[@"reading_end"] && entry[@"reading_end"] != [NSNull null] ? entry[@"reading_end"] : @""];
        }
    }
    return csvoutput;
}

- (void)saveExportedList:(int)listexporttype {
    if ([listservice.sharedInstance checkAccountForCurrentService]) {
        NSSavePanel * sp = [NSSavePanel savePanel];
        int type = 0;
        switch (listexporttype) {
            case jsonAnimeExport:
            case jsonMangaExport:
                sp.allowedFileTypes = @[@"json", @"JavaScript Object Notation File"];
                type = listexporttype == jsonAnimeExport ? 0 : 1;
                sp.nameFieldStringValue = type == 0 ? @"anime_list.json" : @"manga_list.json";
                break;
            case csvAnimeExport:
            case csvMangaExport:
                sp.allowedFileTypes = @[@"csv", @"Comma Delimitnated File"];
                type = listexporttype == csvAnimeExport ? 0 : 1;
                sp.nameFieldStringValue = type == 0 ? @"anime_list.csv" : @"manga_list.csv";
                break;
        }
        sp.title = type == 0 ? @"Export Anime List" : @"Export Manga List";
        sp.message = type == 0 ? @"Where do you want to export your Anime List?" : @"Where do you want to export your Manga List?";
        [sp beginWithCompletionHandler:^(NSInteger result) {
            if (result == NSModalResponseCancel) {
                return;
            }
            NSString *output;
            switch (listexporttype) {
                case jsonAnimeExport:
                case jsonMangaExport:
                    output = [self jsonListForType:type];
                    break;
                case csvAnimeExport:
                case csvMangaExport:
                    output = [self csvListForType:type];
                    break;
                default:
                    return;
            }
            NSError *error;
            [output writeToURL:sp.URL atomically:YES encoding:NSUTF8StringEncoding error:&error];
        }];
    }
    else {
        // User not logged in, show login notice
        AppDelegate *delegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
        [delegate showloginnotice];
    }
}
@end
