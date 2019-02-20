//
//  OAuthCredManager.m
//  Shukofukurou
//
//  Created by 香風智乃 on 2/4/19.
//  Copyright © 2019 MAL Updater OS X Group. All rights reserved.
//

#import "OAuthCredManager.h"
#import <AFNetworking/AFNetworking.h>

@implementation OAuthCredManager

#ifdef DEBUG
NSString *const kKitsuKeychainIdentifier = @"Shukofukurou - Kitsu DEBUG";
NSString *const kAniListKeychainIdentifier = @"Shukofukurou - AniList DEBUG";
#else
NSString *const kKitsuKeychainIdentifier = @"Shukofukurou - Kitsu";
NSString *const kAniListKeychainIdentifier = @"Shukofukurou - AniList";
#endif

+ (instancetype)sharedInstance {
    static OAuthCredManager *sharedManager = nil;
    static dispatch_once_t oauthcredmanagertoken;
    dispatch_once(&oauthcredmanagertoken, ^{
        sharedManager = [[OAuthCredManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _KitsuCredential = [self getFirstAccountForService:2];
        _AniListCredential = [self getFirstAccountForService:3];
    }
    return self;
}

- (AFOAuthCredential *)getFirstAccountForService:(int)service {
    NSString *keychainidentifier;
    switch (service) {
        case 2:
            if (_KitsuCredential) {
                return _KitsuCredential;
            }
            keychainidentifier = kKitsuKeychainIdentifier;
            break;
        case 3:
            if (_AniListCredential) {
                return _AniListCredential;
            }
            keychainidentifier = kAniListKeychainIdentifier;
            break;
        default:
            return [AFOAuthCredential new];
    }
    return [AFOAuthCredential retrieveCredentialWithIdentifier:keychainidentifier];
}

- (AFOAuthCredential *)saveCredentialForService:(int)service withCredential:(AFOAuthCredential *)cred {
    NSString *keychainidentifier;
    switch (service) {
        case 2:
            keychainidentifier = kKitsuKeychainIdentifier;
            break;
        case 3:
            keychainidentifier = kAniListKeychainIdentifier;
            break;
        default:
            return [AFOAuthCredential new];
    }
    [AFOAuthCredential storeCredential:cred withIdentifier:keychainidentifier];
    switch (service) {
        case 2:
            _KitsuCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:keychainidentifier];
            return _KitsuCredential;
        case 3:
            _AniListCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:keychainidentifier];
            return _AniListCredential;
    }
    return nil;
}

- (bool)removeCredentialForService:(int)service {
    NSString *keychainidentifier;
    switch (service) {
        case 2:
            keychainidentifier = kKitsuKeychainIdentifier;
            break;
        case 3:
            keychainidentifier = kAniListKeychainIdentifier;
            break;
        default:
            return false;
    }
    bool success = [AFOAuthCredential deleteCredentialWithIdentifier:keychainidentifier];
    switch (service) {
        case 2:
            _KitsuCredential = nil;
            [NSUserDefaults.standardUserDefaults setValue:@"" forKey:@"kitsu-username"];
            [NSUserDefaults.standardUserDefaults setInteger:0 forKey:@"kitsu-userid"];
            break;
        case 3:
            _AniListCredential = nil;
            [NSUserDefaults.standardUserDefaults setValue:@"" forKey:@"anilist-username"];
            [NSUserDefaults.standardUserDefaults setInteger:0 forKey:@"anilist-userid"];
            break;
    }
    return success;
}
@end
