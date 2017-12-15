//
//  MAL_Library_Unit_Tests.m
//  MAL Library Unit Tests
//
//  Created by 天々座理世 on 2017/04/11.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import "MyAnimeList.h"
#import "listservice.h"
#import "Keychain.h"
#import "HTMLtoBBCode.h"

@interface MAL_Library_Unit_Tests : XCTestCase

@end

@implementation MAL_Library_Unit_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testAnimeListLoading {
    // This class will test retrevial of the Anime List and Manga List
    //Expectation
    XCTestExpectation *expectation = [self expectationWithDescription:@"List Loading"];
    [listservice retrieveList:[Keychain getusername] listType:MALAnime completion:^(id response){
        NSArray *animelist = response[@"anime"];
        int animetotal = [self checkListTotals:animelist type:0];
        if (animetotal == animelist.count){
            XCTAssert(YES, @"List totals matched");
        }
        else {
            XCTAssert(NO, @"Failed: Calculated totals do not match.");
        }
        [expectation fulfill];
    }error:^(NSError *error){
        if (error){
            XCTFail(@"List retrieval failed with error: %@", error);
            [expectation fulfill];
        }
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
    
}

- (void)testMangaListLoading{
    XCTestExpectation *expectation = [self expectationWithDescription:@"List Loading"];
    [listservice retrieveList:[Keychain getusername] listType:MALManga completion:^(id response){
        NSArray *mangalist = response[@"manga"];
        
        int mangatotal = [self checkListTotals:mangalist type:1];
        if (mangatotal == mangalist.count){
            XCTAssert(YES, @"List totals matched");
        }
        else {
            XCTAssert(NO, @"Failed: Calculated totals do not match.");
        }
        [expectation fulfill];
    }error:^(NSError *error){
        if (error){
            XCTFail(@"List retrieval failed with error: %@", error);
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}

- (void)testAnimeSearch{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Search"];
    __block NSString *searchterm = @"Love Live! Sunshine!!";
    [listservice searchTitle:searchterm withType:MALAnime completion:^(id responseObject){
        NSArray *a = responseObject;
        bool match = false;
        for (NSDictionary *d in a){
            NSString *title = d[@"title"];
            if ([title isEqualToString:searchterm]){
                match = true;
                break;
            }
        }
        if (match){
            NSLog(@"Title %@ found", searchterm);
            XCTAssert(YES, @"Title found on search results");
        }
        else {
            XCTAssert(NO, @"Title could not be found on search results");
        }
        [expectation fulfill];
    }error:^(NSError *error){
        XCTFail(@"Search Result retrieval failed with error: %@", error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}

- (void)testMangaSearch{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Search"];
    __block NSString *searchterm = @"Kiniro Mosaic";
    [listservice searchTitle:searchterm withType:MALManga completion:^(id responseObject){
        NSArray *a = responseObject;
        bool match = false;
        for (NSDictionary *d in a){
            NSString *title = d[@"title"];
            if ([title isEqualToString:searchterm]){
                match = true;
                break;
            }
        }
        if (match){
            NSLog(@"Title %@ found", searchterm);
            XCTAssert(YES, @"Title found on search results");
        }
        else {
            XCTAssert(NO, @"Title could not be found on search results");
        }
        [expectation fulfill];
    }error:^(NSError *error){
        XCTFail(@"Search Result retrieval failed with error: %@", error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}
- (void)testAnimeTitleAdd{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *searchterm = @"Love Live! Sunshine!!";
    [listservice searchTitle:searchterm withType:MALAnime completion:^(id responseObject){
        NSArray * a = responseObject;
        bool match = false;
        __block NSNumber * titleid;
        for (NSDictionary *d in a){
            NSString * title = d[@"title"];
            if ([title isEqualToString:searchterm]){
                match = true;
                titleid = d[@"id"];
                break;
            }
        }
        if (match){
            NSLog(@"Title %@ found. Adding title", searchterm);
            [listservice addAnimeTitleToList:titleid.intValue withEpisode:1 withStatus:@"watching" withScore:0 completion:^(id responseObject){
                [listservice retrieveTitleInfo:titleid.intValue withType:MALAnime useAccount:YES completion:^(id responseObject){
                    NSNumber *watchedepisodes = responseObject[@"watched_episodes"];
                    NSString *watchedstatus = responseObject[@"watched_status"];
                    NSNumber *score = responseObject[@"score"];
                    if (watchedepisodes.intValue == 1 && [watchedstatus isEqualToString:@"watching"] && score.intValue == 0){
                        XCTAssert(YES, @"Update successful");
                        NSLog(@"Title added to list successfully");
                    }
                    else {
                        XCTAssert(NO, @"Update failed, values do not match");
                    }
                    [expectation fulfill];
                }error:^(NSError *error){
                    XCTFail(@"Title information retrieval failed with error: %@", error);
                    [expectation fulfill];
                }];
            }error:^(NSError *error){
                XCTFail(@"Title add failed with error: %@", error);
                [expectation fulfill];
            }];
        }
        else {
            XCTAssert(NO, @"Title could not be found on search results");
            [expectation fulfill];
        }
    }error:^(NSError *error){
        XCTFail(@"Search Result retrieval failed with error: %@", error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:90 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}
- (void)testAnimeTitleModify{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *title = @"Love Live! Sunshine!!";
    [listservice retrieveList:[Keychain getusername] listType:MALAnime completion:^(id responseData){
        NSArray * a = responseData[@"anime"];
        __block NSNumber *listid;
        bool match = false;
        for (NSDictionary *d in a){
            listid = d[@"id"];
            NSString *entrytitle = d[@"title"];
            if ([entrytitle isEqualToString:title]){
                match = true;
                break;
            }
        }
        if (match){
            [listservice updateAnimeTitleOnList:listid.intValue withEpisode:13 withStatus:@"completed" withScore:8 withTags:@"" completion:^(id responseObject){
                [listservice retrieveTitleInfo:listid.intValue withType:MALAnime useAccount:YES completion:^(id responseObject){
                    NSNumber *watchedepisodes = responseObject[@"watched_episodes"];
                    NSString *watchedstatus = responseObject[@"watched_status"];
                    NSNumber *score = responseObject[@"score"];
                    if (watchedepisodes.intValue == 13 && [watchedstatus isEqualToString:@"completed"] && score.intValue == 8){
                        XCTAssert(YES, @"Update successful");
                        NSLog(@"Title update was successful");
                    }
                    else {
                        XCTAssert(NO, @"Update failed, values do not match");
                    }
                    [expectation fulfill];
                }error:^(NSError *error){
                    XCTFail(@"Title information retrieval failed with error: %@", error);
                    [expectation fulfill];
                }];
            }error:^(NSError *error){
                XCTFail(@"Update failed with error: %@", error);
                [expectation fulfill];
            }];
        }
        else {
            XCTAssert(NO, @"Title could not be found on user's list");
            [expectation fulfill];
        }
    }error:^(NSError *error){
        XCTFail(@"Title check failed with error: %@", error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:90 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}
- (void)testAnimeTitleRemove{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Deletion"];
    __block NSString *title = @"Love Live! Sunshine!!";
    [listservice retrieveList:[Keychain getusername] listType:MALAnime completion:^(id responseData){
        NSArray * a = responseData[@"anime"];
        __block NSNumber *listid;
        bool match = false;
        for (NSDictionary *d in a){
            listid = d[@"id"];
            NSString *entrytitle = d[@"title"];
            if ([entrytitle isEqualToString:title]){
                match = true;
                break;
            }
        }
        if (match){
            [listservice removeTitleFromList:listid.intValue withType:MALAnime completion:^(id responseData){
                [listservice retrieveTitleInfo:listid.intValue withType:MALAnime useAccount:YES completion:^(id responseObject){
                    if (!responseObject[@"watched_episodes"]){
                        XCTAssert(YES, @"Title removal successful");
                        NSLog(@"Title removed from list successfully");
                    }
                    else {
                        XCTAssert(NO, @"Title removal failed.");
                    }
                    [expectation fulfill];
                }error:^(NSError *error){
                    XCTFail(@"Title information retrieval failed with error: %@", error);
                    [expectation fulfill];
                }];
            }error:^(NSError *error){
                XCTFail(@"Title removal failed with error: %@", error);
                [expectation fulfill];
            }];
        }
        else {
            XCTAssert(NO, @"Title could not be found on user's list");
            [expectation fulfill];
        }
    }error:^(NSError *error){
        XCTFail(@"Title check failed with error: %@", error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:90 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}
- (void)testMangaTitleAdd{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *searchterm = @"Loveless";
    [listservice searchTitle:searchterm withType:MALManga completion:^(id responseObject){
        NSArray * a = responseObject;
        bool match = false;
        __block NSNumber * titleid;
        for (NSDictionary *d in a){
            NSString * title = d[@"title"];
            if ([title isEqualToString:searchterm]){
                match = true;
                titleid = d[@"id"];
                break;
            }
        }
        if (match){
            NSLog(@"Title %@ found. Adding title", searchterm);
            [listservice addMangaTitleToList:titleid.intValue withChapter:10 withVolume:1 withStatus:@"reading" withScore:0 completion:^(id responseObject){
                [listservice retrieveTitleInfo:titleid.intValue withType:MALManga useAccount:YES completion:^(id responseObject){
                    NSNumber *readchapters = responseObject[@"chapters_read"];
                    NSNumber *readvolumes = responseObject[@"volumes_read"];
                    NSString *readstatus = responseObject[@"read_status"];
                    NSNumber *score = responseObject[@"score"];
                    if (readchapters.intValue == 10 && readvolumes.intValue == 1 && [readstatus isEqualToString:@"reading"] && score.intValue == 0){
                        XCTAssert(YES, @"Update successful");
                        NSLog(@"Title added to list successfully");
                    }
                    else {
                        XCTAssert(NO, @"Update failed, values do not match");
                    }
                    [expectation fulfill];
                }error:^(NSError *error){
                    XCTFail(@"Title information retrieval failed with error: %@", error);
                    [expectation fulfill];
                }];
            }error:^(NSError *error){
                XCTFail(@"Title add failed with error: %@", error);
                [expectation fulfill];
            }];
        }
        else {
            XCTAssert(NO, @"Title could not be found on search results");
            [expectation fulfill];
        }
    }error:^(NSError *error){
        XCTFail(@"Search Result retrieval failed with error: %@", error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:90 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}
- (void)testMangaTitleModify{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *title = @"Loveless";
    [listservice retrieveList:[Keychain getusername] listType:MALManga completion:^(id responseData){
        NSArray * a = responseData[@"manga"];
        __block NSNumber *listid;
        bool match = false;
        for (NSDictionary *d in a){
            listid = d[@"id"];
            NSString *entrytitle = d[@"title"];
            if ([entrytitle isEqualToString:title]){
                match = true;
                break;
            }
        }
        if (match){
            [listservice updateMangaTitleOnList:listid.intValue withChapter:20 withVolume:2 withStatus:@"dropped" withScore:7 withTags:@"" completion:^(id responseObject){
                [listservice retrieveTitleInfo:listid.intValue withType:MALManga useAccount:YES completion:^(id responseObject){
                    NSNumber *readchapters = responseObject[@"chapters_read"];
                    NSNumber *readvolumes = responseObject[@"volumes_read"];
                    NSString *readstatus = responseObject[@"read_status"];
                    NSNumber *score = responseObject[@"score"];
                    if (readchapters.intValue == 20 && readvolumes.intValue == 2 && [readstatus isEqualToString:@"dropped"] && score.intValue == 7){
                        XCTAssert(YES, @"Update successful");
                        NSLog(@"Title update was successful.");
                    }
                    else {
                        XCTAssert(NO, @"Update failed, values do not match");
                    }
                    [expectation fulfill];
                }error:^(NSError *error){
                    XCTFail(@"Title information retrieval failed with error: %@", error);
                    [expectation fulfill];
                }];
            }error:^(NSError *error){
                XCTFail(@"Update failed with error: %@", error);
                [expectation fulfill];
            }];
        }
        else {
            XCTAssert(NO, @"Title could not be found on user's list");
            [expectation fulfill];
        }
    }error:^(NSError *error){
        XCTFail(@"Title check failed with error: %@", error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:90 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}
- (void)testMangaTitleRemove{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Deletion"];
    __block NSString *title = @"Loveless";
    [listservice retrieveList:[Keychain getusername] listType:MALManga completion:^(id responseData){
        NSArray * a = responseData[@"manga"];
        __block NSNumber *listid;
        bool match = false;
        for (NSDictionary *d in a){
            listid = d[@"id"];
            NSString *entrytitle = d[@"title"];
            if ([entrytitle isEqualToString:title]){
                match = true;
                break;
            }
        }
        if (match){
            [listservice removeTitleFromList:listid.intValue withType:MALManga completion:^(id responseData){
                [listservice retrieveTitleInfo:listid.intValue withType:MALManga useAccount:YES completion:^(id responseObject){
                    if (!responseObject[@"chapters_read"]){
                        XCTAssert(YES, @"Title removal successful");
                        NSLog(@"Title removed from list successfully");
                    }
                    else {
                        XCTAssert(NO, @"Title removal failed.");
                    }
                    [expectation fulfill];
                }error:^(NSError *error){
                    XCTFail(@"Title information retrieval failed with error: %@", error);
                    [expectation fulfill];
                }];
            }error:^(NSError *error){
                XCTFail(@"Title removal failed with error: %@", error);
                [expectation fulfill];
            }];
        }
        else {
            XCTAssert(NO, @"Title could not be found on user's list");
            [expectation fulfill];
        }
    }error:^(NSError *error){
        XCTFail(@"Title check failed with error: %@", error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:90 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}
- (int)checkListTotals:(NSArray *)a type:(int)type{
    NSArray *filtered;
    if (type == 0){
        NSNumber *watching;
        NSNumber *completed;
        NSNumber *onhold;
        NSNumber *dropped;
        NSNumber *plantowatch;
        for (int i = 0; i < 5; i++){
            switch(i){
                case 0:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"watching"]];
                    watching = @(filtered.count);
                    break;
                case 1:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"completed"]];
                    completed = @(filtered.count);
                    break;
                case 2:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"on-hold"]];
                    onhold = @(filtered.count);
                    break;
                case 3:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"dropped"]];
                    dropped = @(filtered.count);
                    break;
                case 4:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"watched_status ==[cd] %@", @"plan to watch"]];
                    plantowatch = @(filtered.count);
                    break;
            }
        }
        NSLog(@"List Statistics - Anime");
        NSLog(@"Watching (%i)",watching.intValue);
        NSLog(@"Completed (%i)",completed.intValue);
        NSLog(@"On Hold (%i)",onhold.intValue);
        NSLog(@"Dropped (%i)",dropped.intValue);
        NSLog(@"Plan to watch (%i)",plantowatch.intValue);
        int total = watching.intValue + completed.intValue + onhold.intValue + dropped.intValue + plantowatch.intValue;
        return total;
    }
    else {
        NSNumber *reading;
        NSNumber *completed;
        NSNumber *onhold;
        NSNumber *dropped;
        NSNumber *plantoread;
        for (int i = 0; i < 5; i++){
            switch(i){
                case 0:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"reading"]];
                    reading = @(filtered.count);
                    break;
                case 1:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"completed"]];
                    completed = @(filtered.count);
                    break;
                case 2:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"on-hold"]];
                    onhold = @(filtered.count);
                    break;
                case 3:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"dropped"]];
                    dropped = @(filtered.count);
                    break;
                case 4:
                    filtered = [a filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_status ==[cd] %@", @"plan to read"]];
                    plantoread = @(filtered.count);
                    break;
            }
        }
        NSLog(@"List Statistics - Manga");
        NSLog(@"Reading (%i)",reading.intValue);
        NSLog(@"Completed (%i)",completed.intValue);
        NSLog(@"On Hold (%i)",onhold.intValue);
        NSLog(@"Dropped (%i)",dropped.intValue);
        NSLog(@"Plan to read (%i)",plantoread.intValue);
        int total = reading.intValue + completed.intValue + onhold.intValue + dropped.intValue + plantoread.intValue;
        return total;
    }
    return 0;
}

- (void)testHTMLtoBBCode {
    NSString * TestHTML = @"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\n<html>\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n<meta http-equiv=\"Content-Style-Type\" content=\"text/css\">\n<title></title>\n<meta name=\"Generator\" content=\"Cocoa HTML Writer\">\n<meta name=\"CocoaVersion\" content=\"1504.82\">\n<style type=\"text/css\">\np.p1 {margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Helvetica}\np.p2 {margin: 0.0px 0.0px 0.0px 0.0px; text-align: center; font: 12.0px Helvetica}\np.p3 {margin: 0.0px 0.0px 0.0px 0.0px; text-align: right; font: 18.0px Helvetica}\nspan.s1 {text-decoration: underline}\n</style>\n</head>\n<body>\n<p class=\"p1\">test <b>test <i>test </i></b><span class=\"s1\"><b><i>test</i></b></span></p>\n<p class=\"p2\">centered text</p>\n<p class=\"p3\">right text</p>\n<p class=\"p3\"><a href=\"http://www.chikorita157.com/\">Home</a></p>\n</body>\n</html>";
    NSString *ExpectedBBCodeOutput = @"[size=100]test [b]test [i]test [/i][/b][u][b][i]test[/i][/b][/u][/size]\n[size=100][center]centered text[/center][/size]\n[size=150][right]right text[/right][/size]\n[size=150][right][url=http://www.chikorita157.com/]Home[/url][/right][/size]\n";
    NSString *BBCodeOutput = [HTMLtoBBCode convertHTMLStringtoBBCode:TestHTML];
    if (![BBCodeOutput isEqualToString:ExpectedBBCodeOutput]) {
        XCTAssert(NO, @"BBCode output does not match the correct string output.");
    }
    else {
        XCTAssert(YES, @"No errors.");
    }
}

- (void)testAccountVerification {
    // Tests account verification check
    // Set Date
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"credentialscheckdate"];
    // Test
    if ([listservice verifyAccount]) {
        // Set Date
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"credentialscheckdate"];
        if ([listservice verifyAccount]) {
            XCTAssert(YES, @"No errors.");
        }
        else {
            XCTAssert(NO, @"Login failed.");
        }
    }
    else {
        XCTAssert(NO, @"Login failed.");
    }
}

- (void)testretrieveHistory {
    // Test History
    if (![Keychain checkaccount]) {
        XCTAssert(NO, @"No account.");
        return;
    }
    XCTestExpectation *expectation = [self expectationWithDescription:@"History"];
    [listservice retriveUpdateHistory:[Keychain getusername] completion:^(id responseobject){
        if ([responseobject isKindOfClass:[NSArray class]]) {
            NSLog(@"History object count: %li", [(NSArray *)responseobject count]);
            XCTAssert(YES, @"No errors.");
            [expectation fulfill];
        }
        else {
            XCTAssert(NO, @"Response object is not an NSArray class.");
            [expectation fulfill];
        }
    } error:^(NSError *error){
        XCTAssert(NO, @"Can't retrieve history.");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:90 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}

@end
