//
//  ProfileWindowController.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/10/07.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PXSourceList/PXSourceList.h>

@interface ProfileWindowController : NSWindowController <PXSourceListDataSource, PXSourceListDelegate, NSSplitViewDelegate>
@property (strong) IBOutlet NSView *mainview;
@property (strong) IBOutlet PXSourceList *sourceList;
- (void)setAppearance;
- (void)loadProfileWithUsername:(NSString *)username;
@end
