//
//  UploadManager.m
//  BLEReceiver
//
//  Created by Mike Williams on 16/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import "UploadManager.h"


@interface UploadManager()

@property (strong, nonatomic) NSString *userIdentifier;
@property (strong, nonatomic) NSArray *locations;
@property (strong, nonatomic) UIImage *locationMap;

@end

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

- (void)upload:(NSInteger)locationId successBlock:(UploadSuccessBlock)success failedBlock:(UploadFailedBlock)failed {
    
    NSDate *now = [NSDate date];
    NSString *nowString = [now ISO8601String];
    
    NSDictionary *json = @{@"deviceId" : _userIdentifier, @"locationId" :@(locationId),
                           @"datetime" :nowString};
                                                    
    NSArray *data = @[json];
    
    [self saveLocally:_userIdentifier location:locationId date:now dateString:nowString];
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
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

- (void)registerUserWithEmail:(NSString*)email username:(NSString*)username success:(RegisterSuccessBlock)success failure:(RegisterFailedBlock)failure {
    
    NSDictionary *data = @{@"email" : email, @"username": username};
    
    _userIdentifier = email;
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    [self POST:@"/api/register" parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"response from reg = %@", responseObject);
        
        _locations = responseObject;
        success();
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    
}

- (void)retrieveLocationMapSuccess:(MapSuccessBlock)success failure:(MapFailedBlock)failure {
    
    //Need to set the responseSerializer here to be something which can handle images. So far been unable to find one which handles both images and JSON. Note: we need to be very careful here as we're using a singleton, that we don't change this back to a JSON one before we receive the response.
    self.responseSerializer = [AFImageResponseSerializer serializer];
    
    [self GET:@"/api/locations/map" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        _locationMap = (UIImage*)responseObject;
        
        success(_locationMap);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(error);
    }];
    
}

- (NSDictionary*)locationDataForId:(NSInteger)locationId {
    
    NSDictionary *result = nil;
    
    for (NSDictionary *loc in _locations) {
        if ([loc[@"locationId"] isEqual:@(locationId)]) {
            result = loc;
            break;
        }
    }
    
    return result;
}

@end
