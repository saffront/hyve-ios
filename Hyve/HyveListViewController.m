//
//  HyveListViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/6/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import <DKCircleButton.h>
#import <QuartzCore/QuartzCore.h>
#import "UserAccountViewController.h"
#import "HyveListTableViewCell.h"
#import "HyveListViewController.h"
#import "HyveDetailsViewController.h"
#import "ScannedNewHyveViewController.h"
#import "Hyve.h"
#import <AFNetworking.h>
#import <Reachability.h>
#import <BlurryModalSegue.h>
#import <QuartzCore/QuartzCore.h>
#import <POP.h>
#import <MBLoadingIndicator.h>
#import <KVNProgress.h>

@interface HyveListViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, CBPeripheralDelegate, UIGestureRecognizerDelegate, CBCentralManagerDelegate>

@property (strong, nonatomic) Hyve *hyve;
@property (strong, nonatomic) DKCircleButton *userProfileImageButton;
@property (weak, nonatomic) IBOutlet UITableView *hyveListTable;
@property float defaultY;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) MBLoadingIndicator *loadingIndicator;
@property (strong, nonatomic) UIImage *userProfileImage;
@property (strong, nonatomic) DKCircleButton *swarmHyveButton;
@property (strong, nonatomic) NSString *RSSI;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSString *RSSIString;
@property BOOL patchedSwarmInfo;
@property (strong, nonatomic) UIView *hyveListTableViewFooter;
@property (strong, nonatomic) UILongPressGestureRecognizer *swarmButtonLongPressGesture;
@property (nonatomic) KVNProgressConfiguration *loadingProgressView;
@property  BOOL fromUserAccountVC;
@property (strong, nonatomic) NSMutableArray *scannedNewHyveMutableArray;
@property (strong, nonatomic) CBCentralManager *scanNewHyveCentralManager;
@property (strong, nonatomic) NSMutableArray *mutableNewArray;
@property BOOL hyveIsFound;
@property (strong, nonatomic) NSData *buzzData;
@property (strong, nonatomic) UIButton *swarmMenuButton;
@property (strong, nonatomic) UIButton *scanHyveButton;
@property (strong, nonatomic) UIButton *swarmButton;

@end

@implementation HyveListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self settingLoadingProgressView];
    self.hyveIsFound = NO;
    self.mutableNewArray = [NSMutableArray new];
    self.scannedNewHyveMutableArray = [NSMutableArray new];
    self.centralManager.delegate = self;
    
    self.fromUserAccountVC = NO;
    self.patchedSwarmInfo = NO;
    [self connectToHyve];
    [self stylingBackgroundView];
    [self stylingNavigationBar];
    [self stylingHyveListTableView];

    [self connected];
    [self setDefaultUserProfile];
    
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

#pragma mark - default user profile
-(void)setDefaultUserProfile
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        UIView *userProfileHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.hyveListTable.frame.size.width, 200)];
        [userProfileHeader setUserInteractionEnabled:YES];
        [userProfileHeader bringSubviewToFront:self.loadingIndicator];
        userProfileHeader.alpha = 0;
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -200, userProfileHeader.frame.size.width, userProfileHeader.frame.size.height + 200)];
        backgroundImageView.alpha = 0;
        
        self.userProfileImageButton = [[DKCircleButton alloc] initWithFrame:CGRectMake(userProfileHeader.frame.size.width / 2, 80, 100, 100)];
        [self.userProfileImageButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.userProfileImageButton setUserInteractionEnabled:YES];
        [self.userProfileImageButton setTitle:@"" forState:UIControlStateNormal];
        [self.userProfileImageButton setCenter:CGPointMake(CGRectGetMidX(userProfileHeader.bounds), CGRectGetMidY(userProfileHeader.bounds))];
        [self.userProfileImageButton addTarget:self action:@selector(userProfileImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.userProfileImage = [UIImage imageNamed:@"defaultUserProfileImage"];
        self.userProfileImageButton.alpha = 0;

        float positionOfUsernameCoordinateY = userProfileHeader.frame.origin.y + 370;
        UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(backgroundImageView.frame.size.width/2, positionOfUsernameCoordinateY, 250, 40)];
        username.textAlignment = NSTextAlignmentCenter;
        username.numberOfLines = 0;
        username.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:20];
        username.textColor = [UIColor whiteColor];
        [username setCenter:CGPointMake(CGRectGetMidX(backgroundImageView.bounds), positionOfUsernameCoordinateY)];
        username.alpha = 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            backgroundImageView.image = [UIImage imageNamed:@"userProfileHeader"];
            [self.userProfileImageButton setImage:self.userProfileImage forState:UIControlStateNormal];
            [self.userProfileImageButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
            self.userProfileImageButton.imageView.clipsToBounds = YES;
            
            [userProfileHeader addSubview:self.userProfileImageButton];
            username.text = @"Hyve";
            [backgroundImageView addSubview:username];
            
            [userProfileHeader addSubview:backgroundImageView];
            [userProfileHeader bringSubviewToFront:self.userProfileImageButton];
            
            self.hyveListTable.tableHeaderView = userProfileHeader;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            if (self.fromUserAccountVC == NO) {
                self.loadingProgressView.minimumSuccessDisplayTime = 1.5;
                [KVNProgress showSuccessWithStatus:@"Pairing successful!"];
                self.fromUserAccountVC = YES;
                self.hyveListTable.alpha = 1;
                self.userProfileImageButton.alpha = 1;
                userProfileHeader.alpha = 1;
                backgroundImageView.alpha = 1;
                username.alpha = 1;
            }
        });
    });
}

