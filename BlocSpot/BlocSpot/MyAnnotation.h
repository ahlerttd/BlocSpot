//
//  MyAnnotation.h
//  BlocSpot
//
//  Created by Trevor Ahlert on 11/7/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject <MKAnnotation>

@property CLLocationCoordinate2D coordinate;
@property (weak, nonatomic) NSString *title;
@property (weak, nonatomic) NSString *subtitle;

-(id)initWithTitle:(NSString * )newTitle subTitle: (NSString *)newSubTitle location:(CLLocationCoordinate2D)location;
- (MKAnnotationView *)annotationView;


@end
