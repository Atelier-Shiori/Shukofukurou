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
#import <UserNotifications/UserNotifications.h>
#import "Utility.h"

@interface NotificationPreferencesController ()
@property (strong) IBOutlet NSArrayController *arraycontroller;
@property (strong) IBOutlet NSTableView *tableview;

@end

@implementation NotificationPreferencesController

- (instancetype)init {
    return [super initWithNibName:@"NotificationPreferencesController" bundle:nil];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)awakeFromNib {
    _arraycontroller.managedObjectContext = ((AppDelegate *)NSApplication.sharedApplication.delegate).managedObjectContext;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [_arraycontroller setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recieveNotification:) name:@"AirNotifyRefreshed" object:nil];
    [_tableview reloadData];
}

- (void)recieveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"AirNotifyRefreshed"]) {
        //[_arraycontroller fetchWithRequest:_arraycontroller.defaultFetchRequest merge:YES error:nil];
        [_tableview reloadData];
    }
}

- (IBAction)toggleairnotifications:(id)sender {
    if (@available(macOS 10.14, *)) {
        UNUserNotificationCenter *userNotificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        [userNotificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert + UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSNotificationCenter.defaultCenter postNotificationName:@"AirNotifyToggled" object:nil];
                });
            }
            else {
                NSLog(@"Can't grant notification permissions: %@", error.localizedDescription);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"airnotificationsenabled"];
                    // Show Error Message
                    [Utility showsheetmessage:@"Cannot enable Airing Notifications" explaination:[NSString stringWithFormat:@"You need to enable notifications for %@ under Notifications in System Preferences before you can enable Airing Notifications.",[[NSBundle.mainBundle infoDictionary] objectForKey:@"CFBundleName"]] window:self.view.window];
                });
            }
        }];
    }
    else {
        [NSNotificationCenter.defaultCenter postNotificationName:@"AirNotifyToggled" object:nil];
    }
}

- (IBAction)notificationlistservicechanged:(id)sender {
    [NSNotificationCenter.defaultCenter postNotificationName:@"AirNotifyServiceChanged" object:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController
- (NSString *)viewIdentifier {
    return @"AirNotificationPreferences";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:@"Notifications"];
}

- (NSString *)toolbarItemLabel {
    return NSLocalizedString(@"Air Notifications", @"Toolbar item name for the Air Notifications preference pane");
}

#pragma mark NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return ((NSArray *)_arraycontroller.arrangedObjects).count;
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row{
    NSManagedObject *obj = _arraycontroller.arrangedObjects[row];
    if ([tableColumn.identifier isEqualToString:@"showtitle"]) {
        return [obj valueForKey:@"title"];
    }
    else if ([tableColumn.identifier isEqualToString:@"titleenabled"]) {
        return [obj valueForKey:@"enabled"];
    }
    return @"";
}

#pragma mark NSTableViewDelegate


- (IBAction)enablestatechanged:(id)sender {
    if (_arraycontroller.selectedObjects.count > 0) {
        NSManagedObject *selected = [_arraycontroller arrangedObjects][_tableview.selectedRow];
        [selected setValue:@(!((NSNumber *)[selected valueForKey:@"enabled"]).boolValue) forKey:@"enabled"];
        [_arraycontroller.managedObjectContext save:nil];
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
