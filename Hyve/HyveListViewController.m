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
#import <QuartzCore/QuartzCore.h>
#import <POP.h>

@interface HyveListViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate>

@property (strong, nonatomic) Hyve *hyve;
@property (strong, nonatomic) DKCircleButton *userProfileImageButton;
@property (weak, nonatomic) IBOutlet UITableView *hyveListTable;
@property float defaultY;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageBackground;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIView *profileTableHeader;
@property (strong, nonatomic) IBOutlet DKCircleButton *profileImageButton;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation HyveListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self stylingBackgroundView];
    [self stylingNavigationBar];
    [self stylingHyveListTableView];
    [self settingHeaderForHyveListTable];

}

#pragma mark - styling navigation bar
-(void)stylingNavigationBar
{
    self.title = @"Hyve";
    [self.navigationItem setHidesBackButton:YES];
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
    Hyve *hyve = [Hyve new];
    hyve.peripheralName = peripheral.name;
    hyve.peripheralUUID = peripheral.identifier;

    HyveListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HyveCellListVC"];
    cell.backgroundColor = [UIColor clearColor];
    cell.hyveContentView.backgroundColor = [UIColor colorWithRed:0.61 green:0.71 blue:0.71 alpha:0.4];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([hyve.peripheralName isEqualToString:@""] || hyve.peripheralName == nil)
    {
        cell.hyveName.text = @"Unkown devices";
        cell.hyveName.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
        cell.hyveName.textColor = [UIColor whiteColor];
        [cell.hyveImage setImage:[UIImage imageNamed:@"houseKeys"] forState:UIControlStateNormal];
        cell.hyveBattery.alpha = 0;
        cell.hyveProximity.alpha = 0;
        cell.hyveName.numberOfLines = 0;
    }
    else
    {
        cell.hyveName.text = hyve.peripheralName;
        cell.hyveName.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
        cell.hyveName.textColor = [UIColor whiteColor];
        cell.hyveName.numberOfLines = 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.hyveImage setImage:[UIImage imageNamed:@"houseKeys"] forState:UIControlStateNormal];
            cell.hyveImage.borderColor = [UIColor whiteColor];
            cell.hyveImage.borderSize = 3.0f;
        });

        cell.hyveBattery.text = @"Super strong";
        cell.hyveBattery.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:16];
        cell.hyveBattery.textColor = [UIColor whiteColor];
        cell.hyveBattery.numberOfLines = 0;
        
        cell.hyveProximity.text = @"Super far";
        cell.hyveProximity.textColor = [UIColor whiteColor];
        cell.hyveProximity.numberOfLines = 0;
        cell.hyveProximity.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:16];
        
    }
    return cell;
}

-(void)settingHeaderForHyveListTable
{
    UIView *userProfileHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.hyveListTable.frame.size.width, 250)];
    [userProfileHeader setUserInteractionEnabled:YES];

    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, userProfileHeader.frame.size.width, userProfileHeader.frame.size.height)];
    backgroundImageView.image = [UIImage imageNamed:@"userProfileHeader"];

    self.userProfileImageButton = [[DKCircleButton alloc] initWithFrame:CGRectMake(userProfileHeader.frame.size.width / 2, 130, 100, 100)];
    [self.userProfileImageButton setUserInteractionEnabled:YES];
    [self.userProfileImageButton setImage:[UIImage imageNamed:@"jlaw"] forState:UIControlStateNormal];
    [self.userProfileImageButton setTitle:@"" forState:UIControlStateNormal];
    [self.userProfileImageButton setCenter:CGPointMake(CGRectGetMidX(userProfileHeader.bounds), CGRectGetMidY(userProfileHeader.bounds))];
    [self.userProfileImageButton addTarget:self action:@selector(userProfileImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserAccountVC:)];
//    [self.userProfileImageButton addGestureRecognizer:tapGestureRecognizer];
//    [userProfileHeader addGestureRecognizer:tapGestureRecognizer];
    
    [userProfileHeader addSubview:self.userProfileImageButton];
    
    float positionOfUsernameCoordinateY = self.userProfileImageButton.frame.origin.y + self.userProfileImageButton.frame.size.height + 40;
    
    UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(backgroundImageView.frame.size.width/2, positionOfUsernameCoordinateY, 250, 40)];
    username.text = @"Jennifer Lawrence";
    username.textAlignment = NSTextAlignmentCenter;
    username.numberOfLines = 0;
    username.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
    username.textColor = [UIColor whiteColor];
    [username setCenter:CGPointMake(CGRectGetMidX(backgroundImageView.bounds), positionOfUsernameCoordinateY)];
    
    [backgroundImageView addSubview:username];
    
    [userProfileHeader addSubview:backgroundImageView];
    [userProfileHeader bringSubviewToFront:self.userProfileImageButton];
    
    self.hyveListTable.tableHeaderView = userProfileHeader;
}


#pragma mark - profile image settings
- (IBAction)onProfileImageButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    springAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(10, 10)];
    springAnimation.springBounciness = 20.0f;
    [self.profileImageButton pop_addAnimation:springAnimation forKey:@"sendAnimation"];
    springAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        
        if (finished)
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                    self.imagePickerController = [UIImagePickerController new];
                    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                    self.imagePickerController.delegate = (id)self;
                    self.imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:self.imagePickerController animated:YES completion:^{
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    }];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Sorry, your device does not seem to have a camera" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }

        }
    };
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *imageTakenByUser = [info valueForKey:UIImagePickerControllerOriginalImage];
        CGRect rect = CGRectMake(0, 0, 912, 980);
        
        UIGraphicsBeginImageContext(rect.size);
        [imageTakenByUser drawInRect:rect];
        UIImage *resizedImageTakenByUser = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.profileImageButton setImage:resizedImageTakenByUser forState:UIControlStateNormal];
        });
    });
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
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
        UserAccountViewController *uavc = segue.destinationViewController;
    }
}

//from user profile image
-(void)showUserAccountVC:(UITapGestureRecognizer*)tapGestureRecognizer
{
    if (tapGestureRecognizer.view.tag == 123)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"ShowUserAccountVC" sender:nil];
        });
    }
}

-(void)userProfileImageButtonTapped:(id)sender
{
    NSLog(@"userProfileImageButtonTapped");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"ShowUserAccountVC" sender:nil];
    });
}

@end
