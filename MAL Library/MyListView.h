//
//  MyListView.h
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/10/06.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "ListView.h"
#import "MainWindow.h"

@interface MyListView : ListView
@property (strong) IBOutlet MainWindow *mw;

// Toolbar Items
@property (strong) IBOutlet NSToolbarItem *edittitleitem;
@property (strong) IBOutlet NSToolbarItem *deletetitleitem;
@property (strong) IBOutlet NSToolbarItem *shareitem;
@property (strong) IBOutlet NSToolbarItem *titleinfoitem;
@property (strong) IBOutlet NSToolbarItem *incrementitem;

- (IBAction)deletetitle:(id)sender;
- (IBAction)increment:(id)sender;
@end
