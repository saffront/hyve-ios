//
//  HyveListViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/6/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "HyveListViewController.h"
#import "HyveDetailsViewController.h"
#import "Hyve.h"

@interface HyveListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Hyve *hyve;
@property (weak, nonatomic) IBOutlet UITableView *hyveListTable;
@property float defaultY;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageBackground;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UIView *profileTableHeader;


@end

@implementation HyveListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stylingNavigationBar];
    [self settingAndStylingUserProfile];
    
    self.hyveListTable.tableHeaderView.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);
    self.hyveListTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - styling navigation bar
-(void)stylingNavigationBar
{
    self.title = @"Hyve";
    [self.navigationItem setHidesBackButton:YES];
}

#pragma mark - user
-(void)settingAndStylingUserProfile
{
    self.usernameLabel.text = @"Jay Ang";
    self.usernameLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
    
    self.profileImage.image = [UIImage imageNamed:@"jlaw"];
    
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
    CBPeripheral *peripheral = [self.hyveDevicesMutableArray objectAtIndex:indexPath.row];
    Hyve *hyve = [Hyve new];
    hyve.peripheralName = peripheral.name;
    hyve.peripheralUUID = peripheral.identifier;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HyveCellListVC"];
    
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

//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    self.usernameLabel.text = @"Jay Ang";
//    self.usernameLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:17];
//    self.usernameLabel.numberOfLines = 0;
//    
//    self.profileImage.image = [UIImage imageNamed:@"jlaw"];
//    
//    [self.profileTableHeader addSubview:self.usernameLabel];
//    [self.profileTableHeader addSubview:self.profileImage];
//
//    return self.profileTableHeader;
//}



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
