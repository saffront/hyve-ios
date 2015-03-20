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

@end

@implementation FourthWalkthroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];

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
