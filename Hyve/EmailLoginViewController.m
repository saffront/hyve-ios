//
//  EmailLoginViewController.m
//  Hyve
//
//  Created by VLT Labs on 4/10/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "EmailLoginViewController.h"
#import "DashboardViewController.h"
#import <AFNetworking.h>
#import <Reachability.h>
#import <KVNProgress.h>
#import <POP.h>

@interface EmailLoginViewController() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *hyveImageLogo;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (nonatomic) KVNProgressConfiguration *loadingProgressView;
@property BOOL emptyTextField;

@end

@implementation EmailLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Login";
    
    self.emptyTextField = NO;
    [self stylingBackgroundView];
    [self settingUpHyveImageLogo];
    [self stylingTextField:self.emailTextField];
    [self stylingTextField:self.passwordTextField];
    [self stylingLoginButton];
    [self connected];
}

#pragma mark - connected
-(BOOL)connected
{
    __block BOOL reachable;
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
            {
                NSLog(@"not reachable");
                reachable = NO;
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Internet unavailable. Please connect to the Internet" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:okAction];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alertController animated:YES completion:nil];
                });
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                NSLog(@"reachable with wifi");
                reachable = YES;
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                NSLog(@"reachable via WWAN");
                reachable = YES;
                break;
            }
            default:
            {
                NSLog(@"Unkown internet status");
                reachable = NO;
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Internet unavailable. Please connect to the Internet" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:okAction];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alertController animated:YES completion:nil];
                });
                break;
            }
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    return reachable;
}

#pragma mark - setting up hyve image logo
-(void)settingUpHyveImageLogo
{
    UIImage *hyveImageLogo = [UIImage imageNamed:@"EmailLoginHyveLogo"];
    [self.hyveImageLogo setImage:hyveImageLogo];
    [self.hyveImageLogo setContentMode:UIViewContentModeScaleAspectFit];
    
    UIImage *animate5 = [UIImage imageNamed:@"animate5"];
    
    NSMutableArray *bluetoothIndicatorImage = [NSMutableArray arrayWithObjects:hyveImageLogo,animate5,nil];
    
    self.hyveImageLogo.animationImages = bluetoothIndicatorImage;
    self.hyveImageLogo.animationDuration = 3;
    [self.hyveImageLogo startAnimating];
}

#pragma mark - viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIImage *backButtonImage = [UIImage imageNamed:@"backButton"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 30, 30)];
    [backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButtonOnBar = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonOnBar;
    
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"OpenSans-SemiBold" size:17],
      NSFontAttributeName, nil]];
}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - styling background view
-(void)stylingBackgroundView
{
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundImageView.image = [UIImage imageNamed:@"loginBg"];
    [self.view addSubview:backgroundImageView];
}

#pragma mark - styling text fields
-(void)stylingTextField:(UITextField*)loginTextFields
{
    loginTextFields.delegate = self;
    loginTextFields.borderStyle = UITextBorderStyleNone;
    loginTextFields.backgroundColor = [UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:1];
    loginTextFields.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    loginTextFields.textColor = [UIColor blackColor];
    loginTextFields.font = [UIFont fontWithName:@"OpenSans" size:17];
    
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    keyboardToolbar.barStyle = UIBarStyleDefault;
    keyboardToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonPressed)],
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                              [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)]
                              ];
    
    [keyboardToolbar sizeToFit];
    loginTextFields.inputAccessoryView = keyboardToolbar;
    
    
    [self settingPlaceholderTextFieldColor:self.emailTextField setPlaceholderText:@"Email"];
    [self settingPlaceholderTextFieldColor:self.passwordTextField setPlaceholderText:@"Password"];
}


-(void)settingPlaceholderTextFieldColor:(UITextField*)registrationTextField setPlaceholderText:(NSString*)placeholderText
{
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:placeholderText attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    registrationTextField.attributedPlaceholder = placeholder;
    
}

-(void)clearButtonPressed
{
    for (UIView *textFields in self.view.subviews)
    {
        if ([textFields isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField*)textFields;
            
            if (textField.isEditing)
            {
                textField.text = @"";
            }
        }
    }
}

