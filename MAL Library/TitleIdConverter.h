//
//  TitleIdConverter.h
//  MAL Library
//
//  Created by 小鳥遊六花 on 2/27/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TitleIdConverter : NSObject
+ (void)getKitsuIDFromMALId:(int)malid  withType:(int)type completionHandler:(void (^)(int kitsuid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)getMALIDFromKitsuId:(int)kitsuid withType:(int)type completionHandler:(void (^)(int malid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)getMALIDFromServiceID:(int)titleid withTitle:(NSString *)title titletype:(NSString *)titletype fromServiceID:(int)fromservice completionHandler:(void (^)(int malid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)getserviceTitleIDFromServiceID:(int)titleid withTitle:(NSString *)title titletype:(NSString *)titletype fromServiceID:(int)fromservice completionHandler:(void (^)(int kitsuid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
@end
