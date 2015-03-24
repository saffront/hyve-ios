//
//  SecondWalkthroughViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/20/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "SecondWalkthroughViewController.h"

@interface SecondWalkthroughViewController ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation SecondWalkthroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self stylingBackgroundView];
    [self stylingTitleLabel];
    [self stylingDescriptionLabel];
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
    self.titleLabel.text = @"2. Pair";
    self.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:30];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textColor = [UIColor colorWithRed:0.28 green:0.35 blue:0.40 alpha:1];
}

#pragma mark - styling description label
-(void)stylingDescriptionLabel
{
    self.descriptionLabel.text = @"By pairing, HYVE will be able to identify your ownership to the device";
    self.descriptionLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:22];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textColor = [UIColor colorWithRed:0.28 green:0.35 blue:0.40 alpha:1];
}



@end
