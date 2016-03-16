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


typedef void (^UploadSuccessBlock) ();
typedef void (^UploadFailedBlock) (NSError *error);

#define kBaseURL @"http://development-visitorpal.rhcloud.com"

@interface UploadManager : AFHTTPSessionManager

+ (id)sharedInstance;

- (void)upload:(NSString*)deviceId location:(NSInteger)locationId
    successBlock:(UploadSuccessBlock)success failedBlock:(UploadFailedBlock)failed;

@end
