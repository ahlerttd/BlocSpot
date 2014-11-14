//
//  MapAnnotationViewController.h
//  BlocSpot
//
//  Created by Trevor Ahlert on 11/10/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKitViewController.h"

@protocol MapAnnotationViewControllerDelegate;


@interface MapAnnotationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titlePopover;
@property (weak, nonatomic) IBOutlet UITextField *notes;
@property (nonatomic, retain) NSString *data;
@property (nonatomic, retain) NSString *mapNotesData;
@property (weak) id <MapAnnotationViewControllerDelegate> delegate;
- (IBAction)goBack:(id)sender;

@end

@protocol MapAnnotationViewControllerDelegate <NSObject>

-(void)dismissPop: (NSString *)value;



@end
