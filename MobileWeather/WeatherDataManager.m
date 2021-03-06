//
//  WeatherDataManager.m
//  MobileWeather
//
//  Copyright (c) 2013-2015 Ford Motor Company. All rights reserved.
//

#import "WeatherDataManager.h"
#import "Settings.h"

@interface WeatherDataManager()

/** This property is used to remember the last known unit type that is set in the settings app. Important to do unit change notification. */
@property (nonatomic) UnitType lastKnownUnit;


@end

@implementation WeatherDataManager

+ (instancetype)sharedManager {
    static id shared = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        // copy the unit value that is saved in the settings app.
        [self setLastKnownUnit:[self unit]];
        
        [center addObserver:self selector:@selector(handleLocationUdpate:) name:MobileWeatherLocationUpdateNotification object:nil];
        [center addObserver:self selector:@selector(handleWeatherDataUpdate:) name:MobileWeatherDataUpdatedNotification object:nil];
        [center addObserver:self selector:@selector(handleUserDefaultsUpdate:) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleLocationUdpate:(NSNotification *)notification {
    WeatherLocation *location = [[notification userInfo] objectForKey:@"location"];
    [self setCurrentLocation:location];
}

- (void)handleWeatherDataUpdate:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    WeatherLanguage *language = [userInfo objectForKey:@"language"];
    WeatherConditions *conditions = [userInfo objectForKey:@"weatherConditions"];
    NSArray *dailyForecast = [userInfo objectForKey:@"dailyForecast"];
    NSArray *hourlyForecast = [userInfo objectForKey:@"hourlyForecast"];
    NSArray *alerts = [userInfo objectForKey:@"alerts"];

    [self setLanguage:language];
    [self setWeatherConditions:conditions];
    [self setDailyForecast:dailyForecast];
    [self setHourlyForecast:hourlyForecast];
    [self setAlerts:alerts];
}

- (void)handleUserDefaultsUpdate:(NSNotification *)notification {
    UnitType old = [self lastKnownUnit];
    UnitType new = [self unit];
    
    if (old != new) {
        [self setLastKnownUnit:new];
        [[NSNotificationCenter defaultCenter] postNotificationName:MobileWeatherUnitChangedNotification object:self userInfo:@{@"old": @(old), @"new": @(new)}];
    }
}

- (UnitType)unit {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *unit = [defaults stringForKey:@"unit"];
    
    if ([PREFS_UNITS_METRIC_KEY isEqualToString:unit]) {
        return UnitTypeMetric;
    }
    else if ([PREFS_UNITS_IMPERIAL_KEY isEqualToString:unit]) {
        return UnitTypeImperial;
    }
    else {
        return UnitTypeUnknown;
    }
}

- (void)setUnit:(UnitType)unit {
    NSString *unitstring = unit == UnitTypeImperial ? PREFS_UNITS_IMPERIAL_KEY : PREFS_UNITS_METRIC_KEY;
    
    // get the app settings and change the unit desired
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:unitstring forKey:PREFS_UNITS_KEY];
    [defaults synchronize];
}


@end
