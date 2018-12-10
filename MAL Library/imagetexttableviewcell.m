//
//  imagetexttableviewcell.m
//  Shukofukurou
//
//  Created by 香風智乃 on 12/10/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "imagetexttableviewcell.h"
#import "Utility.h"

@implementation imagetexttableviewcell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
- (void)loadimage:(NSString *)url {
    if ([url isEqualToString:@"/images/original/missing.png"] || url.length == 0) {
        self.imageView.image = [NSImage imageNamed:@"noimage"];
        return;
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSImage *posterimage = [Utility loadImage:[NSString stringWithFormat:@"%@.jpg",[[url stringByReplacingOccurrencesOfString:@"https://" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@"-"]] withAppendPath:@"imgcache" fromURL:[NSURL URLWithString:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = posterimage;
        });
    });
}
@end
