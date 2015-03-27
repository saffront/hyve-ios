//
//  WalkthroughViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/20/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

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
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@end

@implementation WalkthroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkingForToken];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundView.image = [UIImage imageNamed:@"walkthroughBg2"];
    [self.view addSubview:backgroundView];
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
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        WalkthroughViewController *wvc = [storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
        [self.navigationController presentViewController:wvc animated:YES completion:nil];
        [self performSegueWithIdentifier:@"ToDashboardVC" sender:nil];
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
    self.signUp.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
    self.signUp.titleLabel.text = @"SIGN UP";
    self.signUp.layer.borderWidth = 1.0f;
    self.signUp.layer.borderColor = [UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1].CGColor;
    [self.signUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signUp setBackgroundColor:[UIColor colorWithRed:0.22 green:0.63 blue:0.80 alpha:1]];
}

#pragma mark - styling login button
-(void)stylingLoginButton
{
    [self.loginButton setTitle:@"LOG IN" forState:UIControlStateNormal];
    self.loginButton.layer.borderWidth = 1.0f;
    self.loginButton.layer.borderColor = [UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1].CGColor;
    [self.loginButton setBackgroundColor:[UIColor clearColor]];
    self.loginButton.titleLabel.text = @"LOG IN";
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
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
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1];

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




@end
