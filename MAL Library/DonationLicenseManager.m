//
//  DonationLicenseManager.m
//  Shukofukuro
//
//  Created by 小鳥遊六花 on 4/17/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "DonationLicenseManager.h"
#import <DonationCheck/DonationCheck.h>
#import "AppDelegate.h"
#import "Utility.h"

@interface DonationLicenseManager ()
@property (strong) IBOutlet NSButton *registerbtn;
@property (strong) IBOutlet NSButton *cancelbtn;
@property (strong) IBOutlet NSButton *upgradebtn;
@property (strong) IBOutlet NSTextField *name;
@property (strong) IBOutlet NSTextField *donationkey;

@end

@implementation DonationLicenseManager
- (AppDelegate *)getAppDelegate {
    return (AppDelegate *)[NSApplication sharedApplication].delegate;
}

- (instancetype)init {
    self = [super initWithWindowNibName:@"DonationLicenseManager"];
    if (!self) {
        return nil;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)registerkey:(id)sender {
    bool success = [DonationKeyVerify checkLicense:_name.stringValue withDonationKey:_donationkey.stringValue isUpgradeLicense:false];
    if (success) {
        [[self getAppDelegate] donationKeyRegister:_name.stringValue withKey:_donationkey.stringValue];
        [self.window close];
    }
    else {
        success = [DonationKeyVerify checkLicense:_name.stringValue withDonationKey:_donationkey.stringValue isUpgradeLicense:true];
        if (success) {
            [MigrateAppStoreLicense validateApp:self.window completionHandler:^(bool success, id responseObject, NSString *path) {
                if (success) {
                    [[self getAppDelegate] donationKeyRegister:_name.stringValue withKey:_donationkey.stringValue];
                    [self.window close];
                }
            }];
        }
        else {
            [Utility showsheetmessage:@"Invalid Donation Key" explaination:@"Make sure you entered the name and license key exactly down in your email." window:self.window];
        }
    }
}

- (IBAction)upgrade:(id)sender {
    [self disablebtns:false];
    [MigrateAppStoreLicense validateApp:self.window completionHandler:^(bool success, id responseObject, NSString *path) {
        if (success) {
        [MigrateAppStoreLicense getUpgradeKeyWithReciept:path withName:NSUserName() completionHandler:^(bool success, bool freeupgrade, NSString *name, NSString *license, NSString *path) {
            if (success && freeupgrade){
                NSString *licensedetails = [NSString stringWithFormat:@"\n\nName: %@\nLicense: %@", name, license];
                [self writeLicensetoDesktop:licensedetails];
                [Utility showsheetmessage:@"Your License" explaination:[NSString stringWithFormat:@"Use these details to register Shukofukuro. The details are saved to your desktop.%@",licensedetails] window:self.window];
            }
            else if (success && !freeupgrade) {
                [MigrateAppStoreLicense showfreeupgradenoteligible:self.window];
            }
            else {
                [Utility showsheetmessage:@"Invalid Copy of MAL Library" explaination:@"Please select a valid copy of MAL Library you downloaded from the App Store." window:self.window];
            }
            [self disablebtns:true];
        }];
        }
        else {
            [Utility showsheetmessage:@"Invalid Copy of MAL Library" explaination:@"Please select a valid copy of MAL Library you downloaded from the App Store." window:self.window];
            [self disablebtns:true];
        }
    }];
}

- (IBAction)purchasekey:(id)sender {
    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"https://softwareateliershiori.onfastspring.com/shukofukuro"]];
}

- (IBAction)lookupkey:(id)sender {
    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"https://softwareateliershiori.onfastspring.com/account"]];
}

- (void)writeLicensetoDesktop:(NSString *)details {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *desktopDirectory = [paths objectAtIndex:0]; // Get documents directory
    
    NSError *error;
    BOOL success = [details writeToFile:[desktopDirectory stringByAppendingPathComponent:@"Shukofukuro License Details"]
                              atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!success) {
        // Handle error here
        NSLog((@"Wrote License Details"));
    }
}

- (IBAction)cancel:(id)sender {
    [self.window close];
}

- (void)disablebtns:(bool)enable {
    _registerbtn.enabled = enable;
    _cancelbtn.enabled = enable;
    _upgradebtn.enabled = enable;
}
@end
