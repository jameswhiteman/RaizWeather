//
//  ViewController.h
//  RaizWeather
//
//  Created by James Whiteman on 11/19/15.
//  Copyright © 2015 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Forecastr.h"
#import "RWForecast.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableViewForecasts;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorViewRefresh;
@property (strong, nonatomic) IBOutlet UILabel *labelSummary;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;

-(IBAction)refresh;

@end

