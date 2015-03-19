//
//  HyveDetailsViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/9/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "HyveDetailsViewController.h"
#import <CNPGridMenu.h>
#import <DKCircleButton.h>
#import <POP.h>

//32A9DD44-9B1C-BAA5-8587-8A2D36E0623E  - hive

@interface HyveDetailsViewController () <UIImagePickerControllerDelegate, CNPGridMenuDelegate, CBPeripheralDelegate, CBCentralManagerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet DKCircleButton *hyveImageButton;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UITextField *hyveNameTextField;
@property (strong, nonatomic) UIImage *resizedImage;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (weak, nonatomic) IBOutlet UILabel *distanceSliderLabel;
@property (strong, nonatomic) NSArray *valuesOfDistanceSlider;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *setIconButton;
@property (strong, nonatomic) CNPGridMenu *gridMenu;
@property (strong, nonatomic) NSString *distanceNumber;
@property (strong, nonatomic) NSData *distanceNumberData;
@property (strong, nonatomic) IBOutlet UIButton *hyveDistanceButton;

@end

@implementation HyveDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.95 blue:0.92 alpha:1];
    self.centralManager.delegate = self;
    self.hyveNameTextField.text = self.peripheral.name;
    self.hyveNameTextField.delegate = self;
    
    [self stylingDistanceSliderLabel];
    [self addingSaveButtonToNavigationBar];
    [self addToolbarToKeyboard];
    [self stylingTextField];
    [self stylingHyveDistanceButton];
    [self configureAndStyleDistanceSlider];
    [self stylingConnectButton];
    [self stylingHyveImageButton];
    
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
    self.hyveNameTextField.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:18];
    self.hyveNameTextField.textAlignment = NSTextAlignmentNatural;
}

#pragma mark - styling hyve image button
-(void)stylingHyveImageButton
{
    self.hyveImageButton.borderColor = [UIColor whiteColor];
    self.hyveImageButton.borderSize = 2.0f;
    [self.hyveImageButton setImage:[UIImage imageNamed:@"jlaw2"] forState:UIControlStateNormal];
    [self.hyveImageButton setTitle:@"" forState:UIControlStateNormal];
}

#pragma mark - hyve image button
- (IBAction)onHyveImageButtonPressed:(id)sender
{
    POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    springAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(10, 10)];
    springAnimation.springBounciness = 20.0f;
    [self.hyveImageButton pop_addAnimation:springAnimation forKey:@"sendAnimation"];
    springAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        
        if (finished)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Choose methods below to attach image to your Hyve" preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *takePicture = [UIAlertAction actionWithTitle:@"Take a picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self takeAPictureForHyveImage];
            }];
            
            UIAlertAction *usePresetIcon = [UIAlertAction actionWithTitle:@"Use preset icon" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self usePresetIconForHyveImage];
            }];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alertController addAction:takePicture];
            [alertController addAction:usePresetIcon];
            [alertController addAction:cancel];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    };
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
            POPBasicAnimation *fadeAnimation = [POPBasicAnimation animation];
            fadeAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
            fadeAnimation.fromValue = @(0);
            fadeAnimation.toValue = @(1);
            fadeAnimation.duration = 1.5;
            fadeAnimation.name = @"fade-in";
            [self.hyveImageButton setImage:self.resizedImage animated:NO];
            [self.hyveImageButton pop_addAnimation:fadeAnimation forKey:fadeAnimation.name];
            
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
    self.hyveDistanceButton.layer.borderWidth = 0.5;
    self.hyveDistanceButton.layer.borderColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1].CGColor;
    self.hyveDistanceButton.layer.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1].CGColor;
    self.hyveDistanceButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:18];
    self.hyveDistanceButton.tintColor = [UIColor blackColor];
    self.hyveDistanceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.hyveDistanceButton setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [self.hyveDistanceButton setTitle:@"Distance from Hyve" forState:UIControlStateNormal];

}

- (IBAction)onHyveDistanceButtonPressed:(id)sender
{
    POPSpringAnimation *shakeHyveDistanceButton = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    shakeHyveDistanceButton.springBounciness = 20;
    shakeHyveDistanceButton.velocity = @(3000);
    shakeHyveDistanceButton.name = @"shakeHyveDistanceButton";
    [self.hyveDistanceButton pop_addAnimation:shakeHyveDistanceButton forKey:shakeHyveDistanceButton.name];
    
    CNPGridMenuItem *one = [CNPGridMenuItem new];
    one.title = @"One meter";
    one.icon = [UIImage imageNamed:@"briefcase"];
    
    CNPGridMenuItem *two = [CNPGridMenuItem new];
    two.icon = [UIImage imageNamed:@"remote"];
    two.title = @"Two meters";
    
    CNPGridMenuItem *four = [CNPGridMenuItem new];
    four.title = @"Four meters";
    four.icon = [UIImage imageNamed:@"wallet"];
    
    CNPGridMenuItem *eight = [CNPGridMenuItem new];
    eight.title = @"Eight meters";
    eight.icon = [UIImage imageNamed:@"tablet"];
  
    CNPGridMenuItem *sixteen = [CNPGridMenuItem new];
    sixteen.title = @"Sixteen meters";
    sixteen.icon = [UIImage imageNamed:@"bag"];
    
    shakeHyveDistanceButton.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        self.gridMenu = [[CNPGridMenu alloc] initWithMenuItems:@[one,two,four,eight,sixteen]];
        self.gridMenu.delegate = self;
        self.gridMenu.blurEffectStyle = UIBlurEffectStyleDark;
        [self presentGridMenu:self.gridMenu animated:YES completion:^{
            NSLog(@"display grid menu");
        }];
    };
}

