//
//  WeatherProcessor.h
//  MobileWeather
//
//  Copyright (c) 2013-2015 Ford Motor Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Forecast.h"
#import "WeatherConditions.h"

@protocol WeatherProcessor <NSObject>

@required

+ (WeatherConditions *)weatherConditions:(NSDictionary *)json;

+ (NSArray *)dailyForecast:(NSDictionary *)json;

+ (NSArray *)hourlyForecast:(NSDictionary *)json;

+ (NSArray *)alerts:(NSDictionary *)json;

@end
