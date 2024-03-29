//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by Matthijs Hollemans on 03-06-12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "HudView.h"
#import "Location.h"

@implementation LocationDetailsViewController {
    NSString *descriptionText;
    NSString *categoryName;
    NSDate *date;
}

@synthesize locationToEdit;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        descriptionText = @"";
        categoryName = @"No Category";
        date = [NSDate date];
    }
    return self;
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    return [NSString stringWithFormat:@"%@ %@, %@, %@ %@, %@",
        self.placemark.subThoroughfare, self.placemark.thoroughfare,
        self.placemark.locality, self.placemark.administrativeArea,
        self.placemark.postalCode, self.placemark.country];
}

- (NSString *)formatDate:(NSDate *)theDate
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
 
    return [formatter stringFromDate:theDate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.locationToEdit != nil) {
        self.title = @"Edit Location";
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonItemStyleDone
                                                  target:self
                                                  action:@selector(done:)];
    }
    
    self.descriptionTextView.text = descriptionText;
    self.categoryLabel.text = categoryName;

    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.longitude];
 
    if (self.placemark != nil) {
        self.addressLabel.text = [self stringFromPlacemark:self.placemark];
    } else {
        self.addressLabel.text = @"No Address Found";
    }
 
    self.dateLabel.text = [self formatDate:date];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(hideKeyboard:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

// This method is called from the LocationsViewController setter code at the end of the segue code.
- (void)setLocationToEdit:(Location *)newLocationToEdit {
    if (locationToEdit != newLocationToEdit) {
        locationToEdit = newLocationToEdit;
        
        descriptionText = locationToEdit.locationDescription;
        categoryName = locationToEdit.category;
        self.coordinate = CLLocationCoordinate2DMake([locationToEdit.latitude doubleValue],
                                                     [locationToEdit.longitude doubleValue]);
        self.placemark = locationToEdit.placemark;
        date = locationToEdit.date;
    }
}

- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    
    // This is SO cool
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    
    // So cool
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath != nil && indexPath.section == 0 && indexPath.row == 0) {
        return;
    }
    [self.descriptionTextView resignFirstResponder];
}

- (void)closeScreen
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    HudView *hudView = [HudView hudInView:self.navigationController.view animated:YES];
    
    Location *location = nil;
    if (self.locationToEdit != nil) {
        hudView.text = @"Updated";
        location = self.locationToEdit;
    } else {
        hudView.text = @"Tagged";
        location = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                           inManagedObjectContext:self.managedObjectContext];
    }
    location.locationDescription = descriptionText;
    location.category = categoryName;
    location.latitude = [NSNumber numberWithDouble:self.coordinate.latitude];
    location.longitude = [NSNumber numberWithDouble:self.coordinate.longitude];
    location.date = date;
    location.placemark = self.placemark;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    
    [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];
}

- (IBAction)cancel:(id)sender
{
    [self closeScreen];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickCategory"]) {
        CategoryPickerViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.selectedCategoryName = categoryName;
    }
}

#pragma mark - UITableViewDelegate
 
- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 88;
    } else if (indexPath.section == 2 && indexPath.row == 2) {
 
        // Create super-sized rect to hold the address
        CGRect rect = CGRectMake(10, 10, 190, 1000);
        
        // Set the frame of the addressLabel to this size.
        self.addressLabel.frame = rect;
        
        // Resize label to fit now that address is inside.
        [self.addressLabel sizeToFit];
 
        rect.size.height = self.addressLabel.frame.size.height;
        self.addressLabel.frame = rect;
 
        return self.addressLabel.frame.size.height + 20;
    } else {
        return 44;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == 0) || (indexPath.section == 1)) {
        return indexPath;
    } else
        return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        [self.descriptionTextView becomeFirstResponder];
    }
}

#pragma mark - UITextViewDelegate
 
- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    descriptionText = [theTextView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)theTextView
{
    descriptionText = theTextView.text;
}

#pragma mark - CategoryPickerViewControllerDelegate

- (void)categoryPicker:(CategoryPickerViewController *)picker didPickCategory:(NSString *)theCategoryName
{
    categoryName = theCategoryName;
    self.categoryLabel.text = categoryName;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
