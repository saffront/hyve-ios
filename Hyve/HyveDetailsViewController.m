//
//  HyveDetailsViewController.m
//  Hyve
//
//  Created by VLT Labs on 3/9/15.
//  Copyright (c) 2015 Jay Ang. All rights reserved.
//

#import "HyveDetailsViewController.h"

@interface HyveDetailsViewController () <UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UIButton *hyveCamera;
@property (weak, nonatomic) IBOutlet UITextField *hyveNameTextField;
@property (strong, nonatomic) UIImage *resizedImage;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (weak, nonatomic) IBOutlet UILabel *distanceSliderLabel;
@property (strong, nonatomic) NSArray *valuesOfDistanceSlider;

@end

@implementation HyveDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hyveNameTextField.text = self.peripheral.name;
    
    
    [self stylingDistanceSliderLabel];
    [self addingSaveButtonToNavigationBar];
    [self addToolbarToKeyboard];
    [self stylingTextField];
    [self stylingHyveCameraButton];
    [self configureAndStyleDistanceSlider];
    
    NSString *uuid = [self.peripheral.identifier UUIDString];
    NSLog(@"self.peripheral %@", uuid);
}

#pragma mark - adding save bar button item
-(void)addingSaveButtonToNavigationBar
{
    UIBarButtonItem *saveRightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveHyveDetailsToBackend)];
    self.navigationItem.rightBarButtonItem = saveRightButton;
}

#pragma mark - styling text field
-(void)stylingTextField
{
    self.hyveNameTextField.layer.borderWidth = 0.5;
    self.hyveNameTextField.layer.borderColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1].CGColor;
    self.hyveNameTextField.layer.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1].CGColor;
    self.hyveNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0);
    self.hyveNameTextField.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:15];
}

#pragma mark - adding toolbar to keyboard
-(void)addToolbarToKeyboard
{
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    keyboardToolbar.barStyle = UIBarStyleDefault;
    keyboardToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonPressed)],
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                              [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)]
                              ];
    
    [keyboardToolbar sizeToFit];
    self.hyveNameTextField.inputAccessoryView = keyboardToolbar;
}

-(void)clearButtonPressed
{
    self.hyveNameTextField.text = @"";
}

-(void)doneButtonPressed
{
    [self.hyveNameTextField resignFirstResponder];
}

#pragma mark - styling hyve camera button
-(void)stylingHyveCameraButton
{
    [self.hyveCamera setTitle:@"Camera" forState:UIControlStateNormal];
    
}

#pragma mark - image picker controller
- (IBAction)onHyveCameraButtonPressed:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePickerController = [UIImagePickerController new];
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.delegate = (id)self;
        
        self.imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
    else
    {
        NSLog(@"no camera found");
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *imageTakenByUser = [info valueForKey:UIImagePickerControllerOriginalImage];
        CGRect rect = CGRectMake(0, 0, 700, 800);
        
        UIGraphicsBeginImageContext(rect.size);
        [imageTakenByUser drawInRect:rect];
        UIImage *resizedImageTakenByUser = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resizedImage = resizedImageTakenByUser;
        });
    });
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Cancel image picker was called");
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - slider
- (IBAction)onDistanceSliderDragged:(id)sender
{
    //set hyve's distance to amount dragged
}

-(void)stylingDistanceSliderLabel
{
    self.distanceSliderLabel.text = @"Distance";
    self.distanceSliderLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:15];
}

-(void)configureAndStyleDistanceSlider
{
    /*
     1m = -40dB, 2m = -46dB, 4m = -52dB, 8m = -58dB, 16m = -64dB
    */
    
   self.valuesOfDistanceSlider = @[@(1), @(2), @(4), @(8), @(16)];
    NSInteger numberOfDistanceSliderColumns = ((float)[self.valuesOfDistanceSlider count] -1 );
    
    self.distanceSlider.minimumValue = 1.0;
    self.distanceSlider.maximumValue = numberOfDistanceSliderColumns;
    self.distanceSlider.continuous = YES;
    [self.distanceSlider addTarget:self action:@selector(valueOfDistanceSliderChanged) forControlEvents:UIControlEventValueChanged];
    
}

-(void)valueOfDistanceSliderChanged
{
    NSUInteger index = (NSUInteger)(self.distanceSlider.value + 0.5);
    [self.distanceSlider setValue:index animated:NO];
    NSNumber *number = self.valuesOfDistanceSlider[index];
    NSLog(@"sliderIndex: %i", (int)index);
    NSLog(@"number: %@", number);
}

#pragma mark - send details to backend
-(void)saveHyveDetailsToBackend
{
    //send the hyve's name, uuid, RSSI, image
    NSLog(@"save to Hyve");
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}



@end
