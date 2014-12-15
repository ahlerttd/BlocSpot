//
//  LocationsViewController.m
//  BlocSpot
//
//  Created by Trevor Ahlert on 11/6/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import "LocationsViewController.h"
#import "AppDelegate.h"
#import "POI.h"
#import "POICategory.h"
#import "MapKitViewController.h"
#import "FilterViewController.h"
#import "WYPopoverController.h"
#import "UIColor+String.h"

@interface LocationsViewController () <NSFetchedResultsControllerDelegate, WYPopoverControllerDelegate, FilterViewControllerDelegate>

@property NSFetchedResultsController *frc;
@property NSArray *filteredTableData;
@property (nonatomic, strong) WYPopoverController *popover;
@property (nonatomic, strong) POICategory *selectedCategory;

@end

@implementation LocationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"POI" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setIncludesSubentities:YES];
    
    if (self.selectedCategory) {
         [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(category.name ==[c] %@)", self.selectedCategory.name]];
    }
   
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:NULL cacheName:NULL];
    
    self.frc.delegate = self;
    [self.frc performFetch:NULL];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categorySelected:) name:@"Filter Selected" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allSelected:) name:@"All Selected" object:nil];
    
   /// categoryName = nil;
}

-(void) allSelected: (NSNotification*) notification{
 
    [self.popover  dismissPopoverAnimated:YES];
    
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"POI" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setIncludesSubentities:YES];
    
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:NULL cacheName:NULL];
    
    self.frc.delegate = self;
    [self.frc performFetch:NULL];
    
    [self.tableView reloadData];

    
}


-(void) categorySelected: (NSNotification*) notification{
    
    [self.popover  dismissPopoverAnimated:YES];
    
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"POI" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setIncludesSubentities:YES];
    
    if (self.selectedCategory) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(category.name ==[c] %@)", self.selectedCategory.name]];
    }
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:NULL cacheName:NULL];
    
    self.frc.delegate = self;
    [self.frc performFetch:NULL];
    
    [self.tableView reloadData];
   
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredTableData count];
    } else {
        return [self.frc.fetchedObjects count];;
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PointOfInterest"];
    if (cell == nil) {
        
        cell =
        [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                               reuseIdentifier:@"PointOfInterest"];
        
    }
    
    
    POI *POI = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        POI = [self.filteredTableData objectAtIndex:indexPath.row];
        NSString *title = [NSString stringWithFormat:@"%@", POI.title];
        NSString *subTitle = [NSString stringWithFormat:@"%@", POI.notes];
        
        cell.textLabel.text = title;
        cell.detailTextLabel.text = subTitle;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
   /* else if (tableView != self.searchDisplayController.searchResultsTableView) {
        
        if (self.selectedCategory != nil);{
        
        AppDelegate *appDelegate =
        [[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *context =
        [appDelegate managedObjectContext];
        
        NSFetchRequest * request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"POI" inManagedObjectContext:context]];
        [request setReturnsDistinctResults:YES];
        [request setIncludesSubentities:YES];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(title ==[c] %@)", self.selectedCategory.name]];
        NSArray *results = [context executeFetchRequest:request error:nil];
        
            if (results.count == 0) {
            
            }
            
            else {
            
            POI = [results objectAtIndex:0];
        NSString *title = [NSString stringWithFormat:@"%@", POI.title];
        NSString *subTitle = [NSString stringWithFormat:@"%@", POI.notes];
        
        cell.textLabel.text = title;
        cell.detailTextLabel.text = subTitle;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
    }
    
    }*/
    
    else {
    
    
    POI = [self.frc.fetchedObjects objectAtIndex:indexPath.row];
    NSString *title = [NSString stringWithFormat:@"%@", POI.title];
    NSString *subTitle = [NSString stringWithFormat:@"%@", POI.notes];
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subTitle;
    }
    
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete object from database
        [context deleteObject:[self.frc.fetchedObjects objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
    }
}

#pragma mark - SearchBar Functionality

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"POI" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"title" ascending:YES];
    NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    if(searchText.length > 0)
    {
        // Define how we want our entities to be filtered
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title contains[c] %@)", searchText];
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error;
    NSArray* loadedEntities = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    self.filteredTableData = [[NSMutableArray alloc] initWithArray:loadedEntities];
    
    [self.tableView reloadData];
    
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}


#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Perform segue to candy detail
    [self performSegueWithIdentifier:@"editSpot" sender:tableView];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"editSpot"]) {
        MapKitViewController *MapKitViewController = segue.destinationViewController;
    
         if(sender == self.searchDisplayController.searchResultsTableView) {
             
             POI *selectedNote = [self.filteredTableData objectAtIndex:[[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow] row]];
             MapKitViewController.editSpot = selectedNote;
             
         }
         else {
             
             
             POI *selectedNote = [self.frc.fetchedObjects objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
             
             
             MapKitViewController.editSpot = selectedNote;
         }
        
        
}


}

- (IBAction)filter:(id)sender {

    FilterViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterPicker"];
    
    self.popover = [[WYPopoverController alloc] initWithContentViewController:vc];
    
    [self.popover setDelegate:self];
    vc.delegate = self;
    
    ///self.annotationPopoverController = poc;
    
    self.popover.popoverContentSize = CGSizeMake(200, 200);
    
    [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
    


}

-(void)dismissPop: (POICategory *)object {
    
    self.selectedCategory = object;
    NSLog(@"Category Filter: %@", self.selectedCategory.name);
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
