//
//  MapViewController.m
//  Badge 4 Check-In
//
//  Created by Sergey Koval on 25/10/2016.
//  Copyright © 2016 Sergey Koval. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "LocationViewController.h"

@interface MapViewController () <MKMapViewDelegate> {
    IBOutlet MKMapView *myMapView;
    NSMutableArray *masterArray;
}

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //masterArray = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Locations" ofType:@"plist"]];
    masterArray = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LocationsClient" ofType:@"plist"]];
    
    myMapView.delegate = self;
    myMapView.mapType = MKMapTypeStandard;
    myMapView.showsUserLocation = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [myMapView removeAnnotations:myMapView.annotations];
    
    for (NSDictionary *location in masterArray) {
        MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
        myAnnotation.coordinate = CLLocationCoordinate2DMake([location[@"latitude"] doubleValue], [location[@"longitude"] doubleValue]);
        myAnnotation.title = location[@"title"];
        NSArray *locations = (NSArray*)location[@"locations"];
        myAnnotation.subtitle = [NSString stringWithFormat:@"%@ (%lu locations)", location[@"subtitle"], (unsigned long)locations.count];
        [myMapView addAnnotation:myAnnotation];
    }
    [self zoomToPins:nil];
}

#pragma mark - Delegate Methods

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        NSLog(@"Clicked callout button");
        [self performSegueWithIdentifier:@"showLocation" sender:annotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKPinAnnotationView *pinView = nil;
    
    static NSString *defaultPinID = @"identifier";
    pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    if ( pinView == nil ) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        pinView.pinTintColor = [UIColor redColor];  //or Green or Purple
        
        pinView.enabled = YES;
        pinView.canShowCallout = YES;
        
        if (![annotation.title isEqualToString:@"My Location"]) {
            pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cool_filled"]];
            [iconView setFrame:CGRectMake(0, 0, 35, 35)];
            pinView.leftCalloutAccessoryView = iconView;
        }
    }
    else {
        pinView.annotation = annotation;
    }
    
    return pinView;
}

#pragma mark - Zoom

- (IBAction)zoomToCurrentLocation:(UIBarButtonItem *)sender {
    float spanX = 0.00725;
    float spanY = 0.00725;
    MKCoordinateRegion region;
    region.center.latitude = myMapView.userLocation.coordinate.latitude;
    region.center.longitude = myMapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [myMapView setRegion:region animated:YES];
}

-(IBAction)zoomToPins:(id)sender {
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in myMapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
        zoomRect = [myMapView mapRectThatFits:zoomRect edgePadding:UIEdgeInsetsMake(20, 20, 20, 20)];
    }
    [myMapView setVisibleMapRect:zoomRect animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showLocation"]) {
        LocationViewController *photoController = segue.destinationViewController;
        
        id <MKAnnotation> annotation = sender;
        for (NSDictionary *location in masterArray) {
            if ([annotation.title isEqualToString:location[@"title"]]) {
                photoController.mainData = location;
                break;
            }
        }
    }
}


@end
