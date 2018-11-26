//
//  AniListSeasonListGenerator.m
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/07/12.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import "AtarashiiAPIListFormatAniList.h"
#import "AtarashiiAPIListFormatKitsu.h"
#import "AniListSeasonListGenerator.h"
#import "AniListConstants.h"
#import "listservice.h"
#import "Utility.h"

@interface AniListSeasonListGenerator ()

@end

@implementation AniListSeasonListGenerator
+ (NSManagedObjectContext *)managedObjectContext {
    return ((AppDelegate *)NSApplication.sharedApplication.delegate).managedObjectContext;
}

+ (void)retrieveSeasonDataWithSeason:(NSString *)season withYear:(int)year refresh:(bool)refresh completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    NSArray *seasondata = [self retrieveFromCoreData:[NSPredicate predicateWithFormat:@"season ==[c] %@ AND year == %i AND service == %i",season, year, [listservice getCurrentServiceID]]];
    if (seasondata.count > 0 && !refresh) {
        completionHandler(seasondata);
    }
    else {
        NSMutableArray *tmplist = [NSMutableArray new];
        switch ([listservice getCurrentServiceID]) {
            case 2:
                [self retrieveKitsuSeasonDataWithSeason:season withYear:year withPage:0 withArray:tmplist completion:completionHandler error:errorHandler];
                break;
            case 3:
                [self retrieveAniListSeasonDataWithSeason:season withYear:year withPage:1 withArray:tmplist completion:completionHandler error:errorHandler];
                break;
            default:
                break;
        }
    }
}

