//
//  MapKitViewController.h
//  BlocSpot
//
//  Created by Trevor Ahlert on 11/7/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MapKitViewController;
@protocol MapKitViewControllerDelegate <NSObject>

- (void)mapKitViewControllerDidCancel:(MapKitViewController *)controller;

@end

@interface MapKitViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property BOOL userLocationUpdated;
@property (nonatomic, weak) id <MapKitViewControllerDelegate> delegate;


- (IBAction)listView:(id)sender;

@end
