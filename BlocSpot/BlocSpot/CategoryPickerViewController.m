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

@interface CategoryPickerViewController () <NSFetchedResultsControllerDelegate>

@property NSFetchedResultsController *frc;
@property POICategory *POICategory;


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
    cell.backgroundColor = [UIColor fromString:subTitle];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    self.POICategory = [self.frc.fetchedObjects objectAtIndex:indexPath.row];
    [self.delegate dismissPop:self.POICategory];
    

    [[NSNotificationCenter defaultCenter] postNotificationName:@"Category Selected" object: self.POICategory];
}




@end
