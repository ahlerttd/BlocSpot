//
//  FilterViewController.h
//  BlocSpot
//
//  Created by Trevor Ahlert on 12/15/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "POICategory.h"

@protocol FilterViewControllerDelegate;

@interface FilterViewController : UITableViewController

@property (strong) NSManagedObject *selectCategory;
@property (weak) id <FilterViewControllerDelegate> delegate;

@end

@protocol FilterViewControllerDelegate <NSObject>

-(void)dismissPop: (POICategory *)object;

@end