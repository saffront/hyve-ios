//
//  HyveDetailsViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/9/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#define kAWS_ACCESS_KEY @"AKIAJSSBZVG65WCQVB5A"
#define kAWS_BUCKET @"hyveplus-staging"
#define kAWS_SECRET_ACCESS_KEY @"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"

#import "HyveDetailsViewController.h"
#import <AWSS3.h>
#import <AFNetworking.h>
#import <Reachability.h>
#import <CNPGridMenu.h>
#import <DKCircleButton.h>
#import <POP.h>
#import <KVNProgress.h>

@interface HyveDetailsViewController () <UIImagePickerControllerDelegate, CNPGridMenuDelegate, CBPeripheralDelegate, CBCentralManagerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet DKCircleButton *hyveImageButton;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UITextField *hyveNameTextField;
@property (strong, nonatomic) UIImage *resizedImage;
@property (strong, nonatomic) NSArray *valuesOfDistanceSlider;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) CNPGridMenu *gridMenu;
@property (strong, nonatomic) NSString *distanceNumber;
@property (strong, nonatomic) NSMutableData *distanceNumberData;
@property (strong, nonatomic) IBOutlet UIButton *hyveDistanceButton;
@property (strong, nonatomic) IBOutlet UIButton *settingHyveImageButton;
@property (strong, nonatomic) NSNumber *ninthTime;
@property BOOL takePictureButtonDidPressed;
@property BOOL setPresetIconButtonDidPressed;
@property (strong, nonatomic) NSString *hyveDistance;
@property (strong, nonatomic) AWSS3PutObjectRequest *por;
@property (strong, nonatomic) AWSS3 *s3;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong, nonatomic) NSURLSession *session;
@property (nonatomic) KVNProgressConfiguration *loadingProgressView;

@end

@implementation HyveDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hyveNameTextField.userInteractionEnabled = NO;
    
    [self.hyveImageButton setImage:[UIImage imageNamed:@"defaultHyveImage"] forState:UIControlStateNormal];
    self.takePictureButtonDidPressed = NO;
    self.setPresetIconButtonDidPressed = NO;
    
    self.distanceNumberData = [NSMutableData new];

    self.centralManager.delegate = self;
    self.hyveNameTextField.text = self.peripheral.name;
    self.hyveNameTextField.delegate = self;
    self.title = self.peripheral.name;
    
    [self stylingBackgroundView];
    [self addToolbarToKeyboard];
    [self stylingTextField];
    [self stylingHyveDistanceButton];
    [self stylingConnectButton];
    [self retrieveHyveImageFromServer];
    [self stylingSettingHyveImageButton];
    
    NSString *uuid = [self.peripheral.identifier UUIDString];
    NSLog(@"self.peripheral %@", uuid);
    
    if (self.peripheral.name == nil)
    {
        self.hyveNameTextField.placeholder = @"Unkown Device";
    }
    
    [self connected];
}

#pragma mark - connected
-(BOOL)connected
{
    __block BOOL reachable;
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
            {
                NSLog(@"not reachable");
                reachable = NO;
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Internet unavailable. Please connect to the Internet" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:okAction];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alertController animated:YES completion:nil];
                });
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                NSLog(@"reachable with wifi");
                reachable = YES;
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                NSLog(@"reachable via WWAN");
                reachable = YES;
                break;
            }
            default:
            {
                NSLog(@"Unkown internet status");
                reachable = NO;
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Internet unavailable. Please connect to the Internet" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:okAction];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alertController animated:YES completion:nil];
                });
                break;
            }
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    return reachable;
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
      [UIFont fontWithName:@"OpenSans-SemiBold" size:21],
      NSFontAttributeName, nil]];
    
    [self settingUpLoadingProgressView];
}

#pragma mark - setting up loading progress view
-(void)settingUpLoadingProgressView
{
    self.loadingProgressView = [KVNProgressConfiguration defaultConfiguration];
    [KVNProgress setConfiguration:self.loadingProgressView];
    self.loadingProgressView.backgroundType = KVNProgressBackgroundTypeBlurred;
    self.loadingProgressView.fullScreen = YES;
    self.loadingProgressView.minimumDisplayTime = 1;
    [KVNProgress showWithStatus:@"Loading..."];
}

