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
    self.title = @"Register";
    
    [self stylingTextField:self.emailTextField];
    [self stylingTextField:self.lastNameTextField];
    [self stylingTextField:self.firstNameTextField];
    [self stylingTextField:self.passwordTextField];
}

#pragma mark - styling text field
-(void)stylingTextField:(UITextField*)registrationTextField
{
    registrationTextField.borderStyle = UITextBorderStyleNone;
    registrationTextField.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    registrationTextField.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    keyboardToolbar.barStyle = UIBarStyleDefault;
    keyboardToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonPressed)],
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                              [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)]
                              ];
    
    [keyboardToolbar sizeToFit];
    registrationTextField.inputAccessoryView = keyboardToolbar;
    
//    for (UIView *textFieldInView in self.view.subviews)
//    {
//        if ([textFieldInView isKindOfClass:[UITextField class]])
//        {
//            UITextField *registrationTextFields = (UITextField*)textFieldInView;
//            
//            registrationTextFields.borderStyle = UITextBorderStyleNone;
//            registrationTextFields.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
//            registrationTextFields.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
//        }
//    }
}

-(void)clearButtonPressed
{
    for (UIView *textFields in self.view.subviews)
    {
        if ([textFields isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField*)textFields;
            
            textField.text = @"";
        }
    }
}

-(void)doneButtonPressed
{
    for (UIView *textFields in self.view.subviews)
    {
        if ([textFields isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField*)textFields;
            
            [textField resignFirstResponder];
        }
    }
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
            else
            {
                NSString *username = [NSString stringWithFormat:@"%@ %@", self.lastNameTextField.text, self.firstNameTextField.text];
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
