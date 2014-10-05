//
//  clMapViewController.m
//  MapBox
//
//  Created by Denis on 19.03.14.
//  Copyright (c) 2014 cityleeks. All rights reserved.
//

#import "clMapViewController.h"
#import "MapBox/Mapbox.h"
#import <CoreLocation/CoreLocation.h>
#import "clProblemDetailViewController.h"
#import "Problem.h"
#import "AppDelegate.h"
#import "MapBox/RMOpenStreetMapSource.h"
#import "Notification.h"
#import "Category.h"
#import "AsyncURLConnection.h"

#define kTintColor [UIColor colorWithRed:0.120 green:0.550 blue:0.670 alpha:1.000]
#define API_DEFAULT_KEY @"q02kwfs5df5b6gqxsk5ntp7nnah461aski1xu772"

@interface clMapViewController ()
@property (strong) IBOutlet RMMapView *mapView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) CLLocationManager *locationManager;
@property (nonatomic,strong)NSArray* fetchedProblemArray;
@property (nonatomic,strong)NSArray* fetchedNotificationArray;
@property (nonatomic,strong)NSArray* fetchedCategoryArray;
@end

@implementation clMapViewController

CLLocationManager *locationManager;

- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude];
}

CLLocation *oldLocation;

NSString *idProblem;

NSString *API_KEY;


- (void)viewDidLoad
{
    [super viewDidLoad];

    @try {

        API_KEY = [[NSUserDefaults standardUserDefaults] stringForKey:@"API_KEY"];
        
        if (!API_KEY)  {
            [[NSUserDefaults standardUserDefaults] setValue:API_DEFAULT_KEY forKey:@"API_KEY"];
            API_KEY = API_DEFAULT_KEY;
        }
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];

        RMOpenStreetMapSource *osmMapSource = [[RMOpenStreetMapSource alloc] init];
        
        self.mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:osmMapSource];
        
        self.mapView.delegate = self;
        
        self.navigationItem.leftBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
        
        CLLocationCoordinate2D centerPoint;
        
        oldLocation = locationManager.location;
        CLLocation *currentLocation = locationManager.location;
        
        centerPoint.latitude = currentLocation.coordinate.latitude;
        centerPoint.longitude = currentLocation.coordinate.longitude;
        
        [self.mapView setCenterCoordinate:centerPoint];
        
        [self.view addSubview:self.mapView];
        
        self.mapView.zoom = 13;
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }

    
}


- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction;
{
    CGFloat valueDistance = [[NSUserDefaults standardUserDefaults] floatForKey:@"sliderDistance"];
    
    if (!valueDistance)  {
        [[NSUserDefaults standardUserDefaults] setFloat:10000.0 forKey:@"sliderDistance"];
        valueDistance = 10000.0;
    }
    
    CLLocation *userLocation =
    [[CLLocation alloc] initWithLatitude:
     self.mapView.centerCoordinate.latitude
                               longitude:
     self.mapView.centerCoordinate.longitude];
    
    float dist = [userLocation distanceFromLocation:oldLocation];
    
    if (valueDistance/2 < dist) NSLog(@"Дистанция: %f", dist);
    
}



- (IBAction)follow:(id)sender
{
    
    CLLocationCoordinate2D centerPoint;
    [locationManager startUpdatingLocation];
    
    CLLocation *currentLocation = locationManager.location;
    
    centerPoint.latitude = currentLocation.coordinate.latitude;
    centerPoint.longitude = currentLocation.coordinate.longitude;
    
    [self.mapView setCenterCoordinate:centerPoint];
    
}


- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    @try {
    
        if (annotation.isUserLocationAnnotation)
            return nil;
        
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:annotation.badgeIcon anchorPoint:CGPointMake(0.5f, 1.0f)];
        
        marker.canShowCallout = YES;
        
        if (annotation.userInfo != NULL) marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure ];

        
        return marker;
    
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }

    
}

- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    @try {
        
        idProblem = annotation.userInfo;
        [self performSegueWithIdentifier:@"goToProblemDetail" sender:self];
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }

}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    @try {
        
        [segue.destinationViewController setItemID:idProblem];
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    
    @try {
        
        API_KEY = [[NSUserDefaults standardUserDefaults] stringForKey:@"API_KEY"];
        NSLog(@"%@", API_KEY);
    
        [self.mapView removeAllAnnotations];
        
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        
        self.fetchedProblemArray = [appDelegate getProblemRecords];
        self.fetchedNotificationArray = [appDelegate getNotificationRecords];
        self.fetchedCategoryArray = [appDelegate getCategoryRecords];

        
        NSLog(@"Count categories %lu", (unsigned long)[self.fetchedCategoryArray count]);
        NSLog(@"Count problem %lu", (unsigned long)[self.fetchedProblemArray count]);
        NSLog(@"Count notifications %lu", (unsigned long)[self.fetchedNotificationArray count]);
        
        for (id problem in self.fetchedProblemArray) {
            
            NSManagedObject *tr = [problem valueForKey:@"geometry"];
            NSArray *coordinates = [tr valueForKey:@"coordinates"];
            NSString *title = [problem valueForKey:@"title"];
            NSString *description = [problem valueForKey:@"description_"];
            NSString *_id = [problem valueForKey:@"id_"];
            NSArray *cats = [problem valueForKey:@"categories"];
            
            CLLocationCoordinate2D centerPoint;
            centerPoint.latitude = [[coordinates objectAtIndex:1] doubleValue];
            centerPoint.longitude = [[coordinates objectAtIndex:0] doubleValue];
            
            
            RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.mapView
                                                                  coordinate:centerPoint
                                                                    andTitle:title];
            
            annotation.subtitle = description;
            annotation.hasBoundingBox = true;
            
            NSString *category_id = cats[0];
            
            
            for (id category in self.fetchedCategoryArray) {
                
                
                if ([[category valueForKey:@"id_"] isEqualToString:category_id]) {
                    annotation.badgeIcon = [UIImage imageNamed:[NSString stringWithFormat: @"001_%@", [category valueForKey:@"icon"]]];
                }
                
            }
            
            annotation.userInfo = _id;
            
            
            [self.mapView addAnnotation:annotation];
            
        }
        
        
        for (id notification in self.fetchedNotificationArray) {
            
            NSManagedObject *tr = [notification valueForKey:@"geometry"];
            NSArray *coordinates = [tr valueForKey:@"coordinates"];
            NSString *title = [notification valueForKey:@"location"];
            NSString *description = [notification valueForKey:@"description_"];
            NSArray *cats = [notification valueForKey:@"categories"];
            
            
            
            CLLocationCoordinate2D centerPoint;
            centerPoint.latitude = [[coordinates objectAtIndex:1] doubleValue];
            centerPoint.longitude = [[coordinates objectAtIndex:0] doubleValue];
            
            
            RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.mapView
                                                                  coordinate:centerPoint
                                                                    andTitle:title];
            
            annotation.subtitle = description;
            annotation.hasBoundingBox = false;
            
            NSString *category_id = cats[0];
            
            
            for (id category in self.fetchedCategoryArray) {
                
                
                if ([[category valueForKey:@"id_"] isEqualToString:category_id]) {
                    annotation.badgeIcon = [UIImage imageNamed:[NSString stringWithFormat: @"002_%@", [category valueForKey:@"icon"]]];
                }
                
            }

            [self.mapView addAnnotation:annotation];
            
        }
        
        [self.view setNeedsDisplay];
        
        NSLog(@"map updated");
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