#pragma mark - retrieve hyve image from server
-(void)retrieveHyveImageFromServer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *api_token = [userDefaults objectForKey:@"api_token"];
    
    NSString *hyveURLString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/hyves/%@",[self.peripheral.identifier UUIDString]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:api_token forHTTPHeaderField:@"X-hyve-token"];
    [manager.requestSerializer setTimeoutInterval:20];
    
    [manager GET:hyveURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"responseObject retrieveImageFromServer: \r\r %@", responseObject);
        Hyve *hyve = [Hyve new];
        hyve.imageURLString = [responseObject valueForKeyPath:@"hyve.image.image.url"];
        
        [self stylingHyveImageButton:hyve];

    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [KVNProgress dismiss];
        NSLog(@"error with retrieveUserInfoAndPairedHyve: \r\r %@ \r localizedDescription: \r %@", error, [error localizedDescription]);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity. Unable to update Hyve Image." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }];

}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - styling background view
-(void)stylingBackgroundView
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundView.image = [UIImage imageNamed:@"appBg"];
    [self.view addSubview:backgroundView];
}

#pragma mark - styling text field
-(void)stylingTextField
{
    self.hyveNameTextField.backgroundColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:0.8];
    self.hyveNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    self.hyveNameTextField.font = [UIFont fontWithName:@"OpenSans" size:18];
    self.hyveNameTextField.textAlignment = NSTextAlignmentNatural;

}

