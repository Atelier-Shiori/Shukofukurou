//
//  KitsuListRetriever.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/12/18.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KitsuListRetriever : NSObject
@property (strong) NSMutableArray *tmplist;
@property (strong) NSMutableArray *metadata;

- (void)getKitsuidfromUserName:(NSString *)username completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
- (void)retrieveKitsuLibrary:(int)userID type:(int)type atPage:(int)pagenum completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandle;
- (NSDictionary *)retrieveMetaDataWithID:(int)titleid;
@end
