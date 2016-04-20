//
//  SpotAnnotation.m
//  Spotgyro
//
//  Created by BinJin on 12/25/14.
//  Copyright (c) 2014 BinJin. All rights reserved.
//

#import "SpotAnnotation.h"
#import <MapKit/MapKit.h>
#import "Config.h"

int i=0,count;

@implementation SpotAnnotation


+(SpotAnnotation *)sgySpotAnnotationFromFoursquareInfo:(FSVenue *)info CurrLocation:(CLLocationCoordinate2D)curr
{
    SpotAnnotation *annotation = [[SpotAnnotation alloc] init];
    
    CGFloat latitude =  info.location.coordinate.latitude;
    CGFloat longitude = info.location.coordinate.longitude;
    MKCoordinateRegion spotRegion = {{latitude, longitude}, {0.01f, 0.01f}};
    annotation.coordinate = spotRegion.center;
    
    if(info.location.address)
        annotation.address = info.location.address;
    else
        annotation.address = NSLocalizedString(@"Not available", @"Not available");
    
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:curr.latitude longitude:curr.longitude];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:info.coordinate.latitude longitude:info.coordinate.longitude];
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    annotation.distanceMile = [NSString stringWithFormat:@"%.02f miles", distance/1000.0 * MILE_KILO_RATE];
    
    if(info.location.city)
        annotation.city = info.location.city;
    else
        annotation.city = @"";
    
    if(info.location.state)
        annotation.state = info.location.state;
    else
        annotation.state = @"";
    
    if(info.location.contact.formattedPhone)
        annotation.phone = info.location.contact.formattedPhone;
    else
        annotation.phone = @"";
    NSArray *categories = info.categories;
    
    
    if(categories != nil && [categories count] > 0)
    {

        
        
        if(info.venueId.length < 14)
        {
            [[NSUserDefaults standardUserDefaults]setObject:info.venueId forKey:@"Venueids"];
            NSString *categoryID = @"12345";
            annotation.classification = [self filter:categoryID];
            annotation.classification_type=0;
        }
        else
        {
        
//      NSLog(@"category ID for 4 ---%@",[[categories objectAtIndex:0] objectForKey:@"id"]);
       
        NSString *categoryID = [[categories objectAtIndex:0] objectForKey:@"id"];
        
        annotation.classification = [self filter:categoryID];
            
        }
        
        annotation.subtitle = categories[0][@"name"];
    }
    
    if(info.hereNow)
    {
        
        annotation.hereNow = [info.hereNow[@"count"] intValue];
    }
    
//    NSLog(@"%@%@%@",info.deal_left,info.timeleft,info.hourleft);
    
    annotation.title = info.title;
    annotation.checkinsEver = [info.stats.checkinsCount intValue];
    annotation.foursquareId = info.venueId;
    annotation.deal_left=info.deal_left;
    annotation.timeleft=info.timeleft;
    annotation.hourleft=info.hourleft;
    annotation.deal = nil;
    
    return annotation;
}

+(SpotAnnotation *)sgySpotAnnotationFromParseData:(PFObject *)info CurrLocation:(CLLocationCoordinate2D)curr
{
    SpotAnnotation *annotation = [[SpotAnnotation alloc] init];
    
    annotation.title = [info objectForKey:@"name"];
    annotation.foursquareId = [info objectForKey:@"fs_id"];

    PFGeoPoint *locationFromParse = [info objectForKey:@"location"];
    MKCoordinateRegion spotRegion = {{locationFromParse.latitude, locationFromParse.longitude}, {0.01f, 0.01f}};
    annotation.coordinate = spotRegion.center;
    annotation.classification = [info[@"classification"] intValue];
    
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:curr.latitude longitude:curr.longitude];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    annotation.distanceMile = [NSString stringWithFormat:@"%.02f miles", distance/1000.0 * MILE_KILO_RATE];
    
    annotation.address = NSLocalizedString(@"Not available", @"Not available");
    annotation.city = @"";
    annotation.state = @"";
    annotation.phone = @"";
    annotation.subtitle = @"";
    
    // Set the real-time deal information (if any)
    PFObject *dealData = [info objectForKey:@"deal"];
    
    if (dealData)
    {
        annotation.deal = [[SpotDeal alloc] initFromParseObject:dealData];
    }
    
    return annotation;
}

+(NSInteger)filter:(NSString *)categoryID
{
    
    
    NSArray *SGYInAndOutCategoriesArray = [kInAndOutCategoriesString componentsSeparatedByString:@","];
    NSArray *SGYOutAboutCategoriesArray = [kOutAboutCategoriesString componentsSeparatedByString:@","];
    NSArray *SGYRockOnCategoriesArray   = [kRockOnCategoriesString componentsSeparatedByString:@","];
    NSArray *SGYDealOnCategoriesArray   = [kDealOnCategoriesString componentsSeparatedByString:@","];
//    NSArray *SGYDealBlackOnCategoriesArray = [kDealBlackOnCategoriesString componentsSeparatedByString:@","];

    if  ([SGYDealOnCategoriesArray containsObject:categoryID])
    {
        NSMutableArray *arr=[NSMutableArray alloc];
        arr=[[NSUserDefaults standardUserDefaults]objectForKey:@"ids"];
        
        NSMutableArray *arr_type=[[NSMutableArray alloc]init];
        arr_type=[[NSUserDefaults standardUserDefaults]valueForKey:@"Typetriangle"];

        for (int i=0; i<arr_type.count; i++)
        {
            NSString *str_idVenue=[[NSUserDefaults standardUserDefaults]objectForKey:@"Venueids"];
            
            if ([[arr objectAtIndex:i] isEqualToString:str_idVenue] && [[arr_type objectAtIndex:i] isEqualToString:@"pink"])
            {
                return 1;
            }
            else if ([[arr objectAtIndex:i] isEqualToString:str_idVenue] && [[arr_type objectAtIndex:i] isEqualToString:@"green"])
            {
                return 2;
            }
            else if ([[arr objectAtIndex:i] isEqualToString:str_idVenue] && [[arr_type objectAtIndex:i] isEqualToString:@"blue"])
            {
                return 3;
            }
            else  if([[arr objectAtIndex:i] isEqualToString:str_idVenue] && [[arr_type objectAtIndex:i] isEqualToString:@"orange"])
            {
                return 4;
            }
            
        }
        return 0;
        
    }
    else if ([SGYInAndOutCategoriesArray containsObject:categoryID])
    {
        return 1;
    }
    else if ([SGYOutAboutCategoriesArray containsObject:categoryID])
    {
        return 2;
    }
    else if ([SGYRockOnCategoriesArray containsObject:categoryID])
    {
        return 3;
    }
    else
    {
        return 0;
    }

}

#define LAME_MIN    0
#define LAME_MAX    2

#define CHILL_MIN   2
#define CHILL_MAX   4

#define COOL_MIN    4
#define COOL_MAX    6

- (int)getCrowdLevel
{
    if (_hereNow == 0)
        return 0;
    else if(_hereNow > LAME_MIN && _hereNow < LAME_MAX)
        return 1;
    else if(_hereNow >= CHILL_MIN && _hereNow < CHILL_MAX)
        return 2;
    else if(_hereNow >= COOL_MIN && _hereNow < COOL_MAX)
        return 3;
    else
        return 4; // Awesome
}

@end
