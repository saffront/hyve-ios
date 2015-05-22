//
//  ScannedNewHyveViewController.m
//  Hyve
//
//  Created by VLT Labs on 4/22/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "ScannedNewHyveViewController.h"
#import <AFNetworking.h>
#import <Reachability.h>
#import <KVNProgress.h>

@interface ScannedNewHyveViewController() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *scannedNewHyveTable;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UIButton *pairButton;
@property (strong, nonatomic) Hyve *hyve;

@property (strong, nonatomic) NSMutableDictionary *newlyPairedHyveMutableDictionary;
@property (nonatomic) KVNProgressConfiguration *loadingProgressView;
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property BOOL loadingProgressViewAppears;
@property int tapCount;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property BOOL uuidError;

@end


@implementation ScannedNewHyveViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.uuidError = NO;
    self.tapCount = 0;
    self.loadingProgressViewAppears = NO;
    
    [self stylingInstructionLabel];
    [self stylingPairButton];
    self.selectedNewScannedHyveMutableArray = [NSMutableArray new];
    self.scannedNewHyveTable.backgroundColor = [UIColor clearColor];
    self.scannedNewHyveTable.allowsMultipleSelection = YES;
    [self stylingGoBackButton];
    
}

#pragma mark - go back button
-(void)stylingGoBackButton
{
    [self.goBackButton setBackgroundImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
}

- (IBAction)onGoBackButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - setting up progress view
-(void)settingUpProgressView
{
    self.loadingProgressView = [KVNProgressConfiguration defaultConfiguration];
    [KVNProgress setConfiguration:self.loadingProgressView];
    self.loadingProgressView.backgroundType = KVNProgressBackgroundTypeBlurred;
    self.loadingProgressView.fullScreen = YES;
    self.loadingProgressView.minimumDisplayTime = 1;
    
    [KVNProgress showWithStatus:@"Pairing..."];
    
    self.loadingProgressViewAppears = YES;
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
    [self.pairButton addTarget:self action:@selector(onPairButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.pairButton setTitle:@"Pair" forState:UIControlStateNormal];
    [self.pairButton setBackgroundColor:[UIColor colorWithRed:0.22 green:0.63 blue:0.80 alpha:1]];
    [self.pairButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)onPairButtonPressed
{
    [self settingUpProgressView];
    
    for (CBPeripheral *newlyPairedHyve in self.selectedNewScannedHyveMutableArray)
    {
        Hyve *hyve = [Hyve new];
        hyve.peripheralName = newlyPairedHyve.name;
        hyve.peripheralUUIDString = newlyPairedHyve.identifier.UUIDString;
        hyve.peripheralRSSI = @"1";
        
        if (newlyPairedHyve.name == nil)
        {
            hyve.peripheralName = @"Unknown device";
        }
        
        self.newlyPairedHyveMutableDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:hyve.peripheralName,@"name",hyve.peripheralUUIDString,@"uuid",hyve.peripheralRSSI,@"distance", nil];
        [self connectToHyve:self.newlyPairedHyveMutableDictionary];
    }

}

#pragma mark - submit paired hyve to server
-(void)connectToHyve:(NSMutableDictionary*)newlyPairedHyve
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    if (reachability.isReachable)
    {
        [self submitPairedHyveToServer:newlyPairedHyve];
    
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble with Internet connectivity" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)submitPairedHyveToServer:(NSMutableDictionary*)newlyPairedHyve
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *api_token = [userDefaults objectForKey:@"api_token"];

//    NSString *hyveURLString = [NSString stringWithFormat:@"http://hyve-staging.herokuapp.com/api/v1/hyves"];
    NSString *hyveURLString = [NSString stringWithFormat:@"http://hyve-production.herokuapp.com/api/v1/hyves"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:api_token forHTTPHeaderField:@"X-hyve-token"];
    [manager.requestSerializer setTimeoutInterval:20];
    
    [manager POST:hyveURLString parameters:newlyPairedHyve success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"responseObject from connectToHyveBackend \r \r %@", responseObject);
        
        if (self.selectedNewScannedHyveMutableArray.count > 0)
        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"scannedNewHyve" object:self.selectedNewScannedHyveMutableArray];
        }
        self.loadingProgressView.minimumSuccessDisplayTime = 1.5;
        [KVNProgress showSuccessWithStatus:@"Pairing successful!"];
        [KVNProgress dismiss];
//        [self dismissViewControllerAnimated:YES completion:nil];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (error)
        {
            [KVNProgress dismiss];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hyve" message:@"Trouble connecting to server. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            
            if (!self.presentedViewController)
            {
                [self presentViewController:alertController animated:YES completion:nil];
            }

        }
    }];
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
        
        CBPeripheral *peripheral = [self.scannedNewHyveMutableArray objectAtIndex:indexPath.row];
        [self.selectedNewScannedHyveMutableArray addObject:peripheral];
        
        NSLog(@"SELECT: \r self.selectedNewScannedHyveMutableArray : %@ \r %i", self.selectedNewScannedHyveMutableArray, self.selectedNewScannedHyveMutableArray.count);
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedNewScannedHyveMutableArray.count == 0) {
        [self.pairButton setUserInteractionEnabled:NO];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        CBPeripheral *peripheral = [self.scannedNewHyveMutableArray objectAtIndex:indexPath.row];
        [self.selectedNewScannedHyveMutableArray removeObject:peripheral];
        
        NSLog(@"DESLECT: \r self.selectedNewScannedHyveMutableArray : %@ \r %i", self.selectedNewScannedHyveMutableArray, self.selectedNewScannedHyveMutableArray.count);
        
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

@end
