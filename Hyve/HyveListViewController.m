//
//  HyveListViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/6/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "HyveListViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "Hyve.h"

@interface HyveListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) Hyve *hyve;


@end

@implementation HyveListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"selected hyve %@", self.hyveDevicesMutableArray);
    [self.navigationItem setHidesBackButton:YES];
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

@end