#pragma mark - styling hyve image button
-(void)stylingHyveImageButton:(Hyve*)hyve
{
    if (![hyve isKindOfClass:[NSNull class]])
    {
        if (hyve.imageURLString == nil || [hyve.imageURLString isEqual:[NSNull null]])
        {
            UIImage *hyveImage = [UIImage imageNamed:@"defaultHyveImage"];
            
            self.hyveImageButton.borderColor = [UIColor whiteColor];
            self.hyveImageButton.borderSize = 2.0f;
            [self.hyveImageButton setImage:hyveImage forState:UIControlStateNormal];
            [self.hyveImageButton setTitle:@"" forState:UIControlStateNormal];
        }
        else
        {
            NSURL *urlImageString = [NSURL URLWithString:hyve.imageURLString];
            NSData *hyveImageData = [NSData dataWithContentsOfURL:urlImageString];
            UIImage *hyveImage = [UIImage imageWithData:hyveImageData];
            
            self.hyveImageButton.borderColor = [UIColor whiteColor];
            self.hyveImageButton.borderSize = 2.0f;
            self.hyveImageButton.clipsToBounds = YES;
            [self.hyveImageButton setImage:hyveImage forState:UIControlStateNormal];
            [self.hyveImageButton setTitle:@"" forState:UIControlStateNormal];
        }
    }
    else
    {
        UIImage *defaultHyveImage = [UIImage imageNamed:@"defaultHyveImage"];
        self.hyveImageButton.borderColor = [UIColor whiteColor];
        self.hyveImageButton.borderSize = 2.0f;
        [self.hyveImageButton setImage:defaultHyveImage forState:UIControlStateNormal];
        [self.hyveImageButton setTitle:@"" forState:UIControlStateNormal];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.loadingProgressView.minimumSuccessDisplayTime = 1.5;
    [KVNProgress showSuccessWithStatus:@"Found Hyve!"];

}

-(void)takeAPictureForHyveImage
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

-(void)usePresetIconForHyveImage
{
    //backpack, laptop, house key, car key, bag, briefcase, tablet, mobile phone, wallet, remote control,
    
    CNPGridMenuItem *backpack = [CNPGridMenuItem new];
    backpack.icon = [UIImage imageNamed:@"bagpack"];
    backpack.title = @"Backpack";
    
    CNPGridMenuItem *laptop = [CNPGridMenuItem new];
    laptop.icon = [UIImage imageNamed:@"macbook"];
    laptop.title = @"Laptop";
    
    CNPGridMenuItem *houseKey = [CNPGridMenuItem new];
    houseKey.icon = [UIImage imageNamed:@"houseKeys"];
    houseKey.title = @"House Key";
    
    CNPGridMenuItem *carKey = [CNPGridMenuItem new];
    carKey.icon = [UIImage imageNamed:@"carKeys"];
    carKey.title = @"Car Key";
    
    CNPGridMenuItem *bag = [CNPGridMenuItem new];
    bag.icon = [UIImage imageNamed:@"handbag"];
    bag.title = @"Bag";
    
    CNPGridMenuItem *briefcase = [CNPGridMenuItem new];
    briefcase.icon = [UIImage imageNamed:@"briefcase"];
    briefcase.title = @"Briefcase";
    
    CNPGridMenuItem *tablet = [CNPGridMenuItem new];
    tablet.icon = [UIImage imageNamed:@"tablet"];
    tablet.title = @"Backpack";
    
    CNPGridMenuItem *wallet = [CNPGridMenuItem new];
    wallet.icon = [UIImage imageNamed:@"wallet"];
    wallet.title = @"Wallet";
    
    CNPGridMenuItem *remoteControl = [CNPGridMenuItem new];
    remoteControl.icon = [UIImage imageNamed:@"remote"];
    remoteControl.title = @"Remote Control";
    
    self.gridMenu = [[CNPGridMenu alloc] initWithMenuItems:@[backpack, laptop, houseKey,carKey, bag, briefcase, tablet, wallet, remoteControl]];
    self.gridMenu.delegate = self;
    self.gridMenu.blurEffectStyle = UIBlurEffectStyleDark;
    [self presentGridMenu:self.gridMenu animated:YES completion:^{
        NSLog(@"display grid menu");
    }];
}

#pragma mark - camera for take a picture
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *imageTakenByUser = [info valueForKey:UIImagePickerControllerOriginalImage];
        CGRect rect = CGRectMake(0, 0, 580, 580);
        
        UIGraphicsBeginImageContext(rect.size);
        [imageTakenByUser drawInRect:rect];
        UIImage *resizedImageTakenByUser = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resizedImage = resizedImageTakenByUser;
            POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
            springAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(10, 10)];
            springAnimation.springBounciness = 20.0f;
            [self.hyveImageButton pop_addAnimation:springAnimation forKey:@"sendAnimation"];
            
            [self.hyveImageButton setImage:self.resizedImage forState:UIControlStateNormal];
            [self.hyveImageButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
            [self.hyveImageButton setContentMode:UIViewContentModeScaleAspectFill];
            self.hyveImageButton.imageView.clipsToBounds = YES;
            [self.hyveImageButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
            [self.hyveImageButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
            
            self.takePictureButtonDidPressed = YES;
            self.loadingProgressView.minimumSuccessDisplayTime = 1.5;
            [KVNProgress showSuccessWithStatus:@"Image taken!"];

        });
    });
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Cancel image picker was called");
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - hyve distance
-(void)stylingHyveDistanceButton
{
    self.hyveDistanceButton.backgroundColor = [UIColor colorWithRed:0.22 green:0.63 blue:0.80 alpha:1];
    self.hyveDistanceButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    self.hyveDistanceButton.tintColor = [UIColor whiteColor];
    self.hyveDistanceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.hyveDistanceButton setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [self.hyveDistanceButton setTitle:@"Set Proximity" forState:UIControlStateNormal];

}

- (IBAction)onHyveDistanceButtonPressed:(id)sender
{
    CNPGridMenuItem *one = [CNPGridMenuItem new];
    one.title = [NSString stringWithFormat:@"One \r meter"];
    one.icon = [UIImage imageNamed:@"one"];
    
    CNPGridMenuItem *two = [CNPGridMenuItem new];
    two.icon = [UIImage imageNamed:@"two"];
    two.title = [NSString stringWithFormat:@"Two \r meters"];
    
    CNPGridMenuItem *four = [CNPGridMenuItem new];
    four.title = [NSString stringWithFormat:@"Four \r meters"];
    four.icon = [UIImage imageNamed:@"four"];
    
    CNPGridMenuItem *eight = [CNPGridMenuItem new];
    eight.title = [NSString stringWithFormat:@"Eight \r meters"];
    eight.icon = [UIImage imageNamed:@"theEight"];
  
    CNPGridMenuItem *sixteen = [CNPGridMenuItem new];
    sixteen.title = [NSString stringWithFormat:@"Sixteen \r meters"];
    sixteen.icon = [UIImage imageNamed:@"sixteen"];
    
    self.gridMenu = [[CNPGridMenu alloc] initWithMenuItems:@[one,two,four,eight,sixteen]];
    self.gridMenu.delegate = self;
    self.gridMenu.blurEffectStyle = UIBlurEffectStyleDark;
    [self presentGridMenu:self.gridMenu animated:YES completion:^{
        NSLog(@"display grid menu");
    }];
}

