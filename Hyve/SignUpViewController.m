//
//  SignUpViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/23/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "SignUpViewController.h"
#import "WalkthroughViewController.h"
#import <POP.h>
#import <AFNetworking.h>
#import <SimpleAuth/SimpleAuth.h>
#import <Reachability.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <KVNProgress.h>
#import <AFNetworking.h>

@interface SignUpViewController () <GPPSignInDelegate>
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet UILabel *registrationOptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UIButton *googlePlusButton;
@property (strong, nonatomic) IBOutlet UITextField *passwordConfirmationTextField;
@property (nonatomic) KVNProgressConfiguration *loadingProgressView;
@property BOOL textFieldIsEmpty;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textFieldIsEmpty = NO;
    self.title = @"Sign Up";
    
    [self assigningStyleToTextFields];
    [self stylingBackgroundView];
    [self stylingRegisterButton];
    [self stylingRegistrationOptionLabel];
    [self stylingFacebookButton];
    [self stylingGooglePlusButton];
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

#pragma mark - styling registration option label
-(void)stylingRegistrationOptionLabel
{
    self.registrationOptionLabel.text = @"Or Register Via";
    self.registrationOptionLabel.textColor = [UIColor whiteColor];
    self.registrationOptionLabel.font = [UIFont fontWithName:@"OpenSans" size:20];
    self.registrationOptionLabel.numberOfLines = 0;
}

#pragma mark - styling register button
-(void)stylingRegisterButton
{
    self.registerButton.backgroundColor = [UIColor colorWithRed:0.96 green:0.46 blue:0.15 alpha:1];
    [self.registerButton setTitle:@"REGISTER" forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.registerButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:20];
}

#pragma mark - styling background view
-(void)stylingBackgroundView
{
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundImage.image = [UIImage imageNamed:@"loginBg"];
    [self.view addSubview:backgroundImage];
}

#pragma mark - assigning styling to text field
-(void)assigningStyleToTextFields
{
    [self stylingTextField:self.emailTextField];
    [self stylingTextField:self.lastNameTextField];
    [self stylingTextField:self.firstNameTextField];
    [self stylingTextField:self.passwordTextField];
    [self stylingTextField:self.passwordConfirmationTextField];
    
    [self settingPlaceholderTextFieldColor:self.emailTextField setPlaceholderText:@"Email"];
    [self settingPlaceholderTextFieldColor:self.lastNameTextField setPlaceholderText:@"Last Name"];
    [self settingPlaceholderTextFieldColor:self.firstNameTextField setPlaceholderText:@"First Name"];
    [self settingPlaceholderTextFieldColor:self.passwordTextField setPlaceholderText:@"Password (min. 8 characters)"];
    [self settingPlaceholderTextFieldColor:self.passwordConfirmationTextField setPlaceholderText:@"Password Confirmation"];
}

#pragma mark - styling text field
-(void)stylingTextField:(UITextField*)registrationTextField
{
    registrationTextField.borderStyle = UITextBorderStyleNone;
    registrationTextField.backgroundColor = [UIColor colorWithRed:0.77 green:0.77 blue:0.77 alpha:1];
    registrationTextField.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    registrationTextField.textColor = [UIColor blackColor];
    registrationTextField.font = [UIFont fontWithName:@"OpenSans" size:17];
    
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    keyboardToolbar.barStyle = UIBarStyleDefault;
    keyboardToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonPressed)],
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                              [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)]
                              ];
    
    [keyboardToolbar sizeToFit];
    registrationTextField.inputAccessoryView = keyboardToolbar;

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

#pragma mark - register button
- (IBAction)onRegisterButtonPressed:(id)sender
{
    for (UIView *theView in self.view.subviews)
    {
        if ([theView isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField*)theView;
            
            [textField.layer pop_removeAllAnimations];
            if ([textField.text isEqualToString:@""])
            {
                POPSpringAnimation *shakeEmptyTextField = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
                shakeEmptyTextField.springBounciness = 20;
                shakeEmptyTextField.velocity = @(2000);
                shakeEmptyTextField.name = @"shake";
                
                [textField.layer pop_addAnimation:shakeEmptyTextField forKey:shakeEmptyTextField.name];
            }
            else
            {
                Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
            
                if (reachability.isReachable)
                {
                    [self settingProgressView];
                    [self assigningEmailLoginInfo];
                }
                else
                {
                    [self alertMessageToUser:@"Trouble with Internet connectivity"];
                }
            }
        }
    }
}

