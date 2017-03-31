//
//  DonationWindowController.m
//  MAL Updater OS X
//
//  Created by 桐間紗路 on 2017/01/03.
//  Copyright 2009-2017 Atelier Shiori. All rights reserved. Code licensed under New BSD License
//

#import "DonationWindowController.h"
#import "Utility.h"
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import "MainWindow.h"

@interface DonationWindowController ()

@end

@implementation DonationWindowController
-(id)init{
    self = [super initWithWindowNibName:@"DonationWindow"];
    if(!self)
        return nil;
    return self;
}
- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
-(IBAction)validate:(id)sender{
    if ([[name stringValue] length] > 0 && [[key stringValue] length]>0){
        __block NSButton * btn = sender;
        [btn setEnabled:NO];
        // Check donation key
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:@"https://updates.ateliershiori.moe/keycheck/check.php" parameters:@{@"name":name.stringValue, @"key":key.stringValue} progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [btn setEnabled:YES];
            NSDictionary * d = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            int valid = [(NSNumber *)d[@"valid"] intValue];
            if (valid == 1) {
                // Valid Key
                [Utility showsheetmessage:@"Registered" explaination:@"Thank you for donating. The donation reminder will no longer appear and access to weekly builds is now unlocked." window:nil];
                // Add to the preferences
                [[NSUserDefaults standardUserDefaults] setObject:[name stringValue] forKey:@"donor"];
                [[NSUserDefaults standardUserDefaults] setObject:[key stringValue] forKey:@"donatekey"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"donated"];
                // Refresh Mainview
                AppDelegate * del = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                [[del getMainWindowController] loadmainview];
                //Close Window
                [self.window orderOut:self];
            }
            else if (valid == 0){
                [Utility showsheetmessage:@"Invalid Key" explaination:@"Please make sure you copied the name and key exactly from the email." window:[self window]];
            }

        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"%@",error);
            [Utility showsheetmessage:@"No Internet" explaination:@"Make sure you are connected to the internet and try again." window:[self window]];
                   }];
    }
    else{
        [Utility showsheetmessage:@"Missing Information" explaination:@"Please type in the name and key exactly from the email and try again." window:[self window]];
    }
}

-(IBAction)cancel:(id)sender{
    [self.window orderOut:self];
}

-(IBAction)donate:(id)sender{
    // Show Donation Page
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://malupdaterosx.ateliershiori.moe/donate/"]];
}
@end
