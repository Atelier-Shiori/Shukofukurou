//
//  ListImport.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/05/10.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AppDelegate;
@interface ListImport : NSWindowController
@property (strong) IBOutlet AppDelegate *del;
- (IBAction)importMALList:(id)sender;
- (IBAction)importKitsu:(id)sender;
@end
