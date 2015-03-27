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

@interface LoginViewController () <GPPSignInDelegate>

@property (strong, nonatomic) IBOutlet UIButton *loginFacebookButton;
@property (strong, nonatomic) Reachability *reachability;
@property (strong, nonatomic) IBOutlet UIButton *emailButton;
@property (strong, nonatomic) IBOutlet UIButton *googlePlusButton;
@property (strong, nonatomic) IBOutlet UILabel *loginLabelDescription;
@property (strong, nonatomic) IBOutlet UIImageView *hyveLogoImageView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkingForAPIToken];
    [self stylingBackgroundView];
    [self stylingLoginButtons];
    [self stylingLabelDescription];
    [self stylingHyveLogoImageView];

}

#pragma mark - viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}
//
//#pragma mark - viewWillDisappear
//-(void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = NO;
//}



#pragma mark - check for api
-(void)checkingForAPIToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *api_token = [userDefaults objectForKey:@"api_token"];
    
    if (api_token != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"ShowDashboardVC" sender:nil];
        });
    }
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
    self.loginLabelDescription.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:22];
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

#pragma mark - login with facebook
- (IBAction)onLoginWithFacebookButtonPressed:(id)sender
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    if (reachability.isReachable)
    {
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

            NSMutableDictionary *userInfoDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:email,@"email",uid,@"uid",provider,@"provider",first_name,@"first_name",last_name,@"last_name",usernameWithoutWhiteSpace ,@"username", nil];

            [self registerUserToHyve:userInfoDictionary];
            
        }
        else
        {
            NSLog(@"error with login %@", [error localizedDescription]);
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
    
    [manager POST:hyveURLString parameters:userInfoDictionaryJSON success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *api_token = [responseObject valueForKeyPath:@"api_token"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:api_token forKey:@"api_token"];
        [userDefaults synchronize];
        
        [self checkingForFirstTimeUsers];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error %@ \r \r error localized:%@", error, [error localizedDescription]);
    }];
}

#pragma mark - google sign in
- (IBAction)onLoginWithGooglePlusButtonPressed:(id)sender
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    if (reachability.isReachable)
    {
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
                NSString *provider = @"google";
                
                NSMutableDictionary *userInfoDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:email,@"email",uid,@"uid",provider,@"provider",first_name,@"first_name",last_name,@"last_name",usernameWithoutWhiteSpace ,@"username", nil];
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
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//        WalkthroughViewController *wvc = [storyboard instantiateViewControllerWithIdentifier:@"WalkthroughViewController"];
//        [self.navigationController presentViewController:wvc animated:YES completion:nil];
        
        [self performSegueWithIdentifier:@"ShowDashboardVC" sender:nil];
    }
    else
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
    else if ([segue.identifier isEqualToString:@"ShowWalkthrough"])
    {
        WalkthroughViewController *wvc = segue.destinationViewController;
    }
}

@end
