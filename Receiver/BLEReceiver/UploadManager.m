//
//  UploadManager.m
//  BLEReceiver
//
//  Created by Mike Williams on 16/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import "UploadManager.h"

@implementation UploadManager {
    
}

- (instancetype)init {
    self = [super initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

+ (id)sharedInstance {
    static dispatch_once_t once;
    static UploadManager *sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)upload:(NSString*)deviceId location:(NSInteger)locationId successBlock:(UploadSuccessBlock)success failedBlock:(UploadFailedBlock)failed {
    
    NSDate *now = [NSDate date];
    NSString *nowString = [now ISO8601String];
    
    NSDictionary *json = @{@"deviceId" : deviceId, @"locationId" : [NSString stringWithFormat:@"%li", (long)locationId],
                           @"datetime" :nowString};
                                                    
    NSArray *data = @[json];
    
    [self saveLocally:deviceId location:locationId date:now dateString:nowString];
    
    [self POST:@"/api/deviceLocation" parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];
    
}

- (void)saveLocally:(NSString*)deviceId location:(NSInteger)locationId date:(NSDate*)date dateString:(NSString*)dateString {
    
    DeviceLocation *loc = [NSEntityDescription insertNewObjectForEntityForName:@"DeviceLocation" inManagedObjectContext:[self managedObjectContext]];
                           
    loc.deviceId = deviceId;
    loc.locationId = @(locationId);
    loc.datetime = dateString;
    loc.date = date;
    
    NSError *error = nil;
    
    if ([[self managedObjectContext] save:&error] == NO) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"successfully saved locally");
    }
    
}

@end
