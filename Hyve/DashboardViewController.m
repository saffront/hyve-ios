//
//  DashboardViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/5/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "DashboardViewController.h"
#import "PeripheralListViewController.h"
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

/*
 Central has found Peripheral. Peripheral : <CBPeripheral: 0x1757a1f0, identifier = 1147F29D-876F-B2E4-565E-CEE139E445E7, name = VLT’s MacBook Pro, state = disconnected>, RSSI: -53, advertisementData: {
 kCBAdvDataIsConnectable = 1;
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
@property (strong, nonatomic) NSMutableArray *peripheralMutableArray;
@property BOOL firstTimeRunning;
@end


@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.peripheralMutableArray = [NSMutableArray new];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.centralManager.delegate = self;
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.isHyveButtonPressed = NO;
    self.firstTimeRunning = YES;
    self.hyveNetworkDetectionIndicatorImage.alpha = 0;
    [self stylingHyveLabel];
    [self stylingNavigationBar];
}

#pragma mark - viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.isHyveButtonPressed = NO;
    
    if (!self.firstTimeRunning)
    {
        [self.hyveNetworkDetectionIndicatorImage stopAnimating];
        self.detectingHyveLabel.alpha = 0;
        [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CABasicAnimation *slideDownAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            [slideDownAnimation setDelegate:self];
            slideDownAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(self.view.frame.size.width / 2, self.hyveButton.frame.origin.y + 100, self.hyveButton.frame.size.width, self.hyveButton.frame.size.height)];
            slideDownAnimation.fromValue = [NSValue valueWithCGPoint:self.hyveButton.layer.position];
            slideDownAnimation.autoreverses = NO;
            slideDownAnimation.repeatCount = 0;
            slideDownAnimation.duration = 0;
            slideDownAnimation.fillMode = kCAFillModeForwards;
            slideDownAnimation.removedOnCompletion = NO;
            slideDownAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [self.hyveButton.layer addAnimation:slideDownAnimation forKey:@"moveY"];
            
        } completion:^(BOOL finished) {
            
            NSLog(@"It's finished");
        }];
    }
}

#pragma mark - viewWillDisappear
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.firstTimeRunning = NO;
}

#pragma mark - styling navigation bar
-(void)stylingNavigationBar
{
    self.title = @"Hyve";
    
    self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                                         initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
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
            slideDownAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(self.view.frame.size.width / 2, self.hyveButton.frame.origin.y + 350, self.hyveButton.frame.size.width, self.hyveButton.frame.size.height)];
            slideDownAnimation.fromValue = [NSValue valueWithCGPoint:self.hyveButton.layer.position];
            slideDownAnimation.autoreverses = NO;
            slideDownAnimation.repeatCount = 0;
            slideDownAnimation.duration = 2;
            slideDownAnimation.fillMode = kCAFillModeForwards;
            slideDownAnimation.removedOnCompletion = NO;
            slideDownAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [self.hyveButton.layer addAnimation:slideDownAnimation forKey:@"moveY"];
            self.detectingHyveLabel.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(displayBluetoothNetworkDetectionIndicator) userInfo:nil repeats:NO];
            
//            NSArray *uuidArray = @[@"32A9DD44-9B1C-BAA5-8587-8A2D36E0623E"];
//            [self.centralManager retrievePeripheralsWithIdentifiers:uuidArray];
            
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
    
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
    
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timeoutScanningForHyve) userInfo:nil repeats:NO];
}

-(void)timeoutHyveDiscovery
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"We sense a great disturbance in the force..would you like to continue searching?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [NSTimer timerWithTimeInterval:60 target:self selector:@selector(timeoutHyveDiscovery) userInfo:nil repeats:NO];
    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:yesAction];
    [alertController addAction:noAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Core Bluetooth

//check to see if Bluetooth is on
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

    self.peripheral = peripheral;
    if (![self.peripheralMutableArray containsObject:self.peripheral])
    {
        [self.peripheralMutableArray addObject:self.peripheral];
    }


    NSLog(@"self.peripheralMutableArray.count %lu", (unsigned long)self.peripheralMutableArray.count);

//    if ([peripheral.name isEqualToString:@"VLT’s MacBook Pro"])
//    {
//        self.peripheral = peripheral;
//        [self.centralManager stopScan];
//        [self performSegueWithIdentifier:@"ShowPeripheralsList" sender:nil];
//    }
}

-(void)timeoutScanningForHyve
{
    [self.centralManager stopScan];
    [self performSegueWithIdentifier:@"ShowPeripheralsList" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PeripheralListViewController *plvc = segue.destinationViewController;
    plvc.peripheral = self.peripheral;
    plvc.centralManager = self.centralManager;
    plvc.peripheralMutableArray = self.peripheralMutableArray;
}





@end
