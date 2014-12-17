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
#import "WYStoryboardPopoverSegue.h"
#import "PopoverView.h"
#import "UIColor+String.h"

@class MapAnnotationViewController;


@interface MapKitViewController () <MapKitViewControllerDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, WYPopoverControllerDelegate, MapAnnotationViewControllerDelegate, NSFetchedResultsControllerDelegate>


{
    WYPopoverController* popoverController;
    MapAnnotationViewController *ycvc;
    BOOL _didStartMonitoringRegion;
}




@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *initialLocation;
@property (strong, nonatomic) NSMutableArray *geofences;
@property (nonatomic, strong) WYPopoverController *annotationPopoverController;
@property (nonatomic, strong) MyAnnotation *annotation;
@property (nonatomic, strong) NSString *annotationNotes;
@property (nonatomic, strong) NSString *annotationTitleSelected;
@property (nonatomic, strong) NSString *annotationCategorySelected;
@property (nonatomic, strong) POICategory *categorySelected;
@property (nonatomic, strong) POICategory *categoryForColor;
@property (nonatomic, strong) POI *forSavedCategory;
@property NSFetchedResultsController *frc;
@property  CLLocationDegrees latitude;
@property  CLLocationDegrees longitude;



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
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setIncludesSubentities:YES];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
    
    [self.searchDisplayController setDelegate:self];
    [self.searchBar setDelegate:self];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    self.locationManager.pausesLocationUpdatesAutomatically = YES;
    // Check for iOS 8 Vs earlier version like iOS7.Otherwise code will
    // crash on ios 7
    if ([self.locationManager respondsToSelector:@selector
         (requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    // Load Geofences
    self.geofences = [NSMutableArray arrayWithArray:[[self.locationManager monitoredRegions] allObjects]];
    
    NSLog(@"Print Geofences: %@", self.geofences);
    
    
    self.mapView.showsUserLocation = YES;
    self.mapView.userInteractionEnabled = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeNone;
    self.mapView.delegate = self;
    
    CLLocationCoordinate2D startCenter = CLLocationCoordinate2DMake(39.432679, -84.217259);
    CLLocationDistance regionWidth = 1500;
    CLLocationDistance regionHeight = 1500;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(startCenter, regionWidth, regionHeight);
    [self.mapView setRegion:startRegion animated:YES];
    
    for (int i = 0; i < [fetchedObjects count]; i++){
        
        
        POI *POI = [fetchedObjects objectAtIndex:i];
        self.categoryForColor = POI.category;
        NSLog(@"self.categoryforcolor %@", self.categoryForColor.color);
        CLLocationCoordinate2D annotationCoordinate =
        CLLocationCoordinate2DMake([POI.latitude doubleValue], [POI.longitude  doubleValue]);
        MyAnnotation *annotation = [[MyAnnotation alloc]init];
        annotation.coordinate = annotationCoordinate;
        annotation.title = POI.title;
        annotation.subtitle =  nil;
        UIColor *color = [UIColor fromString:self.categoryForColor.color];
        
        if (color) {
            annotation.color = color;
        }
        
        CLLocationDegrees lat = [POI.latitude doubleValue];
        CLLocationDegrees log = [POI.longitude doubleValue];
        CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:lat longitude:log];
        
        CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:[newLocation coordinate] radius:500.0 identifier:[[NSUUID UUID] UUIDString]];
        
        // Start Monitoring Region
        [self.locationManager startMonitoringForRegion:region];
        
        
        
        [self.mapView addAnnotation:annotation];
    }
    
    
    
    
    if ( self.editSpot )
    {
        CLLocationDegrees lat = [self.editSpot.latitude doubleValue];
        CLLocationDegrees log = [self.editSpot.longitude doubleValue];
        
        CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:lat longitude:log];
        
        
        self.initialLocation = newLocation;
        
        MKCoordinateRegion region;
        region.center.latitude = lat;
        region.center.longitude = log;
        region.span = MKCoordinateSpanMake(0.1, 0.1);
        
        region = [self.mapView regionThatFits:region];
        
        
        [self.mapView setRegion:region animated:YES];
        self.editSpot = nil;
        
    }
    
    else {
        
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
    /// -(UIImage *)coloredImage:(UIImage *)firstImage withColor:(UIColor *)color
    
    
    
    MyAnnotation *myAnnotation = (MyAnnotation *)annotation;
    
    if (myAnnotation.color) {
        UIImage *heartImage = [UIImage imageNamed:@"like-26.png"];
        UIColor *imageColor = ((MyAnnotation *)annotation).color;
        heartImage = [self coloredImage:heartImage withColor: imageColor];
        view.image = heartImage;
    }
    
    else{
        
        view.image = [UIImage imageNamed:@"like-26.png"];
    }
    return view;
}

