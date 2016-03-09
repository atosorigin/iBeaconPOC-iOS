//
//  RootViewController.m
//  BLEReceiver
//
//  Created by Peter Brock on 08/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIView *viewKitchen;
@property (weak, nonatomic) IBOutlet UIView *viewReception;
@property (weak, nonatomic) IBOutlet UIView *viewDesk;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelScanning;
@property (weak, nonatomic) IBOutlet UILabel *labelBeaconDetails;

@end

@implementation RootViewController

NSString *const groupUUID = @"723C0A0F-D506-4175-8BB7-229A21BE470B";
NSString *const groupId = @"net.atos.mobile.beacon";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initBeaconRegions];
    [self initLocationManager];
    
}

- (void)initLocationManager {
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Location services disabled, starting");
        [self.locationManager startUpdatingLocation];
    }
    
    if (![CLLocationManager isRangingAvailable]) {
        NSLog(@"ERROR - Ranging Not Available");
    }
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"ERROR - Monitoring Not Available");
    }
    
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable) {
        NSLog(@"ERROR - Background Refresh Not Available");
    }
    
    [self.locationManager requestWhenInUseAuthorization];
    
}

- (void)initBeaconRegions {
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:groupUUID];
    
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:groupId];
    
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    self.beaconRegion.notifyOnEntry = YES;
    self.beaconRegion.notifyOnExit = YES;
}

- (void)startMonitoring {
    
    NSLog(@"Will start ranging beacons in region");
    [self.locationManager startRangingBeaconsInRegion:_beaconRegion];
    
    [_labelScanning setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark LocationManager

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    
    NSLog(@"DidRangeBeacons - found %lu beacons", (unsigned long)beacons.count);
    
    //the beacons array generally comes sorted with Unknowns, then closest to furthest. This isn't documented though so probably don't want to rely on this in a real app
    CLBeacon *nearestBeacon = nil;
    for (CLBeacon *beacon in beacons) {
        
        if (beacon.accuracy != CLProximityUnknown) {
            nearestBeacon = beacon;
            break;
        }
    }
    
    if (nearestBeacon != nil) {
        
        [_labelStatus setHidden:NO];
        [_labelBeaconDetails setHidden:NO];

        _labelBeaconDetails.text = [NSString stringWithFormat:@"RSSI: %d", (int)nearestBeacon.rssi];
        
        int nearestMajor = [nearestBeacon.major intValue];
        
        switch (nearestMajor) {
            case 1:
                [_viewKitchen setHidden:NO];
                [_viewReception setHidden:YES];
                [_viewDesk setHidden:YES];
                break;
            case 2:
                [_viewKitchen setHidden:YES];
                [_viewReception setHidden:NO];
                [_viewDesk setHidden:YES];
                break;
            case 3:
                [_viewKitchen setHidden:YES];
                [_viewReception setHidden:YES];
                [_viewDesk setHidden:NO];
                break;
            default:
                break;
        }
    } else {
        
        [_labelBeaconDetails setHidden:YES];
        [_labelStatus setHidden:YES];
        [_viewKitchen setHidden:YES];
        [_viewReception setHidden:YES];
        [_viewDesk setHidden:YES];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        NSLog(@"Received Authorisation");
        
        [self startMonitoring];
    }
    
}

@end
