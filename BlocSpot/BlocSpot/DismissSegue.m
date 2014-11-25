//
//  DismissSegue.m
//  BlocSpot
//
//  Created by Trevor Ahlert on 11/17/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import "DismissSegue.h"

@implementation DismissSegue

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
   [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    
}

@end
