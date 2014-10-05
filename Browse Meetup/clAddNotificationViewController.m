//
//  clMapViewController.m
//  MapBox
//
//  Created by Denis on 19.03.14.
//  Copyright (c) 2014 cityleeks. All rights reserved.
//

#import "clAddNotificationViewController.h"
#import "CoreLocation/CoreLocation.h"
#import "CoreLocation/CoreLocation.h"
#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import "CustomIOS7AlertView.h"

#define API_SERVER @"https://api.cityleeks.org"
#define API_DEFAULT_KEY @"q02kwfs5df5b6gqxsk5ntp7nnah461aski1xu772"

@interface clAddNotificationViewController ()
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) CLLocationManager *locationManager;
@property (nonatomic,strong)NSArray* fetchedRecordsArray;
@end


@implementation NSString (URLEncoding)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    CFStringRef stringRef = CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)self,  NULL,  (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",  CFStringConvertNSStringEncodingToEncoding(encoding));
    NSString *returnString = (__bridge NSString*)stringRef;
    CFRelease(stringRef);
    return returnString;
}

@end

@implementation clAddNotificationViewController


@synthesize activeTime;



NSString *valueActiveTime;
NSMutableData *receivedData_;
UILabel *lblActiveTime;
CLLocationCoordinate2D LocationProblem;
NSString *API_KEY;
UIAlertView *loading;


