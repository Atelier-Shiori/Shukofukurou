//
//  TitleIDMapper.m
//  Shukofukurou-
//
//  Created by 香風智乃 on 2/9/19.
//  Copyright © 2019 MAL Updater OS X Group. All rights reserved.
//

#import "TitleIDMapper.h"
#import "AppDelegate.h"
#import "listservice.h"
#import <AFNetworking/AFNetworking.h>

@interface TitleIDMapper ()
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong) AFHTTPSessionManager *manager;
@end

@implementation TitleIDMapper
+ (instancetype)sharedInstance {
    static TitleIDMapper *sharedtManager = nil;
    static dispatch_once_t titleidmappertoken;
    dispatch_once(&titleidmappertoken, ^{
        sharedtManager = [[TitleIDMapper alloc] init];
    });
    return sharedtManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _managedObjectContext = ((AppDelegate*)NSApplication.sharedApplication.delegate).managedObjectContext;
        _manager = [AFHTTPSessionManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

- (void)retrieveTitleIdForService:(int)service withTitleId:(NSString *)titleid withTargetServiceId:(int)tserviceid withType:(int)type completionHandler:(void (^) (id titleid, bool success)) completionHandler {
    NSDictionary *emapping = [self retrieveExistingMappingAsDictionary:titleid forService:service withType:type];
    if (emapping) {
        completionHandler([self retrieveIDFromMappingWithTargetServiceID:tserviceid withMapping:emapping], true);
        return;
    }
    [self retrievemappings:titleid forService:service forType:type completionHandler:^(NSDictionary *mapping) {
        completionHandler([self retrieveIDFromMappingWithTargetServiceID:tserviceid withMapping:mapping], true);
    } error:^(NSError *error) {
        completionHandler(nil, false);
    }];
}
- (NSDictionary *)retrieveTitleIdForService:(int)service withTitleId:(NSString *)titleid withTargetServiceId:(int)tserviceid withType:(int)type {
    NSDictionary *emapping = [self retrieveExistingMappingAsDictionary:titleid forService:service withType:type];
    return emapping;
}

- (void)retreiveMultipleMappingsForSourceService:(int)sourceservice withTitleIds:(NSArray *)titleids withMediaType:(int)mediaType completionHandler:(void (^) (NSDictionary *mapping)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    NSString *site;
    switch (sourceservice) {
        case 1:
            site = @"mal";
            break;
        case 2:
            site = @"kitsu";
            break;
        case 3:
            site = @"anilist";
            break;
        case 4:
            site = @"anidb";
            break;
        default:
            errorHandler(nil);
            return;
    }
    NSString *hatourl = @"https://hato.malupdaterosx.moe/api/mappings/mappings/";
    NSDictionary *parameters = @{@"media_type" : mediaType == 0 ? @"anime" : @"manga", @"service" : site, @"title_ids" : titleids};
    [_manager POST:hatourl parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"data"]) {
            for (NSDictionary *mapping in responseObject[@"data"]) {
                [self.managedObjectContext performBlockAndWait:^{
                    int tmpservice = mapping[@"anilist_id"] ? 3 : mapping[@"kitsu_id"] ? 2 : 1;
                    NSString *sourceid = mapping[@"anilist_id"] ? ((NSNumber *)mapping[@"anilist_id"]).stringValue : mapping[@"kitsu_id"] ? ((NSNumber *)mapping[@"kitsu_id"]).stringValue :  ((NSNumber *)mapping[@"mal_id"]).stringValue;
                    [self saveTitleIDMappings:mapping withTitleId:sourceid forService:tmpservice withType:mediaType];
                }];
            }
            completionHandler(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorHandler(nil);
    }];
}

- (id)retrieveIDFromMappingWithTargetServiceID:(int)targetService withMapping:(NSDictionary *)mapping {
    switch (targetService) {
        case 1: // MAL
            return mapping[@"mal_id"];
        case 2: // Kitsu
            return mapping[@"kitsu_id"];
        case 3: // AniList
            return mapping[@"anilist_id"];
        case 4:
            return mapping[@"anidb_id"];
    }
    return nil;
}

- (void)retrievemappings:(NSString *)titleid forService:(int)service forType:(int)type completionHandler:(void (^) (NSDictionary *mapping)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    NSString *site;
    switch (service) {
        case 1:
            site = @"mal";
            break;
        case 2:
            site = @"kitsu";
            break;
        case 3:
            site = @"anilist";
            break;
        case 4:
            site = @"anidb";
            break;
        default:
            errorHandler(nil);
            return;
    }
    NSString *hatourl = [NSString stringWithFormat:@"https://hato.malupdaterosx.moe/api/mappings/%@/%@/%@", site, type == 0 ? @"anime" : @"manga" ,titleid];
    [_manager GET:hatourl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"data"] && responseObject[@"data"] != [NSNull null]) {
            [self.managedObjectContext performBlockAndWait:^{
                [self saveTitleIDMappings:responseObject[@"data"] withTitleId:titleid forService:service withType:type];
            }];
            completionHandler([self retrieveExistingMappingAsDictionary:titleid forService:service withType:type]);
        }
        else {
            errorHandler(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Title mappings lookup failed: %@", error.localizedDescription);
        errorHandler(error);
    }];
}

