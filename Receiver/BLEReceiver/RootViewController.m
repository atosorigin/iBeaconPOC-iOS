//
//  RootViewController.m
//  BLEReceiver
//
//  Created by Peter Brock on 08/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "RootViewController.h"
#import "UploadManager.h"

@interface RootViewController ()

@property (strong, nonatomic) BeaconLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIImageView *imgCompass;
@property (weak, nonatomic) IBOutlet UIImageView *imgMap;
@property (weak, nonatomic) IBOutlet UIView *viewGridContainer;

@property (weak, nonatomic) IBOutlet UILabel *labelCurrentLocation;
@end

@implementation RootViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGAffineTransform compassTransform = CGAffineTransformMakeRotation(0);
    [_imgCompass setTransform:compassTransform];
    
    [self configureBeaconMap];
    
    _locationManager = [[BeaconLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.traceLog = YES;
    
    // Save initial 'Out of area state'
    [self saveLocationChange:BeaconLocationNone];
    
    [_locationManager initialiseLocationManager];
    //[_locationManager startMonitoring];
}

- (void)viewWillAppear:(BOOL)animated {
    
    //[_locationManager startMonitoring];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    //[_locationManager stopMonitoring];
}

- (void)configureBeaconMap {
    
    [_imgMap setImage:[[UploadManager sharedInstance] getLocationMap]];
    
    //with the viewGridContainer, programmatically add stackview of views 5x5

}

- (NSString*)stringFromBeacon:(CLBeacon*)beacon {
    
    NSString *string = [NSString stringWithFormat:@"RSSI = %ld \nAccuracy = %.3fm \n", (long)beacon.rssi, beacon.accuracy];
    
    NSString *proximity;
    switch (beacon.proximity) {
        case CLProximityUnknown:
            proximity = @"CLProximityUnknown";
            break;
        case CLProximityFar:
            proximity = @"CLProximityFar";
            break;
        case CLProximityImmediate:
            proximity = @"CLProximityImmediate";
            break;
        case CLProximityNear:
            proximity = @"CLProximityNear";
            break;
    }
    
    string = [string stringByAppendingString:proximity];
    
    return string;
}

- (void)speak:(NSString*)speech {
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speech];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
    
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    [synth speakUtterance:utterance];
}

- (void)configureUINoBeacons {
    
    /*
    [_labelBeaconDetails setHidden:YES];
    [_labelStatus setHidden:YES];
    
    [_viewKitchen setHidden:YES];
    [_viewReception setHidden:YES];
    [_viewDesk setHidden:YES];
     */
}

#pragma mark BeaconLocationManagerDelegate

- (void)beaconManagerAuthorisationToContinue {
    
    [_locationManager startMonitoring];
}

- (void)beaconManagerAuthorisationError {
    NSLog(@"Beacon Manager didn't manage to authorise, won't work!");
}

- (void)beaconManagerStartedMonitoring {
    //[_labelScanning setHidden:NO];
}

- (void)beaconManagerStoppedMonitoring {
    //[_labelScanning setHidden:YES];
}

- (void)beaconManagerDetectedNoBeacons {
    
    [self configureUINoBeacons];
    
    [self saveLocationChange:BeaconLocationNone];
    [self speak:@"You have now left the area!"];
}

- (void)beaconManagerDetectedLocation:(BeaconLocation)currentLocation fromBeacon:(CLBeacon*)beacon {
    
    //[_labelStatus setHidden:NO];
    //[_labelBeaconDetails setHidden:NO];
    
    //_labelBeaconDetails.text = [self stringFromBeacon:beacon];
    
    [self saveLocationChange:currentLocation];
    
    NSString *speech;
    
    NSDictionary *locationData = [[UploadManager sharedInstance] locationDataForId:currentLocation];
    
    NSLog(@"found locationData %@", locationData);
    
    if (locationData != nil) {
        speech = locationData[@"audio"];//[NSString stringWithFormat:@"You are now at the %@", locationData[@"description"]];
        _labelCurrentLocation.text = locationData[@"description"];
    } else {
        _labelCurrentLocation.text = @"";
    }
    
    switch (currentLocation) {
        case BeaconLocationKitchen:
            //[_viewKitchen setHidden:NO];
            //[_viewReception setHidden:YES];
            //[_viewDesk setHidden:YES];
            break;
        case BeaconLocationReception:
            //[_viewKitchen setHidden:YES];
            //[_viewReception setHidden:NO];
            //[_viewDesk setHidden:YES];
            break;
        case BeaconLocationDesk:
            //[_viewKitchen setHidden:YES];
            //[_viewReception setHidden:YES];
            //[_viewDesk setHidden:NO];
            break;
        case BeaconLocationNone:
        default:
            //speech = @"You're Lost!";
            break;
    }
    
    [self speak:speech];
    
}

- (void)saveLocationChange:(NSInteger)location {
    
    [[UploadManager sharedInstance] upload:location successBlock:^{
        // could add visual indicator
    } failedBlock:^(NSError *error) {
        NSLog(@"Failed to upload %@", error);
    }];
    
}


- (void)beaconManagerUpdatedLocation:(BeaconLocation)currentLocation fromBeacon:(CLBeacon*)beacon {
    
    //_labelBeaconDetails.text = [self stringFromBeacon:beacon];
}

- (void)beaconManagerChangedHeading:(CLHeading *)newHeading {
    
    double radians = (newHeading.trueHeading * M_PI) / 180;
    CGAffineTransform compassTransform = CGAffineTransformMakeRotation(-1 * radians);
    [_imgCompass setTransform:compassTransform];
}

@end
