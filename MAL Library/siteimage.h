//
//  siteimage.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/06/20.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface siteimage : NSValueTransformer
+ (Class)transformedValueClass;
- (id)transformedValue:(id)value;
@end
