//
//  LoginViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/19/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "LoginViewController.h"
#import "DashboardViewController.h"
#import <SimpleAuth/SimpleAuth.h>

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UIButton *loginFacebookButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

#pragma mark - login with facebook
- (IBAction)onLoginWithFacebookButtonPressed:(id)sender
{
    [self loginWithFacebook];
}

-(void)loginWithFacebook
{
    [SimpleAuth authorize:@"facebook" completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            [self performSegueWithIdentifier:@"ShowDashboardVC" sender:nil];
            NSLog(@"responseObject from FB: \r%@", responseObject);
        }
        else
        {
            NSLog(@"error with login %@", [error localizedDescription]);
        }
    }];
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
