//
//  HyveDetailsViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/9/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "HyveDetailsViewController.h"
#import <AFNetworking.h>
#import <Reachability.h>
#import <CNPGridMenu.h>
#import <DKCircleButton.h>
#import <POP.h>

//32A9DD44-9B1C-BAA5-8587-8A2D36E0623E  - hive

@interface HyveDetailsViewController () <UIImagePickerControllerDelegate, CNPGridMenuDelegate, CBPeripheralDelegate, CBCentralManagerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet DKCircleButton *hyveImageButton;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UITextField *hyveNameTextField;
@property (strong, nonatomic) UIImage *resizedImage;
@property (strong, nonatomic) NSArray *valuesOfDistanceSlider;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) CNPGridMenu *gridMenu;
@property (strong, nonatomic) NSString *distanceNumber;
@property (strong, nonatomic) NSData *distanceNumberData;
@property (strong, nonatomic) IBOutlet UIButton *hyveDistanceButton;
@property (strong, nonatomic) IBOutlet UIButton *settingHyveImageButton;



@end

@implementation HyveDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
}

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
    
    [manager GET:hyveURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"responseObject retrieveImageFromServer: \r\r %@", responseObject);
        Hyve *hyve = [Hyve new];
        hyve.imageURLString = [responseObject valueForKeyPath:@"hyve.image.image.url"];
        
        [self stylingHyveImageButton:hyve];
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error with retrieveUserInfoAndPairedHyve: \r\r %@ \r localizedDescription: \r %@", error, [error localizedDescription]);
        
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
            UIImage *hyveImage = [UIImage imageNamed:@"jlaw2"];
            
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
            [self.hyveImageButton setImage:hyveImage forState:UIControlStateNormal];
            [self.hyveImageButton setTitle:@"" forState:UIControlStateNormal];
        }
    }
    else
    {
        UIImage *defaultHyveImage = [UIImage imageNamed:@"jlaw"];
        self.hyveImageButton.borderColor = [UIColor whiteColor];
        self.hyveImageButton.borderSize = 2.0f;
        [self.hyveImageButton setImage:defaultHyveImage forState:UIControlStateNormal];
        [self.hyveImageButton setTitle:@"" forState:UIControlStateNormal];
    }
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
        CGRect rect = CGRectMake(0, 0, 700, 800);
        
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
    one.icon = [UIImage imageNamed:@"remote"];
    
    CNPGridMenuItem *two = [CNPGridMenuItem new];
    two.icon = [UIImage imageNamed:@"remote"];
    two.title = [NSString stringWithFormat:@"Two \r meters"];
    
    CNPGridMenuItem *four = [CNPGridMenuItem new];
    four.title = [NSString stringWithFormat:@"Four \r meters"];
    four.icon = [UIImage imageNamed:@"remote"];
    
    CNPGridMenuItem *eight = [CNPGridMenuItem new];
    eight.title = [NSString stringWithFormat:@"Eight \r meters"];
    eight.icon = [UIImage imageNamed:@"remote"];
  
    CNPGridMenuItem *sixteen = [CNPGridMenuItem new];
    sixteen.title = [NSString stringWithFormat:@"Sixteen \r meters"];
    sixteen.icon = [UIImage imageNamed:@"remote"];
    
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
    }
    else if ([item.title isEqualToString:@"Laptop"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"macbook"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"House Key"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"houseKeys"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"Car Key"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"carKeys"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"Bag"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"handbag"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"Briefcase"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"briefcase"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"Backpack"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"bagpack"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"Wallet"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"wallet"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"Remote Control"])
    {
        [self settingHyveImageButtonAnimation];
        [self.hyveImageButton setImage:[UIImage imageNamed:@"remote"] forState:UIControlStateNormal];
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"One \r meter"])
    {
        [self.hyveDistanceButton setTitle:@"1 meter" forState:UIControlStateNormal];
//        self.distanceNumber = @"40";
//        self.distanceNumber = @"<S40>";
//        self.distanceNumberData = [self.distanceNumber dataUsingEncoding:NSUTF8StringEncoding];
        
        uint8_t byte[5];
        byte[0]='<';
        byte[1]='S';
        byte[2]='4';
        byte[3]='0';
        byte[4]='>';
        self.distanceNumberData = [NSData dataWithBytes:byte length:1];
    
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"Two \r meters"])
    {
        [self.hyveDistanceButton setTitle:@"2 meters" forState:UIControlStateNormal];
//        self.distanceNumber = @"46";
//        self.distanceNumber = @"<S46>";
//        self.distanceNumberData = [self.distanceNumber dataUsingEncoding:NSUTF8StringEncoding];

/*
        uint8_t byte[5];
        byte[0]='<';
        byte[1]='S';
        byte[2]='4';
        byte[3]='6';
        byte[4]='>';
        self.distanceNumberData = [NSData dataWithBytes:byte length:1];
*/
        
        self.distanceNumber = @"<S46>";
        const char *s =[self.distanceNumber UTF8String];
        self.distanceNumberData = [NSData dataWithBytes:s length:strlen(s)];
        
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"Four \r meters"])
    {
        [self.hyveDistanceButton setTitle:@"4 meters" forState:UIControlStateNormal];
//        self.distanceNumber = @"52";
//        self.distanceNumber = @"0x3C5335323E";
//        self.distanceNumberData = [self.distanceNumber dataUsingEncoding:NSUTF8StringEncoding];
        self.distanceNumber = @"<S52>";
        
        uint8_t byte[5];
        byte[0]='<';
        byte[1]='S';
        byte[2]='5';
        byte[3]='2';
        byte[4]='>';
        self.distanceNumberData = [NSData dataWithBytes:byte length:1];
        
//        self.distanceNumberData = [self.distanceNumber dataUsingEncoding:NSASCIIStringEncoding];
        NSData *utf8 = [self.distanceNumber dataUsingEncoding:NSUTF8StringEncoding];
//        self.distanceNumberData = [self.distanceNumber dataUsingEncoding:NSASCIIStringEncoding];
        
        NSLog(@"self.distanceNumberData %@ \r\r utf8 %@", self.distanceNumberData, utf8);
        
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"Eight \r meters"])
    {
        [self.hyveDistanceButton setTitle:@"8 meters" forState:UIControlStateNormal];
//        self.distanceNumber = @"58";
//        self.distanceNumber = @"<S58>";
//        self.distanceNumberData = [self.distanceNumber dataUsingEncoding:NSUTF8StringEncoding];
        
        uint8_t byte[5];
        byte[0]='<';
        byte[1]='S';
        byte[2]='5';
        byte[3]='8';
        byte[4]='>';
        self.distanceNumberData = [NSData dataWithBytes:byte length:1];
        
        [self dismissGridMenuAnimated:YES completion:nil];
    }
    else if ([item.title isEqualToString:@"Sixteen \r meters"])
    {
        [self.hyveDistanceButton setTitle:@"16 meters" forState:UIControlStateNormal];
//        self.distanceNumber = @"64";
//        self.distanceNumber = @"<S64>";
//        self.distanceNumberData = [self.distanceNumber dataUsingEncoding:NSUTF8StringEncoding];
        
        uint8_t byte[5];
        byte[0]='<';
        byte[1]='S';
        byte[2]='6';
        byte[3]='4';
        byte[4]='>';
        self.distanceNumberData = [NSData dataWithBytes:byte length:1];
        
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
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:[NSString stringWithFormat:@"Successfully connected to %@", peripheral.name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
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
                self.characteristic = characteristic;
//                CBMutableCharacteristic *proximity = [[CBMutableCharacteristic alloc] initWithType:characteristic.UUID properties:CBCharacteristicPropertyWrite value:self.distanceNumberData permissions:CBAttributePermissionsWriteable];
//                [peripheral writeValue:self.distanceNumberData forCharacteristic:proximity type:CBCharacteristicWriteWithResponse];
                
//            [self.peripheral writeValue:self.distanceNumberData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                
                
//                CBMutableCharacteristic *proximity = [[CBMutableCharacteristic alloc] initWithType:characteristic.UUID properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
//                [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
                
                NSString *a = @"0x61";
                NSData *aData = [a dataUsingEncoding:NSASCIIStringEncoding];
                
                uint8_t byte[1];
                byte[0]='<';

                self.distanceNumberData = [NSData dataWithBytes:byte length:1];
                
//                self.distanceNumber = @"0x61";
//                const char *s =[self.distanceNumber UTF8String];
//                self.distanceNumberData = [NSData dataWithBytes:s length:strlen(s)];
                
//                [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(sendingAToHyve) userInfo:nil repeats:NO];
                
                
                [self.peripheral writeValue:self.distanceNumberData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                [self.peripheral readRSSI];
//                [peripheral readValueForCharacteristic:characteristic];
                
//                NSUInteger bytes = [self.distanceNumber lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//                NSLog(@"bytes of self.distanceNumber is %i", bytes);
//    
//                NSData *distanceString = [self stringToBytes:self.distanceNumber];
//                NSLog(@"distanceString of data is %@", distanceString);
//                [peripheral writeValue:distanceString forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                
/*
                int8_t distanceNumberIntValue = [self.distanceNumber integerValue];
                int16_t distanceNumberAtSixteen = [self.distanceNumber integerValue];
                int16_t distanceNumber = CFSwapInt16HostToLittle(distanceNumberAtSixteen);
                NSData *theDistanceNumberData = [NSData dataWithBytes:&distanceNumber length:sizeof(distanceNumberIntValue)];
                
                NSLog(@"self.distanceNumberData is %@", theDistanceNumberData);
                [peripheral writeValue:theDistanceNumberData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
*/
                
//                NSData *distanceNumberDataLittleEndian = [self.distanceNumber dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
//                [peripheral writeValue:distanceNumberDataLittleEndian forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
//                NSLog(@"distanceNumberDataLittleEndian %@", distanceNumberDataLittleEndian);
            }
        }
    

/*
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"Characteristic of services : %@", characteristic);
        
        CBUUID *characteristicUUID = characteristic.UUID;
        CBUUID *characteristicUUIDString = [CBUUID UUIDWithString:@"FFF6"];
        
        if ([characteristicUUID isEqual:characteristicUUIDString])
        {
            NSData *distanceStringData = [self.distanceNumber dataUsingEncoding:NSASCIIStringEncoding];
//            NSLog(@"distanceStringData %@ %i", distanceStringData, [distanceStringData length]);
            
//            NSLog(@"characteristic.properties %u", characteristic.properties);
//            
//            if (characteristic.properties == 8) //write
//            {
//                int i = 1;
//                [peripheral writeValue:[NSData dataWithBytes:&i length:sizeof(i)] forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
//            }
//            else if (characteristic.properties == 02) //read
//            {
//                
                [peripheral readValueForCharacteristic:characteristic];
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//            }
//            else if (characteristic.properties == 10) //notify
//            {
//                NSLog(@"this characteristic is notify");
//            }
            
//            NSString *characteristicUUIDString1 = [NSString stringWithFormat:@"%@",characteristic.UUID];
//            CBUUID *theCharacteristicUUID = [CBUUID UUIDWithString:characteristicUUIDString1];
//            const uint8_t *distanceNumberUint8 = (const uint8_t*)[self.distanceNumber cStringUsingEncoding:NSUTF8StringEncoding];
//            NSData *distanceData = [NSData dataWithBytes:distanceNumberUint8 length:self.distanceNumber.length];
            
            const uint8_t *distanceNumberUint8 = (const uint8_t*)[self.distanceNumber cStringUsingEncoding:NSASCIIStringEncoding];
            NSData *theDistanceStringData = [NSData dataWithBytes:distanceNumberUint8 length:[distanceStringData length]];
            [peripheral writeValue:theDistanceStringData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            
            
        }
    }
*/
}



