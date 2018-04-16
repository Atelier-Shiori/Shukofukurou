//
//  TitleIdConverter.h
//  MAL Library
//
//  Created by 小鳥遊六花 on 2/27/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TitleIdConverter : NSObject
+ (void)getKitsuIDFromMALId:(int)malid withTitle:(NSString *)title titletype:(NSString *)titletype withType:(int)type completionHandler:(void (^)(int kitsuid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)getMALIDFromKitsuId:(int)kitsuid withTitle:(NSString *)title titletype:(NSString *)titletype withType:(int)type completionHandler:(void (^)(int malid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)getMALIDFromAniListID:(int)titleid withTitle:(NSString *)title titletype:(NSString *)titletype withType:(int)type completionHandler:(void (^)(int malid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)getAniIDFromMALListID:(int)titleid withTitle:(NSString *)title titletype:(NSString *)titletype withType:(int)type completionHandler:(void (^)(int anilistid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)getAniIDFromKitsuID:(int)titleid withTitle:(NSString *)title titletype:(NSString *)titletype withType:(int)type completionHandler:(void (^)(int anilistid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)getKitsuIdFromAniID:(int)titleid withTitle:(NSString *)title titletype:(NSString *)titletype withType:(int)type completionHandler:(void (^)(int kitsuid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)getMALIDFromServiceID:(int)titleid withTitle:(NSString *)title titletype:(NSString *)titletype withType:(int)type fromServiceID:(int)fromservice completionHandler:(void (^)(int malid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)getserviceTitleIDFromServiceID:(int)titleid withTitle:(NSString *)title titletype:(NSString *)titletype fromServiceID:(int)fromservice completionHandler:(void (^)(int kitsuid)) completionHandler error:(void (^)(NSError * error)) errorHandler;
+ (void)setImportStatus:(bool)isImporting;
@end
