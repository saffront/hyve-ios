//
//  DashboardViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/5/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "DashboardViewController.h"
#import <POP.h>

@interface DashboardViewController ()

@property (weak, nonatomic) IBOutlet UILabel *hyveLabel;
@property (weak, nonatomic) IBOutlet UIButton *hyveButton;
@property (weak, nonatomic) IBOutlet UIImageView *hyveNetworkDetectionIndicatorImage;
@property BOOL isHyveButtonPressed;
@end


@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.isHyveButtonPressed = NO;
    self.hyveNetworkDetectionIndicatorImage.alpha = 0;
    [self stylingHyveLabel];
}

#pragma mark - styling Hyve label
-(void)stylingHyveLabel
{
    self.hyveLabel.text = @"Hyve";
    self.hyveLabel.numberOfLines = 0;
    self.hyveLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:40];
    self.hyveLabel.textColor = [UIColor lightTextColor];
}


#pragma mark - pressing on Hyve button
- (IBAction)onHyveButtonPressed:(id)sender
{
    if (self.isHyveButtonPressed == NO)
    {
        [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CABasicAnimation *slideDownAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            [slideDownAnimation setDelegate:self];
            slideDownAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(self.view.frame.size.width / 2, self.hyveButton.frame.origin.y + 400, self.hyveButton.frame.size.width, self.hyveButton.frame.size.height)];
            slideDownAnimation.fromValue = [NSValue valueWithCGPoint:self.hyveButton.layer.position];
            slideDownAnimation.autoreverses = NO;
            slideDownAnimation.repeatCount = 0;
            slideDownAnimation.duration = 2;
            slideDownAnimation.fillMode = kCAFillModeForwards;
            slideDownAnimation.removedOnCompletion = NO;
            slideDownAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [self.hyveButton.layer addAnimation:slideDownAnimation forKey:@"moveY"];
            
        } completion:^(BOOL finished) {
            
            [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(displayBluetoothNetworkDetectionIndicator) userInfo:nil repeats:NO];
        }];
    }
}

#pragma mark - displaying Bluetooth network detection indicator
-(void)displayBluetoothNetworkDetectionIndicator
{
    self.hyveNetworkDetectionIndicatorImage.alpha = 1;
    
    UIImage *bluetooth1 = [UIImage imageNamed:@"bluetooth1"];
    UIImage *bluetooth2 = [UIImage imageNamed:@"bluetooth2"];
    UIImage *bluetooth3 = [UIImage imageNamed:@"bluetooth3"];
    
    NSMutableArray *bluetoothIndicatorImage = [NSMutableArray arrayWithObjects:bluetooth1, bluetooth2, bluetooth3, nil];
    
    self.hyveNetworkDetectionIndicatorImage.animationImages = bluetoothIndicatorImage;
    self.hyveNetworkDetectionIndicatorImage.animationDuration = 2;
    self.hyveNetworkDetectionIndicatorImage.backgroundColor = [UIColor clearColor];
    [self.hyveNetworkDetectionIndicatorImage startAnimating];
    
//    self.hyveNetworkDetectionIndicatorImage.alpha = 1;
//    self.hyveNetworkDetectionIndicatorImage.image = [UIImage imageNamed:@"jlaw"];
//    
//    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeAnimation.duration = 1.3;
//    fadeAnimation.repeatCount = 1e1000f;
//    fadeAnimation.autoreverses = YES;
//    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
//    fadeAnimation.toValue = [NSNumber numberWithFloat:0.1];
//    
//    [self.hyveNetworkDetectionIndicatorImage.layer addAnimation:fadeAnimation forKey:@"animateOpacity"];
}

@end
