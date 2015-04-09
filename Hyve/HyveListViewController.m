//
//  HyveListViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/6/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import <DKCircleButton.h>
#import "UserAccountViewController.h"
#import "HyveListTableViewCell.h"
#import "HyveListViewController.h"
#import "HyveDetailsViewController.h"
#import "Hyve.h"
#import <AFNetworking.h>
#import <Reachability.h>
#import <BlurryModalSegue.h>
#import <QuartzCore/QuartzCore.h>
#import <POP.h>
#import <MBLoadingIndicator.h>

@interface HyveListViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate>

@property (strong, nonatomic) Hyve *hyve;
@property (strong, nonatomic) DKCircleButton *userProfileImageButton;
@property (weak, nonatomic) IBOutlet UITableView *hyveListTable;
@property float defaultY;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) MBLoadingIndicator *loadingIndicator;

@end

@implementation HyveListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingUpLoadingIndicator];
    [self connectToHyve];
    [self stylingBackgroundView];
    [self stylingNavigationBar];
    [self stylingHyveListTableView];

}

#pragma mark - viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingUserImage:) name:@"user" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingHyveImage:) name:@"userImageURLString" object:nil];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

-(void)settingUpLoadingIndicator
{
    self.loadingIndicator = [MBLoadingIndicator new];
    [self.loadingIndicator setBackColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1]];
    [self.loadingIndicator setOuterLoaderBuffer:5.0];
    [self.loadingIndicator setLoaderBackgroundColor:[UIColor whiteColor]];
    [self.loadingIndicator setLoadedColor:[UIColor colorWithRed:0.22 green:0.63 blue:0.80 alpha:1]];
    [self.loadingIndicator setStartPosition:MBLoaderTop];
    [self.loadingIndicator setAnimationSpeed:MBLoaderSpeedMiddle];

    
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.loadingIndicator start];
        int count = 0;
        
        while (count++ < 2)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(count * 1.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.loadingIndicator incrementPercentageBy:20];
            });
        }
        [self.view addSubview:self.loadingIndicator];

    });
    
    [self.hyveListTable addSubview:self.loadingIndicator];
    [self.hyveListTable bringSubviewToFront:self.loadingIndicator];
}

#pragma mark - setting user info
-(void)settingUserImage:(NSNotification*)notification
{
    NSDictionary *user = notification.object;

    NSString *username = [user objectForKey:@"username"];
    NSString *userProfileImage = [user objectForKey:@"userAvatarUR"];
    
    [self settingHeaderForHyveListTable:username imageURLString:userProfileImage];

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
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
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
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:api_token forHTTPHeaderField:@"X-hyve-token"];
    
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
            [self.loadingIndicator dismiss];
            
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
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *api_token = [userDefaults objectForKey:@"api_token"];
    
    NSString *hyveURLString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/account"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:api_token forHTTPHeaderField:@"X-hyve-token"];
    
    [manager GET:hyveURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"responseObject retrieveUserInfoAndPairedHyve: \r\r %@", responseObject);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            NSArray *hyvesArray = [responseObject valueForKeyPath:@"user.hyves"];
            
            for (NSDictionary *pairedHyves in hyvesArray)
            {
//                Hyve *hyve = [Hyve new];
//                hyve.peripheralName = [pairedHyves valueForKeyPath:@"name"];
//                hyve.peripheralRSSI = [pairedHyves valueForKeyPath:@"distance"];
//                hyve.hyveID = [pairedHyves valueForKeyPath:@"id"];
                
                NSString *peripheralUUIDStringFromHyveServer = [pairedHyves valueForKeyPath:@"uuid"];
                
                if ([peripheralUUIDStringFromHyveServer isEqualToString:hyve.peripheralUUIDString])
                {
                    hyve.imageURLString = [pairedHyves valueForKeyPath:@"image.image.url"];
                    
                    if ([hyve.imageURLString isKindOfClass:[NSNull class]])
                    {
                        NSLog(@"imageURLString : %@", hyve.imageURLString);
                        [cell.hyveImage setImage:[UIImage imageNamed:@"jlaw2"] forState:UIControlStateNormal];
                        cell.hyveImage.borderColor = [UIColor whiteColor];
                        cell.hyveImage.userInteractionEnabled = NO;
                        cell.hyveImage.borderSize = 3.0f;
                    }
                    else if ([hyve.imageURLString isEqualToString:@""])
                    {
                        [cell.hyveImage setImage:[UIImage imageNamed:@"jlaw"] forState:UIControlStateNormal];
                        cell.hyveImage.borderColor = [UIColor whiteColor];
                        cell.hyveImage.userInteractionEnabled = NO;
                        cell.hyveImage.borderSize = 3.0f;
                    }
                    else
                    {
                        NSURL *imageURL = [NSURL URLWithString:hyve.imageURLString];
                        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                        UIImage *hyveImage = [UIImage imageWithData:imageData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [cell.hyveImage setImage:hyveImage forState:UIControlStateNormal];
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
        
        NSLog(@"error with retrieveUserInfoAndPairedHyve: \r\r %@ \r localizedDescription: \r %@", error, [error localizedDescription]);
        
    }];

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
    self.hyveListTable.tableHeaderView.frame = CGRectMake(0, 0, self.view.frame.size.width, 320);
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
    cell.hyveContentView.backgroundColor = [UIColor colorWithRed:0.61 green:0.71 blue:0.71 alpha:0.4];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self.hyve.peripheralName isEqualToString:@""] || self.hyve.peripheralName == nil)
    {
        cell.hyveName.text = @"Unkown devices";
        cell.hyveName.font = [UIFont fontWithName:@"OpenSans-Bold" size:20];
        cell.hyveName.textColor = [UIColor whiteColor];
        [cell.hyveImage setImage:[UIImage imageNamed:@"houseKeys"] forState:UIControlStateNormal];
        cell.hyveBattery.alpha = 0;
        cell.hyveProximity.alpha = 0;
        cell.hyveName.numberOfLines = 0;
    }
    else
    {
        cell.hyveBattery.alpha = 1;
        cell.hyveProximity.alpha = 1;
        
        cell.hyveName.text = self.hyve.peripheralName;
        cell.hyveName.font = [UIFont fontWithName:@"OpenSans-Bold" size:20];
        cell.hyveName.textColor = [UIColor whiteColor];
        cell.hyveName.numberOfLines = 0;
        
        cell.hyveBattery.text = @"Super strong";
        cell.hyveBattery.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:16];
        cell.hyveBattery.textColor = [UIColor whiteColor];
        cell.hyveBattery.numberOfLines = 0;
        
        cell.hyveProximity.text = @"Super far";
        cell.hyveProximity.textColor = [UIColor whiteColor];
        cell.hyveProximity.numberOfLines = 0;
        cell.hyveProximity.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:16];
        
