//
//  MAL_LibraryUITests.m
//  MAL LibraryUITests
//
//  Created by 桐間紗路 on 2017/04/09.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface MAL_LibraryUITests : XCTestCase

@end

@implementation MAL_LibraryUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = @[@"testing"];
    [app launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Specifiy the full exact title here to test
    NSString * animetitle = @"Love Live! Sunshine!!";
    NSString * mangatitle = @"Sword Art Online";
    
    // Do not modify anything below.
    XCUIElementQuery *windowsQuery = [[XCUIApplication alloc] init].windows;
    XCUIElement *animeListStaticText = windowsQuery.outlines.staticTexts[@"Anime List"];
    [animeListStaticText click];
    
    XCUIElement *automatictablecolumnidentifier0Outline = [windowsQuery.outlines containingType:XCUIElementTypeTableColumn identifier:@"AutomaticTableColumnIdentifier.0"].element;
    [automatictablecolumnidentifier0Outline typeKey:XCUIKeyboardKeyDownArrow modifierFlags:XCUIKeyModifierNone];
    [automatictablecolumnidentifier0Outline typeKey:XCUIKeyboardKeyDownArrow modifierFlags:XCUIKeyModifierNone];
    [automatictablecolumnidentifier0Outline typeKey:XCUIKeyboardKeyDownArrow modifierFlags:XCUIKeyModifierNone];
    [automatictablecolumnidentifier0Outline typeKey:XCUIKeyboardKeyDownArrow modifierFlags:XCUIKeyModifierNone];
    [automatictablecolumnidentifier0Outline typeKey:XCUIKeyboardKeyDownArrow modifierFlags:XCUIKeyModifierNone];
    [automatictablecolumnidentifier0Outline typeKey:XCUIKeyboardKeyDownArrow modifierFlags:XCUIKeyModifierNone];
    [automatictablecolumnidentifier0Outline typeKey:XCUIKeyboardKeyDownArrow modifierFlags:XCUIKeyModifierNone];
    [windowsQuery.outlines.staticTexts[@"Anime"] click];
    
    XCUIElementQuery *toolbarsQuery2 = [[XCUIApplication alloc] init].toolbars;
    XCUIElement *titleSearchSearchField = toolbarsQuery2.searchFields[@"Title Search"];
    [titleSearchSearchField click];
    
    XCUIElement *cell = [[[windowsQuery.outlines childrenMatchingType:XCUIElementTypeOutlineRow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeCell].element;
    [cell typeText:animetitle];
    [[[[[windowsQuery.tables[@"animesearch"] childrenMatchingType:XCUIElementTypeTableRow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeTextField] elementBoundByIndex:0] click];
    
    XCUIElement *addTitleButton = toolbarsQuery2.buttons[@"Add Title"];
    [addTitleButton click];
    
    XCUIElementQuery *popoversQuery = windowsQuery.tables[@"animesearch"].popovers;
    XCUIElementQuery *steppersQuery = popoversQuery.steppers;
    XCUIElement *incrementArrow = [steppersQuery childrenMatchingType:XCUIElementTypeIncrementArrow].element;
    [incrementArrow click];
    [incrementArrow click];
    [incrementArrow click];
    [incrementArrow click];
    [[steppersQuery childrenMatchingType:XCUIElementTypeDecrementArrow].element click];
    [[[popoversQuery childrenMatchingType:XCUIElementTypePopUpButton] elementBoundByIndex:1] click];
    [windowsQuery.tables[@"animesearch"].popovers.menuItems[@"8 - Very Good"] click];
    [popoversQuery.buttons[@"Add"] click];
    [NSThread sleepForTimeInterval:5];
    
    [animeListStaticText click];
    [windowsQuery.checkBoxes[@"Watching"] click];
    
    XCUIElement *filterSearchField = toolbarsQuery2.searchFields[@"Filter"];
    [filterSearchField click];
    [cell typeText:animetitle];
    
    XCUIElementQuery *tablesQuery = windowsQuery.tables;
    XCUIElement *textField = [[tablesQuery.tableRows childrenMatchingType:XCUIElementTypeTextField] elementBoundByIndex:0];
    [textField click];
    
    XCUIElementQuery *toolbarsQuery = toolbarsQuery2;
    [toolbarsQuery.buttons[@"Edit Title"] click];
    
    XCUIElementQuery *popoversQuery2 = windowsQuery.tables.popovers;
    [[[popoversQuery2 childrenMatchingType:XCUIElementTypePopUpButton] elementBoundByIndex:0] click];
    [windowsQuery.tables.popovers.menuItems[@"completed"] click];
    [popoversQuery2.buttons[@"Edit"] click];
    [NSThread sleepForTimeInterval:5];
    
    [windowsQuery.checkBoxes[@"Completed"] click];
    [textField click];
    
    XCUIElement *deleteTitleButton = toolbarsQuery.buttons[@"Delete Title"];
    [deleteTitleButton click];
    
    XCUIElement *yesButton = windowsQuery.sheets[@"alert"].buttons[@"Yes"];
    [yesButton click];
    [NSThread sleepForTimeInterval:5];
    
    
    [windowsQuery.outlines.staticTexts[@"Manga"] click];
    [titleSearchSearchField click];
    [cell typeText:mangatitle];
    [[[[[tablesQuery childrenMatchingType:XCUIElementTypeTableRow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeTextField] elementBoundByIndex:0] click];
    [addTitleButton click];
    
    XCUIElement *incrementArrow2 = [popoversQuery2.steppers[@"chapterstepper"] childrenMatchingType:XCUIElementTypeIncrementArrow].element;
    [incrementArrow2 click];
    [incrementArrow2 click];
    [incrementArrow2 click];
    [incrementArrow2 click];
    [[[popoversQuery2 childrenMatchingType:XCUIElementTypePopUpButton] elementBoundByIndex:1] click];
    [windowsQuery.tables.popovers.menuItems[@"7 - Good"] click];
    [popoversQuery2.buttons[@"Add"] click];
    [NSThread sleepForTimeInterval:5];
    
    [windowsQuery.outlines.staticTexts[@"Manga List"] click];
    [windowsQuery.checkBoxes[@"Reading"] click];
    [filterSearchField click];
    [cell typeText:mangatitle];
    [textField click];
    [deleteTitleButton click];
    [yesButton click];
    [NSThread sleepForTimeInterval:5];
    
    [windowsQuery.outlines.staticTexts[@"Seasons"] click];
    [toolbarsQuery2.popUpButtons[@"Year"] click];
    [toolbarsQuery2.menuItems[@"2016"] click];
    [toolbarsQuery2.popUpButtons[@"Season"] click];
    [toolbarsQuery2.menuItems[@"spring"] click];
    
    XCUIElement *titleButton = windowsQuery.tables.buttons[@"Title"];
    [titleButton click];
    [titleButton click];
    [[[[[tablesQuery childrenMatchingType:XCUIElementTypeTableRow] elementBoundByIndex:3] childrenMatchingType:XCUIElementTypeTextField] elementBoundByIndex:0] doubleClick];
    [NSThread sleepForTimeInterval:10];
    
}

@end
