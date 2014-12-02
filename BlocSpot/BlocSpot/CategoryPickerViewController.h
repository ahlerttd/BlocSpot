//
//  CategoryPickerViewController.h
//  BlocSpot
//
//  Created by Trevor Ahlert on 11/21/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "POICategory.h"

@protocol CategoryPickerViewControllerDelegate;

@interface CategoryPickerViewController : UITableViewController

@property (strong) NSManagedObject *selectCategory;
@property (weak) id <CategoryPickerViewControllerDelegate> delegate;

@end

@protocol CategoryPickerViewControllerDelegate <NSObject>

-(void)dismissPop: (POICategory *)object;

@end
