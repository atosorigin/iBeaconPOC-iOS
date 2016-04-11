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
#import "HighlightableCellGrid.h"

@interface RootViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgCompass;
@property (weak, nonatomic) IBOutlet UIImageView *imgMap;
@property (weak, nonatomic) IBOutlet HighlightableCellGrid *viewGridContainer;

@property (weak, nonatomic) IBOutlet UILabel *labelCurrentLocation;
@property (weak, nonatomic) IBOutlet UILabel *textCurrentLocation;
@property (weak, nonatomic) IBOutlet UILabel *textMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imagePowered;
@property (weak, nonatomic) IBOutlet UIImageView *imageConnected;
@end

@implementation RootViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set the compass up
    CGAffineTransform compassTransform = CGAffineTransformMakeRotation(0);
    [_imgCompass setTransform:compassTransform];
    
    //load the beacon map image into the view
    [_imgMap setImage:[[UploadManager sharedInstance] getLocationMap]];
    
    //create the location manager
    BeaconLocationManager *manager = [BeaconLocationManager sharedInstance];
    manager.delegate = self;
    manager.traceLog = NO;
    
    //save initial 'Out of area' state
    [self saveLocationChange:BEACON_NONE];
    
    //configure the screen
    [self configureOffline];
    
    //start the location manager here, after we've logged in!
    [manager initialiseLocationManagerWithLocations:[[UploadManager sharedInstance] getLocationData]];
    
    //now highlight the meeting location
    NSDictionary *locationData = [manager locationDataForMeeting];
    NSNumber *xRef = locationData[@"xRef"];
    NSNumber *yRef = locationData[@"yRef"];
    [_viewGridContainer exclusiveMeetingHighlightCellX:[xRef intValue] andCellY:[yRef intValue]];
}

- (void)viewWillAppear:(BOOL)animated {

}

- (void)viewDidDisappear:(BOOL)animated {

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

#pragma mark Screen Configuration
- (void)configureOffline {
    
    [_labelCurrentLocation setHidden:YES];
    [_textMessage setHidden:YES];
    [_textCurrentLocation setHidden:YES];
    
    [_imagePowered setImage:[UIImage imageNamed:@"offline"]];
    [_imageConnected setHidden:YES];
    
}

- (void)configureOnlineNoBeacons {
    
    [_labelCurrentLocation setHidden:YES];
    [_textMessage setHidden:YES];
    [_textCurrentLocation setHidden:YES];
    
    [_imagePowered setImage:[UIImage imageNamed:@"online"]];
    [_imageConnected setHidden:YES];
}

- (void)configureOnlineBeaconsWithLocation:(NSString*)location andMessage:(NSString*)message {
    
    [_labelCurrentLocation setHidden:NO];
    [_textMessage setHidden:NO];
    [_textMessage setText:message];
    [_textCurrentLocation setHidden:NO];
    [_textCurrentLocation setText:location];
    
    [_imagePowered setImage:[UIImage imageNamed:@"online"]];
    [_imageConnected setHidden:NO];
}

#pragma mark BeaconLocationManagerDelegate

- (void)beaconManagerAuthorisationToContinue {
    
    [[BeaconLocationManager sharedInstance] startMonitoring];
}

- (void)beaconManagerAuthorisationError {
    NSLog(@"Beacon Manager didn't manage to authorise, won't work!");
}

- (void)beaconManagerStartedMonitoring {
    [self configureOnlineNoBeacons];
}

- (void)beaconManagerStoppedMonitoring {
    [self configureOffline];
}

- (void)beaconManagerDetectedNoBeacons {
    
    [self saveLocationChange:BEACON_NONE];
    
    [self configureOnlineNoBeacons];
    [_viewGridContainer exclusiveHighlightCellX:-1 andCellY:-1];
    
    [self speak:@"You have now left the area!"];
}

- (void)beaconManagerDetectedLocationId:(int)currentLocationId fromBeacon:(CLBeacon*)beacon {
    
    [self saveLocationChange:currentLocationId];
    
    NSString *speech = @"";
    
    NSDictionary *locationData = [[BeaconLocationManager sharedInstance] locationDataForId:currentLocationId];
    NSLog(@"found locationData %@", locationData);
    
    if (locationData != nil) {
        speech = locationData[@"audio"];
        
        NSNumber *xRef = locationData[@"xRef"];
        NSNumber *yRef = locationData[@"yRef"];
        
        [_viewGridContainer exclusiveHighlightCellX:[xRef intValue] andCellY:[yRef intValue]];
        
        [self configureOnlineBeaconsWithLocation:locationData[@"description"] andMessage:locationData[@"audio"]];

    } else {

        //if we don't have location data, something has gone wrong somewhere :/
        [self configureOnlineNoBeacons];
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


- (void)beaconManagerUpdatedLocationId:(int)currentLocationId fromBeacon:(CLBeacon*)beacon {
    
    //_labelBeaconDetails.text = [self stringFromBeacon:beacon];
}

- (void)beaconManagerChangedHeading:(CLHeading *)newHeading {
    
    double radians = (newHeading.trueHeading * M_PI) / 180;
    CGAffineTransform compassTransform = CGAffineTransformMakeRotation(-1 * radians);
    [_imgCompass setTransform:compassTransform];
}

@end
