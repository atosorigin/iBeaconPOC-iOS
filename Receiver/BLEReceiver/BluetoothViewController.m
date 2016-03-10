//
//  BluetoothViewController.m
//  BLEReceiver
//
//  Created by Peter Brock on 10/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import "BluetoothViewController.h"

@interface BluetoothViewController ()

@property (nonatomic, strong) CBCentralManager *manager;

@end

@implementation BluetoothViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CentralManager PoweredOn; starting scanner");
            [_manager scanForPeripheralsWithServices:nil options:nil];
            break;
        default:
            NSLog(@"Received CentralManager state: %ld", (long)central.state);
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Discovered a peripheral!");
    NSLog(@">> Peripheral: id[%@], state[%ld], name[%@], services[%@], RSSI[%@]", peripheral.identifier, (long)peripheral.state, peripheral.name, peripheral.services, RSSI);
    
    NSLog(@">> AdvertisementData: %@", advertisementData);
    NSLog(@">> AdvertisementDataManufactorerKey: %@", [advertisementData objectForKey:@"CBAdvertisementDataManufacturerDataKey"]);
    NSLog(@">> AdvertisementDataServiceKey: %@", [advertisementData objectForKey:@"CBAdvertisementDataServiceDataKey"]);
    
    NSData * myData = [NSKeyedArchiver archivedDataWithRootObject:advertisementData];
    
    NSLog(@">> AdvertisementNSData: [%@] and length [%lul]", myData, (unsigned long)myData.length );

}


@end
