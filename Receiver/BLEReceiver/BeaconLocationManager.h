//
//  BeaconLocationManager.h
//  BLEReceiver
//
//  Created by Peter Brock on 15/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define BEACON_NONE 0

@protocol BeaconLocationManagerDelegate;

@interface BeaconLocationManager : NSObject<CLLocationManagerDelegate>

@property (nonatomic, weak) id<BeaconLocationManagerDelegate> delegate;
@property (nonatomic) int currentLocationId;
@property (strong, nonatomic) CLBeacon *currentBeacon;

//if true, logs out every poll interval (second) with beacon details
@property (nonatomic) BOOL traceLog;

//the number of dropouts allowed for the current beacon before it's considered dropped
@property (nonatomic) int dropoutThreshold;

- (void)initialiseLocationManagerWithLocations:(NSArray*)locations;
- (void)startMonitoring;
- (void)stopMonitoring;

- (NSDictionary*)locationDataForId:(NSInteger)locationId;

@end

@protocol BeaconLocationManagerDelegate <NSObject>

- (void)beaconManagerAuthorisationToContinue;
- (void)beaconManagerAuthorisationError;

- (void)beaconManagerStartedMonitoring;
- (void)beaconManagerStoppedMonitoring;

- (void)beaconManagerDetectedNoBeacons;
- (void)beaconManagerDetectedLocationId:(int)currentLocationId fromBeacon:(CLBeacon*)beacon;
- (void)beaconManagerUpdatedLocationId:(int)currentLocationId fromBeacon:(CLBeacon*)beacon;

- (void)beaconManagerChangedHeading:(CLHeading*)newHeading;

@end