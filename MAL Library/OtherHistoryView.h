//
//  OtherHistoryView.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/10/17.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "HistoryView.h"

@interface OtherHistoryView : HistoryView
- (void)loadHistory:(NSString *)username;
- (void)clearHistory;
- (IBAction)historydoubleclick:(id)sender;
@end
