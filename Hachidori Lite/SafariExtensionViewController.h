//
//  SafariExtensionViewController.h
//  Hachidori Lite
//
//  Created by 千代田桃 on 6/13/21.
//  Copyright © 2021 Atelier Shiori. All rights reserved.
//

#import <SafariServices/SafariServices.h>

@interface SafariExtensionViewController : SFSafariExtensionViewController

+ (SafariExtensionViewController *)sharedController;

@end
