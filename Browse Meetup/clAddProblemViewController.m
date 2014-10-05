//
//  clMapViewController.m
//  MapBox
//
//  Created by Denis on 19.03.14.
//  Copyright (c) 2014 cityleeks. All rights reserved.
//

#import "clAddProblemViewController.h"
#import "CoreLocation/CoreLocation.h"
#import "AppDelegate.h"
#import "CustomIOS7AlertView.h"

#define API_SERVER @"https://api.cityleeks.org"
#define API_DEFAULT_KEY @"q02kwfs5df5b6gqxsk5ntp7nnah461aski1xu772"

@interface clAddProblemViewController ()
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) CLLocationManager *locationManager;
@property (nonatomic,strong)NSArray* fetchedRecordsArray;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end

UIImagePickerController *mediaPicker;
NSInteger photoCounter;
UIAlertView *alertLoader;
NSString *API_KEY;
UIAlertView *loading;

@implementation NSString (URLEncoding)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    CFStringRef stringRef = CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)self,  NULL,  (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",  CFStringConvertNSStringEncodingToEncoding(encoding));
    NSString *returnString = (__bridge NSString*)stringRef;
    CFRelease(stringRef);
    return returnString;
}

@end

@implementation clAddProblemViewController


CLLocationCoordinate2D LocationProblem;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self showAlert:@"Отсутствует доступ к камере. Вы не сможете добавить фотографию к проблеме."];
            
        });
        
    }
    
    API_KEY = [[NSUserDefaults standardUserDefaults] stringForKey:@"API_KEY"];
    
    UIScrollView *_scroll = (UIScrollView *) [self.view viewWithTag:1];
    
    UIImage *image = [[UIImage imageNamed:@"list-item-detail-hide-keyboard"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIColor *color = [UIColor colorWithRed:0.259 green:0.259 blue:0.259 alpha:1.000];
    
    NSInteger padding = 10;
    
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,310,100)];
    lblTitle.numberOfLines = 1;
    lblTitle.font = [UIFont fontWithName:@"Verdana" size:13];
    lblTitle.textColor = color;
    lblTitle.text = @"Заголовок проблемы:";
    [lblTitle sizeToFit];
    [_scroll addSubview:lblTitle];
    
    padding += lblTitle.bounds.size.height;
    padding += 5;
    
    UITextView *textTitle = [[UITextView alloc]initWithFrame:CGRectMake(5,padding,310,100)];
    textTitle.font = [UIFont fontWithName:@"Verdana" size:13];
    textTitle.tag = 30;
    textTitle.delegate = self;
    [[textTitle layer] setBorderWidth:.0];
    
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:textTitle action:@selector(resignFirstResponder)];
    [barButton setImage:image];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    textTitle.inputAccessoryView = toolbar;
    
    
    [_scroll addSubview:textTitle];
    
    padding += textTitle.bounds.size.height;
    
    padding += 5;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10,padding, 310, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [_scroll addSubview:lineView];
    
    padding += 20;
    
    
    UILabel *lblDesc = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,310,100)];
    lblDesc.numberOfLines = 1;
    lblDesc.font = [UIFont fontWithName:@"Verdana" size:13];
    lblDesc.textColor = color;
    lblDesc.text = @"Описание проблемы:";
    [lblDesc sizeToFit];
    [_scroll addSubview:lblDesc];
    
    padding += lblDesc.bounds.size.height;
    padding += 5;
    
    UITextView *textDesc = [[UITextView alloc]initWithFrame:CGRectMake(5,padding,310,100)];
    textDesc.font = [UIFont fontWithName:@"Verdana" size:13];
    textDesc.textColor = color;
    textDesc.tag = 31;
    textDesc.delegate = self;
    [[textDesc layer] setBorderWidth:.0];
    
    barButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:textDesc action:@selector(resignFirstResponder)];
    [barButton setImage:image];
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    textDesc.inputAccessoryView = toolbar;
    
    
    [_scroll addSubview:textDesc];
    
    padding += textDesc.bounds.size.height;
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(5,padding, 310, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [_scroll addSubview:lineView];
    
    padding += 20;
    
    UILabel *lblLocation = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,310,100)];
    lblLocation.numberOfLines = 1;
    lblLocation.font = [UIFont fontWithName:@"Verdana" size:13];
    lblLocation.textColor = color;
    lblLocation.text = @"Месторасположение проблемы:";
    [lblLocation sizeToFit];
    [_scroll addSubview:lblLocation];
    
    padding += lblLocation.bounds.size.height;
    padding += 5;
    
    UITextView *textLocation = [[UITextView alloc]initWithFrame:CGRectMake(5,padding,310,100)];
    textLocation.font = [UIFont fontWithName:@"Verdana" size:13];
    textLocation.textColor = color;
    textLocation.tag = 32;
     textLocation.delegate = self;
    [[textLocation layer] setBorderWidth:.0];
    
    barButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:textLocation action:@selector(resignFirstResponder)];
    [barButton setImage:image];
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    textLocation.inputAccessoryView = toolbar;
    
    
    [_scroll addSubview:textLocation];
    
    padding += textLocation.bounds.size.height;
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(5,padding, 310, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [_scroll addSubview:lineView];
    
    
    padding += 20;
    
    UILabel *lblSolution = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,310,100)];
    lblSolution.numberOfLines = 1;
    lblSolution.font = [UIFont fontWithName:@"Verdana" size:13];
    lblSolution.textColor = color;
    lblSolution.text = @"Возможное решение проблемы:";
    [lblSolution sizeToFit];
    [_scroll addSubview:lblSolution];
    
    padding += lblSolution.bounds.size.height;
    padding += 5;
    
    UITextView *textSolution = [[UITextView alloc]initWithFrame:CGRectMake(5,padding,310,100)];
    textSolution.font = [UIFont fontWithName:@"Verdana" size:13];
    textSolution.textColor = color;
    textSolution.tag = 33;
     textSolution.delegate = self;
    [[textSolution layer] setBorderWidth:.0];
    
    barButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:textSolution action:@selector(resignFirstResponder)];
    [barButton setImage:image];
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    textSolution.inputAccessoryView = toolbar;
    
    
    [_scroll addSubview:textSolution];
    
    padding += textSolution.bounds.size.height;
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(5,padding, 310, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [_scroll addSubview:lineView];
    
    padding += 20;
    
    
    UILabel *lblCategory = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,310,100)];
    lblCategory.numberOfLines = 1;
    lblCategory.font = [UIFont fontWithName:@"Verdana" size:13];
    lblCategory.text = @"Выберите одну или несколько категорий:";
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
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        button.frame = CGRectMake(15,padding,310,100);
        button.titleLabel.font = [UIFont fontWithName:@"Verdana" size:13];
        [button sizeToFit];
        [_scroll addSubview:button];
        padding += button.bounds.size.height;
        padding += 5;
        
    }
    
    padding += 15;
    lineView = [[UIView alloc] initWithFrame:CGRectMake(5,padding, 310, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [_scroll addSubview:lineView];
    padding += 20;
    
    
    UILabel *lblPhoto = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,310,100)];
    lblPhoto.numberOfLines = 1;
    lblPhoto.font = [UIFont fontWithName:@"Verdana" size:13];
    lblPhoto.text = @"Добавьте одну или несколько фотографий:";
    [lblPhoto sizeToFit];
    [_scroll addSubview:lblPhoto];
    
    padding += lblPhoto.bounds.size.height;
    padding += 10;
    
    UIScrollView *_scrollRecipients = [[UIScrollView alloc]initWithFrame:CGRectMake(10,padding,300,80)];

    _scrollRecipients.tag = 999;
    
    photoCounter = 1;
    
    UIButton *buttonAddPhoto = [[UIButton alloc]initWithFrame:CGRectMake(0,5,60,60)];
    UIImage *buttonImageNormal = [UIImage imageNamed:@"add_photo"];
    [buttonAddPhoto setImage:buttonImageNormal forState:UIControlStateNormal];
    [buttonAddPhoto addTarget:self action:@selector(handleUploadPhotoTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    [_scrollRecipients addSubview:buttonAddPhoto];
    
    _scrollRecipients.contentSize = CGSizeMake(210, 80);
    _scrollRecipients.showsHorizontalScrollIndicator = false;
    _scrollRecipients.showsVerticalScrollIndicator = false;
    
    [_scroll addSubview:_scrollRecipients];
    
    padding += _scrollRecipients.bounds.size.height;
    padding += 20;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Добавить проблему" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addProblemMethod:) forControlEvents:UIControlEventTouchUpInside];
    
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


- (IBAction)handleUploadPhotoTouch:(id)sender {
    mediaPicker = [[UIImagePickerController alloc] init];
    [mediaPicker setDelegate:self];
    mediaPicker.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Отмена"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Снять фото", @"Выбрать фото", nil];
        [actionSheet showInView:self.view];
    } else {
        mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:mediaPicker animated:true completion:nil];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:mediaPicker animated:true completion:nil];
    } else if (buttonIndex == 1) {
        mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:mediaPicker animated:true completion:nil];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    UIScrollView *_scroll = (UIScrollView *) [self.view viewWithTag:999];
    
    NSInteger temp = (int)photoCounter;
    
    NSInteger padding = temp * 60;
    padding += temp * 5;
    
    UIImageView *_im = [[UIImageView alloc] initWithFrame:CGRectMake(padding, 5, 60, 60)];
    
    _im.image = chosenImage;
    _im.tag = 900 + photoCounter;
    _im.contentMode = UIViewContentModeScaleAspectFit;
    
    [_scroll addSubview:_im];
    
    photoCounter ++;
    
    padding = temp * 60;
    padding += temp * 5;
    
    _scroll.contentSize = CGSizeMake(padding+70, 80);

    
    [self.view setNeedsDisplay];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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


