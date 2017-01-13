//
//  ViewController.m
//  BeaconBroadcaster
//
//  Created by Mike Williams on 04/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CLBeaconRegion *region;
@property (nonatomic, strong) NSArray *locations;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UIButton *broadcastButton;
@property (weak, nonatomic) IBOutlet UIPickerView *broadcastArea;

- (IBAction)broadcastButtonPressed:(id)sender;

@end

@implementation ViewController {

    BOOL isBroadcasting;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    static NSString *identifier = @"723C0A0F-D506-4175-8BB7-229A21BE470B";
    
    _uuid = [[NSUUID alloc]initWithUUIDString:identifier];
    
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    _uuidLabel.text = identifier;
    
    _locations = @[@"Kitchen", @"Reception", @"Desks"];
    
    isBroadcasting = NO;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"peripheralManagerDidUpdateState %ld", (long)peripheral.state);
    
    NSString *status = @"";
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
            status = @"CBPeripheralManagerStatePoweredOff";
            
            [_peripheralManager stopAdvertising];
            break;
        case CBPeripheralManagerStatePoweredOn: {
            status = @"CBPeripheralManagerStatePoweredOn";   
        }
            break;
        case CBPeripheralManagerStateResetting:
            status = @"CBPeripheralManagerStateResetting";
            break;
        case CBPeripheralManagerStateUnauthorized:
            status = @"CBPeripheralManagerStateUnauthorized";
            break;
        case CBPeripheralManagerStateUnknown:
            status = @"CBPeripheralManagerStateUnknown";
            break;
        case CBPeripheralManagerStateUnsupported:
            status = @"CBPeripheralManagerStateUnsupported";
            break;
        default: status = @"Unknown"; break;
    }
    _statusLabel.text = status;
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    
    NSLog(@"peripheralManagerDidStartAdvertising");
    
    if (error != nil) {
        NSLog(@"peripheralManagerDidStartAdvertising error returned %@", error);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(nullable NSError *)error {
    
    NSLog(@"didAddService");
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"didSubscribeToCharacteristic");
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
     NSLog(@"didUnsubscribeFromCharacteristic");
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
     NSLog(@"didReceiveReadRequest");
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    NSLog(@"didReceiveWriteRequests");
}


- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
     NSLog(@"peripheralManagerIsReadyToUpdateSubscribers");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)broadcastButtonPressed:(id)sender {
    NSLog(@"broadcastButton pressed");
    
    if (!isBroadcasting) {
        
        CLBeaconMinorValue major = 1;
        CLBeaconMajorValue minor = [_broadcastArea selectedRowInComponent:0] + 1;
        
        
        NSLog(@"setting region major %i, minor %i", major, minor);
        
        self.region = [[CLBeaconRegion alloc]
                       initWithProximityUUID:_uuid major:major minor:minor identifier:@"net.atos.mobile.beacon"];
        
        NSDictionary *peripheralData = [_region peripheralDataWithMeasuredPower:@(broadcastpower)];
        
        [_peripheralManager startAdvertising:peripheralData];
        
        [_broadcastButton setTitle:@"Stop" forState:UIControlStateNormal];
        
        isBroadcasting = YES;
    } else {
        [_peripheralManager stopAdvertising];
        [_broadcastButton setTitle:@"Start" forState:UIControlStateNormal];
        
        isBroadcasting = NO;
    }
}

#pragma mark UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    // We have just a single section to our PickerView
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    // There are 3 different options our PickerView can take
    return [_locations count];
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [_locations objectAtIndex:row];
}
@end
