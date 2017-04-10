//
//  MAL_LibraryUITests.m
//  MAL LibraryUITests
//
//  Created by 桐間紗路 on 2017/04/09.
//  Copyright © 2017 Atelier Shiori. All rights reserved.
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
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // Use recording to get started writing UI tests.
    
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
    
    XCUIElementQuery *toolbarsQuery = windowsQuery.toolbars;
    XCUIElement *titleSearchSearchField = toolbarsQuery.searchFields[@"Title Search"];
    [titleSearchSearchField click];
    
    XCUIElement *cell = [[[windowsQuery.outlines childrenMatchingType:XCUIElementTypeOutlineRow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeCell].element;
    [cell typeText:@""];
    [cell typeKey:XCUIKeyboardKeyDelete modifierFlags:XCUIKeyModifierNone];
    [cell typeKey:XCUIKeyboardKeyDelete modifierFlags:XCUIKeyModifierNone];
    [cell typeKey:XCUIKeyboardKeyDelete modifierFlags:XCUIKeyModifierNone];
    [cell typeKey:XCUIKeyboardKeyDelete modifierFlags:XCUIKeyModifierNone];
    [cell typeKey:XCUIKeyboardKeyDelete modifierFlags:XCUIKeyModifierNone];
    [cell typeText:@"ive sunsine"];
    [[[[[windowsQuery.tables[@"animesearch"] childrenMatchingType:XCUIElementTypeTableRow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeTextField] elementBoundByIndex:0] click];
    
    XCUIElement *addTitleButton = toolbarsQuery.buttons[@"Add Title"];
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
    [animeListStaticText click];
    [windowsQuery.checkBoxes[@"Watching"] click];
    XCUIElementQuery *tablesQuery = windowsQuery.tables;
    [[[[tablesQuery.tableRows containingType:XCUIElementTypeStaticText identifier:@"3/13"] childrenMatchingType:XCUIElementTypeTextField] elementBoundByIndex:0] click];
    
    XCUIElement *editTitleButton = toolbarsQuery.buttons[@"Edit Title"];
    [editTitleButton click];
    
    XCUIElementQuery *popoversQuery2 = windowsQuery.tables.popovers;
    [[[popoversQuery2 childrenMatchingType:XCUIElementTypePopUpButton] elementBoundByIndex:0] click];
    [windowsQuery.tables.popovers.menuItems[@"completed"] click];
    
    XCUIElement *editButton = popoversQuery2.buttons[@"Edit"];
    [editButton click];
    [windowsQuery.checkBoxes[@"Completed"] click];
    [[[[[tablesQuery childrenMatchingType:XCUIElementTypeTableRow] elementBoundByIndex:2] childrenMatchingType:XCUIElementTypeTextField] elementBoundByIndex:0] click];
    
    XCUIElement *deleteTitleButton = toolbarsQuery.buttons[@"Delete Title"];
    [deleteTitleButton click];
    
    XCUIElement *yesButton = windowsQuery.sheets[@"alert"].buttons[@"Yes"];
    [yesButton click];
    [windowsQuery.outlines.staticTexts[@"Manga"] click];
    [titleSearchSearchField.buttons[@"Search"] click];
    [cell typeText:@"loveless"];
    [[[[[tablesQuery childrenMatchingType:XCUIElementTypeTableRow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeTextField] elementBoundByIndex:0] click];
    [addTitleButton click];
    
    XCUIElement *chapterstepperStepper = popoversQuery2.steppers[@"chapterstepper"];
    XCUIElement *incrementArrow2 = [chapterstepperStepper childrenMatchingType:XCUIElementTypeIncrementArrow].element;
    [incrementArrow2 click];
    [incrementArrow2 click];
    [incrementArrow2 click];
    [[chapterstepperStepper childrenMatchingType:XCUIElementTypeDecrementArrow].element click];
    [popoversQuery2.buttons[@"Add"] click];
    [windowsQuery.outlines.staticTexts[@"Manga List"] click];
    [windowsQuery.checkBoxes[@"Reading"] click];
    [[[[tablesQuery.tableRows containingType:XCUIElementTypeStaticText identifier:@"2/0"] childrenMatchingType:XCUIElementTypeTextField] elementBoundByIndex:0] click];
    [editTitleButton click];
    [[popoversQuery2.steppers[@"chapstepper"] childrenMatchingType:XCUIElementTypeIncrementArrow].element click];
    [editButton click];
    [deleteTitleButton click];
    [yesButton click];
    [windowsQuery.outlines.staticTexts[@"Seasons"] click];
    
    XCUIElement *seasonPopUpButton = toolbarsQuery.popUpButtons[@"Season"];
    [seasonPopUpButton click];
    
    XCUIElement *springMenuItem = toolbarsQuery.menuItems[@"spring"];
    [springMenuItem click];
    [toolbarsQuery.popUpButtons[@"Year"] click];
    [toolbarsQuery.menuItems[@"2016"] click];
    [seasonPopUpButton click];
    [springMenuItem click];
    [[[[[tablesQuery childrenMatchingType:XCUIElementTypeTableRow] elementBoundByIndex:16] childrenMatchingType:XCUIElementTypeTextField] elementBoundByIndex:0] doubleClick];
    [[windowsQuery.toolbars containingType:XCUIElementTypeButton identifier:@"Add Title"].element click];
    [windowsQuery.buttons[XCUIIdentifierCloseWindow] click];

}

@end