+ (void)retrieveKitsuSeasonDataWithSeason:(NSString *)season withYear:(int)year withPage:(int)page withArray:(NSMutableArray *)array completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler
{
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/anime?filter[season]=%@&filter[seasonYear]=%i&fields[anime]=canonicalTitle,titles,posterImage,showType,nsfw&page[limit]=20&page[offset]=%i", season.lowercaseString, year, page] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"data"] && responseObject[@"data"] != [NSNull null]) {
            [array addObjectsFromArray:responseObject[@"data"]];
        }
        if (responseObject[@"links"][@"next"]) {
            int newpage = page + 20;
            [self retrieveKitsuSeasonDataWithSeason:season withYear:year withPage:newpage withArray:array completion:completionHandler error:errorHandler];
        }
        else {
            [self processSeasonData:[AtarashiiAPIListFormatKitsu normalizeSeasonData:array withSeason:season withYear:year] withSeason:season withYear:year];
            completionHandler([self retrieveFromCoreData:[NSPredicate predicateWithFormat:@"season ==[c] %@ AND year == %i AND service == %i", season, year, [listservice getCurrentServiceID]]]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}

+ (void)retrieveAniListSeasonDataWithSeason:(NSString *)season withYear:(int)year withPage:(int)page withArray:(NSMutableArray *)array completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler{
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    NSDictionary *parameters = @{@"query" : kAniListSeason, @"variables" : @{@"season" : season.uppercaseString, @"seasonYear" : @(year), @"page" : @(page)}};
    [manager POST:@"https://graphql.anilist.co" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"data"] != [NSNull null]) {
            NSDictionary *dpage = responseObject[@"data"][@"Page"];
            [array addObjectsFromArray:dpage[@"media"]];
            if (((NSNumber *)dpage[@"pageInfo"][@"hasNextPage"]).boolValue) {
                int newpage = page + 1;
                [self retrieveAniListSeasonDataWithSeason:season withYear:year withPage:newpage withArray:array completion:completionHandler error:errorHandler];
            }
            else {
                [self processSeasonData:[AtarashiiAPIListFormatAniList normalizeSeasonData:array withSeason:season withYear:year] withSeason:season withYear:year];
                completionHandler([self retrieveFromCoreData:[NSPredicate predicateWithFormat:@"season ==[c] %@ AND year == %i AND service == %i", season, year, [listservice getCurrentServiceID]]]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(error);
    }];
}

+ (void)processSeasonData:(NSArray *)seasondata withSeason:(NSString *)season withYear:(int)year{
    @autoreleasepool {
        // Save new data
        for (NSDictionary *entry in seasondata) {
            [self saveToCoreData:entry];
        }
        // Delete nonexisting entries that was retrieved
        NSArray *existingseasondata = [self retrieveFromCoreData:[NSPredicate predicateWithFormat:@"season ==[c] %@ AND year == %i AND service == %i", season, year, [listservice getCurrentServiceID]]];
        for (NSDictionary *seasonentry in existingseasondata) {
            NSArray *filteredarray = [seasondata filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@ AND season ==[c] %@ AND year == %@ AND service == %i",seasonentry[@"id"], seasonentry[@"season"], seasonentry[@"year"], [listservice getCurrentServiceID]]];
            if (filteredarray.count == 0) {
                [self deleteFromCoreData:((NSNumber *)seasonentry[@"id"]).intValue withSeason:seasonentry[@"season"] withYear:((NSNumber *)seasonentry[@"year"]).intValue];
            }
        }
        [[self managedObjectContext] save:nil];
    }
}

+ (void)saveToCoreData:(NSDictionary *)seasondata {
    NSManagedObject *sentry = [self retrieveExistingEntry:((NSNumber *)seasondata[@"id"]).intValue withSeason:seasondata[@"season"] withYear:((NSNumber *)seasondata[@"year"]).intValue];
    if (!sentry) {
        sentry = [NSEntityDescription insertNewObjectForEntityForName:@"SeasonData" inManagedObjectContext:[self managedObjectContext]];
    }
    [sentry setValue:seasondata[@"id"] forKey:@"id"];
    [sentry setValue:seasondata[@"idMal"] forKey:@"idMal"];
    [sentry setValue:seasondata[@"title"] forKey:@"title"];
    NSString *othertitlejson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:seasondata[@"other_titles"] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    [sentry setValue:othertitlejson forKey:@"other_titles"];
    [sentry setValue:seasondata[@"episodes"] forKey:@"episodes"];
    [sentry setValue:seasondata[@"image_url"] forKey:@"image_url"];
    [sentry setValue:seasondata[@"status"] forKey:@"status"];
    [sentry setValue:seasondata[@"type"] forKey:@"type"];
    [sentry setValue:seasondata[@"year"] forKey:@"year"];
    [sentry setValue:seasondata[@"season"] forKey:@"season"];
    [sentry setValue:seasondata[@"service"] forKey:@"service"];
}

+ (void)deleteFromCoreData:(int)titleid withSeason:(NSString *)season withYear:(int)year {
    NSManagedObject *seasonentry = [self retrieveExistingEntry:titleid withSeason:season withYear:year];
    [[self managedObjectContext] deleteObject:seasonentry];
}

+ (NSArray *)retrieveFromCoreData:(NSPredicate *)filteringpredicate {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"SeasonData" inManagedObjectContext:moc];
    if (filteringpredicate) {
        fetchRequest.predicate = filteringpredicate;
    }
    NSError *error = nil;
    NSArray *seasonentries = [moc executeFetchRequest:fetchRequest error:&error];
    return [self transformCoreDataAiringData:seasonentries];
}

+ (NSArray *)transformCoreDataAiringData:(NSArray *)seasondata {
    NSMutableArray *finalarray = [NSMutableArray new];
    @autoreleasepool {
        for (NSManagedObject *seasonobj in seasondata) {
            NSArray *keys = seasonobj.entity.attributesByName.allKeys;
            NSMutableDictionary *newdict = [[NSMutableDictionary alloc] initWithDictionary:[seasonobj dictionaryWithValuesForKeys:keys]];
            // Deserialize other_titles JSON object
            NSError *error;
            NSDictionary *jsondata = [NSJSONSerialization JSONObjectWithData:[(NSString *)newdict[@"other_titles"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            if (jsondata) {
                newdict[@"other_titles"] = jsondata;
            }
            else {
                newdict[@"other_titles"] =  @{@"synonyms" : @[]  , @"english" : @[], @"japanese" : @[] };
            }
            [finalarray addObject:newdict.copy];
        }
    }
    return finalarray.copy;
}

+ (NSManagedObject *)retrieveExistingEntry:(int)titleid withSeason:(NSString *)season withYear:(int)year {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"SeasonData" inManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %i AND season ==[c] %@ AND year == %i && service == %i",titleid, season, year, [listservice getCurrentServiceID]];
    fetchRequest.predicate = predicate;
    NSError *error = nil;
    NSArray *seasonentries = [moc executeFetchRequest:fetchRequest error:&error];
    if (seasonentries.count > 0) {
        return seasonentries[0];
    }
    return nil;
}
@end
