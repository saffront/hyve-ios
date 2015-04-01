//
//  User.h
//  Hyve
//
//  Created by VLT Labs on 4/1/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSURL *avatarURL;
@property (strong, nonatomic) NSString *provider;

@end
