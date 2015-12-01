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
@property (nonatomic, strong) AFHTTPRequestOperationManager *imageRequestManager;

@end


@implementation PLCGoogleMapService

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURL *baseURL = [NSURL URLWithString:PLCGoogleBaseURL];
        _requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        _imageRequestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        _imageRequestManager.responseSerializer = [AFImageResponseSerializer serializer];
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

- (void)getPlacesByTextSearch:(NSString *)text
                      success:(PLCSuccessBlock)successBlock
                      failure:(PLCFailureBlock)failure {
    NSDictionary *params = @{
                             @"key": PLCGoogleAPIKey,
                             @"query": text,
                             @"radius": @(1000)
                             };
    
    void(^success)(AFHTTPRequestOperation *, id) =
    ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableArray *placesModels = [NSMutableArray new];
        
        NSString *status = responseObject[@"status"];
        if (![status isEqualToString:@"OK"]) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *errorMessage = responseObject[@"error_message"];
                    NSDictionary *dict = @{@"localizedDescription": errorMessage};
                    NSError *error = [NSError errorWithDomain:@"PLCErrorDomain" code:-1 userInfo:dict];
                    failure(error);
                });
                
            }
        } else {
        
            NSArray *results = responseObject[@"results"];
            if (results.count == 0) {
                if (successBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        successBlock(@[]);
                    });
                }
            }
            for (NSDictionary *placeDict in results) {
                [placesModels addObject:[PLCPlaceMapper placeWithDictionary:placeDict]];
            }
            if (successBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock([placesModels copy]);
                });
            }
        }
        
    };
    
    void(^fail)(id, NSError *) = ^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.requestManager GET:@"https://maps.googleapis.com/maps/api/place/textsearch/json"
                      parameters:params
                         success:success
                         failure:fail];
    });
}

- (void)getPlacePhotoWithReference:(NSString *)reference
                           success:(PLCSuccessBlock)successBlock
                           failure:(PLCFailureBlock)failure {
    
    void(^success)(AFHTTPRequestOperation *, id) =
    ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        UIImage *image = (UIImage *)responseObject;
        
        if (successBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(image);
            });
        }
    };
    
    void(^fail)(id, NSError *) = ^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    };
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxheight=100&photoreference=%@&key=%@", reference, PLCGoogleAPIKey];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.imageRequestManager GET:urlString
                           parameters:@""
                              success:success
                              failure:fail];
    });
}

@end
