//
//  PLCGoogleMapService.m
//  Places
//
//  Created by azat on 28/11/15.
//  Copyright © 2015 azat. All rights reserved.
//

#import "PLCGoogleMapService.h"
#import <AFNetworking.h>
#import "PLCLocationHelper.h"
#import "PLCPlaceMapper.h"

NSString *const PLCGoogleBaseURL = @"https://maps.googleapis.com/maps/api/place/";
NSString *const PLCGoogleAPIKey = @"AIzaSyBhpEhL8vvERVuY9ynrHuElB7kEKdWyiHI";

@interface PLCGoogleMapService()

@property (nonatomic, strong) AFHTTPRequestOperationManager *requestManager;

@end


@implementation PLCGoogleMapService

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURL *baseURL = [NSURL URLWithString:PLCGoogleBaseURL];
        _requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:nil];
    }
    return self;
}


- (void)getPlacesNearCoordinate:(CLLocationCoordinate2D)location
                        success:(PLCSuccessBlock)successBlock
                        failure:(PLCFailureBlock)failure {
    
    NSDictionary *params = @{
                             @"key": PLCGoogleAPIKey,
                             @"location": stringFromCoordinate(location),
                             @"radius": @(1000)
                             };
    
    void(^success)(AFHTTPRequestOperation *, id) =
    ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableArray *placesModels = [NSMutableArray new];
        
        NSArray *results = responseObject[@"results"];
        if (results.count == 0) {
            if (successBlock) {
                successBlock(@[]);
            }
        }
        for (NSDictionary *placeDict in results) {
            [placesModels addObject:[PLCPlaceMapper placeWithDictionary:placeDict]];
        }
        if (successBlock) {
            successBlock([placesModels copy]);
        }
        
    };
    
    void(^fail)(id, NSError *) = ^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    };
    
    [self.requestManager GET:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json"
                  parameters:params
                     success:success
                     failure:fail];
}

@end
