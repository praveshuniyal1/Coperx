//
//  SpotNetworkManger.h
//  Spotgyro
//
//  Created by BinJin on 12/24/14.
//  Copyright (c) 2014 BinJin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "Config.h"

@class SpotNetworkManger;
@class SpotAnnotation;

@protocol SpotNetworkMangerDelegate

@optional

- (void)spotManage:(SpotNetworkManger*)manager didAddSpots:(NSArray *)spots;
- (void)spotManage:(SpotNetworkManger*)manager didRemoveSpots:(NSArray *)spots;
- (void)spotManage:(SpotNetworkManger*)manager didGetFavorite:(SpotAnnotation*)anno;

@end

@interface SpotNetworkManger : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, weak) id<SpotNetworkMangerDelegate> delegate;

- (void)getVenuesForLocation:(CLLocation *)location;
- (void)getDealsForLocation:(CLLocation *)location;

- (NSArray *)getSpots;
- (void)getFavoriteSpot;

- (void)updateCurrentLocation:(CLLocation*)location;

-(BOOL)hasUserFavoritedSpotWithFoursquareId:(NSString *)foursquareId;
-(void)toggleFavoriteForSpotWithFoursquareId:(NSString *)foursquareId;

@end
