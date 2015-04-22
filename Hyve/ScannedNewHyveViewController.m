//
//  ScannedNewHyveViewController.m
//  Hyve
//
//  Created by VLT Labs on 4/22/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "ScannedNewHyveViewController.h"


@interface ScannedNewHyveViewController() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *scannedNewHyveTable;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UIButton *pairButton;
@property (strong, nonatomic) Hyve *hyve;

@end


@implementation ScannedNewHyveViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self stylingInstructionLabel];
    [self stylingPairButton];
    self.scannedNewHyveTable.backgroundColor = [UIColor clearColor];
    self.scannedNewHyveTable.allowsMultipleSelection = YES;
}


#pragma mark - styling instruction label
-(void)stylingInstructionLabel
{
    self.instructionLabel.text = @"Please select which Hyve(s) you want to pair with:";
    self.instructionLabel.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:17];
    self.instructionLabel.numberOfLines = 0;
}

#pragma mark - pair button
-(void)stylingPairButton
{
    [self.pairButton setUserInteractionEnabled:YES];
    self.pairButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:22];
    [self.pairButton setTitle:@"Pair" forState:UIControlStateNormal];
    [self.pairButton setBackgroundColor:[UIColor colorWithRed:0.22 green:0.63 blue:0.80 alpha:1]];
    [self.pairButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)onPairButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.scannedNewHyveMutableArray.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HyveCellID"];
    cell.backgroundColor = [UIColor clearColor];
    
    CBPeripheral *peripheral = [self.scannedNewHyveMutableArray objectAtIndex:indexPath.row];
    Hyve *hyve = [Hyve new];
    hyve.peripheralName = peripheral.name;
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HyveCellID"];
    }
    
    if ([hyve.peripheralName isEqualToString:@""] || hyve.peripheralName == nil)
    {
        cell.textLabel.text = @"Unkown Device";
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:20];
    }
    else
    {
        cell.textLabel.text = hyve.peripheralName;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:20];
    }

    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.pairButton setUserInteractionEnabled:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        NSLog(@"select");
//        self.peripheral = [self.peripheralMutableArray objectAtIndex:indexPath.row];
//        [self.selectedDeviceMutableArray addObject:self.peripheral];
//        
//        NSLog(@"self.selectedDeviceMutableArray didSelectRowAtIndexPath :%@", self.selectedDeviceMutableArray);
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSLog(@"deselect");
        
//        self.peripheral = [self.peripheralMutableArray objectAtIndex:indexPath.row];
//        [self.selectedDeviceMutableArray removeObject:self.peripheral];
//        
//        NSLog(@"self.selectedDeviceMutableArray didDeselectRowAtIndexPath :%@", self.selectedDeviceMutableArray);
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

@end