//            [cell.hyveImage setImage:[UIImage imageNamed:@"houseKeys"] forState:UIControlStateNormal];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self populateCellHyveImage:cell withHyve:self.hyve];
        });
    }
    return cell;
}

-(void)settingHeaderForHyveListTable:(NSString*)usernameFromHyve imageURLString:(NSString*)imageURLString
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.userProfileImageButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        UIView *userProfileHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.hyveListTable.frame.size.width, 250)];
        [userProfileHeader setUserInteractionEnabled:YES];
        [userProfileHeader bringSubviewToFront:self.loadingIndicator];
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, userProfileHeader.frame.size.width, userProfileHeader.frame.size.height)];
        
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        NSData *imageURLData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *userProfileImage = [UIImage imageWithData:imageURLData];
        
        self.userProfileImageButton = [[DKCircleButton alloc] initWithFrame:CGRectMake(userProfileHeader.frame.size.width / 2, 130, 100, 100)];
        [self.userProfileImageButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.userProfileImageButton setUserInteractionEnabled:YES];
        [self.userProfileImageButton setTitle:@"" forState:UIControlStateNormal];
        [self.userProfileImageButton setCenter:CGPointMake(CGRectGetMidX(userProfileHeader.bounds), CGRectGetMidY(userProfileHeader.bounds))];
        [self.userProfileImageButton addTarget:self action:@selector(userProfileImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        float positionOfUsernameCoordinateY = self.userProfileImageButton.frame.origin.y + self.userProfileImageButton.frame.size.height + 40;
        UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(backgroundImageView.frame.size.width/2, positionOfUsernameCoordinateY, 250, 40)];
        
        username.textAlignment = NSTextAlignmentCenter;
        username.numberOfLines = 0;
        username.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:20];
        username.textColor = [UIColor whiteColor];
        [username setCenter:CGPointMake(CGRectGetMidX(backgroundImageView.bounds), positionOfUsernameCoordinateY)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            backgroundImageView.image = [UIImage imageNamed:@"userProfileHeader"];
            [self.userProfileImageButton setImage:userProfileImage forState:UIControlStateNormal];
            [userProfileHeader addSubview:self.userProfileImageButton];
            username.text = usernameFromHyve;
            [backgroundImageView addSubview:username];
            
            [userProfileHeader addSubview:backgroundImageView];
            [userProfileHeader bringSubviewToFront:self.userProfileImageButton];
            
            self.hyveListTable.tableHeaderView = userProfileHeader;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            [self.loadingIndicator finish];
        });
    });
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
            UserAccountViewController *uavc = segue.destinationViewController;

            BlurryModalSegue* bms = (BlurryModalSegue*)segue;
            bms.backingImageBlurRadius = @(40);
            bms.backingImageSaturationDeltaFactor = @(.35);
        }
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
