//
//  clMapViewController.m
//  MapBox
//
//  Created by Denis on 19.03.14.
//  Copyright (c) 2014 cityleeks. All rights reserved.
//

#import "clProblemDetailViewController.h"
#import "CoreLocation/CoreLocation.h"

#import <QuartzCore/QuartzCore.h>
#import "Problem.h"
#import "AppDelegate.h"
#import "GGFullScreenImageViewController.h"
#import "AsyncImageView.h"

#define API_SERVER @"https://api.cityleeks.org"
#define FILE_SERVER_TEST @"http://test.cityleeks.org/files/photos"
#define API_DEFAULT_KEY @"q02kwfs5df5b6gqxsk5ntp7nnah461aski1xu772"

@interface clProblemDetailViewController ()
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end


@implementation NSString (URLEncoding)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    CFStringRef stringRef = CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)self,  NULL,  (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",  CFStringConvertNSStringEncodingToEncoding(encoding));
    NSString *returnString = (__bridge NSString*)stringRef;
    CFRelease(stringRef);
    return returnString;
}

@end

@implementation clProblemDetailViewController



UITapGestureRecognizer *tap;
BOOL isFullScreen;
CGRect prevFrame;
UIImagePickerController *mediaPicker;
NSInteger photoCounter;
NSString *itemID;
NSString *API_KEY;
UIAlertView *loading;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    API_KEY = [[NSUserDefaults standardUserDefaults] stringForKey:@"API_KEY"];
    
    photoCounter = 1;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Problem"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =
    [NSPredicate predicateWithFormat:@"(id_ = %@)", itemID];
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    
    if ([objects count] == 0) {
        NSLog(@"No matches");
    } else {
        
        matches = objects[0];


        UIScrollView *_scroll = (UIScrollView *) [self.view viewWithTag:1];

            
        NSInteger padding = 10;
        UIColor *color = [UIColor colorWithRed:0.259 green:0.259 blue:0.259 alpha:1.000];
            
        UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,300,100)];
        lblTitle.numberOfLines = 0;
        lblTitle.font = [UIFont fontWithName:@"Verdana" size:13];
        lblTitle.text = [matches valueForKey:@"title"];
        [lblTitle sizeToFit];
        [_scroll addSubview:lblTitle];
            
        padding += lblTitle.bounds.size.height;
        padding += 2;
            
        UILabel *lblLocation = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,300,100)];
        lblLocation.numberOfLines = 0;
        lblLocation.font = [UIFont fontWithName:@"Verdana" size:11];
        lblLocation.textColor = color;
        lblLocation.text = [matches valueForKey:@"location"];
        [lblLocation sizeToFit];
        [_scroll addSubview:lblLocation];
            
        padding += lblLocation.bounds.size.height;
        padding += 20;
            
        UILabel *lblDescription = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,300,100)];
        lblDescription.numberOfLines = 0;
        lblDescription.font = [UIFont fontWithName:@"Verdana" size:12];
        lblDescription.text = [matches valueForKey:@"description_"];
        [lblDescription sizeToFit];
        [_scroll addSubview:lblDescription];
            
        padding += lblDescription.bounds.size.height;
        padding += 20;
            
        UILabel *lblTitleSolution = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,300,100)];
        lblTitleSolution.numberOfLines = 0;
        lblTitleSolution.font = [UIFont fontWithName:@"Verdana" size:13];
        lblTitleSolution.text = @"Возможное решение проблемы:";
        [lblTitleSolution sizeToFit];
        [_scroll addSubview:lblTitleSolution];
            
        padding += lblTitleSolution.bounds.size.height;
        padding += 2;
            
        UILabel *lblSolution = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,300,100)];
        lblSolution.numberOfLines = 0;
        lblSolution.font = [UIFont fontWithName:@"Verdana" size:12];
        lblSolution.textColor = color;
        lblSolution.text = [matches valueForKey:@"solution"];
        [lblSolution sizeToFit];
        [_scroll addSubview:lblSolution];
            
        padding += lblSolution.bounds.size.height;
        padding += 20;
            
            
        NSArray *categories = [matches valueForKey:@"supports"];
        NSInteger count = categories.count;
        UILabel *lblSupport = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,300,100)];
        lblSupport.numberOfLines = 0;
        lblSupport.font = [UIFont fontWithName:@"Verdana" size:11];
        lblSupport.textColor = color;
        lblSupport.text = [NSString stringWithFormat:@"Проблему поддерживают %lu пользователя", count];
        [lblSupport sizeToFit];
        [_scroll addSubview:lblSupport];
            
        padding += lblSupport.bounds.size.height;
        padding += 5;
            
        UILabel *lblTimeCreated = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,300,100)];
        lblTimeCreated.numberOfLines = 0;
        lblTimeCreated.font = [UIFont fontWithName:@"Verdana" size:11];
        lblTimeCreated.textColor = color;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSDate *_date = [dateFormat dateFromString:[matches valueForKey:@"time_created"]];
        [dateFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
        NSString *stringFromDate = [dateFormat stringFromDate:_date];
        lblTimeCreated.text = [NSString stringWithFormat:@"Проблема добавлена: %@", stringFromDate];
        [lblTimeCreated sizeToFit];
        [_scroll addSubview:lblTimeCreated];
            
        padding += lblTimeCreated.bounds.size.height;
        padding += 20;
        
        UILabel *lblPhoto = [[UILabel alloc]initWithFrame:CGRectMake(10,padding,300,100)];
        lblPhoto.numberOfLines = 0;
        lblPhoto.font = [UIFont fontWithName:@"Verdana" size:13];
        lblPhoto.text = @"Фотографии проблемы:";
        [lblPhoto sizeToFit];
        [_scroll addSubview:lblPhoto];
        
        padding += lblPhoto.bounds.size.height;
        
        UIScrollView *_scrollRecipients = [[UIScrollView alloc]initWithFrame:CGRectMake(0,padding,320,80)];
        
        _scrollRecipients.tag = 999;
        
        photoCounter = 1;
        
        UIButton *buttonAddPhoto = [[UIButton alloc]initWithFrame:CGRectMake(10,5,60,60)];
        UIImage *buttonImageNormal = [UIImage imageNamed:@"add_photo"];
        [buttonAddPhoto setImage:buttonImageNormal forState:UIControlStateNormal];
        [buttonAddPhoto addTarget:self action:@selector(handleUploadPhotoTouch:) forControlEvents:UIControlEventTouchUpInside];
        
        [_scrollRecipients addSubview:buttonAddPhoto];
        
        _scrollRecipients.contentSize = CGSizeMake(210, 80);
        _scrollRecipients.showsHorizontalScrollIndicator = false;
        _scrollRecipients.showsVerticalScrollIndicator = false;
        
        [_scroll addSubview:_scrollRecipients];
        
        padding += _scrollRecipients.bounds.size.height;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"Отправить жалобу на данную проблему" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(sendClaim:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(10,padding,310,100);
        
        [button sizeToFit];
        [_scroll addSubview:button];
        
        padding += button.bounds.size.height;
        padding += 100;
            
        [_scroll setContentSize:CGSizeMake(_scroll.frame.size.width, padding)];
        
        //1
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        //2
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        
        NSString *urlAsString = [NSString stringWithFormat:@"%@/%@/photo/get/%@", API_SERVER, API_KEY, [matches valueForKey:@"id_"]];
        
        NSURL *url = [[NSURL alloc] initWithString:urlAsString];
        NSLog(@"%@", urlAsString);
        
        [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            if (error) {
                
                NSLog(@"Error %@; %@", error, [error localizedDescription]);
                
            } else {
                
                
                NSError *localError = nil;
                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                
                double delayInSeconds = 0.1;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self addPhotos:parsedObject];
                    
                });
                
            }
        }];
        
        

    }
    
    self.automaticallyAdjustsScrollViewInsets = YES;

    [self.view setNeedsDisplay];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 380 && buttonIndex==1) {
        
        if ([[[alertView textFieldAtIndex:0] text] isEqualToString:@""]) {
            
            
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self showAlert:@"Вы не указали причину. Жалоба не будет отправлена."];
                
            });
            
        } else {
            
            loading = [[UIAlertView alloc] initWithTitle:@"" message:@"Жалоба отправляется..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            
            UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
            
            progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            
            [loading addSubview:progress];
            
            [progress startAnimating];
            
            [loading show];
            
            NSString *textClaim = [[alertView textFieldAtIndex:0] text];
            textClaim = [textClaim urlEncodeUsingEncoding:NSUTF8StringEncoding];
            
            
            NSString *urlAsString = [NSString stringWithFormat:@"%@/%@/item/claim/%@?description=%@", API_SERVER, API_KEY, itemID, textClaim];
            
            NSURL *url = [[NSURL alloc] initWithString:urlAsString];
            NSLog(@"%@", urlAsString);
            
            [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                if (error) {
                    
                    NSLog(@"Error %@; %@", error, [error localizedDescription]);
                    
                } else {
                    
                    double delayInSeconds = 0.5;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        [self showAlert:@"Жалоба успешно отправлена. В скором времени администрация примет меры."];
                        
                    });
                    
                }
            }];
        }
        
    }
    
}


