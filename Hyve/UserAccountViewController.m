//
//  UserAccountViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/26/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "UserAccountViewController.h"
#import "User.h"
#import <Reachability.h>
#import <AFNetworking.h>
#import <DKCircleButton.h>
#import <POP.h>
#import "WalkthroughViewController.h"

@interface UserAccountViewController () <UIImagePickerControllerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet DKCircleButton *userAvatar;
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIButton *editOrSaveProfileButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) User *user;


@end

@implementation UserAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self stylingBackgroundView];
    [self connectToHyve];
    [self stylingUserAvatarButton];

    [self stylingEditOrSaveProfileButton];
    [self stylingBackButton];
    [self addingToolbarToKeyboard];
    [self stylingLogoutButton];
    
    self.username.userInteractionEnabled = NO;
    self.password.userInteractionEnabled = NO;
    self.email.userInteractionEnabled = NO;
    self.userAvatar.userInteractionEnabled = NO;
    [self.userAvatar setContentMode:UIViewContentModeScaleAspectFill];
    [self.userAvatar.imageView setContentMode:UIViewContentModeScaleAspectFill];
    self.password.delegate = self;
}

#pragma mark - connect to Hyve 
-(void)connectToHyve
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    if (reachability.isReachable)
    {
        [self retrieveUserAccountInfo];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)retrieveUserAccountInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *api_token = [userDefaults objectForKey:@"api_token"];
    
    NSString *hyveUserAccountString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/account"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:api_token forHTTPHeaderField:@"X-hyve-token"];
    
    [manager GET:hyveUserAccountString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"userAccount responseObject \r\r %@", responseObject);
        
        NSDictionary *user = [responseObject valueForKeyPath:@"user"];
        self.user = [User new];
        self.user.provider = [[user valueForKeyPath:@"authentications.provider"] objectAtIndex:0];
        self.user.avatarURL = [user valueForKeyPath:@"avatar.avatar.url"];
        self.user.email = [user valueForKeyPath:@"email"];
        self.user.username = [user valueForKeyPath:@"username"];
        self.user.password = [user valueForKeyPath:@"password"];
        self.user.avatarURLString = [user valueForKeyPath:@"avatar.avatar.url"];
        
        NSData *userAvatarURLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.user.avatarURLString]];
        UIImage *avatarImageFromHyve = [UIImage imageWithData:userAvatarURLData];
        
        if ([self.user.provider isEqualToString:@"facebook"] || [self.user.provider isEqualToString:@"google"])
        {
            self.password.alpha = 0;
        }
        else
        {
            [self stylingPasswordTextField:self.user];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stylingUsernameTextField:self.user];
            [self stylingEmailTextField:self.user];
            [self.userAvatar setImage:avatarImageFromHyve forState:UIControlStateNormal];
            
            NSLog(@"self.userAvatar.imageview.image connectToHyve: %@", self.userAvatar.imageView.image);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error %@ \r error localized description %@", error, [error localizedDescription]);
    }];
    
    
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
            NSLog(@"self.userAvatar.image didFinishPickingMedia %@", self.userAvatar.imageView.image);
            UIImageWriteToSavedPhotosAlbum(imageTakenByUser, nil, nil, nil);
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
-(void)stylingUsernameTextField:(User*)user
{
    self.username.text = user.username;
    self.username.backgroundColor = [UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:0.8];
    self.username.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    self.username.font = [UIFont fontWithName:@"OpenSans" size:18];
    self.username.textColor = [UIColor blackColor];

}

#pragma mark - styling email text field
-(void)stylingEmailTextField:(User*)user
{
    self.email.text = user.email;
    self.email.backgroundColor = [UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:0.8];
    self.email.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    self.email.font = [UIFont fontWithName:@"OpenSans" size:18];
    self.email.textColor = [UIColor blackColor];
}

#pragma mark - styling password text field
-(void)stylingPasswordTextField:(User*)user
{
    self.password.text = user.password;
    self.password.secureTextEntry = YES;
    self.password.backgroundColor = [UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:0.8];
    self.password.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    self.password.font = [UIFont fontWithName:@"OpenSans" size:18];
    self.password.textColor = [UIColor blackColor];
}

