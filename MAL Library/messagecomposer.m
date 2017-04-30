//
//  messagecomposer.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/04/30.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "messagecomposer.h"

@interface messagecomposer ()
@property (strong) IBOutlet NSTextField *reciplicant;
@property (weak) IBOutlet NSTextField *subjectfield;
@property (unsafe_unretained) IBOutlet NSTextView *messagetext;

@end

@implementation messagecomposer

- (instancetype)init{
    self = [super initWithWindowNibName:@"messagecomposer"];
    if (!self)
        return nil;
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)setMessage:(NSString *)reciplicant withSubject:(NSString *)subject withMessage:(NSAttributedString *)message {
    _reciplicant.stringValue = reciplicant;
    _subjectfield.stringValue = subject;
    if (message) {
        [_messagetext.textStorage setAttributedString:message];
    }
    else {
        _messagetext.string = @"";
    }
}

- (IBAction)sendmessage:(id)sender {
    NSDictionary *documentAttributes = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSData *htmlData = [_messagetext.attributedString dataFromRange:NSMakeRange(0, _messagetext.attributedString.length) documentAttributes:documentAttributes error:NULL];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",htmlString);
}

@end
