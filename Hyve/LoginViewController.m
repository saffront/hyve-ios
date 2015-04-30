//
//  LoginViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/19/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//


#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "DashboardViewController.h"
#import "WalkthroughViewController.h"
#import <AFNetworking/AFNetworking.h>
#import  <Reachability.h>
#import <SimpleAuth/SimpleAuth.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <KVNProgress.h>
#import <AFNetworking.h>

@interface LoginViewController () <GPPSignInDelegate>

@property (strong, nonatomic) IBOutlet UIButton *loginFacebookButton;
@property (strong, nonatomic) Reachability *reachability;
@property (strong, nonatomic) IBOutlet UIButton *emailButton;
@property (strong, nonatomic) IBOutlet UIButton *googlePlusButton;
@property (strong, nonatomic) IBOutlet UILabel *loginLabelDescription;
@property (strong, nonatomic) IBOutlet UIImageView *hyveLogoImageView;
@property (nonatomic) KVNProgressConfiguration *loadingProgressView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Login";
    
    [self stylingBackgroundView];
    [self stylingLoginButtons];
    [self stylingLabelDescription];
    [self stylingHyveLogoImageView];
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

#pragma mark - styling login buttons
-(void)stylingLoginButtons
{
    [self.emailButton setImage:[UIImage imageNamed:@"hyve"] forState:UIControlStateNormal];
    [self.googlePlusButton setImage:[UIImage imageNamed:@"g+"] forState:UIControlStateNormal];
    [self.loginFacebookButton setImage:[UIImage imageNamed:@"fb"] forState:UIControlStateNormal];
}

#pragma mark - styling background view
-(void)stylingBackgroundView
{
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundImageView.image = [UIImage imageNamed:@"loginBg"];
    [self.view addSubview:backgroundImageView];
}

#pragma mark - styling label description
-(void)stylingLabelDescription
{
    self.loginLabelDescription.text = @"Log into HYVE";
    self.loginLabelDescription.font = [UIFont fontWithName:@"OpenSans" size:22];
    self.loginLabelDescription.textColor = [UIColor whiteColor];
    self.loginLabelDescription.numberOfLines = 0;
}

#pragma mark - styling hyve logo imageview
-(void)stylingHyveLogoImageView
{
    self.hyveLogoImageView.image = [UIImage imageNamed:@"hyveLogo"];
    
    UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    interpolationHorizontal.minimumRelativeValue = @-40;
    interpolationHorizontal.maximumRelativeValue = @40;
    
    UIInterpolatingMotionEffect *interpolationVertical= [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    interpolationVertical.minimumRelativeValue = @-40;
    interpolationVertical.maximumRelativeValue = @40;
    
    [self.hyveLogoImageView addMotionEffect:interpolationHorizontal];
    [self.hyveLogoImageView addMotionEffect:interpolationVertical];
}

#pragma mark - styling KVNProgressView
-(void)settingProgressView
{
    self.loadingProgressView = [KVNProgressConfiguration defaultConfiguration];
    [KVNProgress setConfiguration:self.loadingProgressView];
    self.loadingProgressView.backgroundType = KVNProgressBackgroundTypeBlurred;
    self.loadingProgressView.fullScreen = YES;
    self.loadingProgressView.minimumDisplayTime = 1;
    
    [KVNProgress showWithStatus:@"Processing...Please hold..."];
}

#pragma mark - login with facebook
- (IBAction)onLoginWithFacebookButtonPressed:(id)sender
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    if (reachability.isReachable)
    {
        [self settingProgressView];
        [self loginWithFacebook];
        
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Internet connectivity unnavailable" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
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

            NSMutableDictionary *userInfoDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                       email,@"email",
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
            [KVNProgress dismiss];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Login Error. Please do check your Settings to enable Facebook login.\r Here's a guide: 1. Settings \r 2.Facebook \r 3. Log in Facebook within Settings \r 4.Check to see if Facebook app is enabled \r 5.Login Hyve via Facebook" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [KVNProgress showErrorWithStatus:@"Yikes! Sorry..."];
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

-(void)registerUserToHyve:(NSMutableDictionary*)userInfoDictionaryJSON
{
    NSString *hyveURLString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/user_sessions"];
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
            NSString *email = [responseObject valueForKeyPath:@"user_session.user.email"];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:api_token forKey:@"api_token"];
            [userDefaults setObject:email forKey:@"email"];
            [userDefaults synchronize];
            
            [KVNProgress showSuccessWithStatus:@"Welcome to Hyve!"];
            [self performSegueWithIdentifier:@"ShowDashboardVC" sender:nil];

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error %@ \r \r error localized:%@", error, [error localizedDescription]);
        [KVNProgress dismiss];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [KVNProgress showErrorWithStatus:@"Yikes! Sorry..."];
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

#pragma mark - google sign in
- (IBAction)onLoginWithGooglePlusButtonPressed:(id)sender
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    if (reachability.isReachable)
    {
        [self settingProgressView];
        [self loginWithGooglePlus];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Internet connectivity unnavailable" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)loginWithGooglePlus
{
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
                
//                NSLog(@"person display name: %@ \r person.aboutMe %@ \r birthday %@ \r gender: %@ \r familyName: %@ \r givenName %@ \r identifier %@ \r emails: %@", person.displayName, person.aboutMe, person.birthday, person.gender, person.name.familyName, person.name.givenName, person.identifier, [GPPSignIn sharedInstance].authentication.userEmail);
                
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
                                               imageURLString,@"avatar",nil];

                [self registerUserToHyve:userInfoDictionary];
            }
        }];
    }
}

#pragma mark - email login
- (IBAction)onEmailButtonPressed:(id)sender
{
    NSLog(@"email pressed");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *successLoginViaEmail = [userDefaults objectForKey:@"successLoginViaEmail"];
    
    if (successLoginViaEmail != nil)
    {
        [self performSegueWithIdentifier:@"ShowDashboardVC" sender:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"ShowSignUpVC" sender:nil];
    }

}

#pragma mark - first time check
-(void)checkingForFirstTimeUsers
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *checkingForFirstTime = [userDefaults objectForKey:@"firstTimeEnterApp"];
    if (checkingForFirstTime == nil)
    {
        [self performSegueWithIdentifier:@"ShowDashboardVC" sender:nil];
    }
}

#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDashboardVC"])
    {
        UINavigationController *navController = segue.destinationViewController;
        DashboardViewController *dvc = (DashboardViewController*)[navController topViewController];
    }
    
}

@end
