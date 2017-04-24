//
//  messageview.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/24.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "messageview.h"
#import <WebKit/WebKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MyAnimeList.h"

@interface messageview ()
@property (strong) IBOutlet NSTextField *fromlabel;
@property (strong) IBOutlet NSTextField *subject;
@property (strong) IBOutlet WebView *messagewebview;
@property (strong) IBOutlet NSTextField *date;

@end

@implementation messageview

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
}
- (instancetype)init {
    return [super initWithNibName:@"messageview" bundle:nil];
}

- (void)loadMessage:(NSDictionary *)message {
    _fromlabel.stringValue = [NSString stringWithFormat:@"From: %@", message[@"username"]];
    _subject.stringValue = [NSString stringWithFormat:@"Subject: %@", message[@"subject"]];
    _date.stringValue = (NSString *)message[@"time"];
    NSString *messagestr;
    if (message[@"message"]){
        messagestr = [NSString stringWithFormat:@"<html><head><meta charset=\"UTF-8\"><style> body { font-family: -apple-system; }</style></head><body>%@</body></html>",message[@"message"]];
    }
    else {
        messagestr = @"";
    }
    [[_messagewebview mainFrame] loadHTMLString:messagestr baseURL:[[NSBundle mainBundle] bundleURL]];
}

@end
