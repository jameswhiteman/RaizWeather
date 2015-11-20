//
//  RWForecast.h
//  RaizWeather
//
//  Created by James Whiteman on 11/19/15.
//  Copyright © 2015 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RWForecast : NSObject

+(RWForecast *)parse:(NSDictionary *)data;

@property (strong, nonatomic) NSNumber *time;
@property (strong, nonatomic) NSNumber *high;
@property (strong, nonatomic) NSNumber *low;

-(id)initWithTime:(NSNumber *)time high:(NSNumber *)high low:(NSNumber *)low;
-(NSString *)text;
-(NSDictionary *)dictionary;

@end
