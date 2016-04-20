//
//  SpotDeal.m
//  Spotgyro
//
//  Created by BinJin on 12/25/14.
//  Copyright (c) 2014 BinJin. All rights reserved.
//

#import "SpotDeal.h"

@implementation SpotDeal

-(id)initFromParseObject:(id)parseObject
{    
    if(self = [super init])
    {
        self.dateStart      = parseObject[@"date_start"];
        self.dateEnd        = parseObject[@"date_end"];
        self.duration       = [parseObject[@"duration"] doubleValue];
        self.dealText       = parseObject[@"deal_text"];
        self.foursquareId   = parseObject[@"foursquare_id"];
        self.location       = parseObject[@"location"];
        
#if DEBUG
        if(!_dateStart || !_dateEnd || !_location)
        {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"WARNING: RTDeal created with empty date_start, date_end, or location." userInfo:nil];
        }
        else
        {
            NSLog(@"Created RTDeal: %@", self);
        }
#endif
        
    }
    return self;
}


- (NSDate*) dateToGMT:(NSDate*)sourceDate
{
    
    NSTimeZone* destTimeZone = [NSTimeZone localTimeZone];
    NSInteger destGMTOffset = [destTimeZone secondsFromGMTForDate:sourceDate];
    NSDate* destDate = [[NSDate alloc] initWithTimeInterval:destGMTOffset sinceDate:sourceDate];
    return destDate;
    
    return sourceDate;
}

- (NSDate*) GMTTodate:(NSDate*)sourceDate
{
    
    NSTimeInterval timeZoneOffset = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSTimeInterval gmtTimeInterval = [sourceDate timeIntervalSinceReferenceDate]-timeZoneOffset;
    NSDate* gmtDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
    return gmtDate;
    
    return sourceDate;
}

-(NSTimeInterval)secondsRemaining
{
    // Note: Dates coming from the Parse database are all in UTC format
    NSDate *nowDate = [NSDate date];
    if([nowDate compare:[self GMTTodate:_dateStart]] == NSOrderedDescending &&
       [nowDate compare:[self GMTTodate:_dateEnd]]   == NSOrderedAscending)
    {
        return [[self GMTTodate:_dateEnd] timeIntervalSinceNow];
    }
    else
    {
        return -1; // Deal has expired
    }
}

-(NSString *)getRemainingTimeString
{
    NSTimeInterval remaining = [self secondsRemaining];
    
    if(remaining == -1)
        return @"Expired :(";
    
    int hours   = (int)(remaining /60 / 60);
    int minutes = (int)((remaining - hours * 60 * 60) / 60);
    int seconds = (int)(remaining - minutes * 60 - hours * 60 * 60);
    
    if (hours > 0)
        return [NSString stringWithFormat:@"%dh:%02dm:%02ds", hours, minutes, seconds];
    else if(minutes > 0)
        return [NSString stringWithFormat:@"%2dm:%02ds", minutes, seconds];
    else
        return [NSString stringWithFormat:@"%2ds", seconds];
}

-(BOOL)isActive
{
    if ([self secondsRemaining] != -1) {
        return true;
    }
    return false;
}

- (NSString*)activeHours
{
    NSString *hours;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    hours = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:self.dateStart], [formatter stringFromDate:self.dateEnd]];
    
    return hours;
}

@end
