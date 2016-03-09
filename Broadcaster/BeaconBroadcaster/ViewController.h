//
//  ViewController.h
//  BeaconBroadcaster
//
//  Created by Mike Williams on 04/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;
@import CoreBluetooth;

static int broadcastpower = -59;

#define kDefaultMinValue 0
#define kKitchenMaxValue 1
#define kReceptionMaxValue 2
#define kDesksMaxValue 3

@interface ViewController : UIViewController<CBPeripheralManagerDelegate, UIPickerViewDataSource>


@end

