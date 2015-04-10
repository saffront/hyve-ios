//
//  EmailLoginViewController.m
//  Hyve
//
//  Created by VLT Labs on 4/10/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "EmailLoginViewController.h"

@interface EmailLoginViewController() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *hyveImageLogo;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation EmailLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Login";
    [self stylingBackgroundView];
    [self settingUpHyveImageLogo];
    [self stylingTextField:self.emailTextField];
    [self stylingTextField:self.passwordTextField];
    [self stylingRegisterButton];
}

#pragma mark - setting up hyve image logo
-(void)settingUpHyveImageLogo
{
    UIImage *hyveImageLogo = [UIImage imageNamed:@"EmailLoginHyveLogo"];
    [self.hyveImageLogo setImage:hyveImageLogo];
    [self.hyveImageLogo setContentMode:UIViewContentModeScaleAspectFit];
    
    UIImage *animate5 = [UIImage imageNamed:@"animate5"];
    
    NSMutableArray *bluetoothIndicatorImage = [NSMutableArray arrayWithObjects:hyveImageLogo,animate5,nil];
    
    self.hyveImageLogo.animationImages = bluetoothIndicatorImage;
    self.hyveImageLogo.animationDuration = 3;
    [self.hyveImageLogo startAnimating];
}

#pragma mark - viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIImage *backButtonImage = [UIImage imageNamed:@"backButton"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 30, 30)];
    [backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButtonOnBar = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonOnBar;
    
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"OpenSans-SemiBold" size:17],
      NSFontAttributeName, nil]];
}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - styling background view
-(void)stylingBackgroundView
{
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundImageView.image = [UIImage imageNamed:@"loginBg"];
    [self.view addSubview:backgroundImageView];
}

#pragma mark - styling text fields
-(void)stylingTextField:(UITextField*)loginTextFields
{
    loginTextFields.delegate = self;
    loginTextFields.borderStyle = UITextBorderStyleNone;
    loginTextFields.backgroundColor = [UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:1];
    loginTextFields.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    loginTextFields.textColor = [UIColor blackColor];
    loginTextFields.font = [UIFont fontWithName:@"OpenSans" size:17];
    
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    keyboardToolbar.barStyle = UIBarStyleDefault;
    keyboardToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonPressed)],
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                              [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)]
                              ];
    
    [keyboardToolbar sizeToFit];
    loginTextFields.inputAccessoryView = keyboardToolbar;

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

#pragma mark - styling register button
-(void)stylingRegisterButton
{
    self.loginButton.backgroundColor = [UIColor colorWithRed:0.96 green:0.46 blue:0.15 alpha:1];
    [self.loginButton setTitle:@"LOGIN" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:20];
    
    [self settingPlaceholderTextFieldColor:self.emailTextField setPlaceholderText:@"Email"];
    [self settingPlaceholderTextFieldColor:self.passwordTextField setPlaceholderText:@"Password"];
}

-(void)settingPlaceholderTextFieldColor:(UITextField*)registrationTextField setPlaceholderText:(NSString*)placeholderText
{
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:placeholderText attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    registrationTextField.attributedPlaceholder = placeholder;
    
}

#pragma mark - text field delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.title = @"";
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 180, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.title = @"Login";
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 180, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

#pragma mark - touches began
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
