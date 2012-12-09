//
//  CurrentLocationViewController.m
//  MyLocations
//
//  Created by E. Kevin Hall on 12/9/12.
//  Copyright (c) 2012 E. Kevin Hall. All rights reserved.
//

#import "CurrentLocationViewController.h"

@interface CurrentLocationViewController ()
@end

@implementation CurrentLocationViewController {
    CLLocationManager *locationManager;
    CLLocation *currentLocation, *lastLocation;
    CLHeading *currentHeading;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    BOOL performingReverseGeocoding;
    BOOL updatingLocation;
    NSError *lastGeocodingError;
    NSError *lastLocationError;
}

#pragma mark - CLLocationManager
- (IBAction)getLocation:(id)sender {
    if (updatingLocation) {
        [self stopLocationManager];
        [self.getButton setTitle:@"Start" forState:UIControlStateNormal];
    } else {
        currentLocation = nil;
        lastLocationError = nil;
        placemark = nil;
        lastGeocodingError = nil;
        [self startLocationManager];
        [self.getButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
    [self updateLabels];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location error %@", error);
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    [self stopLocationManager];
    lastLocationError = error;
    [self updateLabels];
}

- (void)startLocationManager {
    NSLog(@"STARTING");
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        [locationManager startUpdatingLocation];
        updatingLocation = YES;
        locationManager.pausesLocationUpdatesAutomatically = YES;
        locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    }
}

- (void)stopLocationManager {
    NSLog(@"STOPPING");
    if (updatingLocation) {
        [locationManager stopUpdatingLocation];
        [locationManager stopUpdatingHeading];
        locationManager.delegate = nil;
        updatingLocation = NO;
        [geocoder reverseGeocodeLocation:currentLocation
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                           NSLog(@"** Found Placemarks: %@, error %@", placemarks, error);
                           placemark = [placemarks lastObject];
                           [self updateLabels];
                       }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    NSLog(@"New Heading: %@", newHeading);
    currentHeading = newHeading;
    [self updateLabels];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"New Loc: %@", locations);
    currentLocation = [locations lastObject];
    [self updateLabels];
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark {
    return [NSString stringWithFormat:@"%@ %@\n %@ %@ %@",
            thePlacemark.subThoroughfare,
            thePlacemark.thoroughfare,
            thePlacemark.locality,
            thePlacemark.administrativeArea,
            thePlacemark.postalCode];
}

# pragma mark - GUI methods
- (void)updateLabels {
    if (currentLocation != nil) {
        self.messageLabel.text      = @"GPS Coordinates";
        self.latitudeLabel.text     = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        self.longitudeLabel.text    = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        self.tagButton.hidden       = NO;
        
    } else {
        self.messageLabel.text      = @"Press the Button to start";
        self.latitudeLabel.text     = @"";
        self.longitudeLabel.text    = @"";
        //self.addressLabel.text      = @"";
        self.tagButton.hidden       = YES;
    }
    if (placemark != nil) {
        NSLog(@"Placemark not nil!");
        self.addressLabel.text = [self stringFromPlacemark:placemark];
    }
    
    NSString *statusMessage;
    if (lastLocationError != nil) {
        if ([lastLocationError.domain isEqualToString:kCLErrorDomain] &&
            lastLocationError.code == kCLErrorDenied) {
            statusMessage = @"Location Services Disabled";
        } else {
            statusMessage = @"Error Getting Location";
        }
    } else if (![CLLocationManager locationServicesEnabled]) {
        statusMessage = @"Location Services Disabled";
    } else if (updatingLocation) {
        statusMessage = @"Searching...";
    } else {
        statusMessage = @"Press the Button to start";
    }
    self.messageLabel.text = statusMessage;
    
}

#pragma mark - Scaffolding
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        locationManager = [[CLLocationManager alloc] init];
        geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateLabels];
}

@end
