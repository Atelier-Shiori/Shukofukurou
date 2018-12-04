//
//  EpisodeDetailViewController.m
//  Shukofukurou
//
//  Created by 香風智乃 on 12/4/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import "EpisodeDetailViewController.h"
#import "Utility.h"

@interface EpisodeDetailViewController ()

@end

@implementation EpisodeDetailViewController

- (instancetype)init {
    return [super initWithNibName:@"EpisodeDetailViewController" bundle:nil];
}

- (void)populateEpisodeDetails:(NSDictionary *)details {
    _episodetitle.stringValue = details[@"episodeTitle"];
    [self loadimage:details[@"thumbnail"]];
    NSMutableString *detailsstr = [NSMutableString new];
    if (((NSString *)details[@"synopsis"]).length > 0) {
        [detailsstr appendFormat:@"Synopsis\n\n%@\n\n", details[@"synopsis"]];
    }
    [detailsstr appendString:@"Other Details\n"];
    [detailsstr appendFormat:@"Episode Number: %@\n", details[@"episodeNumber"]];
    [detailsstr appendFormat:@"Episode Length: %@ mins\n", details[@"episodeLength"]];
    [detailsstr appendFormat:@"Air Date: %@\n", details[@"airDate"]];
    _textview.textColor = NSColor.controlTextColor;
    _textview.string = detailsstr;
}

- (void)loadimage:(NSString *)url {
    if ([url isEqualToString:@"/images/original/missing.png"] || url.length == 0) {
        _image.image = [NSImage imageNamed:@"noimage"];
        return;
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSImage *posterimage = [Utility loadImage:[NSString stringWithFormat:@"%@.jpg",[[url stringByReplacingOccurrencesOfString:@"https://" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@"-"]] withAppendPath:@"imgcache" fromURL:[NSURL URLWithString:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            _image.image = posterimage;
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
}

@end