#pragma mark - assigning email login 
-(void)assigningEmailLoginInfo
{
    NSString *last_name = [self.lastNameTextField.text lowercaseString];
    NSString *first_name = [self.firstNameTextField.text lowercaseString];
    NSString *usernameWithoutWhiteSpace = [[NSString stringWithFormat:@"%@%@", self.lastNameTextField.text, self.firstNameTextField.text] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *provider = @"email";
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    NSUInteger passwordCharacterCount = [password length];
    NSString *passwordConfirmation = self.passwordConfirmationTextField.text;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:password forKey:@"userPassword"];
    
    for (UIView *textFields in self.view.subviews)
    {
        if ([textFields isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField*)textFields;
            
            if ([textField.text isEqualToString:@""])
            {
                self.textFieldIsEmpty = YES;
                break;
            }
        }
    }
    
    
    if (self.textFieldIsEmpty == YES)
    {
        [KVNProgress dismiss];
        
        [self alertMessageToUser:@"Please ensure all fields are entered"];
        self.textFieldIsEmpty = NO;
    }
    
    if (passwordCharacterCount < 8)
    {
        [KVNProgress dismiss];
        [self alertMessageToUser:@"Password length does not meet the required minimum length. Please ensure it has at least 8 characters"];
    }
    
    
//    if ([last_name isEqualToString:@""] ||
//        [first_name isEqualToString:@""] ||
//        [email isEqualToString:@""] ||
//        [password isEqualToString:@""] ||
//        [passwordConfirmation isEqualToString:@""] ||
//        passwordCharacterCount < 8)
//    {
//        [KVNProgress dismiss];
//        
//        [self alertMessageToUser:@"Please ensure all fields are entered"];
//    }
//    else
    if (passwordCharacterCount > 8 && self.textFieldIsEmpty == NO)
    {
        NSMutableDictionary *userInfoDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:email,@"email",
                                      provider,@"provider",
                                      first_name,@"first_name",
                                      last_name,@"last_name",
                                      usernameWithoutWhiteSpace,@"username",
                                      password,@"password",
                                      passwordConfirmation, @"password_confirmation",
                                      nil];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self registerUserToHyve:userInfoDictionary];
        });
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

#pragma mark - facebook
- (IBAction)onFacebookButtonPressed:(id)sender
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    if (reachability.isReachable)
    {
        [self settingProgressView];
        [self loginWithFacebook];
    }
    else
    {
        [self alertMessageToUser:@"Trouble with Internet connectivity"];
    }
}

-(void)loginWithFacebook
{
    [SimpleAuth authorize:@"facebook" completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            NSLog(@"responseObject from FB: \r%@", responseObject);
            
            NSString *email = [responseObject valueForKeyPath:@"info.email"];
            NSString *uid = [responseObject valueForKeyPath:@"uid"];
            NSString *provider = [responseObject valueForKeyPath:@"provider"];
            NSString *first_name = [responseObject valueForKeyPath:@"info.first_name"];
            NSString *last_name = [responseObject valueForKeyPath:@"extra.raw_info.last_name"];
            NSString *username = [NSString stringWithFormat:@"%@ %@", first_name, last_name];
            NSString *usernameWithoutWhiteSpace = [[username stringByReplacingOccurrencesOfString:@" " withString:@""]lowercaseString];
            NSString *image = [responseObject valueForKeyPath:@"info.image"];
            
            NSMutableDictionary *userInfoDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:email,@"email",
               uid,@"uid",
               provider,@"provider",
               first_name,@"first_name",
               last_name,@"last_name",
               usernameWithoutWhiteSpace ,@"username",
               image,@"avatar",nil];
            
            [self registerUserToHyve:userInfoDictionary];

        }
        else
        {
            NSLog(@"error with login %@", [error localizedDescription]);
            
            [self alertMessageToUser:@"Login Error. Please do check your Settings to enable Facebook login.\r Here's a guide:\r 1.Settings \r 2.Facebook \r 3.Log in Facebook within Settings \r 4.Check to see if Facebook app is enabled \r 5.Login Hyve via Facebook "];
            
        }
    }];
}