- (void)viewDidLoad
{
    [super viewDidLoad];

    API_KEY = [[NSUserDefaults standardUserDefaults] stringForKey:@"API_KEY"];
    
    UIScrollView *_scroll = (UIScrollView *) [self.view viewWithTag:1];
    
    
    NSInteger padding = 10;
    
    UIImage *image = [[UIImage imageNamed:@"list-item-detail-hide-keyboard"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIColor *color = [UIColor colorWithRed:0.259 green:0.259 blue:0.259 alpha:1.000];
    
    UILabel *lblDesc = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,310,100)];
    lblDesc.numberOfLines = 1;
    lblDesc.font = [UIFont fontWithName:@"Verdana" size:13];
    lblDesc.text = @"Описание оповещения:";
    lblDesc.textColor = color;
    [lblDesc sizeToFit];
    [_scroll addSubview:lblDesc];
    
    padding += lblDesc.bounds.size.height;
    padding += 5;
    
    UITextView *textDesc = [[UITextView alloc]initWithFrame:CGRectMake(5,padding,310,100)];
    textDesc.font = [UIFont fontWithName:@"Verdana" size:13];
    textDesc.tag = 30;
    textDesc.delegate = self;
    [[textDesc layer] setBorderWidth:.0];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:textDesc action:@selector(resignFirstResponder)];
    [barButton setImage:image];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    textDesc.inputAccessoryView = toolbar;
    
    [_scroll addSubview:textDesc];
    
    
    padding += textDesc.bounds.size.height;
    
    padding += 5;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10,padding, 310, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [_scroll addSubview:lineView];
    
    padding += 20;
    
    UILabel *lblLocation = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,310,100)];
    lblLocation.numberOfLines = 1;
    lblLocation.font = [UIFont fontWithName:@"Verdana" size:13];
    lblLocation.text = @"Месторасположение оповещения:";
    lblLocation.textColor = color;
    [lblLocation sizeToFit];
    [_scroll addSubview:lblLocation];
    
    padding += lblLocation.bounds.size.height;
    padding += 5;
    
    UITextView *textLocation = [[UITextView alloc]initWithFrame:CGRectMake(5,padding,310,100)];
    textLocation.font = [UIFont fontWithName:@"Verdana" size:13];
    textLocation.tag = 31;
    textLocation.delegate = self;
    [[textLocation layer] setBorderWidth:.0];
    
    barButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:textLocation action:@selector(resignFirstResponder)];
    [barButton setImage:image];
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    textLocation.inputAccessoryView = toolbar;
    
    [_scroll addSubview:textLocation];
    
    padding += textLocation.bounds.size.height;
    
    padding += 5;
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(5,padding, 310, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [_scroll addSubview:lineView];
    
    padding += 20;
    
    lblActiveTime = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,310,100)];
    lblActiveTime.numberOfLines = 1;
    lblActiveTime.font = [UIFont fontWithName:@"Verdana" size:13];
    lblActiveTime.text = @"Время действия оповещения: 3 часа";
    lblActiveTime.textColor = color;
    [lblActiveTime sizeToFit];
    [_scroll addSubview:lblActiveTime];
    
    padding += lblActiveTime.bounds.size.height;
    padding += -20;
    
    activeTime = [[UISlider alloc]initWithFrame:CGRectMake(5,padding,310,100)];
    activeTime.minimumValue = 1;
    activeTime.maximumValue = 5;
    activeTime.value = 2;
    activeTime.tag = 32;
    
    [activeTime setContinuous:false];
    [activeTime addTarget:self
                          action:@selector(getSliderValue:)
                forControlEvents:UIControlEventValueChanged];
    
    [_scroll addSubview:activeTime];
    
    
    valueActiveTime = @"10800";
    
    padding += activeTime.bounds.size.height;
    
    UILabel *lblCategory = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,310,100)];
    lblCategory.numberOfLines = 1;
    lblCategory.font = [UIFont fontWithName:@"Verdana" size:13];
    lblCategory.text = @"Выберите одну или несколько категорий:";
    lblCategory.textColor = color;
    [lblCategory sizeToFit];
    [_scroll addSubview:lblCategory];
    
    padding += lblCategory.bounds.size.height;
    padding += 10;
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    //2
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Category" inManagedObjectContext:context]];
    NSArray *categories = [context executeFetchRequest:fetch error:nil];
    
    NSInteger tagCounter = 100;
    
    for (id category in categories) {
    
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];

        [button setTitle:[category valueForKey:@"name"] forState:UIControlStateNormal];
        
        UIImage *buttonImageNormal = [UIImage imageNamed:@"checkbox"];
        [button setImage:buttonImageNormal forState:UIControlStateNormal];
        [button addTarget:self action:@selector(bMethod:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = tagCounter;
        tagCounter++;
        [button setTitleColor:color forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        button.frame = CGRectMake(15,padding,310,100);
        button.titleLabel.font = [UIFont fontWithName:@"Verdana" size:13];
        [button sizeToFit];
        [_scroll addSubview:button];
        padding += button.bounds.size.height;
        padding += 5;
        
    }
    
    padding += 20;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Добавить оповещение" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addNotificationMethod:) forControlEvents:UIControlEventTouchUpInside];
    
    button.frame = CGRectMake(80,padding,310,100);
    
    [button sizeToFit];
    [_scroll addSubview:button];
    
    padding += button.bounds.size.height;
    padding += 90;
    
    [_scroll setContentSize:CGSizeMake(_scroll.frame.size.width, padding)];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self.view setNeedsDisplay];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textField {

    UIScrollView *_scroll = (UIScrollView *) [self.view viewWithTag:1];
    _scroll.contentOffset = CGPointMake(0, textField.frame.origin.y - textField.bounds.size.height);
    
}

-(void)addNotificationMethod:(UIButton*)sender
{
    UITextView *textDesc = (UITextView *) [self.view viewWithTag:30];
    NSString *textDescValue = textDesc.text;
    
    UITextView *textLocation = (UITextView *) [self.view viewWithTag:31];
    NSString *textLocationValue = textLocation.text;

    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    //2
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Category" inManagedObjectContext:context]];
    NSArray *categories = [context executeFetchRequest:fetch error:nil];
    
    NSString *category_string = @"";
    
    NSInteger tagCounter = 100;
    
    for (id category in categories) {
        
        UIButton *tmpButton = (UIButton *)[self.view viewWithTag:tagCounter];
        tagCounter++;
        if (tmpButton.imageView.image == [UIImage imageNamed:@"checkbox_checked"]) {
            
            if (category_string == NULL) category_string = [NSString stringWithFormat:@"&category[]=%@", [[NSString stringWithFormat:@"%@", [category valueForKey:@"id_"]] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
            else category_string = [NSString stringWithFormat:@"%@&category[]=%@", category_string, [[NSString stringWithFormat:@"%@", [category valueForKey:@"id_"]] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
            
        }
    }
    
    if ([textLocationValue isEqualToString:@""] || [textDescValue isEqualToString:@""] || [category_string isEqualToString:@""]) {
        
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Вы неполностью заполнили форму или не указали хотя бы одну категорию"
                                                       delegate:self cancelButtonTitle:@"ОК"
                                              otherButtonTitles:nil];
        [alert show];
        
    } else {
    
        if ([API_KEY isEqualToString:API_DEFAULT_KEY]) {
        
            CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
            [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Не принимаю", @"Принимаю", nil]];
            
            UIView *customView = [[CustomIOS7AlertView alloc]initWithFrame: CGRectMake(5.0, 5.0, alertView.bounds.size.width-10, alertView.bounds.size.height-180)];
            
            UIWebView *webView = [[UIWebView alloc]initWithFrame: CGRectMake(0.0, 0.0, customView.bounds.size.width-10, customView.bounds.size.height-10)];
            
            [customView addSubview:webView];
            
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"agreement" ofType:@"html"]isDirectory:NO]]];
            
            [alertView setContainerView:customView];
            
            alertView.tag = 380;
            
            [alertView setDelegate:self];
            
            [alertView show];
            
            
        } else [self addNotification];
        
    }
    
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if (alertView.tag == 380 && buttonIndex==1) [self addNotification];
    [alertView close];
}


-(void)addNotification
{
    
    loading = [[UIAlertView alloc] initWithTitle:@"" message:@"Оповещение добавляется..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
    UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
    
    progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    
    [loading addSubview:progress];
    
    [progress startAnimating];

    UITextView *textDesc = (UITextView *) [self.view viewWithTag:30];
    NSString *textDescValue = textDesc.text;

    NSLog(@"%@", textDescValue);
    
    
    UITextView *textLocation = (UITextView *) [self.view viewWithTag:31];
    NSString *textLocationValue = textLocation.text;
    
    
    NSLog(@"%@", textLocationValue);

    textLocationValue = [textLocationValue urlEncodeUsingEncoding:NSUTF8StringEncoding];
    textDescValue = [textDescValue urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    NSString *lat = [[NSString stringWithFormat:@"%f", LocationProblem.latitude] urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSString *lng = [[NSString stringWithFormat:@"%f", LocationProblem.longitude] urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSString *act = [[NSString stringWithFormat:@"%@", valueActiveTime] urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    //2
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Category" inManagedObjectContext:context]];
    NSArray *categories = [context executeFetchRequest:fetch error:nil];
    
    NSString *category_string = @"";
    
    NSInteger tagCounter = 100;
    
    for (id category in categories) {
    
        UIButton *tmpButton = (UIButton *)[self.view viewWithTag:tagCounter];
        tagCounter++;
        if (tmpButton.imageView.image == [UIImage imageNamed:@"checkbox_checked"]) {
            
            if ([category_string isEqualToString:@""]) category_string = [NSString stringWithFormat:@"&category[]=%@", [[NSString stringWithFormat:@"%@", [category valueForKey:@"id_"]] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
            else category_string = [NSString stringWithFormat:@"%@&category[]=%@", category_string, [[NSString stringWithFormat:@"%@", [category valueForKey:@"id_"]] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
            
        }
    }
    
        
    [loading show];

    NSString *serverAddress =  [NSString stringWithFormat:@"%@/%@/notification/add?description=%@&location=%@&lat=%@&lng=%@&ttl=%@%@", API_SERVER, API_KEY, textDescValue,textLocationValue, lat, lng, act, category_string];
    
    NSURL *url = [NSURL URLWithString:serverAddress];
    
    NSLog(@"%@", serverAddress);
    
    
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            
            NSLog(@"Error %@; %@", error, [error localizedDescription]);
            
            
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self showAlert:@"При добавлении  оповещения произошла ошибка, попробуйте добавить оповещение позже."];
                
            });
            
            
        } else {
            
            
            NSLog(@"output data %@",response);
            
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSDictionary *results = [parsedObject valueForKey:@"error_data"];
            
            if (results != (NSDictionary*) [NSNull null]) {
                
                
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self showAlert:@"При добавлении  оповещения произошла ошибка, попробуйте добавить оповещение позже."];
                    
                });

                
            } else {
                
                
                NSArray *result = [parsedObject valueForKey:@"data"];
                NSLog(@"Оповещение добавлено. ID:%@", result);

        
                
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self showAlert:@"Оповещение успешно добавлено."];
                    
                });

                popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self clearForm];
                    
                });
        
            }
            
        }
        
    }];

}