-(void)addProblemMethod:(UIButton*)sender
{
    UITextView *textTitle = (UITextView *) [self.view viewWithTag:30];
    NSString *textTitleValue = textTitle.text;
    
    UITextView *textDescription = (UITextView *) [self.view viewWithTag:31];
    NSString *textDescriptionValue = textDescription.text;
    
    UITextView *textLocation = (UITextView *) [self.view viewWithTag:32];
    NSString *textLocationValue = textLocation.text;
    
    
    UITextView *textSolution = (UITextView *) [self.view viewWithTag:33];
    NSString *textSolutionValue = textSolution.text;
    
    
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
    
    if ([textTitleValue isEqualToString:@""] || [textDescriptionValue isEqualToString:@""] || [textLocationValue isEqualToString:@""] || [textSolutionValue  isEqualToString:@""] || [category_string isEqualToString:@""]) {
        
        [loading dismissWithClickedButtonIndex:0 animated:YES];
        
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
            
            
        } else [self addProblem];
        
    }
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if (alertView.tag == 380 && buttonIndex==1) [self addProblem];
    [alertView close];
}

-(void)addProblem
{
    
    loading = [[UIAlertView alloc] initWithTitle:@"" message:@"Проблема добавляется..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
    UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
    
    progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    
    [loading addSubview:progress];
    
    [progress startAnimating];
    
    NSLog(@"Добавить проблему");
    
    UITextView *textTitle = (UITextView *) [self.view viewWithTag:30];
    NSString *textTitleValue = textTitle.text;
    
    NSLog(@"%@", textTitleValue);
    
    
    UITextView *textDescription = (UITextView *) [self.view viewWithTag:31];
    NSString *textDescriptionValue = textDescription.text;
    
    
    NSLog(@"%@", textDescriptionValue);
    
    UITextView *textLocation = (UITextView *) [self.view viewWithTag:32];
    NSString *textLocationValue = textLocation.text;
    
    NSLog(@"%@", textLocationValue);
    
    
    UITextView *textSolution = (UITextView *) [self.view viewWithTag:33];
    NSString *textSolutionValue = textSolution.text;
    
    
    NSLog(@"%@", textSolutionValue);
    
    textTitleValue = [textTitleValue urlEncodeUsingEncoding:NSUTF8StringEncoding];
    textDescriptionValue = [textDescriptionValue urlEncodeUsingEncoding:NSUTF8StringEncoding];
    textLocationValue = [textLocationValue urlEncodeUsingEncoding:NSUTF8StringEncoding];
    textSolutionValue = [textSolutionValue urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    NSString *lat = [[NSString stringWithFormat:@"%f", LocationProblem.latitude] urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSString *lng = [[NSString stringWithFormat:@"%f", LocationProblem.longitude] urlEncodeUsingEncoding:NSUTF8StringEncoding];

    
    
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    //2
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Category" inManagedObjectContext:context]];
    NSArray *categories = [context executeFetchRequest:fetch error:nil];
    
    NSString *category_string;
    NSInteger tagCounter = 100;

    
    for (id category in categories) {
        
        UIButton *tmpButton = (UIButton *)[self.view viewWithTag:tagCounter];
        tagCounter++;
        if (tmpButton.imageView.image == [UIImage imageNamed:@"checkbox_checked"]) {
            
            if (category_string == NULL) category_string = [NSString stringWithFormat:@"&category[]=%@", [[NSString stringWithFormat:@"%@", [category valueForKey:@"id_"]] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
            else category_string = [NSString stringWithFormat:@"%@&category[]=%@", category_string, [[NSString stringWithFormat:@"%@", [category valueForKey:@"id_"]] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
            
        }
    }

    [loading show];
    
    NSString *serverAddress =  [NSString stringWithFormat:@"%@/%@/item/add?title=%@&description=%@&location=%@&solution=%@&lat=%@&lng=%@%@",API_SERVER, API_KEY, textTitleValue, textDescriptionValue, textLocationValue, textSolutionValue, lat, lng, category_string];
    
    NSURL *url = [NSURL URLWithString:serverAddress];

    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            
            NSLog(@"Error %@; %@", error, [error localizedDescription]);
            
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self showAlert:@"При добавлении проблемы произошла ошибка, попробуйте добавить проблему позже."];
                
            });

            
            
        } else {

            
            NSLog(@"output data %@",response);
            
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSDictionary *results = [parsedObject valueForKey:@"error_data"];
            
            if (results != (NSDictionary*) [NSNull null]) {
                
                
                NSLog(@"Error. Count error %lu", (unsigned long)results.count);

                
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self showAlert:@"При добавлении проблемы произошла ошибка, попробуйте добавить проблему позже."];
                    
                });

                
            } else {
                
                
                NSArray *result = [parsedObject valueForKey:@"data"];
                
                
                for (int i = 1; i <= photoCounter; i++) {
                    
                    
                    UIImageView *mainImageView = (UIImageView *) [self.view viewWithTag:900+i];
                    
                    if (mainImageView != NULL) {
                        
                        NSData *imgData = UIImageJPEGRepresentation(mainImageView.image, 90);
                        
                        
                        if (imgData != NULL) {
                            
                            
                            NSString *item_id = [NSString stringWithFormat:@"%@", result];
                            
                            item_id = [item_id urlEncodeUsingEncoding:NSUTF8StringEncoding];
                            
                            NSString *urlString =  [NSString stringWithFormat:@"%@/photo/upload", API_SERVER];
                            NSURL *url = [[NSURL alloc]initWithString:urlString];
                            
                            
                            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                                   cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:15.0];
                            
                            [request setHTTPMethod:@"POST"];
                            
                            NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
                            NSString *boundary = @"0xKhTmLbOuNdArY";
                            NSString *endBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
                            
                            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, boundary];
                            [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
                            
                            
                            NSMutableData *body = [NSMutableData data];
                            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                            
                            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"item_id"] dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData:[item_id dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData:[endBoundary dataUsingEncoding:NSUTF8StringEncoding]];
                            
                            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"security"] dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData:[API_KEY dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData:[endBoundary dataUsingEncoding:NSUTF8StringEncoding]];
                            
                            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", @"iphonefile.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData:[NSData dataWithData:imgData]];
                            [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                            
                            [request setHTTPBody:body];
                            
                            NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                            
                            NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                            
                            NSLog(@"%@",returnString);

                            
                        }
                    }
                    

                    
                }
                
                
                NSLog(@"Проблема добавлена. ID:%@", result);
                
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self showAlert:@"Проблема успешно добавлена."];
                    
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
    
    tagCounter = 100;
    
    for (id category in categories) {
        
        UIButton *tmpButton = (UIButton *)[self.view viewWithTag:tagCounter];
        tagCounter++;
        if (tmpButton.imageView.image == [UIImage imageNamed:@"checkbox_checked"]) {
            
            UIImage *buttonImageNormal = [UIImage imageNamed:@"checkbox"];
            [tmpButton setImage:buttonImageNormal forState:UIControlStateNormal];
            [tmpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
        }
    }
    
    UITextView *textTitle = (UITextView *) [self.view viewWithTag:30];
    textTitle.text = @"";
    
    UITextView *textDescription = (UITextView *) [self.view viewWithTag:31];
    textDescription.text = @"";
    
    UITextView *textLocation = (UITextView *) [self.view viewWithTag:32];
    textLocation.text = @"";
    
    UITextView *textSolution = (UITextView *) [self.view viewWithTag:33];
    textSolution.text = @"";
    
    
    for (int i = 1; i <= photoCounter; i++) {
        
        UIImageView *mainImageView = (UIImageView *) [self.view viewWithTag:900+i];
        [mainImageView removeFromSuperview];
        mainImageView = nil;
        
    }
    
    photoCounter = 1;
    UIScrollView *_scroll = (UIScrollView *) [self.view viewWithTag:999];
    _scroll.contentSize = CGSizeMake(70, 80);
    
    
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

-(void)setLocation:(CLLocationCoordinate2D)location
{
    
    LocationProblem = location;
    
    NSLog(@"Got Location %f , %f", location.latitude, location.longitude);
}

@end
