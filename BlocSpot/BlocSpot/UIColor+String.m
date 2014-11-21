//
//  UIColor+String.m
//  BlocSpot
//
//  Created by Trevor Ahlert on 11/20/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import "UIColor+String.h"

@implementation UIColor (String)

-(NSString *)toString{
    
   
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    NSString *colorAsString = [NSString stringWithFormat:@"%f,%f,%f,%f", components[0], components[1], components[2], components[3]];
 
    return colorAsString;
}

+(UIColor *)fromString: (NSString *)string{
    
    NSArray *components = [string componentsSeparatedByString:@","];
    CGFloat r = [[components objectAtIndex:0] floatValue];
    CGFloat g = [[components objectAtIndex:1] floatValue];
    CGFloat b = [[components objectAtIndex:2] floatValue];
    CGFloat a = [[components objectAtIndex:3] floatValue];
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    
    return color;
}




@end
