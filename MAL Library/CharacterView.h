//
//  CharacterView.h
//  Shukofukuro
//
//  Created by 桐間紗路 on 2017/07/26.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CharactersBrowser;

@interface CharacterView : NSViewController
@property (strong) IBOutlet NSTextField *charactername;
@property int selectedid;
@property int persontype;
@property (weak) CharactersBrowser *cb;
@property (strong) NSString *personhomepage;
typedef NS_ENUM(unsigned int, PersonType) {
    PersonCharacter = 0,
    PersonStaff = 1
};
typedef NS_ENUM(unsigned int, ArrayType) {
    actors = 11,
    voiceactingroles = 12,
    staffpositions = 13,
    publishedmanga = 14
};
- (void)populateCharacterInfo:(NSDictionary *)d withTitle:(NSString *)title;
- (void)populateStaffInformation:(NSDictionary *)d;
- (void)cleanup;
@end