#pragma mark - viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(populateTableWithNewScannedHyve:) name:@"scannedNewHyve" object:nil];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingUserImage:) name:@"user" object:nil];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hyveListTable reloadData];
    });
}

#pragma mark - loading progress view
-(void)settingLoadingProgressView
{
    self.loadingProgressView = [KVNProgressConfiguration defaultConfiguration];
    [KVNProgress setConfiguration:self.loadingProgressView];
    self.loadingProgressView.backgroundType = KVNProgressBackgroundTypeBlurred;
    self.loadingProgressView.fullScreen = YES;
    self.loadingProgressView.minimumDisplayTime = 1;
    
    [KVNProgress showWithStatus:@"Loading..."];
    
    self.hyveListTable.alpha = 0;
    self.userProfileImageButton.alpha = 0;
}

#pragma mark - swarm
-(void)holdOntoSwarmButton
{
    NSLog(@"Swarm button is hold down");
    
    for (CBPeripheral *peripheral in self.hyveDevicesMutableArray) {
        
        if (peripheral.state == CBPeripheralStateConnected)
        {
            NSLog(@"peripheral %@", peripheral);
            peripheral.delegate = self;
            [peripheral readRSSI];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    for (CBPeripheral *hyvePeripheral in self.hyveDevicesMutableArray)
    {
        if ([hyvePeripheral isEqual:peripheral])
        {
            NSLog(@"peripheral %@ \r peripheral RSSI %@", peripheral.name, RSSI);
            
            [self updateHyveProximityToHyveServerViaSwarm:RSSI peripheral:peripheral];
        }
    }
}

-(void)updateHyveProximityToHyveServerViaSwarm:(NSNumber*)RSSI peripheral:(CBPeripheral*)peripheral
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *api_token = [userDefaults objectForKey:@"api_token"];
    
    NSNumber *negativeOneHundres = [NSNumber numberWithInt:-100];
    
    if ([RSSI doubleValue] < [negativeOneHundres doubleValue]) //less than -100 ex. -101,-102 and etc..
    {
        self.RSSIString = @"out of range";
    }
    else
    {
        self.RSSIString = @"close by";
    }
    
    NSDictionary *hyveDictionary = @{@"name":peripheral.name,
                                     @"proximity":self.RSSIString,
                                     @"uuid":[peripheral.identifier UUIDString]};
    
    NSString *uuid = [peripheral.identifier UUIDString];
    NSString *hyveUserAccountString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/hyves/%@",uuid];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:api_token forHTTPHeaderField:@"X-hyve-token"];
    [manager.requestSerializer setTimeoutInterval:20];
    
    [manager PATCH:hyveUserAccountString parameters:hyveDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"responseObject: \r %@", responseObject);
        self.patchedSwarmInfo = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hyveListTable reloadData];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity. Unable update hyve" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        NSLog(@"Error: \r %@ \r localized description: %@", error, [error localizedDescription]);
    }];
}

#pragma mark - notifications
#pragma mark - setting user info
-(void)settingUserImage:(NSNotification*)notification
{
    NSDictionary *user = notification.object;

    NSString *username = [user objectForKey:@"username"];
    NSString *userProfileImage = [user objectForKey:@"userAvatarUR"];
    
    [self settingHeaderForHyveListTable:username imageURLString:userProfileImage];
}

