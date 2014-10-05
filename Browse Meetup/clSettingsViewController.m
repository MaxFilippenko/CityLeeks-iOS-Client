//
//  clSettingsViewController.m
//
//  Created by Denis on 27.04.14.
//  Copyright (c) 2014 cityleeks. All rights reserved.
//

#import "clSettingsViewController.h"
#import "CustomIOS7AlertView.h"
#define API_SERVER @"https://api.cityleeks.org"
#define API_DEFAULT_KEY @"q02kwfs5df5b6gqxsk5ntp7nnah461aski1xu772"

@implementation NSString (URLEncoding)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    CFStringRef stringRef = CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)self,  NULL,  (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",  CFStringConvertNSStringEncodingToEncoding(encoding));
    NSString *returnString = (__bridge NSString*)stringRef;
    CFRelease(stringRef);
    return returnString;
}

@end

@interface clSettingsViewController ()

@end

@implementation clSettingsViewController

NSString *userName;
NSString *userEmail;
NSString *userPassword;
NSString *userApiKey;
UIAlertView *loading;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userApiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"API_KEY"];
    
    UISlider *sliderDistance = (UISlider *) [self.view viewWithTag:301];
    CGFloat value = [[NSUserDefaults standardUserDefaults] floatForKey:@"sliderDistance"];
    
    userName = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserName"];
    
    if (userName) {
        
        UIButton *loginButton = (UIButton *) [self.view viewWithTag:371];
        loginButton.hidden = true;
        
        UIButton *registerButton = (UIButton *) [self.view viewWithTag:372];
        registerButton.hidden = true;
        
        UIButton *loginOutButton = (UIButton *) [self.view viewWithTag:373];
        loginOutButton.hidden = false;
        
        UILabel *userNameLabel = (UILabel *) [self.view viewWithTag:321];
        userNameLabel.text = userName;
    }
    
    if (value) sliderDistance.value = value;
    else [[NSUserDefaults standardUserDefaults] setFloat:10000.0 forKey:@"sliderDistance"];
    
    UILabel *labelDistance = (UILabel *) [self.view viewWithTag:302];
    labelDistance.text = [NSString stringWithFormat:@"%i м", (int)round(sliderDistance.value)];
    
    [sliderDistance addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIButton *loginButton = (UIButton *) [self.view viewWithTag:371];
    [loginButton addTarget:self action:@selector(showLoginForm:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *registerButton = (UIButton *) [self.view viewWithTag:372];
    [registerButton addTarget:self action:@selector(showRegisterForm:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *logOutButton = (UIButton *) [self.view viewWithTag:373];
    [logOutButton addTarget:self action:@selector(logOut:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *sendEmailButton = (UIButton *) [self.view viewWithTag:333];
    [sendEmailButton addTarget:self action:@selector(sendEmail:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)sendEmail:(id)sender {
    
    NSString *url = @"mailto:support@cityleeks.org?subject=Feedback";
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    
}

- (IBAction)logOut:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setValue:API_DEFAULT_KEY forKey:@"API_KEY"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"UserName"];
    UIButton *loginButton = (UIButton *) [self.view viewWithTag:371];
    loginButton.hidden = false;
    
    UIButton *registerButton = (UIButton *) [self.view viewWithTag:372];
    registerButton.hidden = false;
    
    UIButton *loginOutButton = (UIButton *) [self.view viewWithTag:373];
    loginOutButton.hidden = true;
    
    UILabel *userNameLabel = (UILabel *) [self.view viewWithTag:321];
    userNameLabel.text = @"Анонимный пользователь";
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSLog(@"%s",__FUNCTION__);
    NSURL* u = [request URL];
    
    if( [[u scheme] isEqualToString:@"showlicenses"] ) {
        NSLog(@"in %s",__FUNCTION__);
        [self performSegueWithIdentifier:@"loadTNC" sender:self];
        return NO; // DO NOT attempt to load URL
    }
    
    return YES; // if you want to allow the URL to load
}


- (IBAction)showRegisterForm:(id)sender {
    
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

}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if (alertView.tag == 380 && buttonIndex==1) {
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Регистрация. Шаг 1 из 2" message:@"Представьтесь, пожалуйста:" delegate:self cancelButtonTitle:@"Отмена"
                                               otherButtonTitles:@"Далее", nil];
        alert.tag = 382;
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField * alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeTwitter;
        alertTextField.placeholder = @"Введите ваше Имя и Фамилию";
        [alert show];
        
    }
    [alertView close];
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)validatePasswordWithString:(NSString*)name
{
    NSString *nameRegex = @"[0-9а-яА-Я-a-zA-Z]{4,40}";
    NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    return [nameTest evaluateWithObject:name];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 381 && buttonIndex==1) {
        
        userEmail = [[alertView textFieldAtIndex:0] text];
        userPassword = [[alertView textFieldAtIndex:1] text];
        
        if ([self validateEmailWithString:userEmail] && (userPassword.length>8)) {
            loading = [[UIAlertView alloc] initWithTitle:@"" message:@"Авторизация пользователя..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            
            UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
            
            progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            
            [loading addSubview:progress];
            
            [progress startAnimating];
            
            [loading show];
            
            NSString *serverAddress =  [NSString stringWithFormat:@"%@/auth/login?email=%@&password=%@", API_SERVER, userEmail, userPassword];
            
            NSURL *url = [NSURL URLWithString:serverAddress];
            
            NSLog(@"%@", serverAddress);
            
            
            [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                if (error) {
                    
                    NSLog(@"Error %@; %@", error, [error localizedDescription]);
                    
                    
                    double delayInSeconds = 0.5;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        [self showAlert:@"Неправильный логин или пароль."];
                        
                    });
                    
                } else {
                    
                    NSError *localError = nil;
                    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                    
                    NSDictionary *results = [parsedObject valueForKey:@"error_data"];
                    
                    if (results != (NSDictionary*) [NSNull null]) {
                        
                        double delayInSeconds = 0.5;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            
                            [self showAlert:@"Неправильный логин или пароль."];
                            
                        });
                        
                    } else {
                        
                        NSString *result_error = [NSString stringWithFormat:@"%@", [parsedObject valueForKey:@"error"]];
                        
                        [parsedObject valueForKey:@"error"];
                        
                        if ([result_error  isEqual: @"000"]) {
                            NSDictionary *user_data = [parsedObject valueForKey:@"data"];
                            userName = [[user_data valueForKeyPath:@"fullname"] mutableCopy];
                            userApiKey = [[user_data valueForKeyPath:@"api_key"] mutableCopy];
                            [[NSUserDefaults standardUserDefaults] setValue:userApiKey forKey:@"API_KEY"];
                            [[NSUserDefaults standardUserDefaults] setValue:userName forKey:@"UserName"];
                            
                            double delayInSeconds = 0.2;
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                
                                [self changeFormToLogInMode];
                                
                            });
                            
                        }
                        
                    }
                    
                    
                }
                
            }];
            
        } else {
        
            if ([self validateEmailWithString:userEmail]) {
                
                [self showAlert:@"Пароль должен состоять из 8 символов минимум"];
                
            } else {
                
                [self showAlert:@"Вы ввели не существующий email"];
                
            }
            
        }

    }
    
    
    if (alertView.tag == 382  && buttonIndex==1) {
        
        userName = [[alertView textFieldAtIndex:0] text];
        
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Регистрация. Шаг 2 из 2"
                                                          message:@"Укажите ваш email и пароль, пожалуйста:"
                                                         delegate:self
                                                cancelButtonTitle:@"Отмена"
                                                otherButtonTitles:@"Регистрация", nil];
        message.tag = 383;
        
        [message setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        [[message textFieldAtIndex:1] setSecureTextEntry:NO];
        
        
        UITextField *textFieldDescription = [message textFieldAtIndex:0];
        textFieldDescription.keyboardType = UIKeyboardTypeEmailAddress;
        textFieldDescription.placeholder = @"email";
        UITextField *textFieldFileName = [message textFieldAtIndex:1];
        textFieldFileName.placeholder = @"пароль (минимум 8 символов)";
        
        [message show];
    }
    
    if (alertView.tag == 383 && buttonIndex==1) {
        
        userEmail = [[alertView textFieldAtIndex:0] text];
        userPassword = [[alertView textFieldAtIndex:1] text];
        
        NSString *password = [userPassword urlEncodeUsingEncoding:NSUTF8StringEncoding];
        NSString *email = [userEmail urlEncodeUsingEncoding:NSUTF8StringEncoding];
        
        NSString *name = [userName urlEncodeUsingEncoding:NSUTF8StringEncoding];
        
        loading = [[UIAlertView alloc] initWithTitle:@"" message:@"Регистрация пользователя..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        
        UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
        
        progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        
        [loading addSubview:progress];
        
        [progress startAnimating];
        
        [loading show];

        
        NSString *serverAddress =  [NSString stringWithFormat:@"%@/auth/register?email=%@&password=%@&confirmationpassword=%@&fullname=%@", API_SERVER, email, password, password, name];
        
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
                
                NSError *localError = nil;
                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                
                NSDictionary *results = [parsedObject valueForKey:@"error_data"];
                
                if (results != (NSDictionary*) [NSNull null]) {
                    
                    double delayInSeconds = 0.5;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        [self showAlert:@"Во время регистрации пользователя произошла ошибка. Попробуйте позже."];
                        
                    });

                    
                } else {
                    
                    NSString *result_error = [NSString stringWithFormat:@"%@", [parsedObject valueForKey:@"error"]];
                    
                    [parsedObject valueForKey:@"error"];
                    
                    
                    if ([result_error  isEqual: @"000"]) {

                        NSString *serverAddress =  [NSString stringWithFormat:@"%@/auth/login?email=%@&password=%@", API_SERVER, userEmail, userPassword];
                        
                        NSURL *url = [NSURL URLWithString:serverAddress];
                        
                        NSLog(@"%@", serverAddress);
                        
                        [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                            
                            if (error) {
                                
                                NSLog(@"Error %@; %@", error, [error localizedDescription]);
                                
                                
                                double delayInSeconds = 0.5;
                                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                    
                                    [self showAlert:@"Во время регистрации пользователя произошла ошибка. Попробуйте позже."];
                                    
                                });
                                
                            } else {
                        
                                NSError *localError = nil;
                                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                                
                                NSDictionary *results = [parsedObject valueForKey:@"error_data"];
                                
                                if (results != (NSDictionary*) [NSNull null]) {
                                    
                                    
                                    double delayInSeconds = 0.5;
                                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                        
                                        [self showAlert:@"Неправильный логин или пароль."];
                                        
                                    });
                                    
                                    
                                } else {
                                    
                                    NSString *result_error = [NSString stringWithFormat:@"%@", [parsedObject valueForKey:@"error"]];
                                    
                                    [parsedObject valueForKey:@"error"];
                                    
                                    NSLog(@"output data %@",data);
                                    
                                    if ([result_error  isEqual: @"000"]) {
                                        NSDictionary *user_data = [parsedObject valueForKey:@"data"];
                                        userName = [[user_data valueForKeyPath:@"fullname"] mutableCopy];
                                        userApiKey = [[user_data valueForKeyPath:@"api_key"] mutableCopy];
                                        [[NSUserDefaults standardUserDefaults] setValue:userApiKey forKey:@"API_KEY"];
                                        [[NSUserDefaults standardUserDefaults] setValue:userName forKey:@"UserName"];
                                        
                                        double delayInSeconds = 0.2;
                                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                            
                                            [self changeFormToLogInMode];
                                            
                                        });
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }];

                        
                    }
                    
                }
                
            }
            
        }];
        
    }
    
}


