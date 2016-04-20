
//
//  FSConverter.m
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 2/7/13.
//
//

#import "FSConverter.h"
#import "FSVenue.h"

@implementation FSConverter


- (NSArray *)convertToObjects:(NSArray *)venues
{
    _arr_VanueID=[[NSMutableArray alloc]init];
    _arr_parseID=[[NSMutableArray alloc]init];
    _arr_ServiceData=[[NSMutableArray alloc]init];
    
    NSLog(@"%@",venues);

    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:venues.count];
    for (NSDictionary *v  in venues)
    {
        FSVenue *ann = [[FSVenue alloc]init];
        ann.name                = v[@"name"];
        ann.venueId             = v[@"id"];
        ann.location.address    = v[@"location"][@"formattedAddress"][0];
        ann.location.distance   = [v[@"location"][@"distance"] integerValue];
        ann.location.country    = v[@"location"][@"country"];
        ann.location.city       = v[@"location"][@"city"];
        ann.location.state      = v[@"location"][@"state"];
        ann.location.contact.formattedPhone = v[@"contact"][@"formattedPhone"];
        ann.categories          = v[@"categories"];
        ann.hereNow             = v[@"hereNow"];
        ann.stats.checkinsCount = v[@"stats"][@"checkinsCount"];
        ann.timeleft = v[@"time_left"];
        ann.hourleft = v[@"hour_left"];
        ann.deal_left = v[@"deal_left"];
        [ann.location setCoordinate:CLLocationCoordinate2DMake([v[@"location"][@"lat"] doubleValue],[v[@"location"][@"lng"] doubleValue])];
        [objects addObject:ann];
    }
    
    return objects;
}

@end
