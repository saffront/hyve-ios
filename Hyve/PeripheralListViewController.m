//
//  PeripheralListViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/6/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "PeripheralListViewController.h"
#import "HyveListViewController.h"
#import "Hyve.h"

@interface PeripheralListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *peripheralListTableView;
@property (strong, nonatomic) NSMutableArray *selectedDeviceMutableArray;
@property (weak, nonatomic) IBOutlet UIButton *pairButton;


@end

@implementation PeripheralListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self pairButtonConfiguration];
    [self promptingUserToPairDevice];
    self.selectedDeviceMutableArray = [NSMutableArray new];
    [self stylingNavigationBar];
    self.peripheralListTableView.allowsMultipleSelection = YES;
}

-(void)stylingNavigationBar
{
    self.title = @"Devices";
}

#pragma mark - pair button configuration
-(void)pairButtonConfiguration
{
    [self.pairButton setUserInteractionEnabled:YES];
    self.pairButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
    [self.pairButton setTitle:@"Pair up" forState:UIControlStateNormal];
    
}

#pragma mark - prompting user to pair device
-(void)promptingUserToPairDevice
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"We have found these devices around you. Some may not be your Hyve. Please pair up your Hyve(s)" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - table view delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.peripheralMutableArray.count > 0)
    {
        return self.peripheralMutableArray.count;
    }
    else
    {
        return 1;
    }
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
    
    if ([hyve.peripheralName isEqualToString:@""] || hyve.peripheralName == nil)
    {
        cell.textLabel.text = @"Unknown device";
        cell.textLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:20];
    }
    else
    {
        cell.textLabel.text = hyve.peripheralName;
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

- (IBAction)onPairButtonPressed:(id)sender
{
    if (self.selectedDeviceMutableArray.count > 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Do you want to pair up with the selected devices?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"ShowHyveListVC" sender:nil];
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

#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    HyveListViewController *hlvc = segue.destinationViewController;
    hlvc.hyveDevicesMutableArray = self.selectedDeviceMutableArray;
    hlvc.centralManager = self.centralManager;
}

@end