#pragma mark - setting hyve image button
-(void)stylingSettingHyveImageButton
{
    self.settingHyveImageButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    self.settingHyveImageButton.backgroundColor = [UIColor colorWithRed:0.22 green:0.63 blue:0.80 alpha:1];
    self.settingHyveImageButton.tintColor = [UIColor whiteColor];
    self.settingHyveImageButton.clipsToBounds = YES;
    self.settingHyveImageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.settingHyveImageButton setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [self.settingHyveImageButton setTitle:@"Set Hyve image" forState:UIControlStateNormal];
}

-(void)settingHyveImageButtonAnimation
{
    POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    springAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(10, 10)];
    springAnimation.springBounciness = 20.0f;
    [self.hyveImageButton pop_addAnimation:springAnimation forKey:@"sendAnimation"];
}

- (IBAction)onSettingHyveImageButtonPressed:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Choose methods below to attach image to your Hyve" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePicture = [UIAlertAction actionWithTitle:@"Take a picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self takeAPictureForHyveImage];
        
    }];
    
    UIAlertAction *usePresetIcon = [UIAlertAction actionWithTitle:@"Use preset icon" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self usePresetIconForHyveImage];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:takePicture];
    [alertController addAction:usePresetIcon];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];

}


#pragma mark - grid menu preset icons and distance
-(void)gridMenu:(CNPGridMenu *)menu didTapOnItem:(CNPGridMenuItem *)item
{
    //backpack, laptop, house key, car key, bag, briefcase, tablet, mobile phone, wallet, remote control,
    if ([item.title isEqualToString:@"Backpack"])
    {
        NSLog(@"backpack");
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"bagpack"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
        self.setPresetIconButtonDidPressed = YES;
    }
    else if ([item.title isEqualToString:@"Laptop"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"macbook"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
        self.setPresetIconButtonDidPressed = YES;
    }
    else if ([item.title isEqualToString:@"House Key"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"houseKeys"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
        self.setPresetIconButtonDidPressed = YES;
    }
    else if ([item.title isEqualToString:@"Car Key"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"carKeys"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
        self.setPresetIconButtonDidPressed = YES;
    }
    else if ([item.title isEqualToString:@"Bag"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"handbag"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
        self.setPresetIconButtonDidPressed = YES;
    }
    else if ([item.title isEqualToString:@"Briefcase"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"briefcase"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
        self.setPresetIconButtonDidPressed = YES;
    }
    else if ([item.title isEqualToString:@"Backpack"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"bagpack"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
        self.setPresetIconButtonDidPressed = YES;
    }
    else if ([item.title isEqualToString:@"Wallet"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"wallet"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
        self.setPresetIconButtonDidPressed = YES;
    }
    else if ([item.title isEqualToString:@"Remote Control"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"remote"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
        self.setPresetIconButtonDidPressed = YES;
    }
    else if ([item.title isEqualToString:@"One \r meter"])
    {
        [self.hyveDistanceButton setTitle:@"1 meter" forState:UIControlStateNormal];
        self.hyveDistance = @"1";
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"Two \r meters"])
    {
        [self.hyveDistanceButton setTitle:@"2 meters" forState:UIControlStateNormal];
        self.hyveDistance = @"2";
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"Four \r meters"])
    {
        [self.hyveDistanceButton setTitle:@"4 meters" forState:UIControlStateNormal];
        self.hyveDistance = @"4";
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"Eight \r meters"])
    {
        [self.hyveDistanceButton setTitle:@"8 meters" forState:UIControlStateNormal];
        self.hyveDistance = @"8";
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"Sixteen \r meters"])
    {
        [self.hyveDistanceButton setTitle:@"16 meters" forState:UIControlStateNormal];
        self.hyveDistance = @"16";
        [self dismissGridMenuAnimated:YES completion:nil];
    }
}

-(void)gridMenuDidTapOnBackground:(CNPGridMenu *)menu
{
    [self dismissGridMenuAnimated:YES completion:nil];
}

#pragma mark - connect button
- (IBAction)onConnectButtonPressed:(id)sender
{
    NSLog(@"Connect app to hyve");
    [self.centralManager connectPeripheral:self.peripheral options:nil];
    
    self.loadingProgressView = [KVNProgressConfiguration defaultConfiguration];
    [KVNProgress setConfiguration:self.loadingProgressView];
    self.loadingProgressView.backgroundType = KVNProgressBackgroundTypeBlurred;
    self.loadingProgressView.fullScreen = YES;
    self.loadingProgressView.minimumDisplayTime = 1;
    [KVNProgress showWithStatus:@"Connecting to Hyve... \r\r This process may take a while as we are saving your Hyve details"];
    
}

#pragma mark - styling connect button
-(void)stylingConnectButton
{
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    self.connectButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:20];
    [self.connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.connectButton setBackgroundColor:[UIColor colorWithRed:0.89 green:0.39 blue:0.16 alpha:1]];
}

#pragma mark - central manager delegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"The central is off. Turn it on");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"Central is on and ready to use");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"Central is resetting");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"Central state is unautorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"Central is state is unkown.");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"Device does not have CoreBluetooth BLE");
            break;
        default:
            break;
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Central has connected to peripheral: %@ with UUID: %@",peripheral,peripheral.identifier);
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error)
    {
        NSLog(@"didFailToConnectPeripheral : %@", error);
    }
    else
    {
        NSLog(@"connectedToPeripheral : peripheral ==> %@ self.pheripheral ~~> %@", peripheral, self.peripheral);
        
    }
}

#pragma mark - peripheral delegate
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    self.peripheral = peripheral;
    for (CBService *service in peripheral.services)
    {
        NSLog(@"Discovered service %@ CBUUID= %@", service, service.UUID);

        [self.peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"FFF1"]] forService:service];
