//
//  MapAnnotationViewController.m
//  BlocSpot
//
//  Created by Trevor Ahlert on 11/10/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import "MapAnnotationViewController.h"

@interface MapAnnotationViewController ()

@property (nonatomic, strong) UITextField *textField;

@end

@implementation MapAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField = [[UITextField alloc ] init];
    self.textField.placeholder = NSLocalizedString(@"Website URL", @"Placeholder text for web browser URL field");
    
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.textField.frame = CGRectMake(0, 0, 50, 50);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