-(UIImage *)coloredImage:(UIImage *)firstImage withColor:(UIColor *)color {
    UIGraphicsBeginImageContext(firstImage.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    
    CGContextTranslateCTM(context, 0, firstImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGRect rect = CGRectMake(0, 0, firstImage.size.width, firstImage.size.height);
    CGContextDrawImage(context, rect, firstImage.CGImage);
    
    CGContextClipToMask(context, rect, firstImage.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathElementMoveToPoint);
    
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImg;
}

- (void)mapView:(MKMapView *)mapView  annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    [mapView deselectAnnotation:view.annotation animated:YES];
    
    ycvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapAnnotationViewController"];
    ycvc.delegate = self;
    
    WYPopoverController *poc = [[WYPopoverController alloc] initWithContentViewController:ycvc];
    
    
    ycvc.data = self.annotationTitleSelected;
    ycvc.selectedCategory = self.categorySelected;
    ycvc.mapNotesData = self.annotationNotes;
    ycvc.savedCategory = self.categorySelected;
    ycvc.latitude = self.latitude;
    ycvc.longitude = self.longitude;
    
    
    poc.delegate = self;
    self.annotationPopoverController = poc;
    
    poc.popoverContentSize = CGSizeMake(300, 200);
    
    [poc presentPopoverFromRect:view.bounds inView:view permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"mapAnnotationDetailView"]) {
        
    }
    
    
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
    [request setReturnsDistinctResults:YES];
    [request setIncludesSubentities:YES];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(title ==[c] %@)", annotation.title]];
    NSArray *results = [context executeFetchRequest:request error:nil];
    
    if (results.count == 0)
    {
        self.annotationNotes = nil;
        self.annotationCategorySelected = @"Select a Category";
        self.latitude = annotation.coordinate.latitude;
        self.longitude = annotation.coordinate.longitude;
        
    }
    else
    {
        
        POI* POI = [results objectAtIndex:0];
        self.annotationNotes = POI.notes;
        self.categorySelected = POI.category;
        self.latitude = [POI.latitude doubleValue];
        self.longitude = [POI.longitude doubleValue];
        
    }
    
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
        POI.category = self.categorySelected;
        
        [context save:NULL];
        
    }
    else {
        
        POI* POI = [results objectAtIndex:0];
        POI.notes = self.annotationNotes;
        POI.category = self.categorySelected;
        
        [context save:NULL];
        
    }
    
    self.categorySelected = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller;
{
    popoverController.delegate = nil;
    popoverController = nil;
    
}


-(void)passCategory: (POICategory *)category; {
    
    self.categorySelected = category;
    
    
}



/*- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
 
 {
 
 
 
 if ( !self.initialLocation ){
 
 self.initialLocation = userLocation.location;
 
 MKCoordinateRegion region;
 region.center = self.mapView.userLocation.coordinate;
 region.span = MKCoordinateSpanMake(0.1, 0.1);
 
 region = [self.mapView regionThatFits:region];
 /// [self.mapView setRegion:region animated:YES];
 
 }
 
 
 }
 */


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (!self.initialLocation){
        
        // If it's a relatively recent event, turn off updates to save power.
        CLLocation* location = [locations lastObject];
        ///   NSDate* eventDate = location.timestamp;
        //NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        // if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        self.latitude = location.coordinate.latitude;
        self.longitude = location.coordinate.longitude;
        
        MKCoordinateRegion region;
        region.center.latitude = location.coordinate.latitude;
        region.center.longitude = location.coordinate.longitude;
        region.span = MKCoordinateSpanMake(0.1, 0.1);
        
        region = [self.mapView regionThatFits:region];
        [self.mapView setRegion:region animated:YES];
        
    }
    ///}
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

#pragma mark - GeoFence


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    
    NSLog(@"Entered Region");
    
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        UILocalNotification *reminder = [[UILocalNotification alloc] init];
        [reminder setFireDate:[NSDate date]];
        [reminder setTimeZone:[NSTimeZone localTimeZone]];
        [reminder setHasAction:YES];
        [reminder setAlertAction:@"Show"];
        [reminder setSoundName:@"bell.mp3"];
        [reminder setAlertBody:@"Boundary crossed!"];
        [[UIApplication sharedApplication] scheduleLocalNotification:reminder];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Show an alert or otherwise notify the user
        });
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    
}
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    
}


@end
