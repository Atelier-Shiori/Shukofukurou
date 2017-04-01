//
//  Utility.m
//  MAL Updater OS X
//
//  Created by Tail Red on 1/31/15.
//
//

#import "Utility.h"
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"

@implementation Utility
+ (void)showsheetmessage:(NSString *)message
            explaination:(NSString *)explaination
                 window:(NSWindow *)w {
    // Set Up Prompt Message Window
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setInformativeText:explaination];
    // Set Message type to Warning
    [alert setAlertStyle:NSAlertStyleInformational];
    // Show as Sheet on Preference Window
    [alert beginSheetModalForWindow:w
                      modalDelegate:self
                     didEndSelector:nil
                        contextInfo:NULL];
}
+ (NSString *)urlEncodeString:(NSString *)string{
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                  NULL,
                                                                                                  (CFStringRef)string,
                                                                                                  NULL,
                                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                  kCFStringEncodingUTF8 ));
}
+ (NSString *)retrieveApplicationSupportDirectory:(NSString*)append{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSError * error;
    NSString * bundlename = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    append = [NSString stringWithFormat:@"%@/%@", bundlename, append];
    NSURL * path = [filemanager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:true error:&error];
    NSString * dir = [NSString stringWithFormat:@"%@/%@",[path path],append];
    if (![filemanager fileExistsAtPath:dir isDirectory:nil]){
        NSError * ferror;
        bool success = [filemanager createDirectoryAtPath:dir withIntermediateDirectories:true attributes:nil error:&ferror];
        if (success && ferror == nil){
            return dir;
        }
        return @"";
    }
    return dir;
}
+ (id)saveJSON:(id) object withFilename:(NSString*) filename appendpath:(NSString*)appendpath replace:(bool)replace{
    //Save as json object
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    if (!jsonData) {}
    else{
        NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        NSString * path = [Utility retrieveApplicationSupportDirectory:appendpath];
        NSFileManager *filemanger = [NSFileManager defaultManager];
        NSString * fullfilenamewithpath = [NSString stringWithFormat:@"%@/%@",path,filename];
        if (![filemanger fileExistsAtPath:fullfilenamewithpath] || replace){
            NSURL * url = [[NSURL alloc] initFileURLWithPath:fullfilenamewithpath];
            [JSONString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (!error){
                JSONString = [NSString stringWithContentsOfFile:fullfilenamewithpath encoding:NSUTF8StringEncoding error:&error];
                return [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            }
        }
        else{
            JSONString = [NSString stringWithContentsOfFile:fullfilenamewithpath encoding:NSUTF8StringEncoding error:&error];
            return [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        }
    }
    return nil;
}
+ (id)loadJSON:(NSString *)filename appendpath:(NSString*)appendpath{
    NSString * path = [Utility retrieveApplicationSupportDirectory:appendpath];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString * fullfilenamewithpath = [NSString stringWithFormat:@"%@/%@",path,filename];
    if ([filemanager fileExistsAtPath:fullfilenamewithpath]){
        NSError * error;
        NSString * JSONString = [NSString stringWithContentsOfFile:fullfilenamewithpath encoding:NSUTF8StringEncoding error:&error];
        return [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    }
    return nil;
}
+ (bool)deleteFile:(NSString *)filename appendpath:(NSString*)appendpath{
    NSString * path = [Utility retrieveApplicationSupportDirectory:appendpath];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString * fullfilenamewithpath = [NSString stringWithFormat:@"%@/%@",path,filename];
    if ([filemanager fileExistsAtPath:fullfilenamewithpath]){
        NSError * error;
        [filemanager removeItemAtPath:fullfilenamewithpath error:&error];
        if (!error){
            return true;
        }
    }
    return false;
}
+ (NSString *)appendstringwithArray:(NSArray *) a{
    NSMutableString *string = [NSMutableString new];
    for (int i=0; i < [a count]; i++){
        if (i == [a count]-1 && i != 0){
            [string appendString:[NSString stringWithFormat:@"and %@",(NSString *)[a objectAtIndex:i]]];
        }
        else if ([a count] == 1){
            [string appendString:[NSString stringWithFormat:@"%@",(NSString *)[a objectAtIndex:i]]];
        }
        else{
            [string appendString:[NSString stringWithFormat:@"%@, ",(NSString *)[a objectAtIndex:i]]];
        }
    }
    return (NSString *)string;
}
+ (bool)checkifFileExists:(NSString *)filename appendPath:(NSString *) appendpath{
    NSString * path = [Utility retrieveApplicationSupportDirectory:appendpath];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString * fullfilenamewithpath = [NSString stringWithFormat:@"%@/%@",path,filename];
    if ([filemanager fileExistsAtPath:fullfilenamewithpath]){
            return true;
    }
    return false;
}
+ (NSImage *)loadImage:(NSString *)filename withAppendPath:(NSString *)append fromURL:(NSURL *)url{
    NSString * path = [Utility retrieveApplicationSupportDirectory:append];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",path, filename]]){
        return [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",path, filename]];
    }
    return [Utility retrieveimageandsave:filename withAppendPath:append fromURL:url];
}
+ (NSImage *)retrieveimageandsave:(NSString *) filename withAppendPath:(NSString *)append fromURL:(NSURL *)url{
    NSImage * img = [[NSImage alloc] initWithContentsOfURL:url];
    CGImageRef cgref = [img CGImageForProposedRect:NULL context:nil hints:nil];
    NSBitmapImageRep * bitmaprep = [[NSBitmapImageRep alloc] initWithCGImage:cgref];
    [bitmaprep setSize:[img size]];
    NSDictionary *imageProps = @{NSImageCompressionFactor:[NSNumber numberWithFloat:1.0]};
    NSData * imgdata = [bitmaprep representationUsingType:NSJPEGFileType properties:imageProps];
    NSString * path =[Utility retrieveApplicationSupportDirectory:append];
    [imgdata writeToFile: [NSString stringWithFormat:@"%@/%@",path, filename] atomically:TRUE];
    return [Utility loadImage:filename withAppendPath:append fromURL:url];
}
+ (void)donateCheck:(AppDelegate*)delegate{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"donatereminderdate"] == nil){
        [Utility setReminderDate];
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"donatereminderdate"] timeIntervalSinceNow] < 0) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"donated"]){
            // Check donation key
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [manager POST:@"https://updates.ateliershiori.moe/keycheck/check.php" parameters:@{@"name":[[NSUserDefaults standardUserDefaults] objectForKey:@"donor"], @"key":[[NSUserDefaults standardUserDefaults] objectForKey:@"donatekey"]} progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                NSDictionary * d = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                int valid = [(NSNumber *)d[@"valid"] intValue];
                if (valid == 1) {
                    //Reset check
                    [Utility setReminderDate];
                }
                else if (valid == 0){
                    //Invalid Key
                    [Utility showsheetmessage:@"Donation Key Error" explaination:@"This key has been revoked. MAL Library will now quit." window:nil];
                    [Utility showDonateReminder:delegate];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"donated"];
                    [[NSApplication sharedApplication] terminate:nil];
                }

            } failure:^(NSURLSessionTask *operation, NSError *error) {
            }];
        }
        else{
            [Utility showDonateReminder:delegate];
        }
    }
}
+ (void)showDonateReminder:(AppDelegate*)delegate{
    // Shows Donation Reminder
    NSAlert * alert = [[NSAlert alloc] init] ;
    [alert addButtonWithTitle:@"Donate"];
    [alert addButtonWithTitle:@"Enter Key"];
    [alert addButtonWithTitle:@"Remind Me Later"];
    [alert setMessageText:@"Please Support MAL Library"];
    [alert setInformativeText:@"We noticed that you have been using MAL Library for a while. Although MAL Library is free and open source software, it cost us money and time to develop this program. \r\rIf you find this program helpful, please consider making a donation. You will recieve a key to remove this message and enable additional features."];
    [alert setShowsSuppressionButton:NO];
    // Set Message type to Warning
    [alert setAlertStyle:NSInformationalAlertStyle];
    long choice = [alert runModal];
    if (choice == NSAlertFirstButtonReturn) {
        // Open Donation Page
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://malupdaterosx.ateliershiori.moe/donate/"]];
        [Utility setReminderDate];
    }
    else if (choice == NSAlertSecondButtonReturn) {
        // Show Add Donation Key dialog.
        [delegate enterDonationKey:nil];
        [Utility setReminderDate];
    }
    else{
        // Surpress message for 2 weeks.
        [Utility setReminderDate];
    }
}

+ (void)setReminderDate{
    //Sets Reminder Date
    NSDate *now = [NSDate date];
    NSDate * reminderdate = [now dateByAddingTimeInterval:60*60*24*14];
    [[NSUserDefaults standardUserDefaults] setObject:reminderdate forKey:@"donatereminderdate"];
}

@end
