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
#import <Reachability.h>
#import <AFNetworking.h>

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

@property (weak, nonatomic) IBOutlet UIButton *hyveButton;
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
    
    self.isHyveButtonPressed = NO;
    [self.hyveButton setImage:[UIImage imageNamed:@"hyveLogo"] forState:UIControlStateNormal];
    self.hyveButton.contentMode = UIViewContentModeScaleAspectFit;
    self.hyveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.hyveButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    self.firstTimeRunning = YES;
    [self stylingNavigationBar];
    [self stylingBackgroundView];
//    [self connectToHyveServerToRetrievePairedHyve];
}

#pragma mark - detectingHyveLabel at intro
-(void)detectingHyveLabelAtIntro
{
    self.detectingHyveLabel.text = @"Tap on the icon below to start searching for Hyve";
    self.detectingHyveLabel.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:17];
    self.detectingHyveLabel.numberOfLines = 0;
    self.detectingHyveLabel.textColor = [UIColor blackColor];
}


#pragma mark - styling background view
-(void)stylingBackgroundView
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundView.image = [UIImage imageNamed:@"appBg"];
    [self.view addSubview:backgroundView];
}

#pragma mark - viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [self detectingHyveLabelAtIntro];
    self.isHyveButtonPressed = NO;
    
}

#pragma mark - viewWillDisappear
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    self.firstTimeRunning = NO;
}

#pragma mark - styling navigation bar
-(void)stylingNavigationBar
{
    
    UIImage *backButtonImage = [UIImage imageNamed:@"backButton"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 100, 30)];
    [backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
    
    UIBarButtonItem *backButtonOnBar = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonOnBar;
    
//    self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]
//                                                                         initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIFont *font = [UIFont fontWithName:@"OpenSans-SemiBold" size:18];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.89 green:0.39 blue:0.16 alpha:1]];
}

#pragma mark - styling detection hyve label
-(void)stylingDetectingHyveLabel
{
    self.detectingHyveLabel.text = [NSString stringWithFormat:@"Searching for Hyve \r\r This process will take 30 seconds"];
    self.detectingHyveLabel.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:17];
    self.detectingHyveLabel.textColor = [UIColor blackColor];
    self.detectingHyveLabel.numberOfLines = 0;
}

#pragma mark - pressing on Hyve button
- (IBAction)onHyveButtonPressed:(id)sender
{
    if (self.isHyveButtonPressed == NO)
    {
        [self displayBluetoothNetworkDetectionIndicator];
    }
}

#pragma mark - displaying Bluetooth network detection indicator
-(void)displayBluetoothNetworkDetectionIndicator
{
    UIImage *animate1 = [UIImage imageNamed:@"animate1"];
    UIImage *animate2 = [UIImage imageNamed:@"animate2"];
    UIImage *animate3 = [UIImage imageNamed:@"animate3"];
    UIImage *animate4 = [UIImage imageNamed:@"animate4"];
    UIImage *animate5 = [UIImage imageNamed:@"animate6"];
    UIImage *animate6 = [UIImage imageNamed:@"animate5"];

    NSMutableArray *bluetoothIndicatorImage = [NSMutableArray arrayWithObjects:animate1, animate2, animate3,animate4,animate5, animate6,nil];
    
    self.hyveButton.imageView.animationImages = bluetoothIndicatorImage;
    self.hyveButton.imageView.animationDuration = 3;
    [self.hyveButton.imageView startAnimating];
    
    [self stylingDetectingHyveLabel];
    
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
    self.hyveButton.userInteractionEnabled = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeoutScanningForHyve) userInfo:nil repeats:NO];
}

-(void)timeoutHyveDiscovery
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"We sense a great disturbance in the force..would you like to continue searching?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [NSTimer timerWithTimeInterval:30 target:self selector:@selector(timeoutHyveDiscovery) userInfo:nil repeats:NO];
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
            self.hyveButton.enabled = NO;
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"Central is on and ready to use");
            self.hyveButton.enabled = YES;
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
    self.hyveButton.userInteractionEnabled = YES;
}


#pragma mark - retrieve paired Hyve from server
-(void)connectToHyveServerToRetrievePairedHyve
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    if (reachability.isReachable)
    {
        [self retrievingPairedHyve];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:OKAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)retrievingPairedHyve
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *api_token = [userDefaults objectForKey:@"api_token"];
    
    NSString *hyveURLString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/hyves"];
    
    NSURL *url = [NSURL URLWithString:hyveURLString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:api_token forHTTPHeaderField:@"X-hyve-token"];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
       
        if (connectionError)
        {
            NSLog(@"Error found %@ \r localizedDescriptionError %@", connectionError, [connectionError localizedDescription]);
        }
        else
        {
            NSDictionary *theJSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"theJSONDictionary : \r %@", theJSONDictionary);
        }
        
    }];
    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
//    operation.responseSerializer = [AFJSONResponseSerializer serializer];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSLog(@"responseObject %@", responseObject);
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//       
//        NSLog(@"error %@ \r\r localizedError %@", error, [error localizedDescription]);
//        
//    }];
//    [operation start];
    
    
    
//    NSURL *hyveURL = [NSURL URLWithString:hyveURLString];
//    NSURLRequest *hyveURLRequest = [NSURLRequest requestWithURL:hyveURL];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:hyveURLRequest];
//    operation.responseSerializer = [AFJSONResponseSerializer serializer];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSLog(@"responseObject %@", responseObject);
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        NSLog(@"error to GET HYVE PAIRED %@ \r\r %@", error, [error localizedDescription]);
//        
//    }];
//    
//    [operation start];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PeripheralListViewController *plvc = segue.destinationViewController;
    plvc.peripheral = self.peripheral;
    plvc.centralManager = self.centralManager;
    plvc.peripheralMutableArray = self.peripheralMutableArray;
    [self.hyveButton.imageView stopAnimating];
}





@end
