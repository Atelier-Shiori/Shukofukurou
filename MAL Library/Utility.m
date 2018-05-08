//
//  Utility.m
//  MAL Updater OS X
//
//  Created by Tail Red on 1/31/15.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "Utility.h"
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import <CocoaOniguruma/OnigRegexp.h>
#import <CocoaOniguruma/OnigRegexpUtility.h>
#if defined(AppStore)
#else
#import <DonationCheck/DonationCheck.h>
#endif

@implementation Utility
+ (void)showsheetmessage:(NSString *)message
            explaination:(NSString *)explaination
                 window:(NSWindow *)w {
    // Set Up Prompt Message Window
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    alert.messageText = message;
    alert.informativeText = explaination;
    // Set Message type to Warning
    alert.alertStyle = NSAlertStyleInformational;
    // Show as Sheet on Preference Window
    if (w != nil) {
        [alert beginSheetModalForWindow:w completionHandler:nil];
    }
    else {
        [alert runModal];
    }
}

+ (NSString *)urlEncodeString:(NSString *)string{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                  NULL,
                                                                                                  (__bridge CFStringRef)string,
                                                                                                  NULL,
                                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                  kCFStringEncodingUTF8 ));
}

+ (NSString *)retrieveApplicationSupportDirectory:(NSString*)append{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSError *error;
    NSString *bundlename = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
    append = [NSString stringWithFormat:@"%@/%@", bundlename, append];
    NSURL *path = [filemanager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:true error:&error];
    NSString *dir = [NSString stringWithFormat:@"%@/%@",path.path,append];
    if (![filemanager fileExistsAtPath:dir isDirectory:nil]) {
        NSError *ferror;
        bool success = [filemanager createDirectoryAtPath:dir withIntermediateDirectories:true attributes:nil error:&ferror];
        if (success && ferror == nil) {
            return dir;
        }
        return @"";
    }
    return dir;
}

