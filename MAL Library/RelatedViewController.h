//
//  RelatedViewController.h
//  Shukofukurou
//
//  Created by 香風智乃 on 12/11/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PXSourceList/PXSourceList.h>

NS_ASSUME_NONNULL_BEGIN

@interface RelatedViewController : NSViewController <PXSourceListDataSource, PXSourceListDelegate>
@property (strong) IBOutlet PXSourceList *sourceList;
- (bool)hasRelatedTitles;
- (void)generateRelated:(NSDictionary *)titleinfo withType:(int)type;
@end

NS_ASSUME_NONNULL_END
