//
//  KitsuImportPrompt.h
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/05/11.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ImportPrompt : NSWindowController
typedef NS_ENUM(unsigned int, ImportType) {
    ImportKitsu = 0,
    ImportAniList = 1
};
@property (strong) IBOutlet NSTextField *usernamefield;
@property (strong) IBOutlet NSButton *replaceexisting;
@property (strong) IBOutlet NSTextField *promptext;
- (void)setImportType:(int)type;
@end
