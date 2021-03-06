//
//  FourthChildViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/27/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "FourthChildViewController.h"

@interface FourthChildViewController ()

@end

@implementation FourthChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];

    [self stylingTitleLabel];
    [self stylingDescriptionLabel];
}

#pragma mark - styling title label
-(void)stylingTitleLabel
{
    self.titleLabel.text = @"Connect";
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:30];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textColor = [UIColor colorWithRed:0.28 green:0.35 blue:0.40 alpha:1];
    
}

#pragma mark - styling description label
-(void)stylingDescriptionLabel
{
    self.descriptionLabel.text = @"Upon customizing your Hyves, connect them, and we'll handle the rest!";
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textColor = [UIColor colorWithRed:0.28 green:0.35 blue:0.40 alpha:1];
    self.descriptionLabel.font = [UIFont fontWithName:@"OpenSans" size:18];
    
}


@end