#pragma mark - styling editProfileButton
-(void)stylingEditOrSaveProfileButton
{
    self.editOrSaveProfileButton.backgroundColor = [UIColor colorWithRed:0.22 green:0.63 blue:0.80 alpha:1];
    self.editOrSaveProfileButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
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
        
//        NSString *email = [responseObject valueForKeyPath:@"info.email"];
//        NSString *uid = [responseObject valueForKeyPath:@"uid"];
//        NSString *provider = [responseObject valueForKeyPath:@"provider"];
//        NSString *first_name = [responseObject valueForKeyPath:@"info.first_name"];
//        NSString *last_name = [responseObject valueForKeyPath:@"extra.raw_info.last_name"];
//        NSString *username = [NSString stringWithFormat:@"%@ %@", first_name, last_name];
//        NSString *usernameWithoutWhiteSpace = [[username stringByReplacingOccurrencesOfString:@" " withString:@""]lowercaseString];
//        
//        NSMutableDictionary *userInfoDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:email,@"email",uid,@"uid",provider,@"provider",first_name,@"first_name",last_name,@"last_name",usernameWithoutWhiteSpace ,@"username", nil];
        
        NSString *email = self.email.text;
        NSString *username = self.username.text;
        NSString *password = self.password.text;
        UIImage *avatarImage = self.userAvatar.imageView.image;
        NSLog(@"avatarImage PATCH %@", self.userAvatar.imageView.image);
        
        NSString *avatarImageString = [UIImagePNGRepresentation(avatarImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSString *avatarImageStringInSixtyFour = [NSString stringWithFormat:@"data:image/png;base64, (%@)", avatarImageString];
        
        
        if ([self.user.provider isEqualToString:@"facebook"] || [self.user.provider isEqualToString:@"google"])
        {
            NSString *password = @"hello123";
            NSString *password_confirmation = @"hello123";
            
//            NSDictionary *savedInfoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:email,@"email",
//                                                        username,@"username",password,@"password",password_confirmation,@"password_confirmation",nil];
            
            NSDictionary *savedInfoDictionary = @{@"email": email,
                                                  @"password":password,
                                                  @"username": username,
                                                  @"password_confirmation": password_confirmation,
                                                  @"avatar":avatarImageStringInSixtyFour};
            
            NSDictionary *savedUserProfileInfoDictionary = @{@"user": savedInfoDictionary};
            NSDictionary *user = [[NSDictionary alloc] initWithDictionary:savedUserProfileInfoDictionary];
            
            [self updateProfileToHyve:savedUserProfileInfoDictionary];
            
        }
        else //email login
        {
            NSMutableDictionary *savedInfoDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:email,@"email",
                                                        username,@"username",
                                                        password,@"password",nil];
            
            [self updateProfileToHyve:savedInfoDictionary];
        }
    }
}


#pragma mark - logout button
-(void)stylingLogoutButton
{
    self.logoutButton.backgroundColor = [UIColor colorWithRed:0.22 green:0.63 blue:0.80 alpha:1];
    self.logoutButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    self.logoutButton.tintColor = [UIColor whiteColor];
    [self.logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
}

- (IBAction)onLogoutButtonPressed:(id)sender
{
    [self clearToken];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WalkthroughViewController *wvc = [storyboard instantiateViewControllerWithIdentifier:@"WalkthroughViewController"];
    [self presentViewController:wvc animated:YES completion:nil];
    
}


#pragma mark - update profile to Hyve
-(void)updateProfileToHyve:(NSDictionary*)savedUserProfileInfo
{
    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    if (reachability.isReachable)
    {
        [self savingUserProfileEditField:savedUserProfileInfo];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

-(void)savingUserProfileEditField:(NSDictionary*)savedUserInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *api_token = [userDefaults objectForKey:@"api_token"];
    
    NSString *hyveUserAccountString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/account"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:api_token forHTTPHeaderField:@"X-hyve-token"];
    
    [manager PATCH:hyveUserAccountString parameters:savedUserInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"PATCH UserInfo succesful : \r %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        NSLog(@"error in PATCH: \r %@", error);
        
    }];
}


-(void)clearToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:@"api_token"];
}

#pragma mark - styling back button
-(void)stylingBackButton
{
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:20];
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
