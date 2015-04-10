//
//  WalkthroughViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/20/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "DashboardViewController.h"
#import "WalkthroughViewController.h"
#import "FirstChildViewController.h"
#import "SecondChildViewController.h"
#import "ThirdChildViewController.h"
#import "FourthChildViewController.h"

@interface WalkthroughViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (assign, nonatomic) NSInteger currentIndex;
@property (strong, nonatomic) IBOutlet UIButton *signUp;
@property (strong, nonatomic) IBOutlet UIView *blurView;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) UIImageView *backgroundView;
@end

@implementation WalkthroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.blurView.alpha = 0;
    [self checkingForToken];
    
    self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.backgroundView.image = [UIImage imageNamed:@"walkthroughBg2"];
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.containerView];
    
    self.currentIndex = 0;
    
    [self stylingPageViewControllerIndicator];
    [self settingUpPageViewController];
    [self displayWalkthroughsInPageViewController];
    [self stylingSignUp];
    [self stylingLoginButton];

}

#pragma mark - checking for token
-(void)checkingForToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults objectForKey:@"api_token"];
    
    if (token != nil)
    {
        self.blurView.alpha = 1;
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame = CGRectMake(self.blurView.frame.origin.x, self.blurView.frame.origin.y, self.blurView.frame.size.width, self.blurView.frame.size.height);
        [self.blurView addSubview:visualEffectView];
        [self.view addSubview:self.blurView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"ToDashboardVCFromWalkthrough" sender:nil];
        });
    }
}

#pragma mark - viewDidLayoutSubviews
-(void)viewDidLayoutSubviews
{
    self.pageViewController.view.frame = self.containerView.frame;
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

#pragma mark - styling signUp button
-(void)stylingSignUp
{
    [self.signUp setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [self.signUp setBackgroundColor:[UIColor clearColor]];
    self.signUp.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:20];
    self.signUp.titleLabel.text = @"SIGN UP";
    self.signUp.layer.borderWidth = 1.0f;
    self.signUp.layer.borderColor = [UIColor clearColor].CGColor;
    [self.signUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signUp setBackgroundColor:[UIColor colorWithRed:0.22 green:0.63 blue:0.80 alpha:1]];
}

#pragma mark - styling login button
-(void)stylingLoginButton
{
    [self.loginButton setTitle:@"LOG IN" forState:UIControlStateNormal];
    self.loginButton.layer.borderWidth = 1.0f;
    self.loginButton.layer.borderColor = [UIColor clearColor].CGColor;
    [self.loginButton setBackgroundColor:[UIColor clearColor]];
    self.loginButton.titleLabel.text = @"LOG IN";
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:20];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton setBackgroundColor:[UIColor colorWithRed:0.89 green:0.39 blue:0.16 alpha:1]];
}


#pragma mark - setting up page view controller
-(void)settingUpPageViewController
{
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [self.pageViewController setDataSource:self];
    [self.pageViewController setDelegate:self];
}

#pragma mark - displaying child of page view controller
-(void)displayWalkthroughsInPageViewController
{
    [self.pageViewController setViewControllers:@[[self viewAtIndex:self.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.pageViewController];
    [self.pageViewController didMoveToParentViewController:self];
    [self.view addSubview:self.pageViewController.view];
}

#pragma mark - styling page view controller indicator
-(void)stylingPageViewControllerIndicator
{
    UIPageControl *pageControl = [UIPageControl appearanceWhenContainedIn:[UIPageViewController class], nil];
    pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1];

}

#pragma mark - tracking index
-(UIViewController*)viewAtIndex:(NSUInteger)index
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *vc;
    
    switch (index) {
        case 0:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"FirstChildViewController"];
            break;
        case 1:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"SecondChildViewController"];
            break;
        case 2:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"ThirdChildViewController"];

            break;
        case 3:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"FourthChildViewController"];

            break;
        default:
            break;
    }
    return vc;
}

-(NSUInteger)indexAtView:(UIViewController*)view
{
    NSUInteger index = (int)nil;
    
    if ([view isKindOfClass:[FirstChildViewController class]])
    {
        index = 0;
    }
    else if ([view isKindOfClass:[SecondChildViewController class]])
    {
        index = 1;
    }
    else if ([view isKindOfClass:[ThirdChildViewController class]])
    {
        index = 2;
    }
    else if ([view isKindOfClass:[FourthChildViewController class]])
    {
        index = 3;
    }
    return index;
}

#pragma mark - uipageviewcontroller data source
-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexAtView:viewController];
    
    if (index == 0)
    {
        return nil;
    }
    index--;
    return [self viewAtIndex:index];
}

-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexAtView:viewController];
    index++;
    
    if (index == 4)
    {
        return nil;
    }
    return [self viewAtIndex:index];
}

#pragma mark - uipageviewcontroller delegate method
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    UIViewController *currentView = [[_pageViewController viewControllers] objectAtIndex: 0];
    self.currentIndex = [self indexAtView:currentView];
}

//returns total number of dots displayed
-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 4;
}

//returns starting point of the dot
-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToDashboardVCFromWalkthrough"])
    {
        UINavigationController *navController = segue.destinationViewController;
        DashboardViewController *dvc = (DashboardViewController*)[navController topViewController];
    }
}


@end
