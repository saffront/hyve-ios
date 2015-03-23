//
//  SignUpViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/23/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "SignUpViewController.h"
#import <POP.h>

@interface SignUpViewController ()
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
}

#pragma mark - styling text field
-(void)stylingTextField:(UITextField*)registrationTextField
{
    
}


#pragma mark - register button
- (IBAction)onRegisterButtonPressed:(id)sender
{
    for (UIView *theView in self.view.subviews)
    {
        if ([theView isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField*)theView;
            
            if ([textField.text isEqualToString:@""])
            {
                POPSpringAnimation *shakeEmptyTextField = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
                shakeEmptyTextField.springBounciness = 20;
                shakeEmptyTextField.velocity = @(3000);
                shakeEmptyTextField.name = @"shake";
                
                [textField.layer pop_addAnimation:shakeEmptyTextField forKey:shakeEmptyTextField.name];
            }
        }
    }
}

#pragma mark - dismiss keyboard upon touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


@end
