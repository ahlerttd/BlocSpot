//
//  MapKitViewController.m
//  BlocSpot
//
//  Created by Trevor Ahlert on 11/7/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import "MapKitViewController.h"
#import "MyAnnotation.h"
#import "MapAnnotationViewController.h"
#import "WYPopoverController.h"
#import "AppDelegate.h"
#import "POI.h"
#import "POICategory.h"

@class MapAnnotationViewController;


@interface MapKitViewController () <MapKitViewControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, WYPopoverControllerDelegate, MapAnnotationViewControllerDelegate, NSFetchedResultsControllerDelegate>


{
    WYPopoverController* popoverController;
}




@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *initialLocation;
@property (nonatomic, strong) WYPopoverController *annotationPopoverController;
@property (nonatomic, strong) MyAnnotation *annotation;
@property (nonatomic, strong) NSString *annotationNotes;
@property (nonatomic, strong) NSString *annotationTitleSelected;
@property (nonatomic, strong) NSString *categorySelected;
@property NSFetchedResultsController *frc;


@end

@implementation MapKitViewController {
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
    
}

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
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects: @"title", @"notes", @"latitude", @"longitude", @"isvisited", @"id", nil]];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:NULL cacheName:NULL];
    
    self.frc.delegate = nil;
    [self.frc performFetch:NULL];
    
    NSArray *fetchedObjects = [self.frc fetchedObjects];
    
    NSLog(@"Fetched objects %@", fetchedObjects);
    
    
    [self.searchDisplayController setDelegate:self];
    [self.searchBar setDelegate:self];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Check for iOS 8 Vs earlier version like iOS7.Otherwise code will
    // crash on ios 7
    if ([self.locationManager respondsToSelector:@selector
         (requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    self.mapView.userInteractionEnabled = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    self.mapView.delegate = self;
    
    
    
    
    CLLocationCoordinate2D startCenter = CLLocationCoordinate2DMake(39.432679, -84.217259);
    CLLocationDistance regionWidth = 1500;
    CLLocationDistance regionHeight = 1500;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(startCenter, regionWidth, regionHeight);
    [self.mapView setRegion:startRegion animated:YES];
    
    
    
    
    for(NSDictionary *location in fetchedObjects) {
        CLLocationCoordinate2D annotationCoordinate =
        CLLocationCoordinate2DMake([location [@"latitude"] doubleValue], [location [@"longitude"]doubleValue]);
        MyAnnotation *annotation = [[MyAnnotation alloc]init];
        annotation.coordinate = annotationCoordinate;
        annotation.title = location[@"title"];
        annotation.subtitle =  nil;
        [self.mapView addAnnotation:annotation];
    }
    
}


-(MKAnnotationView *)mapView: (MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    
    MKAnnotationView *view = [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"annoView"];
    if (!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annoView"];
        
        view.enabled = YES;
        view.canShowCallout = YES;
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        
        view.rightCalloutAccessoryView = rightButton;
        
    }
    
    else{
        view.annotation = annotation;
        
    }
    
    if([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    view.image = [UIImage imageNamed:@"like-26.png"];
    return view;
}

- (void)mapView:(MKMapView *)mapView  annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    [mapView deselectAnnotation:view.annotation animated:YES];
    
    
    
    MapAnnotationViewController *ycvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapAnnotationViewController"];
    ycvc.delegate = self;
    
    WYPopoverController *poc = [[WYPopoverController alloc] initWithContentViewController:ycvc];
    
    ycvc.data = self.annotationTitleSelected;
    ycvc.mapNotesData = self.annotationNotes;
    
    
    
    
    
    poc.delegate = self;
    self.annotationPopoverController = poc;
    
    
    poc.popoverContentSize = CGSizeMake(300, 200);
    
    
    [poc presentPopoverFromRect:view.bounds inView:view permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
    
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    MyAnnotation *annotation = view.annotation;
    
    self.annotationTitleSelected = annotation.title;
    
    
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"POI" inManagedObjectContext:context]];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:[NSArray arrayWithObjects: @"title", @"notes", @"latitude", @"longitude", @"isvisited", @"id", nil]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(title ==[c] %@)", annotation.title]];
    NSArray *results = [context executeFetchRequest:request error:nil];
    
    if (results.count == 0)
    {
        self.annotationNotes = nil;
    }
    else
    {
        
        for(NSDictionary *location in results) {
            
            NSLog(@"Results %@", results);
            
            self.annotationNotes = location [@"notes"];
            
            NSLog(@"Notes %@", self.annotationNotes);
            
        }
        
    }
    
}




- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller;
{
    popoverController.delegate = nil;
    popoverController = nil;
    
    NSLog(@"Print dismiss");
}

- (void)dismissPop: (NSString *)value {
    
    self.annotationNotes = value; // populates data from popover
    
    
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"POI" inManagedObjectContext:context]];
    [request setResultType:NSManagedObjectResultType];
    [request setReturnsDistinctResults:YES];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(title ==[c] %@)", self.annotationTitleSelected]];
    NSLog(@"Annotation Title %@", self.annotationTitleSelected);
    NSArray *results = [context executeFetchRequest:request error:nil];
    
    
    
    if (results.count == 0)
    {
        
        
        
        POI *POI;
        POI = [NSEntityDescription
               insertNewObjectForEntityForName:@"POI"
               inManagedObjectContext:context];
        
        if (self.annotation.title.length > 0) {
            POI.title = self.annotation.title;
        }
        POI.notes = self.annotationNotes;
        POI.latitude = [NSNumber numberWithDouble: self.annotation.coordinate.latitude];
        POI.longitude = [NSNumber numberWithDouble:self.annotation.coordinate.longitude];
        
        
        
        
        
        
        [context save:NULL];
        
        
        
        
    }
    else {
        
        NSLog(@"Edit a specific field");
        
        POI* favoritsGrabbed = [results objectAtIndex:0];
        NSLog(@"Managed Object %@", favoritsGrabbed);
        favoritsGrabbed.notes = self.annotationNotes;
        NSLog(@"Annoation Notes  %@", self.annotationNotes);
        
        [context save:NULL];
        
    }
    
    
}

