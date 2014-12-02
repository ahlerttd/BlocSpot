//
//  UIColor+String.h
//  BlocSpot
//
//  Created by Trevor Ahlert on 11/20/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (String)

-(NSString *)toString;
+(UIColor *)fromString: (NSString *)string;

@end
