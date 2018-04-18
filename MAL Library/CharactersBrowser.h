//
//  CharactersBrowser.h
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/07/26.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PXSourceList/PXSourceList.h>

@interface CharactersBrowser : NSWindowController <PXSourceListDataSource, PXSourceListDelegate, NSSplitViewDelegate, NSWindowDelegate>
@property (strong) IBOutlet PXSourceList *sourceList;
@property int selectedtitleid;
@property (strong) NSString *selectedtitle;

- (void)retrievestafflist:(int)idnum;
- (int)getIndexOfItemWithIdentifier:(NSString *)string;
- (void)setAppearance;
@end
