//
//  StreamDataRetriever.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/06/20.
//  Copyright © 2017-2018 MAL Updater OS X Group and Moy IT Solutions. All rights reserved.
//

#import "StreamDataRetriever.h"
#import "Utility.h"
#import <AFNetworking/AFNetworking.h>

@implementation StreamDataRetriever

+ (void)retrieveStreamData {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"stream_data_refresh_date"] || ![Utility checkifFileExists:@"streamdata.json" appendPath:@""]){
        if (((NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:@"stream_data_refresh_date"]).timeIntervalSinceNow < 0 || ![Utility checkifFileExists:@"streamdata" appendPath:@""]) {
            [StreamDataRetriever performrestrieveStreamData];
        }
    }
}

+ (void)performrestrieveStreamData {
    NSString *region = @"";
    switch (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"stream_region"]).intValue) {
        case StreamRegionUS:
            region = @"us";
            break;
        case StreamRegionCA:
            region = @"ca";
            break;
        case StreamRegionUK:
            region = @"uk";
            break;
        case StreamRegionAU:
            region = @"au";
            break;
        default:
            break;
    }
    // Note: Stream Data provided by Because.moe
    // PHP script passthrough is needed to retrieve the data securely
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    [manager GET:[NSString stringWithFormat:@"https://malupdaterosx.moe/streamdata.php?region=%@",region] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [Utility saveJSON:responseObject withFilename:@"streamdata.json" appendpath:@"" replace:true];
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate dateWithTimeIntervalSinceNow:15*24*50*50] forKey:@"stream_data_refresh_date"];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Failed to retrieve stream data. Error: %@", error.localizedDescription);
    }];
}
@end
