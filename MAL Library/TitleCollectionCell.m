//
//  TitleCollectionCell.m
//  Shukofukurou
//
//  Created by 香風智乃 on 11/26/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "TitleCollectionCell.h"
#import "TitleCollectionCellView.h"
#import "Utility.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface TitleCollectionCell ()
@end

@implementation TitleCollectionCell
- (instancetype)init {
    return [super initWithNibName:@"TitleCollectionCell" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)loadimage:(NSString *)url {
    if ([url isEqualToString:@"/images/original/missing.png"] || url.length == 0) {
        _image.image = [NSImage imageNamed:@"noimage"];
        return;
    }
    [_image sd_setImageWithURL:[NSURL URLWithString:url]];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [(TitleCollectionCellView *)self.view setSelected:selected];
    [(TitleCollectionCellView *)self.view setNeedsDisplay:YES];
    if (selected) {
        _titlelabel.textColor = [NSColor selectedTextColor];
    }
    else {
        _titlelabel.textColor = [NSColor textColor];
    }
}

@end
