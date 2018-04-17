//
//  KitsuImportPrompt.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/05/11.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved.
//

#import "ImportPrompt.h"

@interface ImportPrompt ()

@end

@implementation ImportPrompt
- (instancetype)init {
    self = [super initWithWindowNibName:@"ImportPrompt"];
    if (!self) {
        return nil;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
    
- (void)setImportType:(int)type {
    switch (type) {
        case ImportKitsu:
            _promptext.stringValue = @"Please enter a Kitsu username to import.";
            break;
        case ImportAniList:
            _promptext.stringValue = @"Please enter an AniList username to import.";
            break;
        default:
            break;
    }
}
    
- (IBAction)performimport:(id)sender {
    if (_usernamefield.stringValue.length > 0) {
        [NSApp endSheet:self.window returnCode:1];
        [self.window close];
    }
    else {
        NSBeep();
    }
}

- (IBAction)cancelimport:(id)sender {
    [NSApp endSheet:self.window returnCode:0];
}
@end
