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


@interface MapAnnotationViewController () <UIActionSheetDelegate, WYPopoverControllerDelegate>

@property (nonatomic, strong) UITextField *textField;


@end

@implementation MapAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.titlePopover.text = self.data;    
    
    self.textField.text = self.mapNotesData;
    
    
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear: (BOOL)animated {
    [self.notes setText:self.mapNotesData];
}


- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    
}


- (void) viewDidDisappear:(BOOL)animated{
    [self.delegate dismissPop:[self.notes text]];
    NSLog(@"goback: sender: %@", [self.notes text]);
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showCategoryActionSheet:(id)sender {
    
    CategoryPickerViewController *pickCategory = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryPicker"];
    
    
    
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
     if ([[segue identifier] isEqualToString:@"chooseCategory"]) {
         
       ///  CategoryPickerViewController *categoryPicker = segue.destinationViewController;
         
       ///  NSManagedObject *selectedCategory =
       ///
      ///   categoryPicker.selectedCategory = selectedCategory;
       ///
         
         NSLog(@"Pick a category");
         
     }
    
    
    
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    self.categoryPicked = buttonTitle;
    
    [self.delegate addCategoryViewController:self didSelectCategory:self.categoryPicked];
    
}








/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
