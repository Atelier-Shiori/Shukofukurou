//
//  NotificationPreferencesController.m
//  Shukofukurou
//
//  Created by 香風智乃 on 12/3/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "NotificationPreferencesController.h"
#import "AppDelegate.h"
#import "AiringNotificationManager.h"

@interface NotificationPreferencesController ()
@property (strong) IBOutlet NSArrayController *arraycontroller;

@end

@implementation NotificationPreferencesController

- (instancetype)init {
    return [super initWithNibName:@"NotificationPreferencesController" bundle:nil];
}

- (void)awakeFromNib {
    _arraycontroller.managedObjectContext = ((AppDelegate *)NSApplication.sharedApplication.delegate).managedObjectContext;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)toggleairnotifications:(id)sender {
    [NSNotificationCenter.defaultCenter postNotificationName:@"AirNotifyToggled" object:nil];
}

- (IBAction)notificationlistservicechanged:(id)sender {
    [NSNotificationCenter.defaultCenter postNotificationName:@"AirNotifyServiceChanged" object:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController
- (NSString *)identifier {
    return @"AirNotificationPreferences";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:@"Notifications"];
}

- (NSString *)toolbarItemLabel {
    return NSLocalizedString(@"Air Notifications", @"Toolbar item name for the Air Notifications preference pane");
}
- (IBAction)enablestatechanged:(id)sender {
    if (_arraycontroller.selectedObjects.count > 0) {
        [_arraycontroller.managedObjectContext save:nil];
        NSManagedObject *selected = [_arraycontroller selectedObjects][0];
        NSLog(@"%@", [selected valueForKey:@"title"]);
        if (((NSNumber *)[selected valueForKey:@"enabled"]).boolValue) {
            [[AiringNotificationManager sharedAiringNotificationManager] setNotification:selected];
        }
        else {
            [[AiringNotificationManager sharedAiringNotificationManager] removependingnotification:((NSNumber *)[selected valueForKey:@"anilistid"]).intValue];
        }
    }
    
}

@end
