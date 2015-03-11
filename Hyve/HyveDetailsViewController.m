//
//  HyveDetailsViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/9/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "HyveDetailsViewController.h"
#import <CNPGridMenu.h>
//32A9DD44-9B1C-BAA5-8587-8A2D36E0623E  - hive

@interface HyveDetailsViewController () <UIImagePickerControllerDelegate, CNPGridMenuDelegate, CBPeripheralDelegate, CBCentralManagerDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UIButton *hyveCamera;
@property (weak, nonatomic) IBOutlet UITextField *hyveNameTextField;
@property (strong, nonatomic) UIImage *resizedImage;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (weak, nonatomic) IBOutlet UILabel *distanceSliderLabel;
@property (strong, nonatomic) NSArray *valuesOfDistanceSlider;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *setIconButton;
@property (strong, nonatomic) CNPGridMenu *gridMenu;

@end

@implementation HyveDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.centralManager.delegate = self;
    self.hyveNameTextField.text = self.peripheral.name;

    
    [self stylingDistanceSliderLabel];
    [self addingSaveButtonToNavigationBar];
    [self addToolbarToKeyboard];
    [self stylingTextField];
    [self stylingHyveCameraButton];
    [self configureAndStyleDistanceSlider];
    [self stylingIconButton];
    [self stylingConnectButton];
    
    NSString *uuid = [self.peripheral.identifier UUIDString];
    NSLog(@"self.peripheral %@", uuid);

}

#pragma mark - adding save bar button item
-(void)addingSaveButtonToNavigationBar
{
    UIBarButtonItem *saveRightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveHyveDetailsToBackend)];
    self.navigationItem.rightBarButtonItem = saveRightButton;
}

#pragma mark - styling text field
-(void)stylingTextField
{
    self.hyveNameTextField.layer.borderWidth = 0.5;
    self.hyveNameTextField.layer.borderColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1].CGColor;
    self.hyveNameTextField.layer.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1].CGColor;
    self.hyveNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    self.hyveNameTextField.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:15];
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

#pragma mark - styling hyve camera button
-(void)stylingHyveCameraButton
{
    [self.hyveCamera setTitle:@"Camera" forState:UIControlStateNormal];
    self.hyveCamera.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:15];
    [self.hyveCamera setImage:[UIImage imageNamed:@"jlaw2"] forState:UIControlStateNormal];
}

#pragma mark - image picker controller
- (IBAction)onHyveCameraButtonPressed:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePickerController = [UIImagePickerController new];
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.delegate = (id)self;
        
        self.imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
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
        CGRect rect = CGRectMake(0, 0, 700, 800);
        
        UIGraphicsBeginImageContext(rect.size);
        [imageTakenByUser drawInRect:rect];
        UIImage *resizedImageTakenByUser = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resizedImage = resizedImageTakenByUser;
        });
    });
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Cancel image picker was called");
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - icon menu
-(void)stylingIconButton
{
    self.setIconButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:15];
    [self.setIconButton setTitle:@"Select Icon" forState:UIControlStateNormal];
    self.setIconButton.titleLabel.numberOfLines = 0;
    [self.setIconButton setImage:[UIImage imageNamed:@"jlaw"] forState:UIControlStateNormal];
}

- (IBAction)onSetIconButtonPressed:(id)sender
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
    
    CNPGridMenuItem *phone = [CNPGridMenuItem new];
    phone.icon = [UIImage imageNamed:@"phone"];
    phone.title = @"Phone";
    
    CNPGridMenuItem *wallet = [CNPGridMenuItem new];
    wallet.icon = [UIImage imageNamed:@"wallet"];
    wallet.title = @"Wallet";
    
    CNPGridMenuItem *remoteControl = [CNPGridMenuItem new];
    remoteControl.icon = [UIImage imageNamed:@"remote"];
    remoteControl.title = @"Remote Control";
    
    self.gridMenu = [[CNPGridMenu alloc] initWithMenuItems:@[backpack, laptop, houseKey,carKey, bag, briefcase, tablet, phone, wallet, remoteControl]];
    self.gridMenu.delegate = self;
    self.gridMenu.blurEffectStyle = UIBlurEffectStyleDark;
    [self presentGridMenu:self.gridMenu animated:YES completion:^{
        NSLog(@"display grid menu");
    }];
}