#pragma mark - populateTableWithNewScannedHyve
-(void)populateTableWithNewScannedHyve:(NSNotification*)notification
{
    [self.scannedNewHyveMutableArray removeAllObjects];
    NSMutableArray *newScannedHyveMutableArray = notification.object;
    
    [self.hyveDevicesMutableArray addObjectsFromArray:newScannedHyveMutableArray];
    
    NSLog(@"self.hyveDevicesMutableArray %@", self.hyveDevicesMutableArray);
        
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hyveListTable reloadData];
    });
}

#pragma mark - styling navigation bar
-(void)stylingNavigationBar
{
    [self.navigationItem setHidesBackButton:YES];
}


#pragma mark - retrieve user info and paired Hyve
-(void)connectToHyve
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    if (reachability.isReachable)
    {
        [self retrieveUserInfoAndPairedHyve];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self retrieveUserInfoAndPairedHyve];
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)retrieveUserInfoAndPairedHyve
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *api_token = [userDefaults objectForKey:@"api_token"];
    
    NSString *hyveURLString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/account"];
    
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if (reachability.isReachable)
    {
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:api_token forHTTPHeaderField:@"X-hyve-token"];
        [manager.requestSerializer setTimeoutInterval:20];
    }
    else
    {
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:api_token forHTTPHeaderField:@"X-hyve-token"];
        [manager.requestSerializer setTimeoutInterval:20];
        [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    }
    
    [manager GET:hyveURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"responseObject retrieveUserInfoAndPairedHyve: \r\r %@", responseObject);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            NSString *username = [responseObject valueForKeyPath:@"user.username"];
            NSString *avatarURLString = [responseObject valueForKeyPath:@"user.avatar.avatar.url"];
           
            NSArray *hyvesArray = [responseObject valueForKeyPath:@"user.hyves"];
            
            for (NSDictionary *pairedHyves in hyvesArray)
            {
                self.hyve = [Hyve new];
                self.hyve.peripheralName = [pairedHyves valueForKeyPath:@"name"];
                self.hyve.peripheralUUIDString = [pairedHyves valueForKeyPath:@"uuid"];
                self.hyve.peripheralRSSI = [pairedHyves valueForKeyPath:@"distance"];
                self.hyve.hyveID = [pairedHyves valueForKeyPath:@"id"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self settingHeaderForHyveListTable:username imageURLString:avatarURLString];
            });
            
        });
            
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error with retrieveUserInfoAndPairedHyve: \r\r %@ \r localizedDescription: \r %@", error, [error localizedDescription]);
        
        if (error)
        {
            [KVNProgress dismiss];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    }];
}

-(void)populateCellHyveImage:(HyveListTableViewCell*)cell withHyve:(Hyve*)hyve
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [cell.hyveImage setImage:[UIImage imageNamed:@"defaultHyveImage"] forState:UIControlStateNormal];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *api_token = [userDefaults objectForKey:@"api_token"];
    
    NSString *hyveURLString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/account"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:api_token forHTTPHeaderField:@"X-hyve-token"];
    [manager.requestSerializer setTimeoutInterval:20];
    
    [manager GET:hyveURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"responseObject retrieveUserInfoAndPairedHyve: \r\r %@", responseObject);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            NSArray *hyvesArray = [responseObject valueForKeyPath:@"user.hyves"];
            
            for (NSDictionary *pairedHyves in hyvesArray)
            {                
                NSString *peripheralUUIDStringFromHyveServer = [pairedHyves valueForKeyPath:@"uuid"];
                
                if ([peripheralUUIDStringFromHyveServer isEqualToString:hyve.peripheralUUIDString])
                {
                    hyve.imageURLString = [pairedHyves valueForKeyPath:@"image.image.url"];
                    
                    if ([hyve.imageURLString isKindOfClass:[NSNull class]])
                    {
                        NSLog(@"imageURLString : %@", hyve.imageURLString);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [cell.hyveImage setImage:[UIImage imageNamed:@"defaultHyveImage"] forState:UIControlStateNormal];
                            cell.hyveImage.contentMode = UIViewContentModeScaleAspectFill;
                            cell.hyveImage.borderColor = [UIColor whiteColor];
                            cell.hyveImage.userInteractionEnabled = NO;
                            cell.hyveImage.borderSize = 3.0f;
                        });
                    }
                    else if ([hyve.imageURLString isEqualToString:@""])
                    {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [cell.hyveImage setImage:[UIImage imageNamed:@"defaultHyveImage"] forState:UIControlStateNormal];
                            cell.hyveImage.contentMode = UIViewContentModeScaleAspectFill;
                            cell.hyveImage.borderColor = [UIColor whiteColor];
                            cell.hyveImage.userInteractionEnabled = NO;
                            cell.hyveImage.borderSize = 3.0f;
                        });
                    }
                    else
                    {
                        NSURL *imageURL = [NSURL URLWithString:hyve.imageURLString];
                        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                        UIImage *hyveImage = [UIImage imageWithData:imageData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [cell.hyveImage setImage:hyveImage forState:UIControlStateNormal];
                            cell.hyveImage.contentMode = UIViewContentModeScaleAspectFill;
                            cell.hyveImage.borderColor = [UIColor whiteColor];
                            cell.hyveImage.userInteractionEnabled = NO;
                            cell.hyveImage.borderSize = 3.0f;
                        });
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [KVNProgress dismiss];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity. Info may not be real time" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        NSLog(@"error with retrieveUserInfoAndPairedHyve: \r\r %@ \r localizedDescription: \r %@", error, [error localizedDescription]);
        
    }];
}

