//
//  Keychain.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/27.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import "Keychain.h"
#import "SSKeychain.h"
#import "Base64Category.h"

@implementation Keychain
NSString * const kserviceName = @"MAL Library";

+ (BOOL)checkaccount{
    if ([Keychain getusername]){
        return true;
    }
    return false;
}
+ (NSString *)getusername{
    // This method checks for any accounts that Hachidori can use
    NSArray * accounts = [SSKeychain accountsForService:kserviceName];
    if (accounts > 0){
        //retrieve first valid account
        for (NSDictionary * account in accounts){
            return (NSString *)account[@"acct"];
        }
    }
    return nil;
}
+ (BOOL)storeaccount:(NSString *)uname password:(NSString *)password{
    //Clear Account Information in the plist file if it hasn't been done already
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"Base64Token"];
    [defaults setObject:@"" forKey:@"Username"];
    return [SSKeychain setPassword:password forService:kserviceName account:uname];
}
+ (BOOL)removeaccount{
    bool success = [SSKeychain deletePasswordForService:kserviceName account:[Keychain getusername]];
    return success;
}
+ (NSString *)getBase64{
    return [[NSString stringWithFormat:@"%@:%@", [self getusername], [SSKeychain passwordForService:kserviceName account:[self getusername]]] base64Encoding];
}

@end
