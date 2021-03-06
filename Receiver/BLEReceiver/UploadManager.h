//
//  UploadManager.h
//  BLEReceiver
//
//  Created by Mike Williams on 16/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "ISO8601.h"
#import "DeviceLocation.h"
#import <CoreData/CoreData.h>


typedef void (^UploadSuccessBlock) ();
typedef void (^UploadFailedBlock) (NSError *error);

typedef void (^RegisterSuccessBlock) ();
typedef void (^RegisterFailedBlock) (NSError *error);

typedef void (^MapSuccessBlock) (UIImage *map);
typedef void (^MapFailedBlock) (NSError *error);

#define kBaseURL @"https://visitorpal-atosprototype.rhcloud.com"

@interface UploadManager : AFHTTPSessionManager

+ (id)sharedInstance;

- (void)upload:(NSInteger)locationId
    successBlock:(UploadSuccessBlock)success failedBlock:(UploadFailedBlock)failed;

- (void)registerUserWithEmail:(NSString*)email username:(NSString*)username success:(RegisterSuccessBlock)success failure:(RegisterFailedBlock)failure;

- (void)retrieveLocationMapWithSuccess:(MapSuccessBlock)success failure:(MapFailedBlock)failure;

- (NSArray*)getLocationData;
- (UIImage*)getLocationMap;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