-(void)populateCellHyveProximity:(HyveListTableViewCell*)cell withHyve:(Hyve*)hyve
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *api_token = [userDefaults objectForKey:@"api_token"];
    
    NSString *hyveURLString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/account"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:api_token forHTTPHeaderField:@"X-hyve-token"];
    [manager.requestSerializer setTimeoutInterval:20];
    
    [manager GET:hyveURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"responseObject : %@", responseObject);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
           
            NSArray *hyvesArray = [responseObject valueForKeyPath:@"user.hyves"];
            
            for (NSDictionary *hyvesInfo in hyvesArray)
            {
                NSString *peripheralUUIDStringFromHyveServer = [hyvesInfo valueForKeyPath:@"uuid"];
                
                if ([peripheralUUIDStringFromHyveServer isEqualToString:hyve.peripheralUUIDString])
                {
                    NSString *proximity = [hyvesInfo valueForKeyPath:@"proximity"];
                    
                    if ([proximity isKindOfClass:[NSNull class]])
                    {
                        NSLog(@"proximity is null");
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                           
//                            cell.hyveProximity.text = proximity;
                            cell.hyveProximity.text = [NSString stringWithFormat:@"Proximity: %@",proximity];
                            
                            if ([cell.hyveProximity.text isEqualToString:@"Proximity: close by"])
//                            if ([cell.hyveProximity.text isEqualToString:@"close by"])
                            {
                                cell.hyveProximity.textColor = [UIColor greenColor];
                                cell.hyveProximity.numberOfLines = 0;
                                cell.hyveProximity.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:16];
                            }
                            else
                            {
                                cell.hyveProximity.textColor = [UIColor redColor];
                                cell.hyveProximity.numberOfLines = 0;
                                cell.hyveProximity.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:16];
                            }
                            
                            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                            
                        });
                    }
                }
            }
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    }];
    self.patchedSwarmInfo = NO;
}

#pragma mark - styling background view
-(void)stylingBackgroundView
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundView.image = [UIImage imageNamed:@"appBg"];
    [self.view addSubview:backgroundView];
}

#pragma mark - styling hyve list table view
-(void)stylingHyveListTableView
{
    self.hyveListTable.tableHeaderView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.hyveListTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.hyveListTable.backgroundColor = [UIColor clearColor];
    self.hyveListTable.layoutMargins = UIEdgeInsetsZero;
    self.hyveListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.hyveListTable setSeparatorInset:UIEdgeInsetsZero];
}

