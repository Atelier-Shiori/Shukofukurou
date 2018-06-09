//
//  ExportProgressWindow.h
//  Shukofukurou
//
//  Created by 天々座理世 on 2018/06/05.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ExportProgressWindow : NSWindowController
@property (nonatomic, copy, nullable) void (^completion)(NSDictionary * _Nonnull list, int listType);
- (void)checklist:(int)type;
@end
