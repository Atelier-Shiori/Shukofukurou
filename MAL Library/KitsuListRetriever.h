//
//  KitsuListRetriever.h
//  Shukofukuro
//
//  Created by 桐間紗路 on 2017/12/18.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KitsuListRetriever : NSObject
@property (strong) NSMutableArray *tmplist;
@property (strong) NSMutableArray *metadata;

- (void)retrieveKitsuLibrary:(int)userID type:(int)type atPage:(int)pagenum completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandle;
- (NSDictionary *)retrieveMetaDataWithID:(int)titleid;
@end