#pragma mark - table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.hyveDevicesMutableArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    CBPeripheral *peripheral = [self.hyveDevicesMutableArray objectAtIndex:indexPath.row];
    self.hyve = [Hyve new];
    self.hyve.peripheralName = peripheral.name;
    self.hyve.peripheralUUID = peripheral.identifier;
    self.hyve.peripheralUUIDString = [peripheral.identifier UUIDString];

    HyveListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HyveCellListVC"];
    if (cell == nil)
    {
        cell = [[HyveListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HyveCellListVC"];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.hyveContentView.backgroundColor = [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:0.4];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self.hyve.peripheralName isEqualToString:@""] || self.hyve.peripheralName == nil)
    {
        cell.hyveName.text = @"Unkown devices";
        cell.hyveName.font = [UIFont fontWithName:@"OpenSans-Bold" size:22];
        cell.hyveName.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        [cell.hyveImage setImage:[UIImage imageNamed:@"defaultHyveImage"] forState:UIControlStateNormal];
        cell.hyveBattery.alpha = 0;
        cell.hyveProximity.alpha = 0;
        cell.hyveName.numberOfLines = 0;
    }
    else
    {
        cell.hyveBattery.alpha = 1;
        cell.hyveProximity.alpha = 1;
        
        cell.hyveName.text = self.hyve.peripheralName;
        cell.hyveName.font = [UIFont fontWithName:@"OpenSans-Bold" size:22];
        cell.hyveName.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        cell.hyveName.numberOfLines = 0;
        
        cell.hyveBattery.text = [NSString stringWithFormat:@"Battery: Strong"];
        cell.hyveBattery.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:14];
        cell.hyveBattery.textColor = [UIColor whiteColor];
        cell.hyveBattery.numberOfLines = 0;
    
        [self populateCellHyveImage:cell withHyve:self.hyve];
        
        if (peripheral.state == CBPeripheralStateConnected)
        {
//            cell.hyveProximity.text = @"Hyve is connected";
            cell.hyveProximity.text = @"Proximity: Connected";
            cell.hyveProximity.textColor = [UIColor whiteColor];
            cell.hyveProximity.numberOfLines = 0;
            cell.hyveProximity.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:14];
        }
        else
        {
//            cell.hyveProximity.text = @"Hyve not connected";
            cell.hyveProximity.text = @"Proximity: Not Connected";
            cell.hyveProximity.textColor = [UIColor whiteColor];
            cell.hyveProximity.numberOfLines = 0;
            cell.hyveProximity.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:14];
        }
        
        if (self.patchedSwarmInfo == YES)
        {
            if (peripheral.state == CBPeripheralStateConnected)
            {
                [self populateCellHyveProximity:cell withHyve:self.hyve];
            }
        }
    }
    return cell;
}

