//
//  TitleCollectionCell.h
//  Shukofukurou
//
//  Created by 香風智乃 on 11/26/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface TitleCollectionCell : NSCollectionViewItem
@property (strong) IBOutlet NSImageView *image;
@property (strong) IBOutlet NSTextField *titlelabel;
- (void)loadimage:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