-(void)doneButtonPressed
{
    for (UIView *textFields in self.view.subviews)
    {
        if ([textFields isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField*)textFields;
            
            [textField resignFirstResponder];
        }
    }
}

#pragma mark - setting loading progress view
-(void)settingProgressView
{
    self.loadingProgressView = [KVNProgressConfiguration defaultConfiguration];
    [KVNProgress setConfiguration:self.loadingProgressView];
    self.loadingProgressView.backgroundType = KVNProgressBackgroundTypeBlurred;
    self.loadingProgressView.fullScreen = YES;
    self.loadingProgressView.minimumDisplayTime = 1;
    
    [KVNProgress showWithStatus:@"Processing...Please hold..."];
}

#pragma mark - login button
-(void)stylingLoginButton
{
    self.loginButton.backgroundColor = [UIColor colorWithRed:0.96 green:0.46 blue:0.15 alpha:1];
    [self.loginButton setTitle:@"LOGIN" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:20];

}

- (IBAction)onLoginButtonPressed:(id)sender
{
    for (UIView *theView in self.view.subviews)
    {
        if ([theView isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField*)theView;
            
            if ([textField.text isEqualToString:@""])
            {
                self.emptyTextField = YES;
                break;
            }
        }
    }
    
    if (self.emptyTextField == YES)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Please ensure both fields are entered" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        POPSpringAnimation *shakeEmptyTextField = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        shakeEmptyTextField.springBounciness = 20;
        shakeEmptyTextField.velocity = @(2000);
        shakeEmptyTextField.name = @"shake";
        
        [self.emailTextField pop_addAnimation:shakeEmptyTextField forKey:shakeEmptyTextField.name];
        [self.passwordTextField pop_addAnimation:shakeEmptyTextField forKey:shakeEmptyTextField.name];
        self.emptyTextField = NO;
    }
    else
    {
        Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
        
        if (reachability.isReachable)
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            [self settingProgressView];
            [self loginUserViaEmail];
        }
        else
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

-(void)loginUserViaEmail
{
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *provider = @"email";
 
    NSMutableDictionary *userInfoDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               email,@"email",
                                               provider,@"provider",
                                               password,@"password",
                                               nil];
    
    
//    NSString *hyveURLString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/user_sessions"];
    NSString *hyveURLString = [NSString stringWithFormat:@"http://hyve-production.herokuapp.com/api/v1/user_sessions"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setTimeoutInterval:20];
    
    [manager POST:hyveURLString parameters:userInfoDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *errorTextFromRails = [responseObject valueForKeyPath:@"error"];
        NSString *checkingForError = @"User not found, please check your parameters.";
        
        if ([checkingForError isEqualToString:errorTextFromRails])
        {
            [KVNProgress dismiss];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"There seem to be an account error. Please ensure account has been registered" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            NSString *api_token = [responseObject valueForKeyPath:@"api_token"];
            NSString *successLoginViaEmail = @"successLoginViaEmail";
            NSString *email = [responseObject valueForKeyPath:@"user_session.user.email"];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:email forKey:@"email"];
            [userDefaults setObject:api_token forKey:@"api_token"];
            [userDefaults setObject:successLoginViaEmail forKey:@"successLoginViaEmail"];
            [userDefaults synchronize];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            self.loadingProgressView.minimumSuccessDisplayTime = 1.5;
            [KVNProgress showSuccessWithStatus:@"Success!"];
            [self performSegueWithIdentifier:@"ToDashboardFromEmailVC" sender:nil];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error %@ \r \r error localized:%@", error, [error localizedDescription]);
        
        [KVNProgress dismiss];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble connecting with server. Please try again" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }];
}

#pragma mark - text field delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.title = @"";
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 180, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.title = @"Login";
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 180, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

#pragma mark - touches began
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToDashboardFromEmailVC"])
    {
        UINavigationController *navController = segue.destinationViewController;
        DashboardViewController *dvc = (DashboardViewController*)[navController topViewController];
    }
}


@end
