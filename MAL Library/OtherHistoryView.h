//
//  OtherHistoryView.h
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/10/17.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "HistoryView.h"

@interface OtherHistoryView : HistoryView
- (void)loadHistory:(NSString *)username;
- (void)clearHistory;
- (IBAction)historydoubleclick:(id)sender;
@end
