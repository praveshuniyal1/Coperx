//
//  SpotAnnotation.h
//  Spotgyro
//
//  Created by BinJin on 12/25/14.
//  Copyright (c) 2014 BinJin. All rights reserved.

#import <UIKit/UIKit.h>
#import <MapKit/MKAnnotation.h>
#import "SpotDeal.h"
#import "FSVenue.h"

@interface SpotAnnotation : UIView <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D    currCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D    coordinate;
@property (nonatomic, copy) NSString                    *title;
@property (nonatomic, copy) NSString                    *subtitle;
@property (nonatomic, strong) NSString                  *foursquareId;
@property (nonatomic, strong) NSString                  *distanceMile;
@property (nonatomic, strong) NSString                  *phone;
@property (nonatomic, strong) NSString                  *address;
@property (nonatomic, strong) NSString                  *city;
@property (nonatomic, strong) NSString                  *state;
@property (nonatomic, assign) NSInteger                 classification;
@property (nonatomic, assign) NSInteger                 classification_type;

@property (nonatomic, assign) NSInteger                 checkinsEver;
@property (nonatomic, assign) NSInteger                 hereNow;
@property (nonatomic, assign) NSInteger                 venueId;
@property (nonatomic, strong) SpotDeal                  *deal;
@property (nonatomic,strong) NSArray *SGYDEALCategoriesArray;

@property (nonatomic, strong) NSString                   *deal_left;
@property (nonatomic, strong) NSString                 * timeleft;
@property (nonatomic, strong) NSString                  * hourleft;




@property (nonatomic,strong) NSMutableArray *arr_user_id;
+(SpotAnnotation *)sgySpotAnnotationFromFoursquareInfo:(FSVenue *)info CurrLocation:(CLLocationCoordinate2D)curr;
+(SpotAnnotation *)sgySpotAnnotationFromParseData:(PFObject *)info CurrLocation:(CLLocationCoordinate2D)curr;

+(NSInteger)filter:(NSString *)categoryID;
- (int)getCrowdLevel;


@end
