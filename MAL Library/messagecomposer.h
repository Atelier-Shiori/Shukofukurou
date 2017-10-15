//
//  messagecomposer.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/04/30.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface messagecomposer : NSWindowController <NSTextFieldDelegate, NSTextDelegate, NSWindowDelegate>
@property (nonatomic, copy, nullable) void (^completionblock)();
- (void)setToUsername:(NSString *_Nonnull)tousername;
- (void)setMessage:(NSString *_Nullable)reciplicant withSubject:(NSString * _Nullable)subject withMessage:(NSAttributedString * _Nullable)message withThreadID:(int)tid;
@end