#pragma mark - grid menu preset icons and distance
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
    else if ([item.title isEqualToString:@"Wallet"])
    {
        
    }
    else if ([item.title isEqualToString:@"Remote Control"])
    {
        
    }
    else if ([item.title isEqualToString:@"One meter"])
    {
        NSLog(@"one meter selected");
    }
    else if ([item.title isEqualToString:@"Two meters"])
    {
        
    }
    else if ([item.title isEqualToString:@"Four meters"])
    {
        
    }
    else if ([item.title isEqualToString:@"Eight meters"])
    {
        
    }
    else if ([item.title isEqualToString:@"Sixteen meters"])
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

    int theInt = [number intValue];
//    uint8_t byte[5];
    
    switch (theInt) {
        case 1:
            NSLog(@"1");
//            self.distanceNumber = [NSString stringWithFormat:@"<S40>"];
            self.distanceNumber = @"40";

//            byte[0] = '<';
//            byte[1] = 'S';
//            byte[2] = '4';
//            byte[3] = '0';
//            byte[4] = '>';
//            self.distanceNumberData = [NSData dataWithBytes:byte length:1];

            break;
        case 2:
            NSLog(@"2");
//            self.distanceNumber = [NSString stringWithFormat:@"<S46>"];
            self.distanceNumber = @"46";
            
//            byte[0] = '<';
//            byte[1] = 'S';
//            byte[2] = '4';
//            byte[3] = '6';
//            byte[4] = '>';
//            self.distanceNumberData = [NSData dataWithBytes:byte length:1];
            
            break;
        case 4:
            NSLog(@"4");
//            self.distanceNumber = [NSString stringWithFormat:@"<S52>"];
            self.distanceNumber = @"52";
            
//            byte[0] = '<';
//            byte[1] = 'S';
//            byte[2] = '5';
//            byte[3] = '2';
//            byte[4] = '>';
//            self.distanceNumberData = [NSData dataWithBytes:byte length:1];
            
            break;
        case 8:
            NSLog(@"8");
//            self.distanceNumber = [NSString stringWithFormat:@"<S58>"];
            self.distanceNumber = @"58";
            
//            byte[0] = '<';
//            byte[1] = 'S';
//            byte[2] = '5';
//            byte[3] = '8';
//            byte[4] = '>';
//            self.distanceNumberData = [NSData dataWithBytes:byte length:1];
            
            break;
        case 16:
            NSLog(@"16");
//            self.distanceNumber = [NSString stringWithFormat:@"<S64>"];
            self.distanceNumber = @"64";
            
//            byte[0] = '<';
//            byte[1] = 'S';
//            byte[2] = '6';
//            byte[3] = '4';
//            byte[4] = '>';
//            self.distanceNumberData = [NSData dataWithBytes:byte length:1];
            
        default:
            break;
    }
    
    self.distanceSliderLabel.text = [NSString stringWithFormat:@"Maximum proximity of Hyve is %@ m", number];
    self.distanceSliderLabel.numberOfLines = 0;
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
        
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"FFF6"]] forService:service];
//        [peripheral discoverCharacteristics:nil forService:service];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics)
    {
            CBUUID *characteristicUUID = characteristic.UUID;
            CBUUID *characteristicUUIDString = [CBUUID UUIDWithString:@"FFF6"];
    
            if ([characteristicUUID isEqual:characteristicUUIDString])
            {
                [peripheral readValueForCharacteristic:characteristic];
    
//                NSUInteger bytes = [self.distanceNumber lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//                NSLog(@"bytes of self.distanceNumber is %i", bytes);
//    
//                NSData *distanceString = [self stringToBytes:self.distanceNumber];
//                NSLog(@"distanceString of data is %@", distanceString);
//                [peripheral writeValue:distanceString forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                
                
                int8_t distanceNumberIntValue = [self.distanceNumber integerValue];
                int16_t distanceNumberAtSixteen = [self.distanceNumber integerValue];
                int16_t distanceNumber = CFSwapInt16HostToLittle(distanceNumberAtSixteen);
                NSData *theDistanceNumberData = [NSData dataWithBytes:&distanceNumber length:sizeof(distanceNumberIntValue)];
                
                NSLog(@"self.distanceNumberData is %@", theDistanceNumberData);
                [peripheral writeValue:theDistanceNumberData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                
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
        NSData *peripheralValue = characteristic.value;
        NSData *decipherPeripheralValueData = [NSData dataWithBytes:[peripheralValue bytes] length:[peripheralValue length]];
        const uint8_t *bytes = [decipherPeripheralValueData bytes];
        int value = bytes[0];
        NSLog(@"value of bytes : %i", value);
        //reading the nsdata --> nsdata to nsstring --> not working, not nill, but can't via bytes in string
//        NSString *peripheralValueString = [NSString stringWithUTF8String:[peripheralValue bytes]];

        
        NSLog(@"peripheralValue of FFF6 is %@", peripheralValue);
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
        NSLog(@"didWriteValueForCharacteristic : %@", characteristic);
    }
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
