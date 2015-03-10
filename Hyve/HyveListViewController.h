//
//  HyveListViewController.h
//  Hyve
//
//  Created by VLT Labs on 3/6/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface HyveListViewController : UIViewController
@property (strong, nonatomic) NSMutableArray *hyveDevicesMutableArray;
@property (strong, nonatomic) CBCentralManager *centralManager;

@end
