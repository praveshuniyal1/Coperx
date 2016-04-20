//
//  SpotDeal.h
//  Spotgyro
//
//  Created by BinJin on 12/25/14.
//  Copyright (c) 2014 BinJin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface SpotDeal : NSObject

@property (nonatomic, strong) NSDate          *dateStart;
@property (nonatomic, strong) NSDate          *dateEnd;
@property (nonatomic, assign) NSTimeInterval  duration; // deprecated
@property (nonatomic, strong) NSString        *dealText;
@property (nonatomic, strong) NSString        *foursquareId;
@property (nonatomic, strong) PFGeoPoint      *location;

- (id)initFromParseObject:(id)parseObject;

- (NSTimeInterval)secondsRemaining;
- (NSString *)getRemainingTimeString;

- (BOOL)isActive;
- (NSString*)activeHours;

@end