-(void)gridMenu:(CNPGridMenu *)menu didTapOnItem:(CNPGridMenuItem *)item
{
    //backpack, laptop, house key, car key, bag, briefcase, tablet, mobile phone, wallet, remote control,
    
    if ([item.title isEqualToString:@"Backpack"])
    {
        NSLog(@"backpack");
    }
    else if ([item.title isEqualToString:@"Laptop"])
    {
        
    }
    else if ([item.title isEqualToString:@"House Key"])
    {
        
    }
    else if ([item.title isEqualToString:@"Car Key"])
    {
        
    }
    else if ([item.title isEqualToString:@"Bag"])
    {
        
    }
    else if ([item.title isEqualToString:@"Briefcase"])
    {
        
    }
    else if ([item.title isEqualToString:@"Backpack"])
    {
        
    }
    else if ([item.title isEqualToString:@"Phone"])
    {
        
    }
    else if ([item.title isEqualToString:@"Wallet"])
    {
        
    }
    else if ([item.title isEqualToString:@"Remote Control"])
    {
        
    }
}

-(void)gridMenuDidTapOnBackground:(CNPGridMenu *)menu
{
    [self dismissGridMenuAnimated:YES completion:nil];
}


#pragma mark - slider
-(void)stylingDistanceSliderLabel
{
    self.distanceSliderLabel.text = @"Maximum proximity of Hyve";
    self.distanceSliderLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:15];
}

-(void)configureAndStyleDistanceSlider
{
    /*
     1m = -40dB, 2m = -46dB, 4m = -52dB, 8m = -58dB, 16m = -64dB
    */
    
   self.valuesOfDistanceSlider = @[@(1), @(2), @(4), @(8), @(16)];
    NSInteger numberOfDistanceSliderColumns = ((float)[self.valuesOfDistanceSlider count] -1 );
    
    self.distanceSlider.minimumValue = 1.0;
    self.distanceSlider.maximumValue = numberOfDistanceSliderColumns;
    self.distanceSlider.continuous = YES;
    [self.distanceSlider addTarget:self action:@selector(valueOfDistanceSliderChanged) forControlEvents:UIControlEventValueChanged];

}

-(void)valueOfDistanceSliderChanged
{
    NSUInteger index = (NSUInteger)(self.distanceSlider.value + 0.5);
    [self.distanceSlider setValue:index animated:NO];
    NSNumber *number = self.valuesOfDistanceSlider[index];
    
    self.distanceSliderLabel.text = [NSString stringWithFormat:@"Maximum proximity of Hyve is %@ m", number];
    self.distanceSliderLabel.numberOfLines = 0;
    NSLog(@"sliderIndex: %i", (int)index);
    NSLog(@"number: %@", number);
}

#pragma mark - send details to backend
-(void)saveHyveDetailsToBackend
{
    //send the hyve's name, uuid, RSSI, image
    NSLog(@"save to Hyve");
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
    self.connectButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:15];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - central manager delegate

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Central has connected to peripheral: %@ with UUID: %@",peripheral,peripheral.identifier);
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:[NSString stringWithFormat:@"Successfully connected to %@", peripheral.name] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
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

#pragma mark - peripheral delegate
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services)
    {
        NSLog(@"Discovered service %@ CBUUID= %@", service, service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"Characteristic of services : %@", characteristic);
        
        CBUUID *characteristicUUID = characteristic.UUID;
        CBUUID *characteristicUUIDString = [CBUUID UUIDWithString:@"FFF6"];
        
        if ([characteristicUUID isEqual:characteristicUUIDString])
        {
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

//to read characteristic value
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"We have an error reading data from FFF6");
    }
    else
    {
        NSData *peripheralValue = characteristic.value;
        NSString *peripheralValueString = [NSString stringWithUTF8String:[peripheralValue bytes]];
        NSLog(@"peripheralValue of FFF6 is %@", peripheralValueString);
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



@end
