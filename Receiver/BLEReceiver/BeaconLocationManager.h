//
//  BeaconLocationManager.h
//  BLEReceiver
//
//  Created by Peter Brock on 15/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol BeaconLocationManagerDelegate;

typedef NS_ENUM(NSInteger, BeaconLocation) {
    BeaconLocationNone,
    BeaconLocationKitchen,
    BeaconLocationReception,
    BeaconLocationDesk
};

@interface BeaconLocationManager : NSObject<CLLocationManagerDelegate>

@property (nonatomic, weak) id<BeaconLocationManagerDelegate> delegate;
@property (nonatomic) BeaconLocation currentLocation;
@property (nonatomic) BOOL traceLog;

- (void)initialiseLocationManager;
- (void)startMonitoring;
- (void)stopMonitoring;

@end

@protocol BeaconLocationManagerDelegate <NSObject>

- (void)beaconManagerAuthorisationToContinue;
- (void)beaconManagerAuthorisationError;

- (void)beaconManagerStartedMonitoring;
- (void)beaconManagerStoppedMonitoring;

- (void)beaconManagerDetectedNoBeacons;
- (void)beaconManagerDetectedLocation:(BeaconLocation)currentLocation fromBeacon:(CLBeacon*)beacon;
- (void)beaconManagerUpdatedLocation:(BeaconLocation)currentLocation fromBeacon:(CLBeacon*)beacon;

@end