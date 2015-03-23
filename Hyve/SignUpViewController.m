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
@property (strong, nonatomic) IBOutlet UILabel *registrationOptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UIButton *googlePlusButton;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Register";
    
    [self assigningStyleToTextFields];
    [self stylingBackgroundView];
    [self stylingRegisterButton];
    [self stylingRegistrationOptionLabel];
    [self stylingFacebookButton];
    [self stylingGooglePlusButton];
}

#pragma mark - styling registration option label
-(void)stylingRegistrationOptionLabel
{
    self.registrationOptionLabel.text = @"Or Register Via";
    self.registrationOptionLabel.textColor = [UIColor whiteColor];
    self.registrationOptionLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
    self.registrationOptionLabel.numberOfLines = 0;
}

#pragma mark - styling register button
-(void)stylingRegisterButton
{
    self.registerButton.backgroundColor = [UIColor colorWithRed:0.96 green:0.46 blue:0.15 alpha:1];
    [self.registerButton setTitle:@"Register" forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.registerButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
}

#pragma mark - styling background view
-(void)stylingBackgroundView
{
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundImage.image = [UIImage imageNamed:@"loginBg"];
    [self.view addSubview:backgroundImage];
}

#pragma mark - assigning styling to text field
-(void)assigningStyleToTextFields
{
    [self stylingTextField:self.emailTextField];
    [self stylingTextField:self.lastNameTextField];
    [self stylingTextField:self.firstNameTextField];
    [self stylingTextField:self.passwordTextField];
    
    [self settingPlaceholderTextFieldColor:self.emailTextField setPlaceholderText:@"Email"];
    [self settingPlaceholderTextFieldColor:self.lastNameTextField setPlaceholderText:@"Last Name"];
    [self settingPlaceholderTextFieldColor:self.firstNameTextField setPlaceholderText:@"First Name"];
    [self settingPlaceholderTextFieldColor:self.passwordTextField setPlaceholderText:@"Password"];
}

#pragma mark - styling text field
-(void)stylingTextField:(UITextField*)registrationTextField
{
    registrationTextField.borderStyle = UITextBorderStyleNone;
    registrationTextField.backgroundColor = [UIColor colorWithRed:0.77 green:0.77 blue:0.77 alpha:1];
    registrationTextField.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    registrationTextField.textColor = [UIColor blackColor];
    registrationTextField.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:17];
    
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    keyboardToolbar.barStyle = UIBarStyleDefault;
    keyboardToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonPressed)],
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                              [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)]
                              ];
    
    [keyboardToolbar sizeToFit];
    registrationTextField.inputAccessoryView = keyboardToolbar;

}

-(void)settingPlaceholderTextFieldColor:(UITextField*)registrationTextField setPlaceholderText:(NSString*)placeholderText
{
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:placeholderText attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    registrationTextField.attributedPlaceholder = placeholder;

}

-(void)clearButtonPressed
{
    for (UIView *textFields in self.view.subviews)
    {
        if ([textFields isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField*)textFields;

            if (textField.isEditing)
            {
                textField.text = @"";
            }
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

#pragma mark - social media button
- (IBAction)onFacebookButtonPressed:(id)sender
{
    NSLog(@"facebook button is pressed");
}

-(void)stylingFacebookButton
{
    [self.facebookButton setImage:[UIImage imageNamed:@"fb"] forState:UIControlStateNormal];
}

- (IBAction)onGooglePlusButtonPressed:(id)sender
{
    NSLog(@"g+ button is pressed");
}

-(void)stylingGooglePlusButton
{
    [self.googlePlusButton setImage:[UIImage imageNamed:@"g+"] forState:UIControlStateNormal];
}

#pragma mark - dismiss keyboard upon touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


@end