- (IBAction)sendClaim:(id)sender {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Введите причину жалобы на данную проблему:" delegate:self cancelButtonTitle:@"Отмена"
                                           otherButtonTitles:@"Отправить", nil];
    alert.tag = 380;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeTwitter;
    alertTextField.placeholder = @"Причина жалобы";
    [alert show];
}


- (void) addPhotos:(NSDictionary *)parsedObject {
    
    NSDictionary *results = [parsedObject valueForKey:@"data"];
    
    NSLog(@"Count %lu", (unsigned long)results.count);
    
    for (NSDictionary *item in [parsedObject valueForKey:@"data"]) {
        
        UIScrollView *_scrolll = (UIScrollView *) [self.view viewWithTag:999];
        
        
        NSLog(@"%@", [NSString stringWithFormat:@"%@%@", FILE_SERVER_TEST, [[item valueForKeyPath:@"name"] mutableCopy]]);
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", FILE_SERVER_TEST, [[item valueForKeyPath:@"name"] mutableCopy]]];

        
        NSInteger temp = (int)photoCounter;
        
        NSInteger padding = temp * 60 + 10;
        padding += temp * 5;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
        tap.cancelsTouchesInView = YES;
        tap.numberOfTapsRequired = 1;
        
        AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(padding, 5, 60, 60)];

        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        imageView.tag = 900 + photoCounter;
        
        
        [imageView addGestureRecognizer:tap];
        
        [_scrolll addSubview:imageView];
        
        
        
        
        padding = temp * 60;
        padding += temp * 5;
        
        _scrolll.contentSize = CGSizeMake(padding+80, 80);
        
        AsyncImageView *imageViewLoad = (AsyncImageView *) [self.view viewWithTag:900 + photoCounter];
        
        //cancel loading previous image for cell
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imageViewLoad];
        
        //load the image
        imageViewLoad.imageURL = url;
        photoCounter ++;
    }

}


