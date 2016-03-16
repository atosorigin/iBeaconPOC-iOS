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

- (void)upload:(NSArray*)data successBlock:(UploadSuccessBlock)success failedBlock:(UploadFailedBlock)failed {
    NSLog(@"UploadManager upload %@", data);
    
    NSURL *url = [NSURL URLWithString:kBaseURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:@"/api/deviceLocation" parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success");
        
        success();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed to upload %@", error);
        failed(error);
    }];
    
}

@end
