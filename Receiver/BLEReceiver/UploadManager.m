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
    NSDictionary *json = @{@"deviceId" : deviceId, @"locationId" : [NSString stringWithFormat:@"%li", (long)locationId],
                           @"datetime" : [now ISO8601String]};
                                                    
    NSArray *data = @[json];
    
    [self POST:@"/api/deviceLocation" parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];
    
}

@end
