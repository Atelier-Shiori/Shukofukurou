//
//  AniListImport.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/09/02.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFOAuth2Manager.h>

@interface AniListImport : NSObject
+ (void)retrievelist:(NSString *)username completion:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler;
@end
