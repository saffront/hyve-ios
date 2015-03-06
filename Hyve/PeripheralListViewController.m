//
//  PeripheralListViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/6/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "PeripheralListViewController.h"
#import "Hyve.h"

@interface PeripheralListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *peripheralListTableView;
@property (strong, nonatomic) NSMutableArray *selectedDeviceMutableArray;

@end

@implementation PeripheralListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedDeviceMutableArray = [NSMutableArray new];
    [self stylingNavigationBar];
    self.peripheralListTableView.allowsMultipleSelection = YES;
}

-(void)stylingNavigationBar
{
    self.title = @"Devices";
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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
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
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}


@end
