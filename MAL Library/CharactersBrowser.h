//
//  CharactersBrowser.h
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/07/26.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CharactersBrowser : NSWindowController <NSWindowDelegate, NSSearchFieldDelegate>
@property (strong) NSString *selectedtitle;

- (void)retrievecharacterinformation:(int)idnum;
- (void)retrievestaffinformation:(int)idnum;
- (int)getIndexOfItemWithIdentifier:(NSString *)string;
- (void)setAppearance;
@end
