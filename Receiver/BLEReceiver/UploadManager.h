//
//  UploadManager.h
//  BLEReceiver
//
//  Created by Mike Williams on 16/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void (^UploadSuccessBlock) ();
typedef void (^UploadFailedBlock) (NSError *error);

#define kBaseURL @"http://development-visitorpal.rhcloud.com"

@interface UploadManager : NSObject

- (void)upload:(NSArray*)data successBlock:(UploadSuccessBlock)success failedBlock:(UploadFailedBlock)failed;

@end
