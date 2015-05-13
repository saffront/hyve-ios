 //
//  PeripheralListViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/6/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import <Reachability.h>
#import <AFNetworking.h>
#import "PeripheralListViewController.h"
#import "HyveListViewController.h"
#import "Hyve.h"

@interface PeripheralListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *peripheralListTableView;
@property (strong, nonatomic) NSMutableArray *selectedDeviceMutableArray;
@property (weak, nonatomic) IBOutlet UIButton *pairButton;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (strong ,nonatomic) NSMutableDictionary *pairedHyveDictionary;
@property BOOL uuidError;

@end

@implementation PeripheralListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.uuidError = NO;
    self.selectedDeviceMutableArray = [NSMutableArray new];
    self.pairedHyveDictionary = [NSMutableDictionary new];
    
    [self promptingUserToPairDevice];
    [self stylingBackgroundView];
    [self pairButtonConfiguration];
    [self stylingInstructionLabel];
    [self stylingNavigationBar];
    [self stylingPeripheralListTableView];
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
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];

    
}

#pragma mark - styling background view
-(void)stylingBackgroundView
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundView.image = [UIImage imageNamed:@"appBg"];
    [self.view addSubview:backgroundView];
}

#pragma mark - styling nav bar
-(void)stylingNavigationBar
{
    self.title = @"Bluetooth Devices";
    
    UIImage *backButtonImage = [UIImage imageNamed:@"backButton"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 30, 30)];
    [backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButtonOnBar = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonOnBar;
    
    UIFont *font = [UIFont fontWithName:@"OpenSans-SemiBold" size:18];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor colorWithRed:0.89 green:0.39 blue:0.16 alpha:1]};
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.89 green:0.39 blue:0.16 alpha:1]];
    
}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - styling instruction label
-(void)stylingInstructionLabel
{
    self.instructionLabel.text = @"Please select which Hyve(s) you want to pair with:";
    self.instructionLabel.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:17];
    self.instructionLabel.numberOfLines = 0;
    
}

#pragma mark - styling peripheral list table view
-(void)stylingPeripheralListTableView
{
    self.peripheralListTableView.allowsMultipleSelection = YES;
    self.peripheralListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.peripheralListTableView setBackgroundColor:[UIColor clearColor]];
    self.peripheralListTableView.layoutMargins = UIEdgeInsetsZero;
    [self.peripheralListTableView setSeparatorInset:UIEdgeInsetsZero];
}

#pragma mark - pair button configuration
-(void)pairButtonConfiguration
{
    [self.pairButton setUserInteractionEnabled:YES];
    self.pairButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:22];
    [self.pairButton setTitle:@"Pair" forState:UIControlStateNormal];
    [self.pairButton setBackgroundColor:[UIColor colorWithRed:0.22 green:0.63 blue:0.80 alpha:1]];
    [self.pairButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}

#pragma mark - prompting user to pair device
-(void)promptingUserToPairDevice
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"We have found these devices around you. Some may not be your Hyve. Please pair up your Hyve(s)" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self connected];
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - table view delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.peripheralMutableArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Hyve *hyve = [Hyve new];
    if (self.peripheralMutableArray.count > 0)
    {
        self.peripheral = [self.peripheralMutableArray objectAtIndex:indexPath.row];
        hyve.peripheralName = self.peripheral.name;
        hyve.peripheralUUID = self.peripheral.identifier;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PeripheralCellID"];
    cell.backgroundColor = [UIColor clearColor];
    
    if ([hyve.peripheralName isEqualToString:@""] || hyve.peripheralName == nil)
    {
        cell.textLabel.text = @"Unknown device";
        cell.textLabel.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:20];
    }
    else
    {
        cell.textLabel.text = hyve.peripheralName;
        cell.textLabel.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:20];
    }    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.pairButton setUserInteractionEnabled:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        self.peripheral = [self.peripheralMutableArray objectAtIndex:indexPath.row];
        [self.selectedDeviceMutableArray addObject:self.peripheral];
        
        NSLog(@"self.selectedDeviceMutableArray didSelectRowAtIndexPath :%@", self.selectedDeviceMutableArray);
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        self.peripheral = [self.peripheralMutableArray objectAtIndex:indexPath.row];
        [self.selectedDeviceMutableArray removeObject:self.peripheral];
        
        NSLog(@"self.selectedDeviceMutableArray didDeselectRowAtIndexPath :%@", self.selectedDeviceMutableArray);
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

#pragma mark - pair button
- (IBAction)onPairButtonPressed:(id)sender
{
    if (self.selectedDeviceMutableArray.count > 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Do you want to pair up with the selected devices?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            for (CBPeripheral *pairedHyve in self.selectedDeviceMutableArray)
            {
                Hyve *hyve = [Hyve new];
                hyve.peripheralName = pairedHyve.name;
                hyve.peripheralUUIDString = pairedHyve.identifier.UUIDString;
                hyve.peripheralRSSI = @"1";
                
                if (pairedHyve.name == nil)
                {
                    hyve.peripheralName = @"Unknown device";
                }
                
                //passing in name and uuid
                self.pairedHyveDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:hyve.peripheralName,@"name",hyve.peripheralUUIDString,@"uuid",hyve.peripheralRSSI,@"distance",nil];
                [self sendingPairedHyveToBackend:self.pairedHyveDictionary];
            }
        }];
        
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:noAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Please select your Hyve devices to pair with." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - saving paired devices to Hyve
-(void)sendingPairedHyveToBackend:(NSMutableDictionary*)hyveletsPairedDictionary
{
    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    if (reachability.isReachable)
    {
        //connect to hyve backend
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self connectToHyveBackend:hyveletsPairedDictionary];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble connecting to server. Unable to pair selected device" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:OKAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)connectToHyveBackend:(NSMutableDictionary*)hyveletsDictionary
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *api_token = [userDefaults objectForKey:@"api_token"];
    NSString *email = [userDefaults objectForKey:@"email"];
    
    NSString *hyveURLString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/hyves"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:api_token forHTTPHeaderField:@"X-hyve-token"];
    [manager.requestSerializer setTimeoutInterval:20];
    
    [manager POST:hyveURLString parameters:hyveletsDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *invalid = [[responseObject valueForKeyPath:@"errors.distance"] objectAtIndex:0];
        NSLog(@"distanceInvalid %@", invalid);
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self performSegueWithIdentifier:@"ShowHyveListVC" sender:nil];
                
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error %@ \r \r error localized:%@", error, [error localizedDescription]);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity. Unable to pair with Hyve" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }];
}

#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    HyveListViewController *hlvc = segue.destinationViewController;
    hlvc.hyveDevicesMutableArray = self.selectedDeviceMutableArray;
    hlvc.centralManager = self.centralManager;
}

@end
