//
//  UserAccountViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/26/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "UserAccountViewController.h"
#import <DKCircleButton.h>
#import <POP.h>

@interface UserAccountViewController () <UIImagePickerControllerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet DKCircleButton *userAvatar;
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIButton *editOrSaveProfileButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;


@end

@implementation UserAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self stylingBackgroundView];
    [self stylingUserAvatarButton];
    [self stylingUsernameTextField];
    [self stylingEmailTextField];
    [self stylingPasswordTextField];
    [self stylingEditOrSaveProfileButton];
    [self stylingBackButton];
    [self addingToolbarToKeyboard];
    
    self.username.userInteractionEnabled = NO;
    self.password.userInteractionEnabled = NO;
    self.email.userInteractionEnabled = NO;
    self.userAvatar.userInteractionEnabled = NO;
    self.password.delegate = self;
    self.email.delegate = self;
}

#pragma mark - styling backgroundview
-(void)stylingBackgroundView
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundView.image = [UIImage imageNamed:@"appBg"];
    [self.view addSubview:backgroundView];
}

#pragma mark - user avatar
-(void)stylingUserAvatarButton
{
    [self.userAvatar setImage:[UIImage imageNamed:@"jlaw"] forState:UIControlStateNormal];
}

- (IBAction)onUserAvatarButtonPressed:(id)sender
{
    [self presentCamera];
}

-(void)presentCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePickerController = [UIImagePickerController new];
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.delegate = (id)self;
        
        self.imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
    else
    {
        NSLog(@"no camera found");
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *imageTakenByUser = [info valueForKey:UIImagePickerControllerOriginalImage];
        CGRect rect = CGRectMake(0, 0, 400, 400); //0,0,912,980
        
        UIGraphicsBeginImageContext(rect.size);
        [imageTakenByUser drawInRect:rect];
        UIImage *resizedImageTakenByUser = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userAvatar setImage:resizedImageTakenByUser forState:UIControlStateNormal];
        });
    });
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - adding toolbar to keyboard
-(void)addingToolbarToKeyboard
{
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    keyboardToolbar.barStyle = UIBarStyleDefault;
    keyboardToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonPressed)],
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                              [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)]
                              ];
    
    [keyboardToolbar sizeToFit];
    self.username.inputAccessoryView = keyboardToolbar;
    self.password.inputAccessoryView = keyboardToolbar;
    self.email.inputAccessoryView = keyboardToolbar;
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

#pragma mark - styling username text field
-(void)stylingUsernameTextField
{
    self.username.text = @"Jennifer Lawrence";
    self.username.backgroundColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:0.8];
    self.username.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    self.username.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:18];
    self.username.textColor = [UIColor whiteColor];
}

#pragma mark - styling email text field
-(void)stylingEmailTextField
{
    self.email.text = @"jlaw@gmail.com";
    self.email.backgroundColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:0.8];
    self.email.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    self.email.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:18];
    self.email.textColor = [UIColor whiteColor];
}

#pragma mark - styling password text field
-(void)stylingPasswordTextField
{
    self.password.text = @"Jennifer Lawrence";
    self.password.secureTextEntry = YES;
    self.password.backgroundColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:0.8];
    self.password.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    self.password.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:18];
    self.password.textColor = [UIColor whiteColor];
}

#pragma mark - styling editProfileButton
-(void)stylingEditOrSaveProfileButton
{
    self.editOrSaveProfileButton.backgroundColor = [UIColor colorWithRed:0.22 green:0.63 blue:0.80 alpha:1];
    self.editOrSaveProfileButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:18];
    self.editOrSaveProfileButton.tintColor = [UIColor whiteColor];
    [self.editOrSaveProfileButton setTitle:@"Edit" forState:UIControlStateNormal];
}

- (IBAction)onEditOrSaveProfileButtonPressed:(id)sender
{
    if ([self.editOrSaveProfileButton.titleLabel.text isEqualToString:@"Edit"])
    {
        [self assignCustomAnimationToUIElements];
        [self.editOrSaveProfileButton setTitle:@"Save" forState:UIControlStateNormal];
        self.username.userInteractionEnabled = YES;
        self.password.userInteractionEnabled = YES;
        self.email.userInteractionEnabled = YES;
        self.userAvatar.userInteractionEnabled = YES;
    }
    else if ([self.editOrSaveProfileButton.titleLabel.text isEqualToString:@"Save"])
    {
        //save to Hyve backend, api here
        [self.editOrSaveProfileButton setTitle:@"Edit" forState:UIControlStateNormal];
        [self.username resignFirstResponder];
        [self.email resignFirstResponder];
        [self.password resignFirstResponder];
        self.username.userInteractionEnabled = NO;
        self.password.userInteractionEnabled = NO;
        self.email.userInteractionEnabled = NO;
        self.userAvatar.userInteractionEnabled = NO;
    }
}

#pragma mark - styling back button
-(void)stylingBackButton
{
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backButton setBackgroundColor:[UIColor colorWithRed:0.89 green:0.39 blue:0.16 alpha:1]];
}

- (IBAction)onBackButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - touches began
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - custom animation
-(void)assignCustomAnimationToUIElements
{
    [self.userAvatar pop_removeAllAnimations];
    POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    springAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(10, 10)];
    springAnimation.springBounciness = 20.0f;
    [self.userAvatar pop_addAnimation:springAnimation forKey:@"sendAnimation"];
    
    [self shakeTextFieldWhenEdit:self.username];
    [self shakeTextFieldWhenEdit:self.email];
    [self shakeTextFieldWhenEdit:self.password];
    
}

-(void)shakeTextFieldWhenEdit:(UITextField*)textField
{
    [textField.layer pop_removeAllAnimations];
    POPSpringAnimation *shakeEmptyTextField = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    shakeEmptyTextField.springBounciness = 20;
    shakeEmptyTextField.velocity = @(2000);
    shakeEmptyTextField.name = @"shake";
    
    [textField.layer pop_addAnimation:shakeEmptyTextField forKey:shakeEmptyTextField.name];
}

#pragma mark - keyboard animation
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 120, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 120, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

@end