//       [peripheral discoverCharacteristics:nil forService:service];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics)
    {
            CBUUID *characteristicUUID = characteristic.UUID;
            CBUUID *characteristicUUIDString = [CBUUID UUIDWithString:@"FFF1"];
    
            if ([characteristicUUID isEqual:characteristicUUIDString])
            {
                NSLog(@"Not sending anything");
                
                if ([self.hyveDistanceButton.titleLabel.text isEqualToString:@"1 meter"])
                {
                    [self writingDistanceDataToHyve:characteristic withDataOne:'P' withDataTwo:'<' withDataThree:'S' withDataFour:'8' withDataFive:'0' withDataSix:'>' withDataSeven:'<' withDataEight:'X' withDataNine:'>'];
                    
                }
                else if ([self.hyveDistanceButton.titleLabel.text isEqualToString:@"2 meters"])
                {
                    [self writingDistanceDataToHyve:characteristic withDataOne:'P' withDataTwo:'<' withDataThree:'S' withDataFour:'9' withDataFive:'6' withDataSix:'>' withDataSeven:'<' withDataEight:'X' withDataNine:'>'];
                }
                else if ([self.hyveDistanceButton.titleLabel.text isEqualToString:@"4 meters"])
                {
                    [self writingDistanceDataToHyve:characteristic withDataOne:'P' withDataTwo:'<' withDataThree:'S' withDataFour:'9' withDataFive:'2' withDataSix:'>' withDataSeven:'<' withDataEight:'X' withDataNine:'>'];
                }
                else if ([self.hyveDistanceButton.titleLabel.text isEqualToString:@"8 meters"])
                {
                    [self writingDistanceDataToHyve:characteristic withDataOne:'P' withDataTwo:'<' withDataThree:'S' withDataFour:'9' withDataFive:'8' withDataSix:'>' withDataSeven:'<' withDataEight:'X' withDataNine:'>'];
                }
                else if ([self.hyveDistanceButton.titleLabel.text isEqualToString:@"16 meters"])
                {
                    [self writingDistanceDataToHyve:characteristic withDataOne:'<' withDataTwo:'S' withDataThree:'1' withDataFour:'0' withDataFive:'0' withDataSix:'>' withDataSeven:'<' withDataEight:'X' withDataNine:'>'];
                }
                else
                {
                    [self writingDistanceDataToHyve:characteristic withDataOne:'<' withDataTwo:'S' withDataThree:'1' withDataFour:'0' withDataFive:'0' withDataSix:'>' withDataSeven:'<' withDataEight:'X' withDataNine:'>'];
                    self.hyveDistance = @"16";
                }
            }
    }
}