-(void)showAlert:(NSString *)messageText {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:messageText
                                                   delegate:self cancelButtonTitle:@"ОК"
                                          otherButtonTitles:nil];
    [alert show];
    
    [loading dismissWithClickedButtonIndex:0 animated:YES];
    
}


-(void)changeFormToLogInMode {
    
    UIButton *loginButton = (UIButton *) [self.view viewWithTag:371];
    loginButton.hidden = true;
    
    UIButton *registerButton = (UIButton *) [self.view viewWithTag:372];
    registerButton.hidden = true;
    
    UIButton *loginOutButton = (UIButton *) [self.view viewWithTag:373];
    loginOutButton.hidden = false;
    
    UILabel *userNameLabel = (UILabel *) [self.view viewWithTag:321];
    userNameLabel.text = userName;

    [loading dismissWithClickedButtonIndex:0 animated:YES];
}


- (IBAction)showLoginForm:(id)sender {
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Авторизация"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Отмена"
                                            otherButtonTitles:@"Вход", nil];
    [message setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[message textFieldAtIndex:1] setSecureTextEntry:YES];
    message.tag = 381;
    
    UITextField *textFieldDescription = [message textFieldAtIndex:0];
    textFieldDescription.keyboardType = UIKeyboardTypeEmailAddress;
    textFieldDescription.placeholder = @"email";
    UITextField *textFieldFileName = [message textFieldAtIndex:1];
    textFieldFileName.placeholder = @"пароль (минимум 8 символов)";

    [message show];
}


- (IBAction)sliderValueChanged:(UISlider *)sender {
    
    UILabel *labelDistance = (UILabel *) [self.view viewWithTag:302];
    labelDistance.text = [NSString stringWithFormat:@"%i м", (int)round(sender.value)];
    [[NSUserDefaults standardUserDefaults] setFloat:sender.value forKey:@"sliderDistance"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