-(void)addCategoryViewController:(MapAnnotationViewController *)controller didSelectCategory:(NSString *)item{
    
    self.categorySelected = item;
    NSLog(@"Item %@", item);
    
}




- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation

{
    
    if ( !self.initialLocation )
    {
        self.initialLocation = userLocation.location;
        
        MKCoordinateRegion region;
        region.center = self.mapView.userLocation.coordinate;
        region.span = MKCoordinateSpanMake(0.1, 0.1);
        
        region = [self.mapView regionThatFits:region];
        [self.mapView setRegion:region animated:YES];
        
        NSLog(@"%f, %f", self.mapView.userLocation.location.coordinate.latitude,
              self.mapView.userLocation.location.coordinate.longitude);
        
    }
    
    
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)listView:(id)sender
{
    [self.delegate mapKitViewControllerDidCancel:self];
}

- (void)mapKitViewControllerDidCancel:(MapKitViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Search Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    // Cancel any previous searches.
    [localSearch cancel];
    
    // Perform a new search.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = self.mapView.region;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error != nil) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Map Error",nil)
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
            return;
        }
        
        if ([response.mapItems count] == 0) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Results",nil)
                                        message:nil
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
            return;
        }
        
        results = response;
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results.mapItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchDisplayController setActive:NO animated:YES];
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    self.annotation = [[MyAnnotation alloc]init];
    
    self.annotation.coordinate = item.placemark.coordinate;
    self.annotation.title = item.name;
    self.annotation.subtitle = item.placemark.addressDictionary[@"Street"];
    
    [self.mapView addAnnotation:self.annotation];
    
    [self.mapView selectAnnotation:self.annotation animated:YES];
    
    [self.mapView setCenterCoordinate:self.annotation.coordinate animated:YES];
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
    
    
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender != self.list) return;
    
    
}





@end