- (void) handleImageTap:(UIGestureRecognizer *)gestureRecognizer {
    
    UIView* view = gestureRecognizer.view;
    
    GGFullscreenImageViewController *vc = [[GGFullscreenImageViewController alloc] init];
    vc.liftedImageView = view;
    
    [self presentViewController:vc animated:YES completion:nil];
    
    //object of view which invoked this
    NSLog(@"tap");
}

- (IBAction)handleUploadPhotoTouch:(id)sender {
    
    if ([API_KEY isEqualToString:API_DEFAULT_KEY]) {
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self showAlert:@"Незарегистрированные пользователи не могут добавлять фотографии."];
            
        });
        
    } else {
        
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
    
    loading = [[UIAlertView alloc] initWithTitle:@"" message:@"Отправка фотографии..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
    UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
    
    progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    
    [loading addSubview:progress];
    
    [progress startAnimating];
    
    [loading show];
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    UIScrollView *_scroll = (UIScrollView *) [self.view viewWithTag:999];
    
    NSInteger temp = (int)photoCounter;
    
    NSInteger padding = temp * 60 + 10;
    padding += temp * 5;
    
    UIImageView *_im = [[UIImageView alloc] initWithFrame:CGRectMake(padding, 5, 60, 60)];
    _im.contentMode = UIViewContentModeScaleAspectFit;
    
    _im.image = chosenImage;
    _im.userInteractionEnabled = TRUE;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    tap.cancelsTouchesInView = YES;
    tap.numberOfTapsRequired = 1;
    
    [_im addGestureRecognizer:tap];
    _im.tag = 900 + photoCounter;
    
    
    [_scroll addSubview:_im];
    
    photoCounter ++;
    
    padding = temp * 60;
    padding += temp * 5;
    
    _scroll.contentSize = CGSizeMake(padding+80, 80);
    
    
    [self.view setNeedsDisplay];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
    
    
    dispatch_queue_t myqueue = dispatch_queue_create("myqueue", NULL);
    
    // execute a task on that queue asynchronously
    dispatch_async(myqueue, ^{

        
        NSData *imgData = UIImageJPEGRepresentation(_im.image, 90);
        
        NSString *urlString =  [NSString stringWithFormat:@"%@/photo/upload", API_SERVER];
        NSURL *url = [[NSURL alloc]initWithString:urlString];
        
        NSLog(@"%@", urlString);
        
        
        NSLog(@"%@", itemID);
        
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
        [body appendData:[itemID dataUsingEncoding:NSUTF8StringEncoding]];
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
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self showAlert:@"Фотография успешно добавлена."];
            
        });

    
     });

    
}

-(void)showAlert:(NSString *)messageText {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:messageText
                                                   delegate:self cancelButtonTitle:@"ОК"
                                          otherButtonTitles:nil];
    [alert show];
    
    [loading dismissWithClickedButtonIndex:0 animated:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    API_KEY = [[NSUserDefaults standardUserDefaults] stringForKey:@"API_KEY"];
}

-(void)setItemID:(NSString*)id
{
    itemID = id;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