-(void)showAlert:(NSString *)messageText {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:messageText
                                                   delegate:self cancelButtonTitle:@"ОК"
                                          otherButtonTitles:nil];
    [alert show];
    
    [loading dismissWithClickedButtonIndex:0 animated:YES];
    
}

-(void)clearForm {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    //2
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Category" inManagedObjectContext:context]];
    NSArray *categories = [context executeFetchRequest:fetch error:nil];
    
    NSInteger tagCounter = 100;
    
    for (id category in categories) {
        
        UIButton *tmpButton = (UIButton *)[self.view viewWithTag:tagCounter];
        tagCounter++;
        if (tmpButton.imageView.image == [UIImage imageNamed:@"checkbox_checked"]) {
            
            UIImage *buttonImageNormal = [UIImage imageNamed:@"checkbox"];
            [tmpButton setImage:buttonImageNormal forState:UIControlStateNormal];
            [tmpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
        }
    }
    
    UITextView *textDesc = (UITextView *) [self.view viewWithTag:30];
    textDesc.text = @"";
    
    UITextView *textLocation = (UITextView *) [self.view viewWithTag:31];
    textLocation.text = @"";
    
    [loading dismissWithClickedButtonIndex:0 animated:YES];
    
}


-(void)bMethod:(UIButton*)sender
{
    if (sender.imageView.image != [UIImage imageNamed:@"checkbox_checked"]) {
        UIImage *buttonImageNormal = [UIImage imageNamed:@"checkbox_checked"];
        [sender setImage:buttonImageNormal forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    } else {
        UIImage *buttonImageNormal = [UIImage imageNamed:@"checkbox"];
        [sender setImage:buttonImageNormal forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}


- (void) getSliderValue:(UISlider *)paramSender{
    
    //if this is my Step Slider then change the value
    if ([paramSender isEqual:self.activeTime]){
    }
    
    int val = round(paramSender.value);
    
    switch (val) {
        case (int)1:lblActiveTime.text = @"Время действия оповещения: 1 час";break;
        case (int)2:lblActiveTime.text = @"Время действия оповещения: 3 часа";break;
        case (int)3:lblActiveTime.text = @"Время действия оповещения: 12 часов";break;
        case (int)4:lblActiveTime.text = @"Время действия оповещения: 1 сутки";break;
        case (int)5:lblActiveTime.text = @"Время действия оповещения: 3 дня";break;
    }
    
    switch (val) {
        case (int)1:valueActiveTime = @"3600";break;
        case (int)2:valueActiveTime = @"10800";break;
        case (int)3:valueActiveTime = @"43200";break;
        case (int)4:valueActiveTime = @"86400";break;
        case (int)5:valueActiveTime = @"259200";break;
    }
    
    [lblActiveTime sizeToFit];

    NSLog(@"Current value of slider is %d", val);
    
    
}


-(void)setLocation:(CLLocationCoordinate2D)location
{
    
    LocationProblem = location;
    
    NSLog(@"Got Location %f , %f", location.latitude, location.longitude);
}

- (void)viewDidAppear:(BOOL)animated
{
    API_KEY = [[NSUserDefaults standardUserDefaults] stringForKey:@"API_KEY"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
