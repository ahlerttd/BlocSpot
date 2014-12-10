//
//  CategoryPickerViewController.m
//  BlocSpot
//
//  Created by Trevor Ahlert on 11/21/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import "CategoryPickerViewController.h"
#import "AppDelegate.h"
#import "POICategory.h"
#import "UIColor+String.h"
#import "MapAnnotationViewController.h"
#import "MyAnnotation.h"
#import "POICategory.h"



#define TEXT_FIELD_TAG 9999

#define ACTION_SHEET_TAG 8888

@interface CategoryPickerViewController () <NSFetchedResultsControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate>




@property NSFetchedResultsController *frc;
@property POICategory *POICategory;
@property (nonatomic, strong) NSString *alertViewString;

@end

@implementation CategoryPickerViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"POICategory" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:NULL cacheName:NULL];
    
    self.frc.delegate = self;
    [self.frc performFetch:NULL];
    [self.tableView reloadData];
    
    
}

-(void) viewDidDisappear:(BOOL)animated{
    
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.frc.fetchedObjects count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PointOfInterest"];
    if (cell == nil) {
        
        cell =
        [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                               reuseIdentifier:@"PointOfInterest"];
        
    }
    
    
    POICategory *POICategory = [self.frc.fetchedObjects objectAtIndex:indexPath.row];
    
    NSString *title = [NSString stringWithFormat:@"%@", POICategory.name];
    NSString *subTitle = [NSString stringWithFormat:@"%@", POICategory.color];
    
    cell.textLabel.text = title;
    cell.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor fromString:subTitle];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    self.POICategory = [self.frc.fetchedObjects objectAtIndex:indexPath.row];
    [self.delegate dismissPop:self.POICategory];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Category Selected" object: self.POICategory];
}





- (IBAction)addCategory:(id)sender {
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Add a Category"
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Ok", nil];
    theAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    
    [theAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Ok"])
    {
        
        UITextField *alertViewText = [alertView textFieldAtIndex:0];
        
        self.alertViewString = alertViewText.text;
        
        NSLog(@"Category Picked: %@", alertViewText.text);
        
    }
    
    
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    POICategory *POICategory;
    POICategory = [NSEntityDescription
                   insertNewObjectForEntityForName:@"POICategory"
                   inManagedObjectContext:context];
    if (self.alertViewString.length > 0){
        
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        
        POICategory.name = self.alertViewString;
        POICategory.color = [color toString];
        
    }
    
    [context save: NULL];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"POICategory" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:NULL cacheName:NULL];
    
    self.frc.delegate = self;
    [self.frc performFetch:NULL];
    [self.tableView reloadData];

}



@end
