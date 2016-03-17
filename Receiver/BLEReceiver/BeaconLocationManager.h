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
@property (strong, nonatomic) CLBeacon *currentBeacon;

//if true, logs out every poll interval (second) with beacon details
@property (nonatomic) BOOL traceLog;

//the number of dropouts allowed for the current beacon before it's considered dropped
@property (nonatomic) int dropoutThreshold;

- (void)initialiseLocationManager;
- (void)startMonitoring;
- (void)stopMonitoring;

+ (BeaconLocation)getLocationForID:(int)locationId;
+ (NSString*)getLocationDescriptionForLocation:(BeaconLocation)location;

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