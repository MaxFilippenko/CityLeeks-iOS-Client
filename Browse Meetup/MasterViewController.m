//
//  MasterViewController.m
//  Read JSON
//
//  Created by TAMIM Ziad on 8/16/13.
//  Copyright (c) 2013 TAMIM Ziad. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailCell.h"

#import "clProblemDetailViewController.h"
#import "Problem.h"
#import "Notification.h"
#import "Category.h"
#import "AppDelegate.h"
#import "AsyncURLConnection.h"

#define API_DEFAULT_KEY @"q02kwfs5df5b6gqxsk5ntp7nnah461aski1xu772"
#define API_SERVER @"https://api.cityleeks.org"

@interface MasterViewController ()  {
}
@property (weak, nonatomic) CLLocationManager *locationManager;
@property (nonatomic,strong)NSArray* fetchedProblemArray;
@end

@implementation MasterViewController

CLLocationManager *locationManager;
UILabel *label;

NSString *API_KEY;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    API_KEY = [[NSUserDefaults standardUserDefaults] stringForKey:@"API_KEY"];
    
    if (!API_KEY)  {
        [[NSUserDefaults standardUserDefaults] setValue:API_DEFAULT_KEY forKey:@"API_KEY"];
        API_KEY = API_DEFAULT_KEY;
    }
    
    
    
    
    self.fetchedProblemArray = 0;
    
    label = [[UILabel alloc] init];
    [label setTextColor:[UIColor lightGrayColor]];
    label.numberOfLines = 2;
    [label sizeToFit];
    label.frame = CGRectMake((self.tableView.bounds.size.width - label.bounds.size.width) / 2.0f,
                             (self.tableView.rowHeight - label.bounds.size.height) / 2.0f,
                             label.bounds.size.width,
                             label.bounds.size.height);
    [self.tableView insertSubview:label atIndex:0];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    [refreshControl addTarget:self action:@selector(loadDataFormServer) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self.refreshControl beginRefreshing];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        [self loadDataFormServer];
        
    });
    
}


