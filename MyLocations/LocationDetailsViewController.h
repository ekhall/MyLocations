//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by Matthijs Hollemans on 03-06-12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import "CategoryPickerViewController.h"
@class Location;

@interface LocationDetailsViewController : UITableViewController <UITextViewDelegate, CategoryPickerViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, strong) IBOutlet UILabel *categoryLabel;
@property (nonatomic, strong) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) CLPlacemark *placemark;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Location *locationToEdit;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
