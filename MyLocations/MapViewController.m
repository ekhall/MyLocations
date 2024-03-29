//
//  MapViewController.m
//  MyLocations
//
//  Created by E. Kevin Hall on 12/26/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController {
    NSArray *locations;
}

@synthesize managedObjectContext;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        Location *location = [locations objectAtIndex:((UIButton *) sender).tag];
        controller.locationToEdit = location;
    }
}

#pragma mark - Core Data
- (void)updateLocations {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location"
                                              inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                     error:&error];
    if (foundObjects == nil) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    
    NSLog(@"Annotations: %@", foundObjects);
    
    if (locations != nil) {
        [self.mapView removeAnnotations:locations];
    }
    
    locations = foundObjects;
    [self.mapView addAnnotations:locations];
//    for (id <MKAnnotation> a in locations) {
//        [self.mapView addAnnotation:a];
//    }
}

#pragma mark - UI Methods
- (IBAction)showUser {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations {
    MKCoordinateRegion region;
    
    if ([annotations count] == 0) {
        region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate,
                                                    1000, 1000);
    } else if ([annotations count] == 1) {
        id <MKAnnotation> annotation = [annotations lastObject];
        region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000);
    } else {
        CLLocationCoordinate2D topLeftCoord;
        topLeftCoord.latitude = -90;
        topLeftCoord.longitude = 180;
        CLLocationCoordinate2D bottomRightCoord;
        bottomRightCoord.latitude = 90;
        bottomRightCoord.longitude= -180;
        
        for (id <MKAnnotation> annotation in annotations) {
            topLeftCoord.latitude       = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
            topLeftCoord.longitude      = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
            bottomRightCoord.latitude   = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
            bottomRightCoord.longitude  = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        }
        
        const double extraSpace = 1.1;
        region.center.latitude      = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude)/2.0;
        region.center.longitude     = topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude)/2.0;
        region.span.latitudeDelta   = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace;
        region.span.longitudeDelta  = fabs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace;
    }
    return [self.mapView regionThatFits:region];
}

- (IBAction)showLocations {
    MKCoordinateRegion region = [self regionForAnnotations:locations];
    [self.mapView setRegion:region animated:YES];

}

#pragma mark - MKMapViewDelegate

- (void)showLocationDetails:(UIButton *)button {
    [self performSegueWithIdentifier:@"EditLocation" sender:button];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[Location class]]) {
        static NSString *identifier = @"Location";
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = NO;
            annotationView.pinColor = MKPinAnnotationColorGreen;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(showLocationDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = rightButton;
        } else {
            annotationView.annotation = annotation;
        }
        
        UIButton *button = (UIButton *)annotationView.rightCalloutAccessoryView;
        button.tag = [locations indexOfObject:(Location *)annotation];
        return annotationView;
    }
    return nil;
}

#pragma mark - Scaffolding
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidChange:)
                                                     name:NSManagedObjectContextObjectsDidChangeNotification
                                                   object:self.managedObjectContext];
    }
    return self; 
}

- (void)contextDidChange:(NSNotification *)notification {
    // First check if the view is loaded.
    // This is only necessary before ios6 because the view is never
    //   unloaded. (page 107 part 2).
    if ([self isViewLoaded])
        [self updateLocations];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:self.managedObjectContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateLocations];
    
    if ([locations count] > 0) {
        [self showLocations];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
