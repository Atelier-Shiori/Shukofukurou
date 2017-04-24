//
//  messageview.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/24.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface messageview : NSViewController
@property int selectedmessageid;
@property (strong) NSDictionary *selectedmessage;
- (void)loadMessage:(NSDictionary *)message;
@end