-(void)stylingFacebookButton
{
    [self.facebookButton setImage:[UIImage imageNamed:@"fb"] forState:UIControlStateNormal];
}

#pragma mark - google
- (IBAction)onGooglePlusButtonPressed:(id)sender
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    if (reachability.isReachable)
    {
        [self settingProgressView];
        [self loginWithGooglePlus];
    }
    else
    {
        [self alertMessageToUser:@"Trouble with Internet connectivity"];
    }
}

-(void)loginWithGooglePlus
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = @"488151226427-0mj2pg9jipcv26djbgmp4gi8pmfjc866.apps.googleusercontent.com";
    signIn.scopes = @[@"profile"];
    signIn.delegate = self;
    [signIn authenticate];
}

-(void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    if (error)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:[NSString stringWithFormat:@"Unable to login via Google Plus. %@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        
        GTLServicePlus *plusService = [GTLServicePlus new];
        plusService.retryEnabled = YES;
        [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        
        [plusService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLPlusPerson *person, NSError *error)
         {
             if (error)
             {
                 NSLog(@"Error: %@", error);
             }
             else
             {
                 
                 NSString *email = [GPPSignIn sharedInstance].authentication.userEmail;
                 NSString *uid = person.identifier;
                 NSString *first_name = person.name.givenName;
                 NSString *last_name = person.name.familyName;
                 NSString *usernameWithoutWhiteSpace = [[NSString stringWithFormat:@"%@%@",first_name,last_name] lowercaseString];
                 NSString *imageURLString = person.image.url;
                 NSString *provider = @"google";
                 
                 NSMutableDictionary *userInfoDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:email,@"email",
                                                  uid,@"uid",
                                                  provider,@"provider",
                                                  first_name,@"first_name",
                                                  last_name,@"last_name",
                                                  usernameWithoutWhiteSpace,@"username",
                                                  imageURLString, @"avatar",nil];
                 
                 [self registerUserToHyve:userInfoDictionary];
             }
         }];
    }
}


-(void)stylingGooglePlusButton
{
    [self.googlePlusButton setImage:[UIImage imageNamed:@"g+"] forState:UIControlStateNormal];
}


#pragma mark - register user to hyve
-(void)registerUserToHyve:(NSMutableDictionary*)userInfoDictionaryJSON
{
    NSString *hyveURLString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/register"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer.timeoutInterval = 20;
    
    [manager POST:hyveURLString parameters:userInfoDictionaryJSON success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *errorArray = [responseObject valueForKeyPath:@"errors.email"];
        
        if (errorArray.count > 0)
        {
            [KVNProgress dismiss];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"You already have an established acccount with Hyve. You can go ahead and use the login functionality." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okACtion = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alertController addAction:okACtion];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            NSString *api_token = [responseObject valueForKeyPath:@"api_token"];
            NSString *successLoginViaEmail = @"successLoginViaEmail";
            NSString *email = [responseObject valueForKeyPath:@"user_session.user.email"];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:api_token forKey:@"api_token"];
            [userDefaults setObject:email forKey:@"email"];
            [userDefaults setObject:successLoginViaEmail forKey:@"successLoginViaEmail"];
            [userDefaults synchronize];
            
            [KVNProgress showSuccessWithStatus:@"Success!"];
            [self performSegueWithIdentifier:@"ToDashboardVCFromSignUp" sender:nil];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [KVNProgress dismiss];
        NSLog(@"error %@ \r \r error localized:%@", error, [error localizedDescription]);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble connecting to server. Plese try again" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }];
}

#pragma mark - alert 
-(void)alertMessageToUser:(NSString*)alertMessage
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    
    if (self.presentedViewController == nil)
    {
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - dismiss keyboard upon touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


@end