//footer
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 100;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.hyveListTableViewFooter == nil)
    {
        self.hyveListTableViewFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        self.hyveListTableViewFooter.backgroundColor = [UIColor clearColor];
        
        self.swarmMenuButton = [[UIButton alloc] initWithFrame:CGRectMake(self.hyveListTableViewFooter.frame.size.width / 2, 50, 70, 70)];
        self.swarmMenuButton.tag = 1;
        [self.swarmMenuButton setCenter:CGPointMake(CGRectGetMidX(self.hyveListTableViewFooter.bounds), CGRectGetMidY(self.hyveListTableViewFooter.bounds))];
        [self.swarmMenuButton setImage:[UIImage imageNamed:@"hexMenuHamburger"] forState:UIControlStateNormal];
        [self.swarmMenuButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.swarmMenuButton addTarget:self action:@selector(onHyveMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.scanHyveButton = [[UIButton alloc] initWithFrame:CGRectMake(self.hyveListTableViewFooter.frame.size.width / 2, self.hyveListTableViewFooter.frame.size.height / 2, 70, 70)];
        [self.scanHyveButton setCenter:CGPointMake(CGRectGetMidX(self.hyveListTableViewFooter.bounds) - 80, CGRectGetMidY(self.hyveListTableViewFooter.bounds))];
        [self.scanHyveButton setImage:[UIImage imageNamed:@"scan"] forState:UIControlStateNormal];
        [self.scanHyveButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.scanHyveButton addTarget:self action:@selector(onScanHyveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.scanHyveButton.alpha = 0;
        
        self.swarmButton = [[UIButton alloc] initWithFrame:CGRectMake(self.hyveListTableViewFooter.frame.size.width / 2 - 130, 50, 70, 70)];
        [self.swarmButton setCenter:CGPointMake(CGRectGetMidX(self.hyveListTableViewFooter.bounds), CGRectGetMidY(self.hyveListTableViewFooter.bounds))];
        [self.swarmButton setImage:[UIImage imageNamed:@"swarm1"] forState:UIControlStateNormal];
        [self.swarmButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.swarmButton addTarget:self action:@selector(onSwarmButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.swarmButton.alpha = 0;
        
        [self.hyveListTableViewFooter addSubview:self.swarmMenuButton];
        [self.hyveListTableViewFooter addSubview:self.scanHyveButton];
        [self.hyveListTableViewFooter addSubview:self.swarmButton];
        self.hyveListTableViewFooter.userInteractionEnabled = YES;
    }
    
    return self.hyveListTableViewFooter;
}

-(void)onSwarmButtonPressed:(DKCircleButton*)sender
{
    NSLog(@"swarm button pressed!");
    [self holdOntoSwarmButton];
}

-(void)onScanHyveButtonPressed:(id)sender
{
    NSLog(@"scan hyve button pressed!");
    
    self.scanNewHyveCentralManager = self.centralManager;
    
    [self.scanNewHyveCentralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
    self.scanHyveButton.userInteractionEnabled = NO;
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeoutScanningForNewHyve) userInfo:nil repeats:NO];
    
    self.loadingProgressView = [KVNProgressConfiguration defaultConfiguration];
    [KVNProgress setConfiguration:self.loadingProgressView];
    self.loadingProgressView.backgroundType = KVNProgressBackgroundTypeBlurred;
    self.loadingProgressView.fullScreen = YES;
    
    self.loadingProgressView.minimumDisplayTime = 1;
    [KVNProgress showWithStatus:@"Scanning \r\r Please hold for 10 secs"];
}

//central manager delegate
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
    
    CBPeripheral *newHyve = peripheral;
    
    for (CBPeripheral *pairedHyve in self.hyveDevicesMutableArray)
    {
        self.hyveIsFound = NO;
        if ([pairedHyve.identifier.UUIDString isEqualToString:newHyve.identifier.UUIDString])
        {
            self.hyveIsFound = YES;
            break;
        }
    }
    
    if (self.hyveIsFound == NO)
    {
        if (![self.scannedNewHyveMutableArray containsObject:newHyve])
        {
            [self.scannedNewHyveMutableArray addObject:newHyve];
        }
    }
}

-(void)timeoutScanningForNewHyve
{
    [self.scanNewHyveCentralManager stopScan];
    
    NSLog(@"self.scannedNewHyveMutableArray: %@ \r self.scannedNewHyveMutableArray.count \r %lu", self.scannedNewHyveMutableArray, (unsigned long)self.scannedNewHyveMutableArray.count);
    self.scanHyveButton.userInteractionEnabled = YES;
    
    [KVNProgress dismissWithCompletion:^{
        [self performSegueWithIdentifier:@"ToScannedNewHyveVC" sender:nil];
    }];
}

-(void)onHyveMenuButtonPressed:(DKCircleButton*)sender
{
    NSLog(@"HYVE MENU BUTTON PRESSED");

    CGPoint finalPosition = CGPointMake(self.hyveListTable.frame.size.width / 2 + 90, 50);
    POPSpringAnimation *moveSwarmButtonAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    if (sender.tag == 1)
    {
        moveSwarmButtonAnimation.toValue = [NSValue valueWithCGPoint:finalPosition];
        moveSwarmButtonAnimation.springBounciness = 10;
        moveSwarmButtonAnimation.springSpeed = 2;
        
        POPSpringAnimation *spinAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
        spinAnimation.fromValue = @(M_PI / 8);
        spinAnimation.toValue = @(0);
        spinAnimation.springBounciness = 5;
        spinAnimation.velocity = @(20);
        [self.swarmMenuButton.layer pop_addAnimation:moveSwarmButtonAnimation forKey:@"move"];
        [self.swarmMenuButton.layer pop_addAnimation:spinAnimation forKey:@"rotation"];
        
        [self.swarmMenuButton pop_removeAllAnimations];
        POPBasicAnimation *fadingAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        fadingAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        fadingAnimation.fromValue = @(0.0);
        fadingAnimation.toValue = @(1.0);
        
        [self.swarmButton pop_addAnimation:fadingAnimation forKey:@"fade"];
        [self.scanHyveButton pop_addAnimation:fadingAnimation forKey:@"fade"];
        
        sender.tag = 2;
    }
    else if (sender.tag == 2)
    {
        POPBasicAnimation *fadingAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        fadingAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        fadingAnimation.fromValue = @(1.0);
        fadingAnimation.toValue = @(0.0);
        [self.swarmButton pop_addAnimation:fadingAnimation forKey:@"fade"];
        [self.scanHyveButton pop_addAnimation:fadingAnimation forKey:@"fade"];
        
        CGPoint originalPosition = CGPointMake(finalPosition.x - 90, self.swarmHyveButton.frame.origin.y);
        
        moveSwarmButtonAnimation.toValue = [NSValue valueWithCGPoint:originalPosition];
        moveSwarmButtonAnimation.springBounciness = 20;
        moveSwarmButtonAnimation.springSpeed = 2;
    
        [self.swarmMenuButton.layer pop_addAnimation:moveSwarmButtonAnimation forKey:@"move"];
        moveSwarmButtonAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            sender.tag = 1;
        };
    }
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CBPeripheral *peripheralToBeBuzzed = [self.hyveDevicesMutableArray objectAtIndex:indexPath.row];
    
    NSString *buzz = @"Buzz";
    NSString *buzzWithSpace = [buzz stringByPaddingToLength:10 withString:@" " startingAtIndex:0];
    
    
    UITableViewRowAction *buzzAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:buzzWithSpace handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        if (peripheralToBeBuzzed.state == CBPeripheralStateConnected)
        {
            if ([action.title isEqualToString:@"Buzz"])
            {
                uint8_t byte[1];
                byte[0]='a';
                
                self.buzzData = [NSData dataWithBytes:byte length:1];
                
                [peripheralToBeBuzzed discoverServices:nil];
                action.title = @"Shh...";
                
                [buzzAction setTitle:@"Shh..."];
            }
            else if ([action.title isEqualToString:@"Shh..."])
            {
                uint8_t byte[1];
                byte[0]='b';
                
                self.buzzData = [NSData dataWithBytes:byte length:1];
                
                [peripheralToBeBuzzed discoverServices:nil];
                buzzAction.title = @"Buzz";
            }
        }
    }];
    buzzAction.backgroundColor = [UIColor colorWithRed:0.89 green:0.39 blue:0.16 alpha:1];
    
    UITableViewRowAction *disconnectAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Disconnect"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        CBPeripheral *peripheralToBeDisconnected = [self.hyveDevicesMutableArray objectAtIndex:indexPath.row];
        [self.centralManager cancelPeripheralConnection:peripheralToBeDisconnected];
        [self.hyveListTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }];
    disconnectAction.backgroundColor = [UIColor colorWithRed:0.22 green:0.63 blue:0.80 alpha:1];
    
    
    UITableViewRowAction *unbuzzAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Unbuzz" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
       
        uint8_t byte[1];
        byte[0]='b';
        
        self.buzzData = [NSData dataWithBytes:byte length:1];
        
        [peripheralToBeBuzzed discoverServices:nil];
    }];
    unbuzzAction.backgroundColor = [UIColor colorWithRed:1 green:0.64 blue:0 alpha:1];
    
    return @[unbuzzAction, buzzAction,disconnectAction];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        NSLog(@"pressed");