+ (id)saveJSON:(id) object withFilename:(NSString*) filename appendpath:(NSString*)appendpath replace:(bool)replace{
    //Save as json object
    NSError *error;
    NSData *jsonData;
    @try {
        jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
        if (!jsonData) {}
        else {
                NSString *JSONString = [[NSString alloc] initWithBytes:jsonData.bytes length:jsonData.length encoding:NSUTF8StringEncoding];
                NSString *path = [Utility retrieveApplicationSupportDirectory:appendpath];
                NSFileManager *filemanger = [NSFileManager defaultManager];
                NSString *fullfilenamewithpath = [NSString stringWithFormat:@"%@/%@",path,filename];
                if (![filemanger fileExistsAtPath:fullfilenamewithpath] || replace) {
                    NSURL *url = [[NSURL alloc] initFileURLWithPath:fullfilenamewithpath];
                    [JSONString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error];
                    if (!error) {
                        JSONString = [NSString stringWithContentsOfFile:fullfilenamewithpath encoding:NSUTF8StringEncoding error:&error];
                        return [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                    }
                }
                else {
                    JSONString = [NSString stringWithContentsOfFile:fullfilenamewithpath encoding:NSUTF8StringEncoding error:&error];
                    return [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                }
            }
    }
    @catch (NSException *ex) {
        NSLog(@"Unable to write JSON: %@", ex.reason);
        return object;
    }
    return nil;
}

+ (id)loadJSON:(NSString *)filename appendpath:(NSString*)appendpath{
    NSString *path = [Utility retrieveApplicationSupportDirectory:appendpath];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *fullfilenamewithpath = [NSString stringWithFormat:@"%@/%@",path,filename];
    if ([filemanager fileExistsAtPath:fullfilenamewithpath]) {
        NSError *error;
        NSString *JSONString = [NSString stringWithContentsOfFile:fullfilenamewithpath encoding:NSUTF8StringEncoding error:&error];
        if (!error) {
            return [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        }
    }
    return nil;
}

+ (bool)deleteFile:(NSString *)filename appendpath:(NSString*)appendpath{
    NSString *path = [Utility retrieveApplicationSupportDirectory:appendpath];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *fullfilenamewithpath = [NSString stringWithFormat:@"%@/%@",path,filename];
    if ([filemanager fileExistsAtPath:fullfilenamewithpath]) {
        NSError *error;
        [filemanager removeItemAtPath:fullfilenamewithpath error:&error];
        if (!error) {
            return true;
        }
    }
    return false;
}

+ (NSString *)appendstringwithArray:(NSArray *) a{
    NSMutableString *string = [NSMutableString new];
    for (int i=0; i < a.count; i++) {
        if (i == a.count-1 && i != 0) {
            [string appendString:[NSString stringWithFormat:@"and %@",(NSString *)a[i]]];
        }
        else if (a.count == 1) {
            [string appendString:[NSString stringWithFormat:@"%@",(NSString *)a[i]]];
        }
        else {
            [string appendString:[NSString stringWithFormat:@"%@, ",(NSString *)a[i]]];
        }
    }
    return (NSString *)string;
}

+ (bool)checkifFileExists:(NSString *)filename appendPath:(NSString *) appendpath{
    NSString *path = [Utility retrieveApplicationSupportDirectory:appendpath];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *fullfilenamewithpath = [NSString stringWithFormat:@"%@/%@",path,filename];
    if ([filemanager fileExistsAtPath:fullfilenamewithpath]) {
            return true;
    }
    return false;
}

+ (NSImage *)loadImage:(NSString *)filename withAppendPath:(NSString *)append fromURL:(NSURL *)url{
    NSString *path = [Utility retrieveApplicationSupportDirectory:append];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",path, filename]]) {
        return [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",path, filename]];
    }
    return [Utility retrieveimageandsave:filename withAppendPath:append fromURL:url];
}

+ (NSImage *)retrieveimageandsave:(NSString *) filename withAppendPath:(NSString *)append fromURL:(NSURL *)url{
    NSImage *img = [[NSImage alloc] initWithContentsOfURL:url];
    CGImageRef cgref = [img CGImageForProposedRect:NULL context:nil hints:nil];
    NSBitmapImageRep *bitmaprep = [[NSBitmapImageRep alloc] initWithCGImage:cgref];
    bitmaprep.size = img.size;
    NSDictionary *imageProps = @{NSImageCompressionFactor:@1.0f};
    NSData *imgdata = [bitmaprep representationUsingType:NSJPEGFileType properties:imageProps];
    NSString *path =[Utility retrieveApplicationSupportDirectory:append];
    [imgdata writeToFile: [NSString stringWithFormat:@"%@/%@",path, filename] atomically:TRUE];
    return [Utility loadImage:filename withAppendPath:append fromURL:url];
}

+ (NSString *)statusFromDateRange:(NSString *)start toDate:(NSString *)end{
    bool startedairing = false;
    bool finishedairing = false;
    NSDate * datenow = [NSDate date];
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    dateformat.dateFormat = @"yyyy-MM-dd";
    if (start.length == 7 && start) {
        start = [NSString stringWithFormat:@"%@-01",start];
    }
    if (start) {
        NSDate * startdate = [dateformat dateFromString:start];
        if ([datenow compare:startdate] == NSOrderedDescending || [datenow compare:startdate] == NSOrderedSame) {
            startedairing = true;
        }
    }
    if (end.length > 7 && end) {
        end = [NSString stringWithFormat:@"%@-01",end];
    }
    if (end) {
        NSDate * enddate = [dateformat dateFromString:end];
        if ([datenow compare:enddate] == NSOrderedDescending || [datenow compare:enddate] == NSOrderedSame) {
            finishedairing = true;
        }
    }
    // Generate Status String
    if (!startedairing && !finishedairing) {
        return @"not yet aired";
    }
    else if (startedairing && finishedairing) {
        return @"finished airing";
    }
    return @"currently airing";
}

+ (NSString *)convertNameFormat:(NSString *)string {
    // Swaps the family name and given name position
    // e.g. Doe, John -> John Doe
    if ([[OnigRegexp compile:@".*,"] match:string]) {
        NSString *familyname = [[OnigRegexp compile:@".*,"] search:string].strings[0];
        NSString *givenname = [string stringByReplacingOccurrencesOfString:familyname withString:@""];
        givenname = [givenname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        familyname = [familyname stringByReplacingOccurrencesOfString:@"," withString:@""];
        return [NSString stringWithFormat:@"%@ %@", givenname, familyname];
    }
    return string;
}

+ (void)donateCheck:(AppDelegate*)delegate {
#if defined(AppStore)
#else
    if (!((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"donated"]).boolValue) {
        [Utility showDonateReminder:delegate];
    }
    else if (((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"donated"]).boolValue) {
        // Check copy of Shukofukurou
        NSString *license = [[NSUserDefaults standardUserDefaults] valueForKey:@"donation_license"];
        NSString *name = [[NSUserDefaults standardUserDefaults] valueForKey:@"donation_name"];
        bool valid = [DonationKeyVerify checkLicense:name withDonationKey:license isUpgradeLicense:NO];
        valid = !valid ? [DonationKeyVerify checkLicense:name withDonationKey:license isUpgradeLicense:YES] : valid;
        if (valid) {
            //Reset check
            [Utility setReminderDate];
        }
        else {
            //Invalid Copy
            [Utility showsheetmessage:@"Donation Key Error" explaination:@"This key has been revoked. Shukofukurou will now quit." window:nil];
            [Utility showDonateReminder:delegate];
            [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"donated"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"donatereminderdate"];
            [[NSApplication sharedApplication] terminate:nil];
        }
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"donatereminderdate"] timeIntervalSinceNow] < 0) {
            [Utility showDonateReminder:delegate];
    }
    else if (((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"donated"]).boolValue && ![[NSUserDefaults standardUserDefaults] valueForKey:@"donatereminderdate"]) {
        [Utility setReminderDate];
    }
#endif
}
+ (void)showDonateReminder:(AppDelegate*)delegate{
#if defined(AppStore)
#else
    // Shows Donation Reminder
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *version = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleVersion"];
    bool show = !(![defaults valueForKey:@"surpressversion"] || ((NSString *)[defaults valueForKey:@"surpressversion"]).intValue ==  version.integerValue);
    if (![defaults boolForKey:@"surpressreminder"] || show) {
        NSAlert *alert = [[NSAlert alloc] init] ;
        [alert addButtonWithTitle:@"Open App Store"];
        [alert addButtonWithTitle:@"Donate"];
        [alert addButtonWithTitle:@"Enter Key"];
        [alert addButtonWithTitle:@"Not Yet"];
        alert.messageText = @"Please Support Shukofukurou";
        alert.informativeText = @"We noticed that you have been using Shukofukurou for a while. Shukofukurou is donationware to substain development of our applications. \r\rIf you find this program helpful, obtain the full version of Shukofukurou, which adds Manga support and more from the Mac App Store or Purchase a License. You can hide this message until the next update.";
        [alert setShowsSuppressionButton:YES];
        // Set Message type to Warning
        alert.alertStyle = NSInformationalAlertStyle;
        long choice = [alert runModal];
        if (choice == NSAlertFirstButtonReturn) {
            // Open App Store Page
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/shukofukurou/id1373973596?ls=1&mt=12"]];
        }
        else if (choice == NSAlertSecondButtonReturn) {
            [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"https://softwareateliershiori.onfastspring.com/shukofukurou"]];
        }
        else if (choice == NSAlertThirdButtonReturn) {
            [(AppDelegate *)[NSApplication sharedApplication].delegate unlockprofeatures:self];
        }
        if (alert.suppressionButton.state == NSOnState) {
            // Suppress this alert until the next version
            [defaults setBool: YES forKey: @"surpressversion"];
            [defaults setValue:version forKey:@"surpressversion"];
        }
    }
#endif
}

+ (void)setReminderDate {
#if defined(AppStore)
#else
    //Sets Reminder Date
    NSDate *now = [NSDate date];
    NSDate *reminderdate = [now dateByAddingTimeInterval:60*60*24];
    [[NSUserDefaults standardUserDefaults] setObject:reminderdate forKey:@"donatereminderdate"];
#endif
}

+ (void)checkandclearimagecache {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"imagecacheexpire"]) {
        if (((NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:@"imagecacheexpire"]).timeIntervalSinceNow < 0) {
            [Utility clearImageCache];
        }
    }
    else {
        [Utility setCacheClearDate];
    }
}

