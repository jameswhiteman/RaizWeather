//
//  ViewController.m
//  RaizWeather
//
//  Created by James Whiteman on 11/19/15.
//  Copyright © 2015 Raizlabs. All rights reserved.
//

#import "ViewController.h"

NSString *const IdentifierTableViewCellForecast = @"TableViewCellForecast";

@interface ViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSMutableArray *forecasts;
@property (nonatomic) NSInteger requestCount;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.longitude = @0;
    self.latitude = @0;
    self.requestCount = 0;
    
    // Find location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)updateRequests
{
    if (self.requestCount > 0)
    {
        self.requestCount--;
    }
    if (self.requestCount == 0)
    {
        [self.activityIndicatorViewRefresh stopAnimating];
        [self.tableViewForecasts reloadData];
    }
}

# pragma mark- CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = locations[0];
    if (location.horizontalAccuracy < 100)
    {
        double rawLongitude = location.coordinate.longitude;
        double rawLatitude = location.coordinate.latitude;
        self.longitude = [NSNumber numberWithDouble:rawLongitude];
        self.latitude = [NSNumber numberWithDouble:rawLatitude];
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Error occurred" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

# pragma mark- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableViewForecasts)
    {
        return 5;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewForecasts)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IdentifierTableViewCellForecast];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IdentifierTableViewCellForecast];
        }
        NSString *text = @"";
        if (self.forecasts && self.forecasts.count == 5)
        {
            RWForecast *forecast = self.forecasts[indexPath.row];
            text = [forecast text];
        }
        cell.textLabel.text = text;
        return cell;
    }
    return nil;
}

# pragma mark- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewForecasts)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

# pragma mark- IBAction

-(IBAction)refresh
{
    if (self.requestCount > 0)
    {
        return;
    }
    Forecastr *forecastr = [Forecastr sharedManager];
    forecastr.apiKey = @"203bf0976335ed98863b556ed9f61f79";
    [self.activityIndicatorViewRefresh startAnimating];
    
    // Get today's forecast
    self.requestCount++;
    [forecastr getForecastForLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue time:nil exclusions:nil extend:nil language:nil success:^(id JSON) {
        [self updateRequests];
        NSDictionary *json = JSON;
        NSDictionary *forecast = json[@"currently"];
        NSNumber *temperature = forecast[@"temperature"];
        NSNumber *humidity = forecast[@"humidity"];
        NSString *summary = forecast[@"summary"];
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        [formatter setMaximumFractionDigits:2];
        self.labelSummary.text = [NSString stringWithFormat:@"Now: %@", summary];
        self.labelDescription.text = [NSString stringWithFormat:@"%@F, Humidity: %@", [formatter stringFromNumber:temperature], [formatter stringFromNumber:humidity]];
    } failure:^(NSError *error, id response) {
        [self updateRequests];
        [[[UIAlertView alloc] initWithTitle:@"Error retrieving forecast" message:[forecastr messageForError:error withResponse:response] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
    
    // Get next 5 day forecast
    NSNumber *today = [NSNumber numberWithUnsignedLongLong:[NSDate date].timeIntervalSince1970];
    int day = 86400;
    self.forecasts = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 5; i++)
    {
        NSNumber *time = [NSNumber numberWithUnsignedLongLong: today.unsignedLongLongValue + (day * i)];
        self.requestCount++;
        [forecastr getForecastForLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue time:time exclusions:nil success:^(id JSON) {
            [self updateRequests];
            NSDictionary *json = JSON;
            NSDictionary *daily = json[@"daily"];
            NSArray *data = daily[@"data"];
            NSDictionary *datum = data[0];
            RWForecast *forecast = [RWForecast parse:datum];
            [self.forecasts addObject:forecast];
        } failure:^(NSError *error, id response) {
            [self updateRequests];
            [[[UIAlertView alloc] initWithTitle:@"Error retrieving forecast" message:[forecastr messageForError:error withResponse:response] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
}

@end
