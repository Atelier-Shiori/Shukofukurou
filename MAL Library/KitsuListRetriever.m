//
//  KitsuListRetriever.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/12/18.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "KitsuListRetriever.h"
#import <AFNetworking/AFNetworking.h>
#import "Utility.h"
#import "AtarashiiAPIListFormatKitsu.h"

@interface KitsuListRetriever ()

@end

@implementation KitsuListRetriever
- (void)getKitsuidfromUserName:(NSString *)username completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/users?filter[name]=%@",[Utility urlEncodeString:username]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        errorHandler(error);
    }];
}
- (void)retrieveKitsuLibrary:(int)userID type:(int)type atPage:(int)pagenum completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    if (pagenum == 0) {
        _tmplist = [NSMutableArray new];
        _metadata = [NSMutableArray new];
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    NSString *listtype;
    switch (type) {
        case 0:
            listtype = @"anime";
            break;
        case 1:
            listtype = @"manga";
            break;
        default:
            errorHandler(nil);
            return;
    }
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/library-entries?filter[userId]=%i&filter[kind]=%@&include=%@&page[limit]=500&page[offset]=%i",userID, listtype, listtype, pagenum] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (responseObject[@"data"]){
            [_tmplist addObjectsFromArray:responseObject[@"data"]];
            if (responseObject[@"included"]){
                [_metadata addObjectsFromArray:responseObject[@"included"]];
            }
            if (responseObject[@"links"][@"next"]) {
                int nextPage = pagenum+1;
                [self retrieveKitsuLibrary:userID type:type atPage:nextPage completionHandler:completionHandler error:errorHandler];
            }
            else {
                switch (type) {
                    case 0:
                        completionHandler([AtarashiiAPIListFormatKitsu KitsutoAtarashiiAnimeList:self]);
                        break;
                    case 1:
                        
                        break;
                    default:
                        errorHandler(nil);
                        return;
                }
                
            }
        }
        else {
            completionHandler([AtarashiiAPIListFormatKitsu KitsutoAtarashiiAnimeList:self]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        errorHandler(error);
    }];
}
- (NSDictionary *)retrieveMetaDataWithID:(int)titleid {
    NSArray *filtered = [_metadata filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id==[cd] %i", titleid]];
    if (filtered.count > 0) {
        return filtered[0];
    }
    return nil;
}
@end
