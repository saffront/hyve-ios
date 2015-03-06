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
    
    [self.pairButton setUserInteractionEnabled:NO];
    
    [self promptingUserToPairDevice];
    self.selectedDeviceMutableArray = [NSMutableArray new];
    [self stylingNavigationBar];
    self.peripheralListTableView.allowsMultipleSelection = YES;
}

-(void)stylingNavigationBar
{
    self.title = @"Devices";
}

#pragma mark - prompting user to pair device
-(void)promptingUserToPairDevice
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"We have found these devices around you. Please pair up your Hyve(s)" preferredStyle:UIAlertControllerStyleAlert];
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
        CBPeripheral *peripheral = [self.peripheralMutableArray objectAtIndex:indexPath.row];
        hyve.peripheralName = peripheral.name;
        hyve.peripheralUUID = peripheral.identifier;
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
        
        CBPeripheral *peripheral = [self.peripheralMutableArray objectAtIndex:indexPath.row];
        [self.selectedDeviceMutableArray addObject:peripheral];
        
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
        
        CBPeripheral *peripheral = [self.peripheralMutableArray objectAtIndex:indexPath.row];
        [self.selectedDeviceMutableArray removeObject:peripheral];
        
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
        [self performSegueWithIdentifier:@"ShowHyveListVC" sender:nil];
    }
    else
    {
        [self.pairButton setUserInteractionEnabled:NO];
    }
}

#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    HyveListViewController *hlvc = segue.destinationViewController;
    hlvc.hyveDevicesMutableArray = self.selectedDeviceMutableArray;
}

@end
