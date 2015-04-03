//
//  HyveDetailsViewController.h
//  Hyve
//
//  Created by VLT Labs on 3/9/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hyve.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface HyveDetailsViewController : UIViewController
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) Hyve *hyve;
@property (strong, nonatomic) CBCharacteristic *characteristic;

@end
