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

@end

@implementation FourthWalkthroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self stylingBackgroundView];
    [self stylingEnterHyveAppButton];
    [self stylingTitleLabel];
}

#pragma mark - styling background view
-(void)stylingBackgroundView
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundView.image = [UIImage imageNamed:@"jlaw"];
    [self.view addSubview:backgroundView];
}

#pragma mark - styling title label
-(void)stylingTitleLabel
{
    self.titleLabel.text = @"";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:30];
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
    [self.enterHyveAppButton setTitle:@"Enter HYVE" forState:UIControlStateNormal];
    self.enterHyveAppButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:22];
    
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