- (void)saveTitleIDMappings:(NSDictionary *)mapping withTitleId:(NSString *)titleid forService:(int)service withType:(int)type {
    NSManagedObject *map = [self retrieveExistingMapping:titleid forService:service withType:type];
    if (!map) {
        map = [NSEntityDescription insertNewObjectForEntityForName:@"NewTitleIdmappings" inManagedObjectContext:self.managedObjectContext];
    }
    [map setValuesForKeysWithDictionary:mapping];
    [self.managedObjectContext save:nil];
}

- (NSDictionary *)retrieveExistingMappingAsDictionary:(NSString *)titleid forService:(int)service withType:(int)type {
    __block NSManagedObject *mapping;
    [_managedObjectContext performBlockAndWait:^{
        mapping = [self retrieveExistingMapping:titleid forService:service withType:type];
    }];
    if (mapping) {
        NSArray *keys = mapping.entity.attributesByName.allKeys;
        return [mapping dictionaryWithValuesForKeys:keys];
    }
    return nil;
}

- (NSManagedObject *)retrieveExistingMapping:(NSString *)titleid forService:(int)service withType:(int)type {
    __block NSArray *mappings = @[];
    [self.managedObjectContext performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = [NSEntityDescription entityForName:@"NewTitleIdmappings" inManagedObjectContext:self.managedObjectContext];
        NSPredicate *predicate;
        switch (service) {
            case 1:
                predicate = [NSPredicate predicateWithFormat:@"mal_id == %i AND type == %i", titleid.intValue, type];
                break;
            case 2:
                predicate = [NSPredicate predicateWithFormat:@"kitsu_id == %i AND type == %i", titleid.intValue, type];
                break;
            case 3:
                predicate = [NSPredicate predicateWithFormat:@"anilist_id == %i AND type == %i", titleid.intValue, type];
                break;
            case 4:
                predicate = [NSPredicate predicateWithFormat:@"anidb_id == %i AND type == %i", titleid.intValue, type];
                break;
            default:
                break;
        }
        if (predicate) {
            fetchRequest.predicate = predicate;
            NSError *error = nil;
            mappings = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        }
    }];
    if (mappings.count > 0) {
        return mappings[0];
    }
    return nil;
}

- (void)clearAllMappings {
    [_managedObjectContext performBlockAndWait:^{
        NSArray *mappings;
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = [NSEntityDescription entityForName:@"NewTitleIdmappings" inManagedObjectContext:self.managedObjectContext];
        NSError *error = nil;
        mappings = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (NSManagedObject *obj in mappings) {
            [self.managedObjectContext deleteObject:obj];
        }
        [self.managedObjectContext save:nil];
    }];
}
@end
