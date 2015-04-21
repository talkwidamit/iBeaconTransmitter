//
//  ViewController.m
//  iBeaconTransmitter
//
//  Created by P, Venkatesh (ASPL) on 1/30/15.
//  Copyright (c) 2015 Allstate. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *udidTextField;
@property (weak, nonatomic) IBOutlet UITextField *majorTextField;
@property (weak, nonatomic) IBOutlet UITextField *minorTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //New test code
    self.udidTextField.text = @"A77A1B68-49A7-4DBF-914C-760D07FBB87B";
    self.majorTextField.text = @"2";
    self.minorTextField.text = @"200";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.udidTextField resignFirstResponder];
    [self.majorTextField resignFirstResponder];
    [self.minorTextField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.udidTextField resignFirstResponder];
    [self.majorTextField resignFirstResponder];
    [self.minorTextField resignFirstResponder];
}

#pragma mark - Beacon

- (void)setBeaconRegion
{
    // Create a NSUUID object
    
    NSLog(@"%@",self.udidTextField.text);
    
    NSString * string =self.udidTextField.text ;
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:string]; //@"A77A1B68-49A7-4DBF-914C-760D07FBB87B"];

    NSLog(@"UDID = %@", uuid);
    
    NSInteger majorInteger = [self.majorTextField.text integerValue];
    NSLog(@"Major = %ld", (long)majorInteger);
    
    NSInteger minorInteger = [self.minorTextField.text integerValue];
    NSLog(@"Minor = %ld", (long)minorInteger);
    
    // Initialize the Beacon Region
    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                  major:majorInteger
                                                                  minor:minorInteger
                                                             identifier:@"allstate"];
    
    [self.myBeaconRegion setNotifyEntryStateOnDisplay:YES];
    [self.myBeaconRegion setNotifyOnEntry:YES];
    [self.myBeaconRegion setNotifyOnExit:YES];
    
    self.myBeaconData = [self.myBeaconRegion peripheralDataWithMeasuredPower:nil];
    
    // Start the peripheral manager
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:nil
                                                                   options:nil];
}

- (BOOL) validateUUID: (NSString *) string
{
    NSString *uuidRegex = @"[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-4[a-fA-F0-9]{3}-[89aAbB][a-fA-F0-9]{3}-[a-fA-F0-9]{12}";
    NSPredicate *uuidTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", uuidRegex];
    
    return [uuidTest evaluateWithObject:string];
}


- (IBAction)buttonClicked:(id)sender
{
    NSString *UDID = [self.udidTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *major = [self.majorTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *minor = [self.minorTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //Check the mandatory fileds
    if ((UDID.length == 0) || (major.length == 0) || (minor.length == 0))
    {
        [self showAlert:NO];
    }
    else
    {
        if (![self validateUUID:UDID])
        {
            [self showAlert:YES];
        }
        else
        {
            [self setBeaconRegion];
        }
    }
}

- (void)showAlert:(BOOL)validate
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry!" message:((validate)?@"Please enter correct UUID.":@"All fields are mandatory.") preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK!" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        // Bluetooth is on
        // Update our status label
        self.statusLabel.text = @"Broadcasting...";
        
        // Start broadcasting
        [self.peripheralManager startAdvertising:self.myBeaconData];
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff)
    {
        // Update our status label
        self.statusLabel.text = @"Stopped";
        // Bluetooth isn't on. Stop broadcasting
        [self.peripheralManager stopAdvertising];
    }
    else if (peripheral.state == CBPeripheralManagerStateUnsupported)
    {
        self.statusLabel.text = @"Unsupported";
    }
}

@end
