//
//  CharactersBrowser.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/07/26.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PXSourceList/PXSourceList.h>

@interface CharactersBrowser : NSWindowController <PXSourceListDataSource, PXSourceListDelegate, NSSplitViewDelegate>
@property (strong) IBOutlet PXSourceList *sourceList;
@property int selectedtitleid;
- (void)retrievestafflist:(int)idnum;
@end
