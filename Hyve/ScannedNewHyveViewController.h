//
//  ScannedNewHyveViewController.h
//  Hyve
//
//  Created by VLT Labs on 4/22/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Hyve.h"

@interface ScannedNewHyveViewController : UIViewController
@property (strong, nonatomic) NSMutableArray *scannedNewHyveMutableArray;
@property (strong, nonatomic) NSMutableArray *pairedHyveMutableArray;

@end
