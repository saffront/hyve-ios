//
//  Hyve.h
//  Hyve
//
//  Created by VLT Labs on 4/6/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface Hyve : NSObject
@property (strong, nonatomic) NSString *peripheralUUIDString;
@property (strong, nonatomic) NSUUID *peripheralUUID;
@property (strong, nonatomic) NSString *peripheralRSSI;
@property (strong, nonatomic) NSString *peripheralName;
@property (strong, nonatomic) NSString *hyveID;
@property (strong, nonatomic) CBPeripheral *hyvePeripheral;

@end
