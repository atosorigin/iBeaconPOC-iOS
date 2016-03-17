//
//  RootViewController.h
//  BLEReceiver
//
//  Created by Peter Brock on 08/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconLocationManager.h"
#import "UploadManager.h"
#import "AppDelegate.h"

#define kDeviceIdentiier @"123456789"

@interface RootViewController : UIViewController<BeaconLocationManagerDelegate>

@end

