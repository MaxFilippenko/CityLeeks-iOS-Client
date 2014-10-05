//
//  clMapAddProblemViewController.m
//  MapBox
//
//  Created by Denis on 19.03.14.
//  Copyright (c) 2014 cityleeks. All rights reserved.
//

#import "clMapAddProblemViewController.h"
#import "MapBox/Mapbox.h"
#import "MapBox/RMOpenStreetMapSource.h"
#import <CoreLocation/CoreLocation.h>
#import "clAddProblemViewController.h"
#import "MBProgressHUD.h"

@interface clMapAddProblemViewController ()
@property (strong) IBOutlet RMMapView *mapView;
@end

@implementation clMapAddProblemViewController

CLLocationManager *locationManager;

- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude];
}

CLLocationCoordinate2D LocationProblem;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    RMOpenStreetMapSource *osmMapSource = [[RMOpenStreetMapSource alloc] init];

    
    self.mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:osmMapSource];
    
    self.mapView.delegate = self;

    
    CLLocationCoordinate2D centerPoint;
    CLLocation *currentLocation = locationManager.location;
    
    centerPoint.latitude = currentLocation.coordinate.latitude;
    centerPoint.longitude = currentLocation.coordinate.longitude;
    
    [self.mapView setCenterCoordinate:centerPoint];
    
    [self.view addSubview:self.mapView];
    
    [self.view.subviews objectAtIndex:0];
    
    
    RMAnnotation *annotation2 = [[RMAnnotation alloc] initWithMapView:self.mapView
                                                           coordinate:centerPoint
                                                             andTitle:@""];
    annotation2.userInfo = @"big";
    
    LocationProblem = annotation2.coordinate;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView addAnnotation:annotation2];
    
    self.mapView.zoom = 16;
    
    self.navigationItem.leftBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    [hud setDetailsLabelText:@"Укажите позицию проблемы на карте и нажмите Далее"];
    [hud setDetailsLabelFont:[UIFont fontWithName:@"Verdana" size:11]];
    
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.00 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [hud hide:YES];
    });
    
}


- (IBAction)follow:(id)sender
{
    
    CLLocationCoordinate2D centerPoint;
    [locationManager startUpdatingLocation];
    
    CLLocation *currentLocation = locationManager.location;
    
    centerPoint.latitude = currentLocation.coordinate.latitude;
    centerPoint.longitude = currentLocation.coordinate.longitude;
    
    [self.mapView setCenterCoordinate:centerPoint];
    
    
    centerPoint.latitude = currentLocation.coordinate.latitude;
    centerPoint.longitude = currentLocation.coordinate.longitude;
    
    [self.mapView setCenterCoordinate:centerPoint];
    
    [self.mapView removeAllAnnotations];
    
    RMAnnotation *annotation2 = [[RMAnnotation alloc] initWithMapView:self.mapView
                                                           coordinate:centerPoint
                                                             andTitle:@""];
    LocationProblem = annotation2.coordinate;
    annotation2.userInfo = @"big";
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView addAnnotation:annotation2];

    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    [segue.destinationViewController setLocation:LocationProblem];

}


- (void)singleTapOnMap:(RMMapView *)mapView at:(CGPoint)point
{
    NSLog(@"You tapped at %f, %f", [mapView pixelToCoordinate:point].latitude, [mapView pixelToCoordinate:point].longitude);
    
    RMAnnotation *annotation2 = [[RMAnnotation alloc] initWithMapView:mapView
                                                           coordinate:[mapView pixelToCoordinate:point]
                                                             andTitle:@""];
    LocationProblem = annotation2.coordinate;
    
    annotation2.userInfo = @"big";
    
    [mapView removeAnnotations:mapView.annotations];
    
    [mapView addAnnotation:annotation2];
}


- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"001_workshop.png"] anchorPoint:CGPointMake(0.5f, 1.0f)];
    
    marker.canShowCallout = YES;
    
    return marker;
}

- (void)viewDidAppear:(BOOL)animated
{

    CLLocationCoordinate2D centerPoint;
    CLLocation *currentLocation = locationManager.location;
    
    centerPoint.latitude = currentLocation.coordinate.latitude;
    centerPoint.longitude = currentLocation.coordinate.longitude;
    
    [self.mapView setCenterCoordinate:centerPoint];
    
    [self.mapView removeAllAnnotations];
    
    RMAnnotation *annotation2 = [[RMAnnotation alloc] initWithMapView:self.mapView
                                                           coordinate:centerPoint
                                                             andTitle:@""];
    LocationProblem = annotation2.coordinate;
    annotation2.userInfo = @"big";
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView addAnnotation:annotation2];

    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