+ (void)setCacheClearDate {
    //Sets Reminder Date
    NSDate *now = [NSDate date];
    NSDate *reminderdate = [now dateByAddingTimeInterval:60*60*24*14];
    [[NSUserDefaults standardUserDefaults] setObject:reminderdate forKey:@"imagecacheexpire"];
}

+ (void)clearImageCache {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [Utility retrieveApplicationSupportDirectory:@"imgcache"];
    NSDirectoryEnumerator *en = [fm enumeratorAtPath:path];
    NSError *error = nil;
    bool success;
    NSString *file;
    while (file = [en nextObject]) {
        success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@",path,file] error:&error];
        if (!success && error) {
            NSLog(@"%@", error);
        }
        [Utility setCacheClearDate];
    }
}

+ (NSDate *)stringDatetoDate:(NSString *)stringdate {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init] ;
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter dateFromString:stringdate];
}

+ (NSString *)stringDatetoLocalizedDateString:(NSString *)stringdate {
    return [NSDateFormatter localizedStringFromDate:[Utility stringDatetoDate:stringdate]
                                                             dateStyle: NSDateFormatterShortStyle
                                                             timeStyle: NSDateFormatterNoStyle];
}
+ (AFHTTPSessionManager*)jsonmanager {
    static dispatch_once_t jonceToken;
    static AFHTTPSessionManager *jmanager = nil;
    if (jmanager) {
        [jmanager.requestSerializer clearAuthorizationHeader];
        jmanager.requestSerializer = [Utility httprequestserializer];
        jmanager.responseSerializer =  [Utility jsonresponseserializer];
    }
    dispatch_once(&jonceToken, ^{
        jmanager = [AFHTTPSessionManager manager];
        jmanager.requestSerializer = [Utility httprequestserializer];
        jmanager.responseSerializer =  [Utility jsonresponseserializer];
    });
    return jmanager;
}
+ (AFHTTPSessionManager*)httpmanager {
    static dispatch_once_t hmonceToken;
    static AFHTTPSessionManager *hmanager = nil;
    if (hmanager) {
        [hmanager.requestSerializer clearAuthorizationHeader];
        hmanager.requestSerializer = [Utility httprequestserializer];
        hmanager.responseSerializer =  [Utility httpresponseserializer];
    }
    dispatch_once(&hmonceToken, ^{
        hmanager = [AFHTTPSessionManager manager];
        hmanager.requestSerializer = [Utility httprequestserializer];
        hmanager.responseSerializer =  [Utility httpresponseserializer];
    });
    return hmanager;
}
+ (AFHTTPSessionManager*)syncmanager {
    static dispatch_once_t synconceToken;
    static AFHTTPSessionManager *syncmanager = nil;
    if (syncmanager) {
        [syncmanager.requestSerializer clearAuthorizationHeader];
        syncmanager.requestSerializer = [Utility httprequestserializer];
        syncmanager.responseSerializer = [Utility jsonresponseserializer];
    }
    dispatch_once(&synconceToken, ^{
        syncmanager = [AFHTTPSessionManager manager];
        syncmanager.requestSerializer = [Utility httprequestserializer];
        syncmanager.responseSerializer = [Utility jsonresponseserializer];
        syncmanager.completionQueue = dispatch_queue_create("moe.ateliershiori.Shukofukurou", DISPATCH_QUEUE_CONCURRENT);
    });
    return syncmanager;
}
+ (AFJSONRequestSerializer *)jsonrequestserializer {
    static dispatch_once_t jronceToken;
    static AFJSONRequestSerializer *jsonrequest = nil;
    dispatch_once(&jronceToken, ^{
        jsonrequest = [AFJSONRequestSerializer serializer];
    });
    switch ((int)[NSUserDefaults.standardUserDefaults integerForKey:@"currentservice"]) {
        case 2:
            [jsonrequest setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
            break;
        default:
            [jsonrequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
    }
    return jsonrequest;
}
+ (AFHTTPRequestSerializer *)httprequestserializer {
    static dispatch_once_t hronceToken;
    static AFHTTPRequestSerializer *httprequest = nil;
    dispatch_once(&hronceToken, ^{
        httprequest = [AFHTTPRequestSerializer serializer];
    });
    return httprequest;
}
+ (AFJSONResponseSerializer *)jsonresponseserializer {
    static dispatch_once_t jonceToken;
    static AFJSONResponseSerializer *jsonresponse = nil;
    dispatch_once(&jonceToken, ^{
        jsonresponse = [AFJSONResponseSerializer serializer];
        jsonresponse.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"application/vnd.api+json", @"text/javascript", @"text/html", @"text/plain", nil];
    });
    return jsonresponse;
}
+ (AFHTTPResponseSerializer *)httpresponseserializer {
    static dispatch_once_t honceToken;
    static AFHTTPResponseSerializer *httpresponse = nil;
    dispatch_once(&honceToken, ^{
        httpresponse = [AFHTTPResponseSerializer serializer];
    });
    return httpresponse;
}

+ (double)calculatedays:(NSArray *)list {
    double duration = 0;
    for (NSDictionary *entry in list) {
        duration += ((NSNumber *)entry[@"watched_episodes"]).integerValue * ((NSNumber *)entry[@"duration"]).intValue;
    }
    duration = (duration/60)/24;
    return duration;
}

+ (NSString *)dateIntervalToDateString:(double)timeinterval {
    NSDate *aDate = [NSDate dateWithTimeIntervalSince1970:timeinterval];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    return [dateFormatter stringFromDate:aDate];
}

+ (NSString *)convertAnimeType:(NSString *)type {
    NSString *tmpstr = type.lowercaseString;
    if ([tmpstr isEqualToString: @"tv"]||[tmpstr isEqualToString: @"ova"]||[tmpstr isEqualToString: @"ona"]) {
        tmpstr = tmpstr.uppercaseString;
    }
    else {
        tmpstr = tmpstr.capitalizedString;
        tmpstr = [tmpstr stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        tmpstr = [tmpstr stringByReplacingOccurrencesOfString:@"Tv" withString:@"TV"];
    }
    return tmpstr;
}
@end
