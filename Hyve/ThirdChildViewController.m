//
//  ThirdChildViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/27/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "ThirdChildViewController.h"

@interface ThirdChildViewController ()

@end

@implementation ThirdChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];

    [self stylingTitleLabel];
    [self stylingDescriptionLabel];
}

#pragma mark - styling title label
-(void)stylingTitleLabel
{
    self.titleLabel.text = @"Pair";
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:30];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textColor = [UIColor colorWithRed:0.28 green:0.35 blue:0.40 alpha:1];
    
}

#pragma mark - styling description label
-(void)stylingDescriptionLabel
{
    self.descriptionLabel.text = @"With the discovered Hyves listed, associate your Hyves by tapping on the pair button";
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textColor = [UIColor colorWithRed:0.28 green:0.35 blue:0.40 alpha:1];
    self.descriptionLabel.font = [UIFont fontWithName:@"OpenSans" size:18];
    
}


@end
