//
//  SoftwareUpdatesPref.m
//  Shukofukurou
//
//  Created by Nanoha Takamachi on 2014/10/18.
//  Copyright 2014 MAL Updater OS X Group. All rights reserved. Code licensed under New BSD License
//

#import "SoftwareUpdatesPref.h"


@implementation SoftwareUpdatesPref
- (instancetype)init
{
	return [super initWithNibName:@"SoftwareUpdateView" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)viewIdentifier {
    return @"SoftwareUpdatesPreferences";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageWithSystemSymbolName:@"arrow.triangle.2.circlepath" accessibilityDescription:@""];
}

- (NSString *)toolbarItemLabel {
    return NSLocalizedString(@"Software Updates", @"Toolbar item name for the Software Updatespreference pane");
}
@end