#pragma mark - writing distance data
-(void)writingDistanceDataToHyve:(CBCharacteristic*)characteristic withDataOne:(char)dataOne withDataTwo:(char)dataTwo withDataThree:(char)dataThree withDataFour:(char)dataFour withDataFive:(char)dataFive withDataSix:(char)dataSix withDataSeven:(char)dataSeven withDataEight:(char)dataEight withDataNine:(char)dataNine
{
    uint8_t byte[0];
    NSInteger index;
    
    for (index = 0; index < 9; index++)
    {
        switch (index) {
            case 0:
            {
                byte[0] = dataOne;
                [self writingDistanceNumberDataToHyveHardware:byte characteristic:characteristic];
                break;
            }
            case 1:
            {
                byte[0] = dataTwo;
                [self writingDistanceNumberDataToHyveHardware:byte characteristic:characteristic];
                break;
                
            }
            case 2:
            {
                byte[0] = dataThree;
                [self writingDistanceNumberDataToHyveHardware:byte characteristic:characteristic];
                break;
            }
            case 3:
            {
                byte[0] = dataFour;
                [self writingDistanceNumberDataToHyveHardware:byte characteristic:characteristic];
                break;
            }
            case 4:
            {
                byte[0] = dataFive;
                [self writingDistanceNumberDataToHyveHardware:byte characteristic:characteristic];
                break;
            }
            case 5:
            {
                byte[0] = dataSix;
                [self writingDistanceNumberDataToHyveHardware:byte characteristic:characteristic];
                break;
            }
            case 6:
            {
                byte[0] = dataSeven;
                [self writingDistanceNumberDataToHyveHardware:byte characteristic:characteristic];
                break;
            }
            case 7:
            {
                byte[0] = dataEight;
                [self writingDistanceNumberDataToHyveHardware:byte characteristic:characteristic];
                break;
            }
            case 8:
            {
                byte[0] = dataNine;
                [self writingDistanceNumberDataToHyveHardware:byte characteristic:characteristic];
                break;
            }
            default:
                break;
        }
    }
}

-(void)writingDistanceNumberDataToHyveHardware:(const void*)byte characteristic:(CBCharacteristic*)characteristic
{
    self.distanceNumberData = [[NSMutableData alloc] initWithBytes:byte length:1];
    [self.peripheral writeValue:self.distanceNumberData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    [self.peripheral readRSSI];
//    [self.peripheral readValueForCharacteristic:characteristic];
}

//to read characteristic value
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"We have an error reading data from characteristic %@ %@", error,error.localizedDescription);
    }
    else
    {
        NSLog(@"didUpdateValueForCharacteristic : %@ \r characteristic.value %@ \r characteristic.descriptors %@ \r characteristic.properties %u", characteristic, characteristic.value, characteristic.descriptors, characteristic.properties );
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error reading characteristic %@", [error localizedDescription]);
    }
    else
    {
        if (characteristic.value != nil)
        {
            NSLog(@"didUpdateNotificationStateForCharacteristic %@", characteristic.value);
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error didReadRSSI: %@ \r localizedError: %@",error, [error localizedDescription]);
    }
    else
    {
        if (peripheral.state == CBPeripheralStateConnected)
        {
            NSLog(@"peripheral %@ \r peripheral's RSSI: %@",peripheral ,RSSI);
        }
    }
}

