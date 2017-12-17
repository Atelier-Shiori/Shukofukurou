//
//  MALLibraryAppStoreMigrate.h
//  MALLibraryAppMigrate
//
//  Created by 桐間紗路 on 2017/04/28.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
/**
 This class validates an App Store purchased version of MAL Library.
 */
@interface MALLibraryAppStoreMigrate : NSObject

/**
 This method checks if streamlink is intalled. If not, you can prompt to install it.
 @param window The window to attach the dialog to as a sheet
 @param completeHandler The completion block after the application is validated.
*/
+ (void)selectAppandValidate:(NSWindow *)window completionHandler:(void (^)(bool success, NSString *path)) completeHandler;

/**
 This method checks if streamlink is intalled. If not, you can prompt to install it.
 @param path Path of the MAL Library application to validate.
 @return bool Reciept is valid or not
 */
+ (bool)validateReciept:(NSString *)path;

/**
 This method checks if user is running a prerelease version. If user haven't registered, it will show an alert and quit.
 */
+ (void)checkPreRelease;
@end
