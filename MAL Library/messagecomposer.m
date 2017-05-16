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
#import "MyAnimeList.h"
#import "Utility.h"

@interface messagecomposer ()
@property (strong) IBOutlet NSTextField *reciplicant;
@property (strong) IBOutlet NSTextField *subjectfield;
@property (strong) IBOutlet NSTextView *messagetext;
@property (strong) IBOutlet NSButton *sendbtn;
@property int threadid;
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

- (void)setMessage:(NSString *)reciplicant withSubject:(NSString * _Nullable)subject withMessage:(NSAttributedString * _Nullable)message withThreadID:(int)tid {
    _reciplicant.stringValue = reciplicant;
    _subjectfield.stringValue = subject;
    if (message) {
        [_messagetext.textStorage setAttributedString:message];
    }
    else {
        _messagetext.string = @"";
    }
    _threadid = tid;
    [self setSendBtnState];
    self.window.documentEdited = NO;
}

- (IBAction)sendmessage:(id)sender {
    NSDictionary *documentAttributes = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSData *htmlData = [_messagetext.attributedString dataFromRange:NSMakeRange(0, _messagetext.attributedString.length) documentAttributes:documentAttributes error:NULL];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    [MyAnimeList sendmessage:_reciplicant.stringValue withSubject:_subjectfield.stringValue withMessage:[HTMLtoBBCode convertHTMLStringtoBBCode:htmlString] withthreadID:_threadid completionHandler:^(id responseObject){
        self.window.documentEdited = NO;
        _completionblock();
        [self.window close];
    }error:^(NSError *error){
        NSLog(@"%@",error);
        [Utility showsheetmessage:@"Can't send message." explaination:@"Make sure you have the proper cedentials or specified a valid username to send the message to and try again." window:self.window];
    }];
}

- (void)setSendBtnState {
    if (_reciplicant.stringValue.length > 0 && (_subjectfield.stringValue.length > 0 || _messagetext.string.length > 0)) {
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