-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error peripheralDidUpdateRSSI: %@ \r localizedError: %@",error, [error localizedDescription]);
    }
    else
    {
        if (peripheral.state == CBPeripheralStateConnected)
        {
            NSLog(@"peripheral didUPDATERSSI: \r %@ ",peripheral);
        }
    }
    
}


//writing response to hyve
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"error writing characteristic value : %@ %@", error,[error localizedDescription]);
        NSLog(@"didWriteValueForCharacteristic %@ %@, characteristic property %u", characteristic, characteristic.value, characteristic.properties);
    }
    else
    {
        NSLog(@"didWriteValueForCharacteristic : %@ \r characteristic.value %@ \r characteristic.descriptors %@ \r characteristic.properties %u", characteristic, characteristic.value, characteristic.descriptors, characteristic.properties );

        NSString *hyveName = self.hyveNameTextField.text;
        NSString *hyveProximity = self.hyveDistance;
        UIImage *hyveImage = self.hyveImageButton.imageView.image;
        NSString *hyveUUIDString = peripheral.identifier.UUIDString;
        
        
        if (self.setPresetIconButtonDidPressed == YES || self.takePictureButtonDidPressed == YES)
        {
//            NSDictionary *hyveDictionary = @{@"name":hyveName,
//                                             @"distance":hyveProximity,
//                                             @"uuid":hyveUUIDString,
//                                             @"image":avatarImageStringInSixtyFour};
            
            static dispatch_once_t sendingHyveDictionaryToHyveServerOnce;
            dispatch_once(&sendingHyveDictionaryToHyveServerOnce, ^{
//                [self connectToHyve:hyveDictionary];
                [self connectToAmazonS3:peripheral];
            });

        }
        else
        {
            NSString *hyveName = self.hyveNameTextField.text;
            NSString *hyveProximity = self.hyveDistance;
            NSString *hyveUUIDString = peripheral.identifier.UUIDString;
            
            NSDictionary *hyveDictionary = @{@"name":hyveName,
                                             @"distance":hyveProximity,
                                             @"uuid":hyveUUIDString};
            
            static dispatch_once_t sendingHyveDictionaryToHyveServerOnce;
            dispatch_once(&sendingHyveDictionaryToHyveServerOnce, ^{
                [self connectToHyve:hyveDictionary];
            });
        }
    }
}

#pragma mark - amazon s3
-(void)connectToAmazonS3:(CBPeripheral*)peripheral
{
    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    if (reachability.isReachable)
    {
        [self uploadAndDownloadHyveImageS3:peripheral];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)uploadAndDownloadHyveImageS3:(CBPeripheral*)peripheral
{
    AWSStaticCredentialsProvider *credentialProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:kAWS_ACCESS_KEY secretKey:kAWS_SECRET_ACCESS_KEY];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPSoutheast1 credentialsProvider:credentialProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    UIImage *imageToBeUploadedToS3 = self.hyveImageButton.imageView.image;
    NSString *pathToImage = [NSTemporaryDirectory() stringByAppendingString:@"hyveImage.png"];
    NSData *hyveImageData = UIImagePNGRepresentation(imageToBeUploadedToS3);
    [hyveImageData writeToFile:pathToImage atomically:YES];
    NSURL *hyveImageURL = [[NSURL alloc] initFileURLWithPath:pathToImage];
    
    //Transfer manager upload
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = kAWS_BUCKET;
    uploadRequest.key = @"hyveImage.png";
    uploadRequest.body = hyveImageURL;
    
    //transfer to S3
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                                       withBlock:^id(BFTask *task)
    {
        if (task.error)
        {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain])
            {
                switch (task.error.code)
                {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                        
                    default:
                        NSLog(@"Error: %@", task.error);
                        break;
                }
            }
            else
            {
                NSLog(@"error from awss3transfermanger : \r %@", task.error);
            }
        }
        
        //download from hyve image url from s3
        if (task.result)
        {
            [self downloadHyveImageURLFromS3:task peripheral:peripheral];
        }
        else
        {
            NSLog(@"Error task download error : %@", task.error);
        }
        return nil;
    }];
}

