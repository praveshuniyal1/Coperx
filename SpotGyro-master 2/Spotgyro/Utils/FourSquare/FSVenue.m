//
//  VenueAnnotation.m
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/21/13.
//
//

#import "FSVenue.h"

@implementation FSStats

@end

@implementation FSContact

@end

@implementation FSLocation

- (id)init
{
    self = [super init];
    if (self) {
        self.contact = [[FSContact alloc]init];
    }
    return self;
}

@end

@implementation FSVenue

- (id)init
{
    self = [super init];
    if (self) {
        self.location = [[FSLocation alloc] init];
        self.stats = [[FSStats alloc] init];
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.location.coordinate;
}

- (NSString *)title
{
    return self.name;
}
@end
