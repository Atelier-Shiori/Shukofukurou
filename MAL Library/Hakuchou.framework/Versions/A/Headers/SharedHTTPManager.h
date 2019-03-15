//
//  SharedHTTPManager.h
//  Hakuchou
//
//  Created by 香風智乃 on 3/6/19.
//  Copyright © 2019 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface SharedHTTPManager : NSObject
+ (AFHTTPSessionManager*)jsonmanager;
+ (AFHTTPSessionManager*)httpmanager;
+ (AFHTTPSessionManager*)syncmanager;
+ (AFJSONRequestSerializer *)jsonrequestserializer;
@end

NS_ASSUME_NONNULL_END
