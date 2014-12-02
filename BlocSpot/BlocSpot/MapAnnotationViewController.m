//
//  MapAnnotationViewController.m
//  BlocSpot
//
//  Created by Trevor Ahlert on 11/10/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import "MapAnnotationViewController.h"
#import "MapKitViewController.h"
#import "WYPopoverController.h"
#import "CategoryPickerViewController.h"
#import "POICategory.h"
#import "UIColor+String.h"


@interface MapAnnotationViewController () <UIActionSheetDelegate, WYPopoverControllerDelegate, CategoryPickerViewControllerDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) WYPopoverController *popover;



@end

@implementation MapAnnotationViewController

- (IBAction)category:(id)sender {
    
    CategoryPickerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryPicker"];
    
    self.popover = [[WYPopoverController alloc] initWithContentViewController:vc];
    
    [self.popover setDelegate:self];
    vc.delegate = self;
    
    ///self.annotationPopoverController = poc;
    
    self.popover.popoverContentSize = CGSizeMake(300, 200);
    
    [self.popover presentPopoverFromRect:self.view.bounds inView:self.view permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.titlePopover.text = self.data;
    self.textField.text = self.mapNotesData;
    
    NSString *categoryName = self.savedCategory.name;
    UIColor *color = [UIColor fromString:self.savedCategory.color];
    
    if (categoryName != nil) {
        [self.categoryButton setTitle:categoryName forState:UIControlStateNormal];
        [self.categoryButton setTitleColor:color forState:UIControlStateNormal];
    }
    else {
        
        [self.categoryButton setTitle:@"Select a Category" forState:UIControlStateNormal];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categorySelected:) name:@"Category Selected" object:nil];
    
    
}

-(void) categorySelected: (NSNotification*) notification{
    
    [self.popover  dismissPopoverAnimated:YES];
    
    UIColor *color = [UIColor fromString:self.selectedCategory.color];
    [self.categoryButton setTitle:self.selectedCategory.name forState:UIControlStateNormal];
    [self.categoryButton setTitleColor:color forState:UIControlStateNormal];
    
    
    
    
}

- (void)viewWillAppear: (BOOL)animated {
    [self.notes setText:self.mapNotesData];
}


- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    
}


- (void) viewDidDisappear:(BOOL)animated{
    
    [self.delegate passCategory:self.selectedCategory];
    [self.delegate dismissPop:[self.notes text]];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)dismissPop: (POICategory *)object {
    
    self.selectedCategory = object;
    
    
}





@end
