//
//  InfoView.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindow;

@interface InfoView : NSViewController{
    IBOutlet MainWindow * mw;
}
@property (getter=getSelectedId, setter=setSelectedId:) int selectedid;
@property (getter=getSelectedInfo, readonly) NSDictionary * selectedanimeinfo;
@property (strong) IBOutlet NSTextView *infoviewbackgroundtextview;
@property (strong) IBOutlet NSTextView *infoviewdetailstextview;
@property (strong) IBOutlet NSTextView *infoviewsynopsistextview;
- (void)populateInfoView:(id)object;
- (IBAction)viewonmal:(id)sender;
@end
