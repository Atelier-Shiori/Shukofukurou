//
//  ShukofukurouTests.m
//  ShukofukurouTests
//
//  Created by 小鳥遊六花 on 5/1/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "listservice.h"
#import "Keychain.h"

@interface ShukofukurouTests : XCTestCase
@property (strong) NSString *myanimelistusername;
@property (strong) NSString *kitsuusername;
@property (strong) NSString *anilistusername;
@end

@implementation ShukofukurouTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSDictionary *usernames = [listservice.sharedInstance getAllUserNames];
    _myanimelistusername = usernames[@"myanimelist"];
    _kitsuusername = usernames[@"kitsu"];
    _anilistusername = usernames[@"anilist"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMALAnimeListLoading {
    // This class will test retrevial of the Anime List and Manga List
    //Expectation
    XCTestExpectation *expectation = [self expectationWithDescription:@"List Loading"];
    [MyAnimeList retrieveList:_myanimelistusername listType:MALAnime completion:^(id response){
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

- (void)testMALtMangaListLoading{
    XCTestExpectation *expectation = [self expectationWithDescription:@"List Loading"];
    [MyAnimeList retrieveList:_myanimelistusername listType:MALManga completion:^(id response){
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

- (void)testMALAnimeSearch{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Search"];
    __block NSString *searchterm = @"Love Live! Sunshine!!";
    [MyAnimeList searchTitle:searchterm withType:MALAnime completion:^(id responseObject){
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

- (void)testMALMangaSearch{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Search"];
    __block NSString *searchterm = @"Kiniro Mosaic";
    [MyAnimeList searchTitle:searchterm withType:MALManga completion:^(id responseObject){
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
- (void)testMALAnimeTitleAdd{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *searchterm = @"Love Live! Sunshine!!";
    [MyAnimeList searchTitle:searchterm withType:MALAnime completion:^(id responseObject){
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
            [MyAnimeList addAnimeTitleToList:titleid.intValue withEpisode:1 withStatus:@"watching" withScore:0 completion:^(id responseObject){
                [MyAnimeList retrieveTitleInfo:titleid.intValue withType:MALAnime useAccount:YES completion:^(id responseObject){
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
- (void)testMALAnimeTitleModify{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *title = @"Love Live! Sunshine!!";
    [MyAnimeList retrieveList:_myanimelistusername listType:MALAnime completion:^(id responseData){
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
            [MyAnimeList updateAnimeTitleOnList:listid.intValue withEpisode:13 withStatus:@"completed" withScore:8 withExtraFields:nil completion:^(id responseObject){
                [MyAnimeList retrieveTitleInfo:listid.intValue withType:MALAnime useAccount:YES completion:^(id responseObject){
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
- (void)testMALAnimeTitleRemove{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Deletion"];
    __block NSString *title = @"Love Live! Sunshine!!";
    [MyAnimeList retrieveList:_myanimelistusername listType:MALAnime completion:^(id responseData){
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
            [MyAnimeList removeTitleFromList:listid.intValue withType:MALAnime completion:^(id responseData){
                [MyAnimeList retrieveTitleInfo:listid.intValue withType:MALAnime useAccount:YES completion:^(id responseObject){
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
- (void)testMALMangaTitleAdd{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *searchterm = @"Loveless";
    [MyAnimeList searchTitle:searchterm withType:MALManga completion:^(id responseObject){
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
            [MyAnimeList addMangaTitleToList:titleid.intValue withChapter:10 withVolume:1 withStatus:@"reading" withScore:0 completion:^(id responseObject){
                [MyAnimeList retrieveTitleInfo:titleid.intValue withType:MALManga useAccount:YES completion:^(id responseObject){
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
- (void)testMALMangaTitleModify{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *title = @"Loveless";
    [MyAnimeList retrieveList:_myanimelistusername listType:MALManga completion:^(id responseData){
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
            [MyAnimeList updateMangaTitleOnList:listid.intValue withChapter:20 withVolume:2 withStatus:@"dropped" withScore:7 withExtraFields:nil completion:^(id responseObject){
                [MyAnimeList retrieveTitleInfo:listid.intValue withType:MALManga useAccount:YES completion:^(id responseObject){
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
- (void)testMALMangaTitleRemove{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Deletion"];
    __block NSString *title = @"Loveless";
    [MyAnimeList retrieveList:_myanimelistusername listType:MALManga completion:^(id responseData){
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
            [MyAnimeList removeTitleFromList:listid.intValue withType:MALManga completion:^(id responseData){
                [MyAnimeList retrieveTitleInfo:listid.intValue withType:MALManga useAccount:YES completion:^(id responseObject){
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

- (void)testKitsuAnimeListLoading {
    // This class will test retrevial of the Anime List and Manga List
    //Expectation
    XCTestExpectation *expectation = [self expectationWithDescription:@"List Loading"];
    [Kitsu retrieveList:_kitsuusername listType:KitsuAnime completion:^(id response){
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

- (void)testKitsuMangaListLoading{
    XCTestExpectation *expectation = [self expectationWithDescription:@"List Loading"];
    [Kitsu retrieveList:_kitsuusername listType:KitsuManga completion:^(id response){
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

- (void)testKitsuAnimeSearch{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Search"];
    __block NSString *searchterm = @"Sword Art Online";
    [Kitsu searchTitle:searchterm withType:KitsuAnime completion:^(id responseObject){
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

- (void)testKitsuMangaSearch{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Search"];
    __block NSString *searchterm = @"Kiniro Mosaic";
    [Kitsu searchTitle:searchterm withType:KitsuManga completion:^(id responseObject){
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
- (void)testKitsuAnimeTitleAdd{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *searchterm = @"Sword Art Online";
    [Kitsu searchTitle:searchterm withType:KitsuAnime completion:^(id responseObject){
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
            [Kitsu addAnimeTitleToList:titleid.intValue withEpisode:1 withStatus:@"watching" withScore:4 completion:^(id responseObject){
                [Kitsu retrieveList:_kitsuusername listType:KitsuAnime completion:^(id responseObject) {
                    NSArray *filtered = [responseObject[@"anime"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title ==[c] %@",searchterm]];
                    if (filtered.count > 0) {
                        NSDictionary *entry = filtered[0];
                        NSNumber *watchedepisodes = entry[@"watched_episodes"];
                        NSString *watchedstatus = entry[@"watched_status"];
                        NSNumber *score = entry[@"score"];
                        if (watchedepisodes.intValue == 1 && [watchedstatus isEqualToString:@"watching"] && score.intValue == 4){
                            XCTAssert(YES, @"Update successful");
                            NSLog(@"Title added to list successfully");
                        }
                        else {
                            XCTAssert(NO, @"Update failed, values do not match");
                        }
                    }
                    else {
                        XCTAssert(NO, @"Update failed, entry doesn't exist");
                    }
                    [expectation fulfill];
                } error:^(NSError *error) {
                    XCTFail(@"Title add failed with error: %@", error);
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
- (void)testKitsuAnimeTitleModify{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *title = @"Sword Art Online";
    [Kitsu retrieveList:_kitsuusername listType:KitsuAnime completion:^(id responseData){
        NSArray * a = responseData[@"anime"];
        __block NSNumber *listid;
        bool match = false;
        for (NSDictionary *d in a){
            listid = d[@"entryid"];
            NSString *entrytitle = d[@"title"];
            if ([entrytitle isEqualToString:title]){
                match = true;
                break;
            }
        }
        if (match){
            [Kitsu updateAnimeTitleOnList:listid.intValue withEpisode:25 withStatus:@"completed" withScore:20 withExtraFields:nil completion:^(id responseObject){
                [Kitsu retrieveList:_kitsuusername listType:KitsuAnime completion:^(id responseObject) {
                    NSArray *filtered = [responseObject[@"anime"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title ==[c] %@",title]];
                    if (filtered.count > 0) {
                        NSDictionary *entry = filtered[0];
                        NSNumber *watchedepisodes = entry[@"watched_episodes"];
                        NSString *watchedstatus = entry[@"watched_status"];
                        NSNumber *score = entry[@"score"];
                        if (watchedepisodes.intValue == 25 && [watchedstatus isEqualToString:@"completed"] && score.intValue == 20){
                            XCTAssert(YES, @"Update successful");
                            NSLog(@"Title update was successful");
                        }
                        else {
                            XCTAssert(NO, @"Update failed, values do not match");
                        }
                    }
                    else {
                        XCTAssert(NO, @"Update failed, entry doesn't exist");
                    }
                    [expectation fulfill];
                } error:^(NSError *error) {
                    XCTFail(@"Title update failed with error: %@", error);
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
- (void)testKitsuAnimeTitleRemove{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Deletion"];
    __block NSString *title = @"Sword Art Online";
    [Kitsu retrieveList:_kitsuusername listType:KitsuAnime completion:^(id responseData){
        NSArray * a = responseData[@"anime"];
        __block NSNumber *listid;
        bool match = false;
        for (NSDictionary *d in a){
            listid = d[@"entryid"];
            NSString *entrytitle = d[@"title"];
            if ([entrytitle isEqualToString:title]){
                match = true;
                break;
            }
        }
        if (match){
            [Kitsu removeTitleFromList:listid.intValue withType:KitsuAnime completion:^(id responseData){
                [Kitsu retrieveList:_kitsuusername listType:KitsuAnime completion:^(id responseObject) {
                    NSArray *filtered = [responseObject[@"anime"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title LIKE %@",title]];
                    if (filtered.count > 0) {
                        XCTAssert(NO, @"Title removal failed.");
                    }
                    else {
                        XCTAssert(YES, @"Title removal successful");
                        NSLog(@"Title removed from list successfully");
                    }
                    [expectation fulfill];
                } error:^(NSError *error) {
                    XCTFail(@"Title update failed with error: %@", error);
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
- (void)testKitsuMangaTitleAdd{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *searchterm = @"Loveless";
    [Kitsu searchTitle:searchterm withType:KitsuManga completion:^(id responseObject){
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
            [Kitsu addMangaTitleToList:titleid.intValue withChapter:10 withVolume:1 withStatus:@"reading" withScore:4 completion:^(id responseObject){
                [Kitsu retrieveList:_kitsuusername listType:KitsuManga completion:^(id responseObject) {
                    NSArray *filtered = [responseObject[@"manga"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title ==[c] %@",searchterm]];
                    if (filtered.count > 0) {
                        NSDictionary *entry = filtered[0];
                        NSNumber *readchapters = entry[@"chapters_read"];
                        NSNumber *readvolumes = entry[@"volumes_read"];
                        NSString *readstatus = entry[@"read_status"];
                        NSNumber *score = entry[@"score"];
                        if (readchapters.intValue == 10 && readvolumes.intValue == 1 && [readstatus isEqualToString:@"reading"] && score.intValue == 4){
                            XCTAssert(YES, @"Update successful");
                            NSLog(@"Title added to list successfully");
                        }
                        else {
                            XCTAssert(NO, @"Update failed, values do not match");
                        }
                    }
                    else {
                        XCTAssert(NO, @"Update failed, entry doesn't exist");
                    }
                    [expectation fulfill];
                } error:^(NSError *error) {
                    XCTFail(@"List Retrieval failed with error: %@", error);
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
- (void)testKitsuMangaTitleModify{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *title = @"Loveless";
    [Kitsu retrieveList:_kitsuusername listType:KitsuManga completion:^(id responseData){
        NSArray * a = responseData[@"manga"];
        __block NSNumber *listid;
        bool match = false;
        for (NSDictionary *d in a){
            listid = d[@"entryid"];
            NSString *entrytitle = d[@"title"];
            if ([entrytitle isEqualToString:title]){
                match = true;
                break;
            }
        }
        if (match){
            [Kitsu updateMangaTitleOnList:listid.intValue withChapter:20 withVolume:2 withStatus:@"dropped" withScore:12 withExtraFields:nil completion:^(id responseObject){
                [Kitsu retrieveList:_kitsuusername listType:KitsuManga completion:^(id responseObject) {
                    NSArray *filtered = [responseObject[@"manga"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title ==[c] %@",title]];
                    if (filtered.count > 0) {
                        NSDictionary *entry = filtered[0];
                        NSNumber *readchapters = entry[@"chapters_read"];
                        NSNumber *readvolumes = entry[@"volumes_read"];
                        NSString *readstatus = entry[@"read_status"];
                        NSNumber *score = entry[@"score"];
                        if (readchapters.intValue == 20 && readvolumes.intValue == 2 && [readstatus isEqualToString:@"dropped"] && score.intValue == 12){
                            XCTAssert(YES, @"Update successful");
                            NSLog(@"Title update was successful.");
                        }
                        else {
                            XCTAssert(NO, @"Update failed, values do not match");
                        }
                    }
                    else {
                        XCTAssert(NO, @"Update failed, entry doesn't exist");
                    }
                    [expectation fulfill];
                } error:^(NSError *error) {
                    XCTFail(@"List Retrieval failed with error: %@", error);
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
- (void)testKitsuMangaTitleRemove{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Deletion"];
    __block NSString *title = @"Loveless";
    [Kitsu retrieveList:_kitsuusername listType:KitsuManga completion:^(id responseData){
        NSArray * a = responseData[@"manga"];
        __block NSNumber *listid;
        bool match = false;
        for (NSDictionary *d in a){
            listid = d[@"entryid"];
            NSString *entrytitle = d[@"title"];
            if ([entrytitle isEqualToString:title]){
                match = true;
                break;
            }
        }
        if (match){
            [Kitsu removeTitleFromList:listid.intValue withType:KitsuManga completion:^(id responseData){
                [Kitsu retrieveList:_kitsuusername listType:KitsuManga completion:^(id responseObject) {
                    NSArray *filtered = [responseObject[@"manga"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title ==[c] %@",title]];
                    if (filtered.count > 0) {
                        XCTAssert(NO, @"Title removal failed.");
                    }
                    else {
                        XCTAssert(YES, @"Title removal successful");
                        NSLog(@"Title removed from list successfully");
                    }
                    [expectation fulfill];
                } error:^(NSError *error) {
                    XCTFail(@"List Retrieval failed with error: %@", error);
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
- (void)testAniListAnimeSearch{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Search"];
    __block NSString *searchterm = @"Sword Art Online";
    [AniList searchTitle:searchterm withType:AniListAnime completion:^(id responseObject){
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

- (void)testAniListMangaSearch{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Search"];
    __block NSString *searchterm = @"Kiniro Mosaic";
    [AniList searchTitle:searchterm withType:AniListManga completion:^(id responseObject){
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
- (void)testAniListAnimeTitleAdd{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *searchterm = @"Sword Art Online";
    [AniList searchTitle:searchterm withType:AniListAnime completion:^(id responseObject){
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
            [AniList addAnimeTitleToList:titleid.intValue withEpisode:1 withStatus:@"watching" withScore:20 completion:^(id responseObject){
                [AniList retrieveList:_anilistusername listType:AniListAnime completion:^(id responseObject) {
                    NSArray *filtered = [responseObject[@"anime"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title ==[c] %@",searchterm]];
                    if (filtered.count > 0) {
                        NSDictionary *entry = filtered[0];
                        NSNumber *watchedepisodes = entry[@"watched_episodes"];
                        NSString *watchedstatus = entry[@"watched_status"];
                        NSNumber *score = entry[@"score"];
                        if (watchedepisodes.intValue == 1 && [watchedstatus isEqualToString:@"watching"] && score.intValue == 20){
                            XCTAssert(YES, @"Update successful");
                            NSLog(@"Title added to list successfully");
                        }
                        else {
                            XCTAssert(NO, @"Update failed, values do not match");
                        }
                    }
                    else {
                        XCTAssert(NO, @"Update failed, entry doesn't exist");
                    }
                    [expectation fulfill];
                } error:^(NSError *error) {
                    XCTFail(@"Title add failed with error: %@", error);
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
- (void)testAniListAnimeTitleModify{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *title = @"Sword Art Online";
    [AniList retrieveList:_anilistusername listType:AniListAnime completion:^(id responseData){
        NSArray * a = responseData[@"anime"];
        __block NSNumber *listid;
        bool match = false;
        for (NSDictionary *d in a){
            listid = d[@"entryid"];
            NSString *entrytitle = d[@"title"];
            if ([entrytitle isEqualToString:title]){
                match = true;
                break;
            }
        }
        if (match){
            [AniList updateAnimeTitleOnList:listid.intValue withEpisode:25 withStatus:@"completed" withScore:70 withExtraFields:nil completion:^(id responseObject){
                [AniList retrieveList:_anilistusername listType:AniListAnime completion:^(id responseObject) {
                    NSArray *filtered = [responseObject[@"anime"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title ==[c] %@",title]];
                    if (filtered.count > 0) {
                        NSDictionary *entry = filtered[0];
                        NSNumber *watchedepisodes = entry[@"watched_episodes"];
                        NSString *watchedstatus = entry[@"watched_status"];
                        NSNumber *score = entry[@"score"];
                        if (watchedepisodes.intValue == 25 && [watchedstatus isEqualToString:@"completed"] && score.intValue == 70){
                            XCTAssert(YES, @"Update successful");
                            NSLog(@"Title update was successful");
                        }
                        else {
                            XCTAssert(NO, @"Update failed, values do not match");
                        }
                    }
                    else {
                        XCTAssert(NO, @"Update failed, entry doesn't exist");
                    }
                    [expectation fulfill];
                } error:^(NSError *error) {
                    XCTFail(@"Title update failed with error: %@", error);
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
- (void)testAniListAnimeTitleRemove{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Deletion"];
    __block NSString *title = @"Sword Art Online";
    [AniList retrieveList:_anilistusername listType:AniListAnime completion:^(id responseData){
        NSArray * a = responseData[@"anime"];
        __block NSNumber *listid;
        bool match = false;
        for (NSDictionary *d in a){
            listid = d[@"entryid"];
            NSString *entrytitle = d[@"title"];
            if ([entrytitle isEqualToString:title]){
                match = true;
                break;
            }
        }
        if (match){
            [AniList removeTitleFromList:listid.intValue withType:AniListAnime completion:^(id responseData){
                [AniList retrieveList:_anilistusername listType:AniListAnime completion:^(id responseObject) {
                    NSArray *filtered = [responseObject[@"anime"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title LIKE %@",title]];
                    if (filtered.count > 0) {
                        XCTAssert(NO, @"Title removal failed.");
                    }
                    else {
                        XCTAssert(YES, @"Title removal successful");
                        NSLog(@"Title removed from list successfully");
                    }
                    [expectation fulfill];
                } error:^(NSError *error) {
                    XCTFail(@"Title update failed with error: %@", error);
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
- (void)testAniListMangaTitleAdd{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *searchterm = @"Loveless";
    [AniList searchTitle:searchterm withType:AniListManga completion:^(id responseObject){
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
            [AniList addMangaTitleToList:titleid.intValue withChapter:10 withVolume:1 withStatus:@"reading" withScore:10 completion:^(id responseObject){
                [AniList retrieveList:_anilistusername listType:AniListManga completion:^(id responseObject) {
                    NSArray *filtered = [responseObject[@"manga"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title ==[c] %@",searchterm]];
                    if (filtered.count > 0) {
                        NSDictionary *entry = filtered[0];
                        NSNumber *readchapters = entry[@"chapters_read"];
                        NSNumber *readvolumes = entry[@"volumes_read"];
                        NSString *readstatus = entry[@"read_status"];
                        NSNumber *score = entry[@"score"];
                        if (readchapters.intValue == 10 && readvolumes.intValue == 1 && [readstatus isEqualToString:@"reading"] && score.intValue == 10){
                            XCTAssert(YES, @"Update successful");
                            NSLog(@"Title added to list successfully");
                        }
                        else {
                            XCTAssert(NO, @"Update failed, values do not match");
                        }
                    }
                    else {
                        XCTAssert(NO, @"Update failed, entry doesn't exist");
                    }
                    [expectation fulfill];
                } error:^(NSError *error) {
                    XCTFail(@"List Retrieval failed with error: %@", error);
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
- (void)testAniListMangaTitleModify{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add"];
    __block NSString *title = @"Loveless";
    [AniList retrieveList:_anilistusername listType:AniListManga completion:^(id responseData){
        NSArray * a = responseData[@"manga"];
        __block NSNumber *listid;
        bool match = false;
        for (NSDictionary *d in a){
            listid = d[@"entryid"];
            NSString *entrytitle = d[@"title"];
            if ([entrytitle isEqualToString:title]){
                match = true;
                break;
            }
        }
        if (match){
            [AniList updateMangaTitleOnList:listid.intValue withChapter:20 withVolume:2 withStatus:@"dropped" withScore:80 withExtraFields:nil completion:^(id responseObject){
                [AniList retrieveList:_anilistusername listType:AniListManga completion:^(id responseObject) {
                    NSArray *filtered = [responseObject[@"manga"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title ==[c] %@",title]];
                    if (filtered.count > 0) {
                        NSDictionary *entry = filtered[0];
                        NSNumber *readchapters = entry[@"chapters_read"];
                        NSNumber *readvolumes = entry[@"volumes_read"];
                        NSString *readstatus = entry[@"read_status"];
                        NSNumber *score = entry[@"score"];
                        if (readchapters.intValue == 20 && readvolumes.intValue == 2 && [readstatus isEqualToString:@"dropped"] && score.intValue == 80){
                            XCTAssert(YES, @"Update successful");
                            NSLog(@"Title update was successful.");
                        }
                        else {
                            XCTAssert(NO, @"Update failed, values do not match");
                        }
                    }
                    else {
                        XCTAssert(NO, @"Update failed, entry doesn't exist");
                    }
                    [expectation fulfill];
                } error:^(NSError *error) {
                    XCTFail(@"List Retrieval failed with error: %@", error);
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
- (void)testAniListMangaTitleRemove{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Deletion"];
    __block NSString *title = @"Loveless";
    [AniList retrieveList:_anilistusername listType:AniListManga completion:^(id responseData){
        NSArray * a = responseData[@"manga"];
        __block NSNumber *listid;
        bool match = false;
        for (NSDictionary *d in a){
            listid = d[@"entryid"];
            NSString *entrytitle = d[@"title"];
            if ([entrytitle isEqualToString:title]){
                match = true;
                break;
            }
        }
        if (match){
            [AniList removeTitleFromList:listid.intValue withType:AniListManga completion:^(id responseData){
                [AniList retrieveList:_anilistusername listType:AniListManga completion:^(id responseObject) {
                    NSArray *filtered = [responseObject[@"manga"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title ==[c] %@",title]];
                    if (filtered.count > 0) {
                        XCTAssert(NO, @"Title removal failed.");
                    }
                    else {
                        XCTAssert(YES, @"Title removal successful");
                        NSLog(@"Title removed from list successfully");
                    }
                    [expectation fulfill];
                } error:^(NSError *error) {
                    XCTFail(@"List Retrieval failed with error: %@", error);
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
                default:
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
                default:
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

- (void)testAccountVerification {
    // Tests account verification check
    // Set Date
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"credentialscheckdate"];
    // Test
    if ([MyAnimeList verifyAccount]) {
        // Set Date
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"credentialscheckdate"];
        if ([MyAnimeList verifyAccount]) {
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

@end
