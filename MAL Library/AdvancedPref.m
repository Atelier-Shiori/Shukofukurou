//
//  AdvancedPref.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/04/07.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "AdvancedPref.h"
#import "Utility.h"
#import <AFNetworking/AFNetworking.h>

@interface AdvancedPref ()
@property (strong) IBOutlet NSTextField *fieldmalapi;
@property (strong) IBOutlet NSButton *testapibtn;

@end

@implementation AdvancedPref

- (id)init
{
    return [super initWithNibName:@"AdvancedPref" bundle:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"AdvancedPref";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Advanced", @"Toolbar item name for the Advanced preference pane");
}
#pragma mark
-(IBAction)resetMALAPI:(id)sender{
    //Reset Unofficial MAL API URL
    _fieldmalapi.stringValue = @"https://malapi.ateliershiori.moe";
    // Set MAL API URL in settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    [defaults setObject:_fieldmalapi.stringValue forKey:@"MALAPIURL"];
}
-(IBAction)testMALAPI:(id)sender{
    [_testapibtn setEnabled:NO];
    //Load API URL
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"%@/1/animelist/chikorita157", [defaults objectForKey:@"MALAPIURL"]] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [Utility showsheetmessage:@"API Test Successful" explaination:@"MAL API is functional." window: self.view.window];
        [_testapibtn setEnabled:YES];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [Utility showsheetmessage:@"API Test Unsuccessful" explaination:[NSString stringWithFormat:@"Error: %@", error] window:self.view.window];
        [_testapibtn setEnabled:YES];
    }];
    
}
@end
