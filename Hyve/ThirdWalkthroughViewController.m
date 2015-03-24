//
//  ThirdWalkthroughViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/20/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "ThirdWalkthroughViewController.h"

@interface ThirdWalkthroughViewController ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation ThirdWalkthroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self stylingBackgroundView];
    [self stylingDescriptionLabel];
    [self stylingTitleLabel];
}

#pragma mark - styling background view
-(void)stylingBackgroundView
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundView.image = [UIImage imageNamed:@"walkthroughBg2"];
    [self.view addSubview:backgroundView];
}

#pragma mark - styling title label
-(void)stylingTitleLabel
{
    self.titleLabel.text = @"3. Connect";
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textColor = [UIColor colorWithRed:0.28 green:0.35 blue:0.40 alpha:1];
    self.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:30];
}

#pragma mark - styling description label
-(void)stylingDescriptionLabel
{
    self.descriptionLabel.text = @"";
    self.descriptionLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:22];
    self.descriptionLabel.textColor = [UIColor colorWithRed:0.28 green:0.35 blue:0.40 alpha:1];
    self.descriptionLabel.numberOfLines = 0;
}

@end