-(void)sendingAToHyve
{
    NSString *a = @"a";
    NSData *aData = [a dataUsingEncoding:NSASCIIStringEncoding];
    [self.peripheral writeValue:aData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(sendingXToHyve) userInfo:nil repeats:NO];

}

-(void)sendingXToHyve
{
    NSString *x = @"X";
    NSData *xData = [x dataUsingEncoding:NSASCIIStringEncoding];
    [self.peripheral writeValue:xData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    
}


-(NSData*) stringToBytes:(NSString*)distanceString
{
    NSUInteger size = [distanceString length];
    NSMutableData *bytes = [NSMutableData dataWithLength:size/2];
    //getting a pointer to the actual array of bytes
    
    uint8_t *bytePointer = [bytes mutableBytes];
    NSUInteger i =0;
    
    for (NSUInteger j = 0; j < size / 2; ++j)
    {
        bytePointer[j] = (([distanceString characterAtIndex: i] & 0xf) << 4)
        | ([distanceString characterAtIndex: i + 1] & 0xf);
        i += 2;
    }
    
    return bytes;
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
        NSLog(@"didUpdateValueForCharacteristic : %@ \r characteristic.value %@ \r characteristic.descriptors %@ \r characteristic.properties %lu", characteristic, characteristic.value, characteristic.descriptors, characteristic.properties );
        
        /*
        NSData *peripheralValue = characteristic.value;
        NSData *decipherPeripheralValueData = [NSData dataWithByte%lu[peripheralValue bytes] length:[peripheralValue length]];
        const uint8_t *bytes = [decipherPeripheralValueData bytes];
        int value = bytes[0];
        NSLog(@"value of bytes : %i", value);
        */
        
        
        //reading the nsdata --> nsdata to nsstring --> not working, not nill, but can't via bytes in string
//        NSString *peripheralValueString = [NSString stringWithUTF8String:[peripheralValue bytes]];
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
        NSString *hyveProximity = self.hyveDistanceButton.titleLabel.text;
        UIImage *hyveImage = self.hyveImageButton.imageView.image;
        NSString *hyveUUIDString = peripheral.identifier.UUIDString;
        
        NSString *avatarImageString = [UIImagePNGRepresentation(hyveImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSString *avatarImageStringInSixtyFour = [NSString stringWithFormat:@"data:image/png;base64, (%@)", avatarImageString];
        
        NSDictionary *hyveDictionary = @{@"name":hyveName,
                                         @"distance":hyveProximity,
                                         @"uuid":hyveUUIDString,
                                         @"image":avatarImageStringInSixtyFour};
        
        [self connectToHyve:hyveDictionary];
    }
}


#pragma mark - update hyves details 
-(void)connectToHyve:(NSDictionary*)hyveDetails
{
    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    if (reachability.isReachable)
    {
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
    
    [manager PATCH:hyveUserAccountString parameters:hyveDetails success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        NSLog(@"responseObject: \r %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
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
