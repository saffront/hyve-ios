//
//  WalkthroughViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/20/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "WalkthroughViewController.h"
#import "FirstWalkthroughViewController.h"
#import "SecondWalkthroughViewController.h"
#import "ThirdWalkthroughViewController.h"
#import "FourthWalkthroughViewController.h"

@interface WalkthroughViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (assign, nonatomic) NSInteger currentIndex;
@end

@implementation WalkthroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundView.image = [UIImage imageNamed:@"walkthroughBg2"];
    [self.view addSubview:backgroundView];
    
    self.currentIndex = 0;
    
    [self stylingPageViewControllerIndicator];
    [self settingUpPageViewController];
    [self displayWalkthroughsInPageViewController];
}

#pragma mark - viewDidLayoutSubviews
-(void)viewDidLayoutSubviews
{
    self.pageViewController.view.frame = self.view.frame;
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
    pageControl.currentPageIndicatorTintColor = [UIColor yellowColor];
    
//    pageControl.backgroundColor = [UIColor clearColor];
}

#pragma mark - tracking index
-(UIViewController*)viewAtIndex:(NSUInteger)index
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *vc;
    
    switch (index) {
        case 0:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"FirstWalkthroughViewController"];
            break;
        case 1:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"SecondWalkthroughViewController"];
            break;
        case 2:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"ThirdWalkthroughViewController"];
            break;
        case 3:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"FourthWalkthroughViewController"];
            break;
        default:
            break;
    }
    return vc;
}

-(NSUInteger)indexAtView:(UIViewController*)view
{
    NSUInteger index = (int)nil;
    
    if ([view isKindOfClass:[FirstWalkthroughViewController class]])
    {
        index = 0;
    }
    else if ([view isKindOfClass:[SecondWalkthroughViewController class]])
    {
        index = 1;
    }
    else if ([view isKindOfClass:[ThirdWalkthroughViewController class]])
    {
        index = 2;
    }
    else if ([view isKindOfClass:[FourthWalkthroughViewController class]])
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
