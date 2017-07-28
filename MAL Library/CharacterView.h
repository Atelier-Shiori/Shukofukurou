//
//  CharacterView.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/07/26.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CharacterView : NSViewController
@property int selectedid;
@property int persontype;
typedef NS_ENUM(unsigned int, PersonType) {
    PersonCharacter = 0,
    PersonStaff = 1
};
- (void)populateCharacterInfo:(NSDictionary *)d withTitle:(NSString *)title;
@end
