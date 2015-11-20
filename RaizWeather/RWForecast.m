//
//  RWForecast.m
//  RaizWeather
//
//  Created by James Whiteman on 11/19/15.
//  Copyright © 2015 Raizlabs. All rights reserved.
//

#import "RWForecast.h"

@implementation RWForecast

+(RWForecast *)parse:(NSDictionary *)data
{
    NSNumber *time = data[@"time"];
    NSNumber *high = data[@"temperatureMax"];
    NSNumber *low = data[@"temperatureMin"];
    RWForecast *forecast = [[RWForecast alloc] initWithTime:time high:high low:low];
    return forecast;
}

-(id)initWithTime:(NSNumber *)time high:(NSNumber *)high low:(NSNumber *)low
{
    self = [super init];
    if (self)
    {
        self.time = time;
        self.high = high;
        self.low = low;
    }
    return self;
}

-(NSString *)text
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"EEEE";
    NSDate *rawDate = [NSDate dateWithTimeIntervalSince1970:self.time.unsignedLongLongValue];
    NSString *date = [formatter stringFromDate:rawDate];
    NSString *text = [NSString stringWithFormat:@"%@ High: %@F Low: %@F", date, self.high, self.low];
    return text;
}

-(NSDictionary *)dictionary
{
    return @{
             @"time": self.time,
             @"high": self.high,
             @"low": self.low
             };
}

@end