- (void)loadDataFormServer
{
    
    @try {
    
        [label setText:@""];
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // 100 m
        [locationManager startUpdatingLocation];
        CLLocation *currentLocation = locationManager.location;
        
        //1
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        //2
        
        
        CGFloat valueDistance = [[NSUserDefaults standardUserDefaults] floatForKey:@"sliderDistance"];
        
        if (!valueDistance)  {
            [[NSUserDefaults standardUserDefaults] setFloat:10000.0 forKey:@"sliderDistance"];
            valueDistance = 10000.0;
        }

        NSString *urlAsString = [NSString stringWithFormat:@"%@/%@/category/get/%f/%f/%d", API_SERVER, API_KEY, currentLocation.coordinate.latitude,currentLocation.coordinate.longitude, (int)valueDistance];
        NSLog(@"%@", urlAsString);
        
        
        
        [AsyncURLConnection request:urlAsString completeBlock:^(NSData *data) {
            
            /* success! */
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                /* process downloaded data in Concurrent Queue */
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSError *localError = nil;
                    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                    
                    NSDictionary *results = [parsedObject valueForKey:@"data"];
                    
                    NSLog(@"Count %lu", (unsigned long)results.count);
                    
                    NSManagedObjectContext *context = appDelegate.managedObjectContext;
                    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
                    [fetch setEntity:[NSEntityDescription entityForName:@"Category" inManagedObjectContext:context]];
                    NSArray *result = [context executeFetchRequest:fetch error:nil];
                    for (id basket in result)
                        [context deleteObject:basket];
                    
                    
                    for (NSDictionary *item in [parsedObject valueForKey:@"data"]) {
                        Category *newProblem = [NSEntityDescription insertNewObjectForEntityForName:@"Category"
                                                                             inManagedObjectContext:context];
                        
                        newProblem.id_ = [[item valueForKeyPath:@"_id"] mutableCopy];
                        newProblem.icon = [[item valueForKeyPath:@"icon"] mutableCopy];
                        newProblem.name = [[item valueForKeyPath:@"name"] mutableCopy];
                        
                        //  3
                        NSError *error;
                        if (![context save:&error]) {
                            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                        }
                        
                        
                    }
 
                    /* update UI on Main Thread */
                    
                });
            });
            
        } errorBlock:^(NSError *error) {
            
            /* error! */
            
        }];
        
        

        
        
        urlAsString = [NSString stringWithFormat:@"%@/%@/notification/get/%f/%f/%d/all/table", API_SERVER, API_KEY, currentLocation.coordinate.latitude,currentLocation.coordinate.longitude, (int)valueDistance];

        NSLog(@"%@", urlAsString);
        
        
        [AsyncURLConnection request:urlAsString completeBlock:^(NSData *data) {
            
            /* success! */
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                /* process downloaded data in Concurrent Queue */
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSError *localError = nil;
                    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                    
                    NSDictionary *results = [parsedObject valueForKey:@"data"];
                    
                    NSLog(@"Count %lu", (unsigned long)results.count);
                    
                    
                    NSManagedObjectContext *context = appDelegate.managedObjectContext;
                    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
                    [fetch setEntity:[NSEntityDescription entityForName:@"Notification" inManagedObjectContext:context]];
                    NSArray *result = [context executeFetchRequest:fetch error:nil];
                    for (id basket in result)
                        [context deleteObject:basket];
                    
                    
                    for (NSDictionary *item in [parsedObject valueForKey:@"data"]) {
                        Notification *newProblem = [NSEntityDescription insertNewObjectForEntityForName:@"Notification"
                                                                                 inManagedObjectContext:context];
                        
                        newProblem.id_ = [[item valueForKeyPath:@"_id"] mutableCopy];
                        newProblem.categories = [[item valueForKeyPath:@"categories"] mutableCopy];
                        newProblem.description_ = [[item valueForKeyPath:@"description"] mutableCopy];
                        newProblem.location = [[item valueForKeyPath:@"location"] mutableCopy];
                        newProblem.support = [[item valueForKeyPath:@"support"] mutableCopy];
                        newProblem.geometry = [[item valueForKeyPath:@"geometry"] mutableCopy];
                        newProblem.categories = [[item valueForKeyPath:@"categories"] mutableCopy];
                        
                        //  3
                        NSError *error;
                        if (![context save:&error]) {
                            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                        }
                        
                        
                    }

                    
                });
            });
            
        } errorBlock:^(NSError *error) {
            
            /* error! */
            
        }];
        

        
        
        
        urlAsString = [NSString stringWithFormat:@"%@/%@/item/get/%f/%f/%d/all/false/table", API_SERVER, API_KEY, currentLocation.coordinate.latitude,currentLocation.coordinate.longitude, (int)valueDistance];

        NSLog(@"%@", urlAsString);
        
        [AsyncURLConnection request:urlAsString completeBlock:^(NSData *data) {
            
            /* success! */
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                /* process downloaded data in Concurrent Queue */
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSError *localError = nil;
                    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                    
                    NSDictionary *results = [parsedObject valueForKey:@"data"];
                    
                    NSLog(@"Count %lu", (unsigned long)results.count);
                    
                    
                    
                    NSManagedObjectContext *context = appDelegate.managedObjectContext;
                    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
                    [fetch setEntity:[NSEntityDescription entityForName:@"Problem" inManagedObjectContext:context]];
                    NSArray *result = [context executeFetchRequest:fetch error:nil];
                    for (id basket in result)
                        [context deleteObject:basket];
                    
                    
                    for (NSDictionary *item in [parsedObject valueForKey:@"data"]) {
                        Problem *newProblem = [NSEntityDescription insertNewObjectForEntityForName:@"Problem"
                                                                            inManagedObjectContext:context];
                        
                        newProblem.id_ = [[item valueForKeyPath:@"_id"] mutableCopy];
                        newProblem.title = [[item valueForKeyPath:@"title"] mutableCopy];
                        newProblem.description_ = [[item valueForKeyPath:@"description"] mutableCopy];
                        newProblem.location = [[item valueForKeyPath:@"location"] mutableCopy];
                        newProblem.solution = [[item valueForKeyPath:@"solution"] mutableCopy];
                        newProblem.town_id = [[item valueForKeyPath:@"town_id"] mutableCopy];
                        newProblem.supports = [[item valueForKeyPath:@"supports"] mutableCopy];
                        newProblem.time_created = [[item valueForKeyPath:@"time_created"] mutableCopy];
                        newProblem.edit_right = [[item valueForKeyPath:@"edit_right"] mutableCopy];
                        newProblem.geometry = [[item valueForKeyPath:@"geometry"] mutableCopy];
                        newProblem.categories = [[item valueForKeyPath:@"categories"] mutableCopy];
                        
                        //  3
                        NSError *error;
                        if (![context save:&error]) {
                            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                        }
                        
                    }
                    
                    
                    NSLog(@"Ok, now start reload");
                    
                    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                    
                    self.fetchedProblemArray = [appDelegate getProblemRecords];
                    
                    CGFloat valueDistance = [[NSUserDefaults standardUserDefaults] floatForKey:@"sliderDistance"];
                    
                    if (!valueDistance)  {
                        [[NSUserDefaults standardUserDefaults] setFloat:10000.0 forKey:@"sliderDistance"];
                        valueDistance = 10000.0;
                    }
                    
                    [self.tableView reloadData];
                    
                    
                    [self.refreshControl endRefreshing];
                    
                    NSLog(@"okok");
                    [label setText:@"Проблемы в указаном\r\nрадиусе не найдены"];
                    label.textAlignment = NSTextAlignmentCenter;
                    [label sizeToFit];
                    label.frame = CGRectMake((self.tableView.bounds.size.width - label.bounds.size.width) / 2.0f,
                                             (self.tableView.rowHeight - label.bounds.size.height) / 2.0f,
                                             label.bounds.size.width,
                                             label.bounds.size.height);
                    
                    [self.view setNeedsDisplay];

                    
                });
            });
            
        } errorBlock:^(NSError *error) {
            
            /* error! */
            
        }];
        
    
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
    @finally {
        
    }
    
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.fetchedProblemArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
    Problem *Problem = [self.fetchedProblemArray objectAtIndex:indexPath.row];
    [cell.nameLabel setText:Problem.title];
    [cell.locationLabel setText:[NSString stringWithFormat:@"%@", Problem.location]];
    [cell.descriptionLabel setText:Problem.description_];
    NSDictionary *sup = Problem.supports;
    [cell.supportsLabel setText:[NSString stringWithFormat:@"%lu чел.", (unsigned long)sup.count]];
    [cell.idLabel setText:Problem.id_];
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *_date = [dateFormat dateFromString:Problem.time_created];
    [dateFormat setDateFormat:@"dd.MM.yyyy"];
    NSString *stringFromDate = [dateFormat stringFromDate:_date];
    [cell.dateLabel setText:stringFromDate];
        
    return cell;

}

- (void)viewDidAppear:(BOOL)animated
{
    API_KEY = [[NSUserDefaults standardUserDefaults] stringForKey:@"API_KEY"];
    NSLog(@"%@", API_KEY);
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailCell *cell = (DetailCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [segue.destinationViewController setItemID:cell.idLabel.text];
}

@end
