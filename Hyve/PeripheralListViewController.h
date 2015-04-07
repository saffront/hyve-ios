//
//  PeripheralListViewController.h
//  Hyve
//
//  Created by VLT Labs on 3/6/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Hyve.h"

@interface PeripheralListViewController : UIViewController
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) NSMutableArray *peripheralMutableArray;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) Hyve *hyve;


@end
