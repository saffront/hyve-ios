//
//  Hyve.h
//  Hyve
//
//  Created by VLT Labs on 3/5/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Hyve : NSObject
@property (strong, nonatomic) NSString *peripheralUUIDString;
@property (strong, nonatomic) NSUUID *peripheralUUID;
@property (strong, nonatomic) NSString *peripheralRSSI;
@property (strong, nonatomic) NSString *peripheralName;



@end
