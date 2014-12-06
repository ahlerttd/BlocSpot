//
//  MapAnnotationViewController.h
//  BlocSpot
//
//  Created by Trevor Ahlert on 11/10/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKitViewController.h"
#import "AppDelegate.h"
#import "POICategory.h"
#import "POI.h"

@protocol MapAnnotationViewControllerDelegate;


@interface MapAnnotationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titlePopover;
@property (weak, nonatomic) IBOutlet UITextField *notes;
@property (nonatomic, retain) NSString *data;
@property (nonatomic, retain) NSString *mapNotesData;
@property (weak) id <MapAnnotationViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (nonatomic, strong) POICategory *selectedCategory;
@property (nonatomic, strong) POICategory *savedCategory;
@property (nonatomic, strong) NSString *selectedCategoryString;
@property (nonatomic, strong) POI *mapPOI;
@property  CLLocationDegrees latitude;
@property  CLLocationDegrees longitude;



@end

@protocol MapAnnotationViewControllerDelegate <NSObject>

-(void)dismissPop: (NSString *)value;
-(void)passCategory: (NSManagedObject *)category;
-(void)addCategoryViewController:(MapAnnotationViewController *)controller didSelectCategory:(NSString *)item;




@end
