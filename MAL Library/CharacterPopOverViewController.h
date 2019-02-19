//
//  CharacterPopOverViewController.h
//  Shukofukurou
//
//  Created by 香風智乃 on 12/10/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PXSourceList/PXSourceList.h>

NS_ASSUME_NONNULL_BEGIN

@interface CharacterPopOverViewController : NSViewController <PXSourceListDataSource, PXSourceListDelegate>
@property (strong) IBOutlet PXSourceList *sourceList;
@property int selectedtitleid;
- (void)retrievestafflist:(int)idnum withType:(int)type;
- (int)getIndexOfItemWithIdentifier:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
