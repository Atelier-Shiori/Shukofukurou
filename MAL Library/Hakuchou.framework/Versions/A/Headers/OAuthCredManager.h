//
//  OAuthCredManager.h
//  Shukofukurou-IOS
//
//  Created by 香風智乃 on 2/4/19.
//  Copyright © 2019 MAL Updater OS X Group. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFOAuthCredential;
NS_ASSUME_NONNULL_BEGIN

@interface OAuthCredManager : NSObject
@property (strong, nullable) AFOAuthCredential *AniListCredential;
@property (strong, nullable) AFOAuthCredential *KitsuCredential;
+ (instancetype)sharedInstance;
- (AFOAuthCredential * _Nullable)getFirstAccountForService:(int)service;
- (AFOAuthCredential * _Nullable)saveCredentialForService:(int)service withCredential:(AFOAuthCredential *)cred;
- (bool)removeCredentialForService:(int)service;
- (void)fixkeychainaccessability;
@end

NS_ASSUME_NONNULL_END
