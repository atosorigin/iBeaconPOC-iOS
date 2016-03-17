//
//  DeviceLocation+CoreDataProperties.h
//  BLEReceiver
//
//  Created by Mike Williams on 17/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DeviceLocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceLocation (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *deviceId;
@property (nullable, nonatomic, retain) NSString *datetime;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber *locationId;

@end

NS_ASSUME_NONNULL_END
