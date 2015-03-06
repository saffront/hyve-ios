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

@end

@implementation PeripheralListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"peripheral scanned by dashboard %@", self.peripheral);
}

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
    
    CBPeripheral *peripheral = [self.peripheralMutableArray objectAtIndex:indexPath.row];
    Hyve *hyve = [Hyve new];
    hyve.peripheralName = peripheral.name;
    hyve.peripheralUUID = peripheral.identifier;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PeripheralCellID"];
    
    if ([hyve.peripheralName isEqualToString:@""] || hyve.peripheralName == nil)
    {
        cell.textLabel.text = @"Unknown device";
    }
    else
    {
        cell.textLabel.text = hyve.peripheralName;
    }

    if (hyve.peripheralUUID == nil)
    {
        cell.detailTextLabel.text = @"Unknown UUID device";
    }
    else
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", hyve.peripheralUUID];
    }
    
    return cell;
}




@end
