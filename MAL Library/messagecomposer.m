//
//  messagecomposer.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/04/30.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "messagecomposer.h"
#import "HTMLtoBBCode.h"
#import "AppDelegate.h"

@interface messagecomposer ()
@property (strong) IBOutlet NSTextField *reciplicant;
@property (strong) IBOutlet NSTextField *subjectfield;
@property (strong) IBOutlet NSTextView *messagetext;
@property (weak) IBOutlet NSButton *sendbtn;

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

- (BOOL)windowShouldClose:(id)sender {
    if (self.window.documentEdited){
        [self showCloseWindowPrompt];
        return NO;
    }
    return YES;
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
    [self setSendBtnState];
    self.window.documentEdited = NO;
}

- (IBAction)sendmessage:(id)sender {
    NSDictionary *documentAttributes = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSData *htmlData = [_messagetext.attributedString dataFromRange:NSMakeRange(0, _messagetext.attributedString.length) documentAttributes:documentAttributes error:NULL];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",htmlString);
    NSLog(@"%@",[HTMLtoBBCode convertHTMLStringtoBBCode:htmlString]);
}

- (void)setSendBtnState {
    if (_reciplicant.stringValue.length > 0) {
        _sendbtn.enabled = true;
    }
    else {
        _sendbtn.enabled = false;
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    [self setSendBtnState];
    self.window.documentEdited = YES;
}

- (void)textDidChange:(NSNotification *)notification {
    self.window.documentEdited = YES;
}

- (void)showCloseWindowPrompt {
    NSAlert *alert = [[NSAlert alloc] init] ;
    [alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
    [alert setMessageText:NSLocalizedString(@"Do you want to stop creating this message without sending it?",nil)];
    [alert setInformativeText:NSLocalizedString(@"Once done, all changes will be lost.",nil)];
    // Set Message type to Warning
    alert.alertStyle = NSAlertStyleInformational;
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode== NSAlertFirstButtonReturn) {
            self.window.documentEdited = NO;
            [self.window close];
        }
    }];
}

- (IBAction)addlicense:(id)sender {
    AppDelegate *appdel = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appdel enterDonationKey:sender];
}

@end