//        CBPeripheral *peripheralToBeDisconnected = [self.hyveDevicesMutableArray objectAtIndex:indexPath.row];
//        [self.centralManager cancelPeripheralConnection:peripheralToBeDisconnected];
//        
//        [self.hyveListTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)settingHeaderForHyveListTable:(NSString*)usernameFromHyve imageURLString:(NSString*)imageURLString
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.userProfileImageButton setImage:[UIImage imageNamed:@"defaultUserProfileImage"] forState:UIControlStateNormal];
        UIView *userProfileHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.hyveListTable.frame.size.width, 200)];
        [userProfileHeader setUserInteractionEnabled:YES];
        [userProfileHeader bringSubviewToFront:self.loadingIndicator];
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -200, userProfileHeader.frame.size.width, userProfileHeader.frame.size.height + 200)];
        
        if ([imageURLString isKindOfClass:[NSNull class]] || imageURLString == nil)
        {
            self.userProfileImage = [UIImage imageNamed:@"defaultUserProfileImage"];
            [self.userProfileImageButton setImage:self.userProfileImage forState:UIControlStateNormal];
        }
        else
        {
            NSURL *imageURL = [NSURL URLWithString:imageURLString];
            NSData *imageURLData = [NSData dataWithContentsOfURL:imageURL];
            self.userProfileImage = [UIImage imageWithData:imageURLData];
        }
        
        self.userProfileImageButton = [[DKCircleButton alloc] initWithFrame:CGRectMake(userProfileHeader.frame.size.width / 2, 80, 100, 100)];
        [self.userProfileImageButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.userProfileImageButton setUserInteractionEnabled:YES];
        [self.userProfileImageButton setTitle:@"" forState:UIControlStateNormal];
        [self.userProfileImageButton setCenter:CGPointMake(CGRectGetMidX(userProfileHeader.bounds), CGRectGetMidY(userProfileHeader.bounds))];
        [self.userProfileImageButton addTarget:self action:@selector(userProfileImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        float positionOfUsernameCoordinateY = userProfileHeader.frame.origin.y + 370;
        UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(backgroundImageView.frame.size.width/2, positionOfUsernameCoordinateY, 250, 40)];
        username.textAlignment = NSTextAlignmentCenter;
        username.numberOfLines = 0;
        username.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:20];
        username.textColor = [UIColor whiteColor];
        [username setCenter:CGPointMake(CGRectGetMidX(backgroundImageView.bounds), positionOfUsernameCoordinateY)];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            backgroundImageView.image = [UIImage imageNamed:@"userProfileHeader"];
            [self.userProfileImageButton setImage:self.userProfileImage forState:UIControlStateNormal];
            [self.userProfileImageButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
            self.userProfileImageButton.imageView.clipsToBounds = YES;

            [userProfileHeader addSubview:self.userProfileImageButton];
            username.text = usernameFromHyve;
            [backgroundImageView addSubview:username];
            
            [userProfileHeader addSubview:backgroundImageView];
            [userProfileHeader bringSubviewToFront:self.userProfileImageButton];
            
            self.hyveListTable.tableHeaderView = userProfileHeader;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            if (self.fromUserAccountVC == NO) {
                self.loadingProgressView.minimumSuccessDisplayTime = 1.5;
                [KVNProgress showSuccessWithStatus:@"Pairing successful!"];
                self.fromUserAccountVC = YES;
                self.hyveListTable.alpha = 1;
                self.userProfileImageButton.alpha = 1;
            }
        });
    });
}

