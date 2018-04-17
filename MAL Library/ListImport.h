//
//  ListImport.h
//  Shukofukuro
//
//  Created by 桐間紗路 on 2017/05/10.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AppDelegate;
@interface ListImport : NSWindowController
@property (strong) IBOutlet AppDelegate *del;
- (IBAction)importMALList:(id)sender;
- (IBAction)importAniDBList:(id)sender;
- (IBAction)importKitsu:(id)sender;
@end
