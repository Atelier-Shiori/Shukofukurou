//
//  StreamDataRetriever.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/06/20.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved.
//

#import "AppDelegate.h"
#import "StreamDataRetriever.h"
#import "Utility.h"
#import <AFNetworking/AFNetworking.h>

@implementation StreamDataRetriever
+ (NSManagedObjectContext *)managedObjectContext {
    return ((AppDelegate *)NSApplication.sharedApplication.delegate).managedObjectContext;
}

+ (void)retrieveStreamData {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"stream_data_refresh_date"]){
        if (((NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:@"stream_data_refresh_date"]).timeIntervalSinceNow < 0 || [self getAllObjects].count == 0) {
            [self performrestrieveStreamData];
        }
    }
    else {
        [self performrestrieveStreamData];
    }
}

+ (void)performrestrieveStreamData {
    NSString *region = @"";
    switch (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"stream_region"]).intValue) {
        case StreamRegionUS:
            region = @"us";
            break;
        case StreamRegionCA:
            region = @"ca";
            break;
        case StreamRegionUK:
            region = @"uk";
            break;
        case StreamRegionAU:
            region = @"au";
            break;
        default:
            break;
    }
    // Note: Stream Data provided by Because.moe
    // PHP script passthrough is needed to retrieve the data securely
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager GET:[NSString stringWithFormat:@"https://malupdaterosx.moe/streamdata.php?region=%@",region] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [self saveStreamData:responseObject];
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate dateWithTimeIntervalSinceNow:15*24*50*50] forKey:@"stream_data_refresh_date"];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Failed to retrieve stream data. Error: %@", error.localizedDescription);
    }];
}
+ (void)saveStreamData:(id)responseObject {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSError *error = nil;
    if (responseObject[@"shows"]) {
        NSArray *shows = (NSArray *)responseObject[@"shows"];
        for (NSDictionary *streamentry in shows) {
            NSManagedObject *entry = [self checkExistingEntryForTitle:streamentry[@"name"]];
            if (!entry) {
                entry = [NSEntityDescription insertNewObjectForEntityForName:@"StreamSites" inManagedObjectContext:moc];;
                [entry setValue:streamentry[@"name"] forKey:@"showTitle"];
            }
            NSString *sitesjson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:streamentry[@"sites"] options:NSJSONWritingPrettyPrinted  error:nil] encoding:NSUTF8StringEncoding];
            [entry setValue:sitesjson forKey:@"sites"];
        }
        for (NSManagedObject *sentry in [self getAllObjects]) {
            NSArray *tmparray = [shows filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name ==[c] %@",[sentry valueForKey:@"showTitle"]]];
            if (tmparray.count == 0) {
                [moc deleteObject:sentry];
            }
        }
        [moc save:&error];
        [moc reset];
    }
}

+ (NSManagedObject *)checkExistingEntryForTitle:(NSString *)title {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"StreamSites" inManagedObjectContext:moc];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"showTitle ==[c] %@", [self sanitizetitle:title]];
    NSArray *streamentries =  [moc executeFetchRequest:fetchRequest error:&error];
    if (streamentries.count > 0) {
        return streamentries[0];
    }
    return nil;
}

+ (NSDictionary *)retrieveSitesForTitle:(NSString *)title {
    NSManagedObject *streamentry = [self checkExistingEntryForTitle:title];
    if (streamentry) {
        @try {
            // Deserialize other_titles JSON object
            NSError *error;
            NSDictionary *jsondata = [NSJSONSerialization JSONObjectWithData:[(NSString *)[streamentry valueForKey:@"sites"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            if (jsondata) {
                return jsondata;
            }
        }
        @catch (NSException *ex) {
            NSLog(@"Unable to deserialize stream site data with exception: %@", ex);
            return @{};
        }
    }
    return @{};
}

+ (NSArray *)getAllObjects {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"StreamSites" inManagedObjectContext:moc];
    NSArray *streamentries =  [moc executeFetchRequest:fetchRequest error:&error];
    if (streamentries) {
        return streamentries;
    }
    return @[];
}

+ (void)removeAllStreamEntries {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSArray *streamentries = [self getAllObjects];
    for (NSManagedObject *mobject in streamentries) {
        [moc deleteObject:mobject];
    }
    [moc save:nil];
}

+ (NSString *)sanitizetitle:(NSString *)title {
    NSString *tmpstr = title;
    // Remove seasons
    NSError *errRegex = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s(\\d+(st|nd|rd|th) season|(first|second|third|fourth|fifth|sixth|seventh|eighth|nineth|tenth) season)" options:NSRegularExpressionCaseInsensitive error:&errRegex];
    tmpstr = [regex stringByReplacingMatchesInString:tmpstr options:0 range:NSMakeRange(0, [tmpstr length]) withTemplate:@""];
    regex = [NSRegularExpression regularExpressionWithPattern:@"\\s(\\(TV\\)|\\d+|X|VIII|VII|VI|V|IV|III|II|I)" options:NSRegularExpressionCaseInsensitive error:&errRegex];
    tmpstr = [regex stringByReplacingMatchesInString:tmpstr options:0 range:NSMakeRange(0, [tmpstr length]) withTemplate:@""];
    return tmpstr;
}
@end
