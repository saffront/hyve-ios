//
//  FourthWalkthroughViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/20/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "FourthWalkthroughViewController.h"
#import "DashboardViewController.h"

@interface FourthWalkthroughViewController ()
@property (strong, nonatomic) IBOutlet UIButton *enterHyveAppButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation FourthWalkthroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self stylingBackgroundView];
    [self stylingEnterHyveAppButton];
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
    self.titleLabel.text = @"Welcome to HYVE";
    self.titleLabel.textColor = [UIColor colorWithRed:0.28 green:0.35 blue:0.40 alpha:1];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:30];
}

#pragma mark - styling description label
-(void)stylingDescriptionLabel
{
    self.descriptionLabel.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor";
    self.descriptionLabel.textColor = [UIColor colorWithRed:0.28 green:0.35 blue:0.40 alpha:1];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.font = [UIFont fontWithName:@"AvenirLTSTd-Medium" size:22];
}

#pragma mark - transition into app
- (IBAction)onEnterHyveAppButtonPressed:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"firstTimeEnterApp"])
    {
        NSString *firstTimeEnterApp = @"firstTimeEnterApp";
        [userDefaults setObject:firstTimeEnterApp forKey:@"firstTimeEnterApp"];
        [userDefaults synchronize];
    }
    else
    {
        [self performSegueWithIdentifier:@"ToDashboardVC" sender:nil];
    }
}

#pragma mark - styling hyve button
-(void)stylingEnterHyveAppButton
{
    [self.enterHyveAppButton setTitle:@"Let's Get Started!" forState:UIControlStateNormal];
    self.enterHyveAppButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:22];
    [self.enterHyveAppButton setBackgroundColor:[UIColor colorWithRed:0.96 green:0.46 blue:0.15 alpha:1]];
    [self.enterHyveAppButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}

#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToDashboardVC"])
    {
        UINavigationController *navController = segue.destinationViewController;
        DashboardViewController *dvc = (DashboardViewController*)[navController topViewController];
    }
}


@end
