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

@property (strong, nonatomic) NSArray *locationData;
@property (strong, nonatomic) NSString *atosUUID;
@property (strong, nonatomic) NSString *atosID;

@property (nonatomic) int numConsecutiveBeaconDropouts;
@property (nonatomic) BOOL hasAuthorisation;

@property (nonatomic) BOOL isInitialized;
@property (nonatomic) BOOL isMonitoring;

@property (nonatomic, assign) CLProximity proximityToMeeting;

@end

@implementation BeaconLocationManager {
    
}

+ (id)sharedInstance {
    static dispatch_once_t once;
    static BeaconLocationManager *sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [self basicInitialisation];
    }
    
    return self;
}

- (void)logIfTracing:(NSString*)logMsg {
    
    if (_traceLog) {
        NSLog(@"Location Manager - trace - %@", logMsg);
    }
    
}

#pragma mark Initialisation

- (void)basicInitialisation {
    
    [self clearLatestBeacon];
    
    _hasAuthorisation = NO;
    _dropoutThreshold = 3;
    
    _numConsecutiveBeaconDropouts = 0;
    
    _isInitialized = NO;
    _isMonitoring = NO;
    
    _locationData = nil;
    _atosID = nil;
    _atosUUID = nil;
    _proximityToMeeting = CLProximityUnknown;
}

- (void)initialiseLocationManagerWithLocations:(NSArray*)locations {
    
    NSLog(@"Location Manager - initialising");
    
    //re-do the basic initialisation - this is incase we're starting again from fresh, but we've not got a new object
    [self basicInitialisation];
    
    _currentLocationId = BEACON_NONE;
    _locationData = locations;
    
    [self initFromLocationData];
    
    [self initBeaconRegion];
    [self initLocationManager];
    
    _isInitialized = YES;
    
    [_locationManager requestWhenInUseAuthorization];
}

- (void)initFromLocationData {
    
    assert([_locationData count] > 0);
    
    //assume that all the locations have the same UUID, AtosID
    NSDictionary *location = [_locationData firstObject];
    
    _atosUUID = location[@"uuid"];
    _atosID = location[@"refId"];
    
}

- (void)initBeaconRegion {
    
    NSLog(@"Location Manager - creating beacon region for uuid [%@] and id [%@]", _atosUUID, _atosID);
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:_atosUUID];
    
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:_atosID];
    
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

#pragma mark Commands

- (void)startMonitoring {
    
    //start monitoring if we're authorised, initialised and not already monitoring
    if (_hasAuthorisation && _isInitialized && !_isMonitoring) {
        
        NSLog(@"Location Manager - starting monitoring for region[%@] and updating heading", _beaconRegion);
        
        _isMonitoring = YES;
        
        [_locationManager startUpdatingHeading];
        [_locationManager startRangingBeaconsInRegion:_beaconRegion];
        [_delegate beaconManagerStartedMonitoring];
    }
    
}