#pragma mark - peripheral delegate
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services)
    {
        NSLog(@"peripheral = %@ \r service: %@ \r service.uuid: %@", peripheral, service, service.UUID);
        
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"FFF1"]] forService:service];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characterisitc in service.characteristics)
    {
        CBUUID *characteristicUUID = characterisitc.UUID;
        CBUUID *characteristicUUIDString = [CBUUID UUIDWithString:@"FFF1"];
        
        if ([characteristicUUID isEqual:characteristicUUIDString])
        {
            [peripheral writeValue:self.buzzData forCharacteristic:characterisitc type:CBCharacteristicWriteWithResponse];
        }
    }
}

#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowHyveDetailsVC"])
    {
        NSIndexPath *indexPath = [self.hyveListTable indexPathForSelectedRow];
        CBPeripheral *peripheral = [self.hyveDevicesMutableArray objectAtIndex:indexPath.row];
        
        HyveDetailsViewController *hdvc = segue.destinationViewController;
        hdvc.peripheral = peripheral;
        hdvc.centralManager = self.centralManager;
    }
    else if ([segue.identifier isEqualToString:@"ShowUserAccountVC"])
    {
        if ([segue isKindOfClass:[BlurryModalSegue class]])
        {
            UINavigationController *navigationController = segue.destinationViewController;
            UserAccountViewController *uavc = (UserAccountViewController*)[navigationController topViewController];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"scannedNewHyve" object:nil];
            
            BlurryModalSegue* bms = (BlurryModalSegue*)segue;
            bms.backingImageBlurRadius = @(30);
            bms.backingImageSaturationDeltaFactor = @(.35);
        }
    }
    else if ([segue.identifier isEqualToString:@"ToScannedNewHyveVC"])
    {
        ScannedNewHyveViewController *snhvc = segue.destinationViewController;
        snhvc.scannedNewHyveMutableArray = self.scannedNewHyveMutableArray;
        snhvc.pairedHyveMutableArray = self.hyveDevicesMutableArray;
        
        BlurryModalSegue *bms = (BlurryModalSegue*)segue;
        bms.backingImageBlurRadius = @(15);
        bms.backingImageSaturationDeltaFactor = @(.15);
    }
}

-(IBAction)unwindSegue:(UIStoryboardSegue*)segue
{
    UserAccountViewController *uavc = segue.sourceViewController;
    
    if ([uavc isKindOfClass:[UserAccountViewController class]])
    {
        NSLog(@"return back from user account vc");
    }
}

-(void)userProfileImageButtonTapped:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"ShowUserAccountVC" sender:nil];
    });
}

@end
