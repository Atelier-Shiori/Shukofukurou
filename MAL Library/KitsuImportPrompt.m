//
//  KitsuImportPrompt.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/05/11.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
//

#import "KitsuImportPrompt.h"

@interface KitsuImportPrompt ()

@end

@implementation KitsuImportPrompt
- (instancetype)init{
    self = [super initWithWindowNibName:@"KitsuImportPrompt"];
    if (!self)
        return nil;
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)performkitsuimport:(id)sender {
    if (_kitsuusernamefield.stringValue.length > 0) {
        [NSApp endSheet:self.window returnCode:1];
        [self.window close];
    }
    else {
        NSBeep();
    }
}

- (IBAction)cancelkitsuimport:(id)sender {
    [NSApp endSheet:self.window returnCode:0];
}
@end
