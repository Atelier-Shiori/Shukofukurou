//
//  OtherFormatExport.h
//  Shukofukurou
//
//  Created by 香風智乃 on 4/15/19.
//  Copyright © 2019 Atelier Shiori. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OtherFormatExport : NSObject
typedef NS_ENUM(int,ListExportType) {
    jsonAnimeExport = 1,
    jsonMangaExport = 2,
    csvAnimeExport = 3,
    csvMangaExport = 4
};

+ (instancetype)sharedManager;
- (NSString *)jsonListForType:(int)type;
- (NSString *)csvListForType:(int)type;
- (void)saveExportedList:(int)listexporttype;
@end

NS_ASSUME_NONNULL_END
