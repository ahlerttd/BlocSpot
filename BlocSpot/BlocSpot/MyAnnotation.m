//
//  MyAnnotation.m
//  BlocSpot
//
//  Created by Trevor Ahlert on 11/7/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

-(id)initWithTitle:(NSString *)newTitle subTitle:(NSString *)newSubTitle location:(CLLocationCoordinate2D)location{
    self = [super init];
    if(self)
    {
        self.title = newTitle;
        self.subtitle = newSubTitle;
        self.coordinate = location;
    }
    return self;
    
}

- (MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView= [[MKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"MyAnnotation"];
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}


@end