- (void)stopMonitoring {
    
    //stop monitoring if we're already monitoring
    if (_isMonitoring) {
        NSLog(@"Location Manager - stopping monitoring for region[%@] and stop updating heading", _beaconRegion);
    
        [_locationManager stopUpdatingHeading];
        [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
        [_delegate beaconManagerStoppedMonitoring];
    }
}

#pragma mark LocationData Handlers

- (BOOL)validateBeaconValueIsValidLocation:(int)beaconValue {
    
    BOOL matchedLocationId = false;
    
    //check to see whether the beaconId is in our expected list of locations
    for (NSDictionary *loc in _locationData) {
        if ([loc[@"locationId"] isEqual:@(beaconValue)]) {
            matchedLocationId = true;
            break;
        }
    }
    
    return matchedLocationId;
}

- (NSDictionary*)locationDataForId:(NSInteger)locationId {
    
    NSDictionary *result = nil;
    
    for (NSDictionary *loc in _locationData) {
        if ([loc[@"locationId"] isEqual:@(locationId)]) {
            result = loc;
            break;
        }
    }
    
    return result;
}

- (NSDictionary*)locationDataForMeeting {
    NSDictionary *result = nil;
    
    for (NSDictionary *loc in _locationData) {
        if ([loc[@"isMeetingLocation"] isEqual:@(1)]) {
            result = loc;
            break;
        }
    }
    
    return result;
}

#pragma mark Utility

- (void)clearLatestBeacon {
    
    _currentBeacon = nil;
    _currentLocationId = BEACON_NONE;
}

- (BOOL)beacon:(CLBeacon*)beacon1 isEquivalentToBeacon:(CLBeacon*)beacon2 {
    
    return ([beacon1.proximityUUID isEqual:beacon2.proximityUUID] &&
            [beacon1.major isEqual:beacon2.major] &&
            [beacon1.minor isEqual:beacon2.minor]);
}

- (BOOL)hasChangedBeacon:(CLBeacon*)beacon {
    
    //TODO Is the new beacon closer than the old beacon by a considerable amount?
    BOOL newBeacon = false;
    
    if ([self beacon:beacon isEquivalentToBeacon:_currentBeacon]) {
        
        [self logIfTracing:[NSString stringWithFormat:@"nearest beacon is [the same] as before"]];
        
        newBeacon = false;
        
    } else {
        
        _currentBeacon = beacon;
        
        newBeacon = true;
        
        //map the beacon to a new region
        _currentLocationId = [self getNewLocationFromCurrentBeacon];
        
        //if we've got a beacon we're not expecting, we should reset and de-range
        if (_currentLocationId == BEACON_NONE) {
            
            [self logIfTracing:[NSString stringWithFormat:@"nearest beacon is now an invalid beacon"]];
            [self clearLatestBeacon];
            
        } else {
            
            [self logIfTracing:[NSString stringWithFormat:@"nearest beacon is now at location [%d]", _currentLocationId]];
        }
    }
    
    return newBeacon;
}

- (int)getNewLocationFromCurrentBeacon {
    
    int newLocation = BEACON_NONE;
    
    if ([[_currentBeacon.proximityUUID UUIDString] isEqualToString:_atosUUID]) {
    
        int beaconValue = [_currentBeacon.minor intValue];
        
        if ([self validateBeaconValueIsValidLocation:beaconValue]) {
            newLocation = beaconValue;
        }
    }
    
    return newLocation;
}

- (NSArray<CLBeacon*>*)sortBeaconsByAccuracy:(NSArray<CLBeacon*>*)beacons {
    
    //sort the beacons by Proximity then Accuracy (Nearest to Furthest)
    NSArray<CLBeacon*> *sortedBeacons = [beacons sortedArrayUsingComparator:^NSComparisonResult(CLBeacon *obj1, CLBeacon* obj2) {
        
        if (obj1.accuracy < obj2.accuracy) {
            return NSOrderedAscending;
        } else if (obj1.accuracy > obj2.accuracy) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
        
    }];
    
    return sortedBeacons;
    
}

#pragma mark LocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    [_delegate beaconManagerChangedHeading:newHeading];
}

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
    
    NSArray<CLBeacon*> *sortedBeacons = [self sortBeaconsByAccuracy:beacons];
    
    //DEBUG BEACONS
    /*
    int i = 0;
    for (CLBeacon *beacon in sortedBeacons) {
        NSLog(@"DEBUG - beacon[%d] has max[%d] and accuracy[%f] and rssi[%ld]", i, [beacon.major intValue], beacon.accuracy, beacon.rssi);
        i++;
    }
     */
    //END DEBUG BEACONS
    
    NSDictionary *meetingLoc = [self locationDataForMeeting];
    
    BOOL meetingLocationFound = NO;
    
    CLBeacon *nearestBeacon = nil;
    BOOL nearestBeaconDidDropout = false;
    for (CLBeacon *beacon in sortedBeacons) {
        
        // Save the meeting proximity per update
        if (meetingLoc[@"locationId"] != nil) {
            if ([meetingLoc[@"locationId"] isEqual:beacon.minor]) {
                meetingLocationFound = YES;
                meetingLocationFound = YES;
                if (_proximityToMeeting != beacon.proximity) {
                    [self logIfTracing:[NSString stringWithFormat:@"Updating meeting proximity to [%ld]", (long)beacon.proximity]];
                     _proximityToMeeting = beacon.proximity;
                    [_delegate beaconManagerMeetingProximityUpdated:_proximityToMeeting rssi:beacon.rssi];
                }
            }
        }
        
        //beacons with an unknown location/accuracy will be first, filter these out
        if (beacon.proximity != CLProximityUnknown && beacon.accuracy != -1) {
            nearestBeacon = beacon;
            break;
        } else {
            //nearest beacon is unknown, lets check to see if its the beacon we're currently attached to
            if ([self beacon:beacon isEquivalentToBeacon:_currentBeacon]) {
                
                _numConsecutiveBeaconDropouts++;
                
                [self logIfTracing:[NSString stringWithFormat:@"current beacon has dropped out [%d] time/s, threshold is [%d]", _numConsecutiveBeaconDropouts, _dropoutThreshold]];
                
                //if the beacon has dropped out less than equal to the threshold, continue as if the beacon is still connected
                if (_numConsecutiveBeaconDropouts <= _dropoutThreshold) {
                
                    nearestBeacon = _currentBeacon;
                    nearestBeaconDidDropout = true;
                    break;
                }
            }
        }
    }
    
    if (meetingLocationFound == NO && _proximityToMeeting != CLProximityUnknown) {
        [self logIfTracing:[NSString stringWithFormat:@"Couldnt find meeting beacon - setting proximity to unknown"]];
        _proximityToMeeting = CLProximityUnknown;
        [_delegate beaconManagerMeetingProximityUpdated:_proximityToMeeting rssi:-1];
        
    }
    
    //reset the counter if we're not dealing with a dropout beacon
    if (!nearestBeaconDidDropout) {
        _numConsecutiveBeaconDropouts = 0;
    }
    
    if (nearestBeacon != nil) {
        
        //check if we've changed beacons
        if ([self hasChangedBeacon:nearestBeacon]) {
        
            //check if the new beacon has been de-ranged (because it's value is something we don't expect)
            if (_currentLocationId == BEACON_NONE) {
                [_delegate beaconManagerDetectedNoBeacons];
            } else {
                [_delegate beaconManagerDetectedLocationId:_currentLocationId fromBeacon:nearestBeacon];
            }
        } else {
            
            //we've not changed beacon, just updated
            [_delegate beaconManagerUpdatedLocationId:_currentLocationId fromBeacon:nearestBeacon];
        }
        
    } else {
        
        //no beacons in range
        [self logIfTracing:[NSString stringWithFormat:@"no beacons detected with suitable accuracy"]];
        
        //check to see whether this is a new exit or not
        if (_currentLocationId != BEACON_NONE) {
        
            [self clearLatestBeacon];
            [_delegate beaconManagerDetectedNoBeacons];
        
        }
    }
    
}



@end
