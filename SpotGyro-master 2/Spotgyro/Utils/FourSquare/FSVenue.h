//
//  VenueAnnotation.h
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/21/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface FSStats : NSObject

@property (nonatomic, strong) NSString                  *checkinsCount;

@end

@interface FSContact : NSObject

@property (nonatomic, strong) NSString                  *formattedPhone;

@end

@interface FSLocation : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D    coordinate;
@property (nonatomic, assign) NSInteger                 distance;
@property (nonatomic, strong) NSString                  *country;
@property (nonatomic, strong) NSString                  *address;
@property (nonatomic, strong) NSString                  *city;
@property (nonatomic, strong) NSString                  *state;
@property (nonatomic, strong) FSContact                 *contact;


@end


@interface FSVenue : NSObject<MKAnnotation>

@property (nonatomic, strong) NSString                  *name;
@property (nonatomic, strong) NSString                  *venueId;
@property (nonatomic, strong) FSLocation                *location;
@property (nonatomic, strong) NSArray                   *categories;
@property (nonatomic, strong) NSDictionary              *hereNow;
@property (nonatomic, strong) FSStats                   *stats;

@property (nonatomic, strong) NSString                   *deal_left;
@property (nonatomic, strong) NSString                 * timeleft;
@property (nonatomic, strong) NSString                  * hourleft;


@end
