//
//  HyveListViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/6/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import <DKCircleButton.h>
#import "HyveListViewController.h"
#import "HyveDetailsViewController.h"
#import "Hyve.h"
#import <QuartzCore/QuartzCore.h>
#import <POP.h>

@interface HyveListViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate>

@property (strong, nonatomic) Hyve *hyve;
@property (weak, nonatomic) IBOutlet UITableView *hyveListTable;
@property float defaultY;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageBackground;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UIView *profileTableHeader;
@property (strong, nonatomic) IBOutlet DKCircleButton *profileImageButton;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation HyveListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.95 blue:0.92 alpha:1];
    
    [self stylingBackgroundView];
    [self stylingNavigationBar];
    [self settingAndStylingUserProfile];
    [self stylingHyveListTableView];

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
    [self.hyveListTable setSeparatorInset:UIEdgeInsetsZero];
}

#pragma mark - user
-(void)settingAndStylingUserProfile
{
    self.usernameLabel.text = @"Jay Ang";
    self.usernameLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
    self.usernameLabel.textColor = [UIColor whiteColor];
    
    [self.profileImageButton setImage:[UIImage imageNamed:@"jlaw"] forState:UIControlStateNormal];
    [self.profileImageButton setTitle:@"" forState:UIControlStateNormal];
    self.profileImageButton.borderColor = [UIColor whiteColor];
    self.profileImageButton.borderSize = 2.0f;
    
    self.hyveListTable.tableHeaderView.backgroundColor = [UIColor clearColor];
    self.hyveListTable.backgroundColor = [UIColor clearColor];
    
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

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HyveCellListVC"];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = [UIColor clearColor];
    
    if ([hyve.peripheralName isEqualToString:@""] || hyve.peripheralName == nil)
    {
        cell.textLabel.text = @"Unknown device";
        cell.textLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
    }
    else
    {
        cell.textLabel.text = hyve.peripheralName;
        cell.textLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
    }
    return cell;
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
}

@end
