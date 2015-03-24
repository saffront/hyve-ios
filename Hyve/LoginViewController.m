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
    
    [self stylingBackgroundView];
    [self stylingLoginButtons];
    [self stylingLabelDescription];
    [self stylingHyveLogoImageView];
}


#pragma mark - viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - viewWillDisappear
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
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
            [self checkingForFirstTimeUsers];
            NSLog(@"responseObject from FB: \r%@", responseObject);
            
            NSString *email = [responseObject valueForKeyPath:@"info.email"];
            NSString *uid = [responseObject valueForKeyPath:@"uid"];
            NSString *provider = [responseObject valueForKeyPath:@"provider"];
            NSString *first_name = [responseObject valueForKeyPath:@"info.first_name"];
            NSString *last_name = [responseObject valueForKeyPath:@"extra.raw_info.last_name"];
//            NSString *image = [responseObject valueForKeyPath:@"info.image"];
           
            NSString *username = [NSString stringWithFormat:@"%@ %@", first_name, last_name];
            NSString *usernameWithoutWhiteSpace = [[username stringByReplacingOccurrencesOfString:@" " withString:@""]lowercaseString];

            NSMutableDictionary *userInfoDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:email,@"email",uid,@"uid",provider,@"provider",first_name,@"first_name",last_name,@"last_name",usernameWithoutWhiteSpace ,@"username", nil];
            NSData *userInfoDictionaryJSON = [NSJSONSerialization dataWithJSONObject:userInfoDictionary options:NSJSONWritingPrettyPrinted error:nil];
            [self registerUserToHyve:userInfoDictionary];
            
//            NSLog(@"email %@ \r uid %@ \r provider %@ \r first_name %@ \r last_name %@ \r image %@", email, uid, provider, first_name, last_name, image);
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
//    NSMutableURLRequest *hyveURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:hyveURLString]];
//    [hyveURLRequest setHTTPMethod:@"POST"];
//    [hyveURLRequest setHTTPBody:userInfoDictionaryJSON];
//    [hyveURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [hyveURLRequest setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//    
//    [NSURLConnection sendAsynchronousRequest:hyveURLRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//       
//        if (connectionError)
//        {
//            NSLog(@"connectionError %@", connectionError);
//        }
//        else
//        {
//            NSLog(@"response %@",response);
//        }
//    }];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:@"http://hyve-staging.herokuapp.com/api/v1/user_sessions" parameters:userInfoDictionaryJSON success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"responseObject %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error %@ \r \r error localized:%@", error, [error localizedDescription]);
    }];
    
//    NSString *pathURL = @"api/v1/user_sessions";
//    
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:hyveURLString]];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//
//    
//    [manager POST:pathURL parameters:userInfoDictionaryJSON success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"responseObject : %@", responseObject);
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"error %@ \r\r error localized: %@", error, [error localizedDescription]);
//    }];
    
//    NSURL *hyveURL = [NSURL URLWithString:hyveURLString];
//    NSURLRequest *hyveURLRequest = [NSURLRequest requestWithURL:hyveURL];
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [manager.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
//    [manager POST:hyveURLString parameters:userInfoDictionaryJSON success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"responseObject %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error: %@ %@", [error localizedDescription], error);
//    }];
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
                
                NSLog(@"person display name: %@ \r person.aboutMe %@ \r birthday %@ \r gender: %@ \r familyName: %@ \r givenName %@ \r identifier %@", person.displayName, person.aboutMe, person.birthday, person.gender, person.name.familyName, person.name.givenName, person.identifier);
                
                [self checkingForFirstTimeUsers];
            }
        }];
    }
}

#pragma mark - email login
- (IBAction)onEmailButtonPressed:(id)sender
{
    NSLog(@"email pressed");
    [self performSegueWithIdentifier:@"ShowSignUpVC" sender:nil];
}

#pragma mark - first time check
-(void)checkingForFirstTimeUsers
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *checkingForFirstTime = [userDefaults objectForKey:@"firstTimeEnterApp"];
    if (checkingForFirstTime == nil)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        WalkthroughViewController *wvc = [storyboard instantiateViewControllerWithIdentifier:@"WalkthroughViewController"];
        [self.navigationController presentViewController:wvc animated:YES completion:nil];
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
