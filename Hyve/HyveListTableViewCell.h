//
//  HyveListTableViewCell.h
//  Hyve
//
//  Created by VLT Labs on 3/25/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DKCircleButton/DKCircleButton.h>

@interface HyveListTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *hyveContentView;
@property (strong, nonatomic) IBOutlet DKCircleButton *hyveImage;
@property (strong, nonatomic) IBOutlet UILabel *hyveName;
@property (strong, nonatomic) IBOutlet UILabel *hyveBattery;
@property (strong, nonatomic) IBOutlet UILabel *hyveProximity;
@property (strong, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) IBOutlet UIButton *disconnectButton;


@end
