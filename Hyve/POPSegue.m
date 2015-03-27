//
//  POPSegue.m
//  Hyve
//
//  Created by VLT Labs on 3/27/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "POPSegue.h"
#import <POP.h>

@implementation POPSegue

//method to override -perform
-(void)perform
{
    UIViewController *sourceVC = (UIViewController*)[self sourceViewController];
    UIViewController *destinationVC = (UIViewController*)[self destinationViewController];
    
    CALayer *layer = destinationVC.view.layer;
    [layer pop_removeAllAnimations];
    
    POPSpringAnimation *positionXAnimation = [POPSpringAnimation animationWithPropertyNamed:@"kPOPLayerPositionX"];
    positionXAnimation.fromValue = @(320);
    positionXAnimation.springBounciness = 16;
    positionXAnimation.springSpeed = 10;
    positionXAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished){
        NSLog(@"Finished animating POPSegue");
    };
    
    POPSpringAnimation *sizeAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerSize];
    sizeAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(64, 114)];
    
    [layer pop_addAnimation:positionXAnimation forKey:@"position"];
    [layer pop_addAnimation:sizeAnimation forKey:@"size"];
    
    [sourceVC.navigationController presentViewController:destinationVC animated:NO completion:nil];
}

@end
