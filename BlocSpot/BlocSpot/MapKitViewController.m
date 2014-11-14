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

@class MapAnnotationViewController;


@interface MapKitViewController () <MapKitViewControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, WYPopoverControllerDelegate, MapAnnotationViewControllerDelegate>


    {
        WYPopoverController* popoverController;
    }




@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *initialLocation;
@property (nonatomic, strong) WYPopoverController *annotationPopoverController;
@property (nonatomic, strong) MyAnnotation *annotation;
@property (nonatomic, strong) NSString *annotationNotes;


@end

@implementation MapKitViewController {
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    
    CLLocationCoordinate2D annotationCoordinate = CLLocationCoordinate2DMake(39.432679, -84.217259);
    /*MyAnnotation *annotation = [[MyAnnotation alloc]init];
     annotation.coordinate = annotationCoordinate;
     [self.mapView addAnnotation:annotation];
     annotation.title = @"Lake Eola";
     annotation.subtitle = @"Cool swans";*/
    
    NSArray *locations = @[
                           @{@"name": @"Overly Hautz",
                             @"lat": @39.432679,
                             @"lng": @-84.217259},
                           @{@"name": @"Golden Lamb",
                             @"lat": @39.452679,
                             @"lng": @-84.217259},
                           @{@"name": @"Train Station",
                             @"lat": @39.492679,
                             @"lng": @-84.217259}
                           
                           ];
    
    
    for(NSDictionary *location in locations) {
        CLLocationCoordinate2D annotationCoordinate =
        CLLocationCoordinate2DMake([location [@"lat"] doubleValue], [location [@"lng"]doubleValue]);
        MyAnnotation *annotation = [[MyAnnotation alloc]init];
        annotation.coordinate = annotationCoordinate;
        annotation.title = location[@"name"];
        annotation.subtitle = nil;
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
    
    ycvc.data = self.annotation.title;

    
    poc.delegate = self;
    self.annotationPopoverController = poc;
    

    poc.popoverContentSize = CGSizeMake(300, 200);
    
    
    [poc presentPopoverFromRect:view.bounds inView:view permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
    
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
    NSLog(@"Print Annotation Notes %@", value);
    
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


@end
