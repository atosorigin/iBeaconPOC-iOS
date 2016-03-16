//
//  BeaconLocationManager.m
//  BLEReceiver
//
//  Created by Peter Brock on 15/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import "BeaconLocationManager.h"

@interface BeaconLocationManager ()

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) CLBeacon *currentBeacon;

@property (nonatomic) BOOL hasAuthorisation;

@end

@implementation BeaconLocationManager {
    
}

static NSString *const atosBeaconUUID = @"723C0A0F-D506-4175-8BB7-229A21BE470B";
static NSString *const atosBeaconId = @"net.atos.mobile.beacon";

- (id)init {
    
    self = [super init];
    if (self) {
        
        [self clearLatestBeacon];
        
        _hasAuthorisation = NO;
        _traceLog = YES;
    }
    
    return self;
}

- (void)logIfTracing:(NSString*)logMsg {
    
    if (_traceLog) {
        NSLog(@"Location Manager - trace - %@", logMsg);
    }
    
}

- (void)initialiseLocationManager {
    
    NSLog(@"Location Manager - initialising");
    
    [self initBeaconRegion];
    [self initLocationManager];
    
    [_locationManager requestWhenInUseAuthorization];
}

- (void)initBeaconRegion {
    
    NSLog(@"Location Manager - creating beacon region for uuid [%@] and id [%@]", atosBeaconUUID, atosBeaconId);
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:atosBeaconUUID];
    
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:atosBeaconId];
    
    _beaconRegion.notifyEntryStateOnDisplay = YES;
    _beaconRegion.notifyOnEntry = YES;
    _beaconRegion.notifyOnExit = YES;
}

- (void)initLocationManager {
    
    NSLog(@"Location Manager - creation location manager");
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Location Manager - location services disabled, starting");
        [self.locationManager startUpdatingLocation];
    }
    
    if (![CLLocationManager isRangingAvailable]) {
        NSLog(@"Location Manager - ERROR - Ranging Not Available");
    }
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"Location Manager - ERROR - Monitoring Not Available");
    }
    
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable) {
        NSLog(@"Location Manager - ERROR - Background Refresh Not Available");
    }

}

- (void)startMonitoring {
    
    if (_hasAuthorisation) {
        
        NSLog(@"Location Manager - starting monitoring for region[%@]", _beaconRegion);

        [_locationManager startRangingBeaconsInRegion:_beaconRegion];
        [_delegate beaconManagerStartedMonitoring];
    }
    
}

- (void)stopMonitoring {
    
    NSLog(@"Location Manager - stopping monitoring for region[%@]", _beaconRegion);
    
    [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
    [_delegate beaconManagerStoppedMonitoring];
}

- (void)clearLatestBeacon {
    
    _currentBeacon = nil;
    _currentLocation = BeaconLocationNone;
}

- (BOOL)hasChangedBeacon:(CLBeacon*)beacon {
    
    //TODO Is the new beacon closer than the old beacon by a considerable amount?
    BOOL newBeacon = false;
    
    if ([beacon.proximityUUID isEqual:_currentBeacon.proximityUUID] &&
        [beacon.major isEqual:_currentBeacon.major] &&
        [beacon.minor isEqual:_currentBeacon.minor]) {
        
        [self logIfTracing:[NSString stringWithFormat:@"nearest beacon is [the same] as before"]];
        
        newBeacon = false;
    } else {
        
        _currentBeacon = beacon;
        
        newBeacon = true;
        
        //map the beacon to a new region
        _currentLocation = [self getNewLocationFromCurrentBeacon];
        
        //if we've got a beacon we're not expecting, we should reset and de-range
        if (_currentLocation == BeaconLocationNone) {
            
            [self logIfTracing:[NSString stringWithFormat:@"nearest beacon is now an invalid beacon"]];
            [self clearLatestBeacon];
            
        } else {
            
            [self logIfTracing:[NSString stringWithFormat:@"nearest beacon is now at location [%ld]", (long)_currentLocation]];
        }
    }
    
    return newBeacon;
}

- (BeaconLocation)getNewLocationFromCurrentBeacon {
    
    BeaconLocation newLocation = BeaconLocationNone;
    
    if ([[_currentBeacon.proximityUUID UUIDString] isEqualToString:atosBeaconUUID]) {
        
        //we could just do this as _currentLocation = [_beaconMajor intValue], but this way guards against beacons we don't expect
        switch ([_currentBeacon.major intValue]) {
            case BeaconLocationNone:
                newLocation = BeaconLocationNone;
                break;
            case BeaconLocationKitchen:
                newLocation = BeaconLocationKitchen;
                break;
            case BeaconLocationReception:
                newLocation = BeaconLocationReception;
                break;
            case BeaconLocationDesk:
                newLocation = BeaconLocationDesk;
                break;
            default:
                newLocation = BeaconLocationNone;
                break;
        }
    }
    
    return newLocation;
}

#pragma mark LocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        NSLog(@"Location Manager - authorisation received");
        _hasAuthorisation = YES;
        
        [_delegate beaconManagerAuthorisationToContinue];
        
    } else {
        
        NSLog(@"Location Manager - ERROR - authorisation denied");
        
        _hasAuthorisation = NO;
        
        [_delegate beaconManagerAuthorisationError];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    
    [self logIfTracing:[NSString stringWithFormat:@"ranging found [%lu] beacons, checking nearest", (unsigned long)beacons.count]];
    
    //sort the beacons by Proximity then Accuracy (Nearest to Furthest)
    NSArray<CLBeacon*> *sortedBeacons = [beacons sortedArrayUsingComparator:^NSComparisonResult(CLBeacon *obj1, CLBeacon* obj2) {

        if (obj1.proximity < obj2.proximity) {
            return NSOrderedAscending;
        } else if (obj1.proximity > obj2.proximity) {
            return NSOrderedDescending;
        } else {
            
            if (obj1.accuracy < obj2.accuracy) {
                return NSOrderedAscending;
            } else if (obj1.accuracy > obj2.accuracy) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
            
        }
    }];
    
    CLBeacon *nearestBeacon = nil;
    for (CLBeacon *beacon in sortedBeacons) {
        
        //beacons with an unknown location/accuracy will be first, filter these out
        if (beacon.proximity != CLProximityUnknown && beacon.accuracy != -1) {
            nearestBeacon = beacon;
            
            break;
        }
    }
    
    if (nearestBeacon != nil) {
        
        //check if we've changed beacons
        if ([self hasChangedBeacon:nearestBeacon]) {
        
            //check if the new beacon has been de-ranged (because it's value is something we don't expect)
            if (_currentLocation == BeaconLocationNone) {
                [_delegate beaconManagerDetectedNoBeacons];
            } else {
                [_delegate beaconManagerDetectedLocation:_currentLocation fromBeacon:nearestBeacon];
            }
        } else {
            
            //we've not changed beacon, just updated
            [_delegate beaconManagerUpdatedLocation:_currentLocation fromBeacon:nearestBeacon];
        }
        
    } else {
        
        //no beacons in range
        [self logIfTracing:[NSString stringWithFormat:@"no beacons detected with suitable accuracy"]];
        
        //check to see whether this is a new exit or not
        if (_currentLocation != BeaconLocationNone) {
        
            [self clearLatestBeacon];
            [_delegate beaconManagerDetectedNoBeacons];
        
        }
    }
    
}



@end
