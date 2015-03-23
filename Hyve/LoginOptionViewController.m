//
//  LoginOptionViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/23/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "LoginOptionViewController.h"

@interface LoginOptionViewController ()

@end

@implementation LoginOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];

}

- (IBAction)onLoginWithFacebookButtonPressed:(id)sender
{
    NSLog(@"FB login pressed");
}

- (IBAction)onLoginWithGooglePlus:(id)sender
{
    NSLog(@"google plus login pressed");
}

- (IBAction)onLoginWithHyveButtonPressed:(id)sender
{
    NSLog(@"hyve login pressed");
}

@end
