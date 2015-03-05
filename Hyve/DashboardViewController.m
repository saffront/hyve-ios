//
//  DashboardViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/5/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "DashboardViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "Hyve.h"
#import <POP.h>
// 5F10970D-4751-8EAE-0E80-FCA227055CB5 --- name=rpts , kCBAdvDataServiceUUIDs = FFF0,
/*
 Central has found Peripheral. Peripheral : <CBPeripheral: 0x17e5f8c0, identifier = 5F10970D-4751-8EAE-0E80-FCA227055CB5, name = rpts, state = disconnected>, RSSI: 127, advertisementData: {
 kCBAdvDataIsConnectable = 1;
 kCBAdvDataLocalName = rpts;
 kCBAdvDataManufacturerData = <0112>;
 kCBAdvDataServiceUUIDs =     (
 FFF0
 );
 kCBAdvDataTxPowerLevel = 4;
 }
*/

@interface DashboardViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (weak, nonatomic) IBOutlet UILabel *hyveLabel;
@property (weak, nonatomic) IBOutlet UIButton *hyveButton;
@property (weak, nonatomic) IBOutlet UIImageView *hyveNetworkDetectionIndicatorImage;
@property BOOL isHyveButtonPressed;
@property (weak, nonatomic) IBOutlet UILabel *detectingHyveLabel;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) Hyve *hyve;
@property (strong, nonatomic) CBPeripheral *peripheral;
@end


@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.centralManager.delegate = self;
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.isHyveButtonPressed = NO;
    self.hyveNetworkDetectionIndicatorImage.alpha = 0;
    [self stylingHyveLabel];
}

#pragma mark - styling Hyve label
-(void)stylingHyveLabel
{
    self.hyveLabel.text = @"Hyve";
    self.hyveLabel.numberOfLines = 0;
    self.hyveLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:40];
    self.hyveLabel.textColor = [UIColor lightTextColor];
}

#pragma mark - styling detection hyve label
-(void)stylingDetectingHyveLabel
{
    self.detectingHyveLabel.text = [NSString stringWithFormat:@"Searching for Hyve"];
    self.detectingHyveLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
    self.detectingHyveLabel.textColor = [UIColor whiteColor];
    self.detectingHyveLabel.numberOfLines = 0;
    
}


#pragma mark - pressing on Hyve button
- (IBAction)onHyveButtonPressed:(id)sender
{
    if (self.isHyveButtonPressed == NO)
    {
        [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CABasicAnimation *slideDownAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            [slideDownAnimation setDelegate:self];
            slideDownAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(self.view.frame.size.width / 2, self.hyveButton.frame.origin.y + 400, self.hyveButton.frame.size.width, self.hyveButton.frame.size.height)];
            slideDownAnimation.fromValue = [NSValue valueWithCGPoint:self.hyveButton.layer.position];
            slideDownAnimation.autoreverses = NO;
            slideDownAnimation.repeatCount = 0;
            slideDownAnimation.duration = 2;
            slideDownAnimation.fillMode = kCAFillModeForwards;
            slideDownAnimation.removedOnCompletion = NO;
            slideDownAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [self.hyveButton.layer addAnimation:slideDownAnimation forKey:@"moveY"];
            
        } completion:^(BOOL finished) {
            
            [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(displayBluetoothNetworkDetectionIndicator) userInfo:nil repeats:NO];
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        }];
    }
}

#pragma mark - displaying Bluetooth network detection indicator
-(void)displayBluetoothNetworkDetectionIndicator
{
    self.hyveNetworkDetectionIndicatorImage.alpha = 1;
    
    UIImage *bluetooth1 = [UIImage imageNamed:@"bluetooth1"];
    UIImage *bluetooth2 = [UIImage imageNamed:@"bluetooth2"];
    UIImage *bluetooth3 = [UIImage imageNamed:@"bluetooth3"];
    
    NSMutableArray *bluetoothIndicatorImage = [NSMutableArray arrayWithObjects:bluetooth1, bluetooth2, bluetooth3, nil];
    
    self.hyveNetworkDetectionIndicatorImage.animationImages = bluetoothIndicatorImage;
    self.hyveNetworkDetectionIndicatorImage.animationDuration = 2;
    self.hyveNetworkDetectionIndicatorImage.backgroundColor = [UIColor clearColor];
    [self.hyveNetworkDetectionIndicatorImage startAnimating];
    
    [self stylingDetectingHyveLabel];
//    self.hyveNetworkDetectionIndicatorImage.alpha = 1;
//    self.hyveNetworkDetectionIndicatorImage.image = [UIImage imageNamed:@"jlaw"];
//    
//    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeAnimation.duration = 1.3;
//    fadeAnimation.repeatCount = 1e1000f;
//    fadeAnimation.autoreverses = YES;
//    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
//    fadeAnimation.toValue = [NSNumber numberWithFloat:0.1];
//    
//    [self.hyveNetworkDetectionIndicatorImage.layer addAnimation:fadeAnimation forKey:@"animateOpacity"];
}

#pragma mark - Core Bluetooth

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

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Central has found Peripheral. Peripheral : %@, RSSI: %@, advertisementData: %@", peripheral, RSSI, advertisementData);

//    if ([peripheral.name isEqualToString:self.hyve.peripheralName])
//    {
//        self.peripheral = peripheral;
//        [self.centralManager stopScan];
//    }

}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Central has connected to peripheral: %@ with UUID: %@",peripheral,peripheral.identifier);
    peripheral.delegate = self;
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

-(void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"didReceivePeripherals");
    
    for (CBPeripheral *peripheral in peripherals)
    {
        NSLog(@"Peripherals Array has %@  == >peripheral %@ %@",peripherals, peripheral, peripheral.identifier);
    }
}




@end