-(void)downloadHyveImageURLFromS3:(BFTask*)task peripheral:(CBPeripheral*)peripheral
{
    AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
    NSLog(@"uploadOutput %@", uploadOutput);
    
    AWSS3GetPreSignedURLRequest *getPresignedURLRequest = [AWSS3GetPreSignedURLRequest new];
    getPresignedURLRequest.key = @"hyveImage.png";
    getPresignedURLRequest.HTTPMethod = AWSHTTPMethodGET;
    getPresignedURLRequest.bucket = kAWS_BUCKET;
    getPresignedURLRequest.expires = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 63115200]; //31622400

    [[[AWSS3PreSignedURLBuilder defaultS3PreSignedURLBuilder] getPreSignedURL:getPresignedURLRequest] continueWithBlock:^id(BFTask *task)
     {
         if (task.error)
         {
            NSLog(@"Error: taskError from asss3presignedurlbuilder %@", task.error);
         }
         else
         {
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                 NSURL *hyveImageS3URL = task.result;
                 //PATCH HYVE STUFF HERE
                 [self sendUpdatedHyveInfoToHyve:hyveImageS3URL peripheral:peripheral];
                 
                 
                 NSURLRequest *request = [NSURLRequest requestWithURL:hyveImageS3URL];
                 self.downloadTask = [self.session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                     
                     if (error)
                     {
                         NSLog(@"Error NSURLSessionDownloadTask TaskCreation :%@", error);
                     }
                     else
                     {
                         NSLog(@"location from NSURLSessionDownloadTask:  %@", location);
                         NSLog(@"response from NSURLSessionDownloadTask == %@", response);
                     }
                     [self.downloadTask resume];
                 }];
             });
         }
         return nil;
     }];
}

#pragma mark - send updated hyve info to Hyve
-(void)sendUpdatedHyveInfoToHyve:(NSURL*)hyveImageS3URL peripheral:(CBPeripheral*)peripheral
{
    NSString *hyveName = self.hyveNameTextField.text;
    NSString *hyveProximity = self.hyveDistance;
    NSString *hyveUUIDString = peripheral.identifier.UUIDString;
    NSString *avatarURL = [NSString stringWithFormat:@"%@", hyveImageS3URL];
    //    UIImage *hyveImage = self.hyveImageButton.imageView.image;
    
    NSDictionary *hyveDictionary = @{@"name":hyveName,
                                     @"distance":hyveProximity,
                                     @"uuid":hyveUUIDString,
                                     @"image":avatarURL};
    
    [self connectToHyve:hyveDictionary];
    
}

#pragma mark - update hyves details
-(void)connectToHyve:(NSDictionary*)hyveDetails
{
    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    if (reachability.isReachable)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self updateHyveDetails:hyveDetails];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)updateHyveDetails:(NSDictionary*)hyveDetails
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *api_token = [userDefaults objectForKey:@"api_token"];
    
    NSString *uuid = [self.peripheral.identifier UUIDString];
    NSString *hyveUserAccountString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/hyves/%@",uuid];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:api_token forHTTPHeaderField:@"X-hyve-token"];
    [manager.requestSerializer setTimeoutInterval:20];
    
    [manager PATCH:hyveUserAccountString parameters:hyveDetails success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        NSLog(@"responseObject: \r %@", responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.loadingProgressView.minimumSuccessDisplayTime = 3.0;
        [KVNProgress showSuccessWithStatus:@"Connected!"];

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Succesfully connect to Hyve" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [KVNProgress dismiss];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity. Unable to update hyve" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        NSLog(@"Error: \r %@ \r localized description: %@", error, [error localizedDescription]);
    }];
}

#pragma mark - touches began
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - adding toolbar to keyboard
-(void)addToolbarToKeyboard
{
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    keyboardToolbar.barStyle = UIBarStyleDefault;
    keyboardToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonPressed)],
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                              [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)]
                              ];
    
    [keyboardToolbar sizeToFit];
    self.hyveNameTextField.inputAccessoryView = keyboardToolbar;
}

-(void)clearButtonPressed
{
    self.hyveNameTextField.text = @"";
}

-(void)doneButtonPressed
{
    [self.hyveNameTextField resignFirstResponder];
}


#pragma mark - text field delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 80, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 80, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

@end
