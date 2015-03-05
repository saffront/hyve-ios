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

-(void)stylingHyveLabel
{
    self.hyveLabel.text = @"Hyve";
    self.hyveLabel.numberOfLines = 0;
    self.hyveLabel.font = [UIFont fontWithName:@"Helvetica" size:40];
    self.hyveLabel.textColor = [UIColor lightTextColor];
}

- (IBAction)onHyveButtonPressed:(id)sender
{
    if (self.isHyveButtonPressed == NO)
    {
//        POPBasicAnimation *fadingAnimation = [POPBasicAnimation animationWithPropertyNamed:@"kPOPViewAlpha"];
//        fadingAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        fadingAnimation.fromValue = @(1.0);
//        fadingAnimation.toValue = @(0.1);
//        [self.hyveNetworkDetectionIndicatorImage.layer pop_addAnimation:fadingAnimation forKey:@"fade"];
        
        POPDecayAnimation *decayAnimation = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerPositionY];
        decayAnimation.velocity = @(650);
        [self.hyveButton.layer pop_addAnimation:decayAnimation forKey:@"slide"];
        
        self.isHyveButtonPressed = YES;
        
        self.hyveNetworkDetectionIndicatorImage.image = [UIImage imageNamed:@"jlaw"];
        
        CABasicAnimation *fadingAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadingAnimation.duration = 2;
        fadingAnimation.repeatCount = 1e100f;
        fadingAnimation.autoreverses = YES;
        fadingAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        fadingAnimation.toValue = [NSNumber numberWithFloat:0.1];
        [self.hyveNetworkDetectionIndicatorImage.layer addAnimation:fadingAnimation forKey:@"animateOpacity"];
        self.hyveNetworkDetectionIndicatorImage.alpha = 1;
    }
}


@end
