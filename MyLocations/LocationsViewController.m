//
//  LocationsViewController.m
//  MyLocations
//
//  Created by E. Kevin Hall on 12/26/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import "LocationsViewController.h"

@interface LocationsViewController ()

@end

@implementation LocationsViewController {
    NSFetchedResultsController *fetchedResultsController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location"
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"category"
                                                                          ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"date"
                                                                          ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
        [fetchRequest setFetchBatchSize:20];
        fetchedResultsController = [[NSFetchedResultsController alloc]
                                    initWithFetchRequest:fetchRequest
                                    managedObjectContext:self.managedObjectContext
                                    sectionNameKeyPath:@"category"
                                    cacheName:@"Locations"];
        fetchedResultsController.delegate = self;
    }
    return fetchedResultsController;
}

- (void)performFetch {
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self performFetch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        // Call the LDVC setLocationToEdit overridden method
        controller.locationToEdit = location;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections]
                                                   objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // This is the same NSString used in the Nib - instantiation must be being performed there.
    static NSString *cellIdentifier = @"Location";
    
    UITableViewCell *cell           = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    LocationCell *locationCell      = (LocationCell *)cell;
    Location *location              = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([location.locationDescription length] > 0)
        locationCell.descriptionLabel.text = location.locationDescription;
    else
        locationCell.descriptionLabel.text = @"(No Description)";
    
    if (location.placemark != nil) {
        locationCell.addressLabel.text = [NSString stringWithFormat:@"%@ %@, %@",
                                          location.placemark.subThoroughfare,
                                          location.placemark.thoroughfare,
                                          location.placemark.locality];
    } else {
        locationCell.addressLabel.text = [NSString stringWithFormat:@"Lat: %.8f, Long: %.8f",
                                          [location.latitude doubleValue],
                                          [location.longitude doubleValue]];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:location];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            FATAL_CORE_DATA_ERROR(error);
            return;
        }
    }
}
//
//#pragma mark - Custom View Section
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 20;
//}
//
//- (CAGradientLayer *) greyGradient {
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.startPoint = CGPointMake(0.5, 0.0);
//    gradient.endPoint = CGPointMake(0.5, 1.0);
//    
//    UIColor *color1 = [UIColor colorWithRed:80.0f/255.0f green:80.0f/255.0f blue:80.0f/255.0f alpha:1.0];
//    UIColor *color2 = [UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1.0];
//    
//    [gradient setColors:@[(id)color1.CGColor, (id)color2.CGColor, (id)color1.CGColor]];
//    return gradient;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 360, 20)];
//    CAGradientLayer *gradient = [self greyGradient];
//    gradient.frame = sectionHeaderView.bounds;
//    [sectionHeaderView.layer addSublayer:gradient];
//    
//    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
//    infoButton.frame = CGRectMake(0, 0, 18, 18); // x,y,width,height
//    infoButton.enabled = YES;
//    [infoButton addTarget:self action:@selector(infoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    
//    //Add the subview to the UIView
//    [sectionHeaderView addSubview:infoButton];
//    return sectionHeaderView;
//}
//- (void)infoButtonClicked:(id)sender {
//    NSLog(@"infoButtonClicked");
//}

#pragma mark - TableView SECTION methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections]
                                                    objectAtIndex:section];
    return [sectionInfo name];
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"*** controllerWillChangeContent");
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** controllerDidChangeOBJECT - NSFetchedResultsChangeInsert");
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** controllerDidChangeOBJECT - NSFetchedResultsChangeDelete");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"*** controllerDidChangeOBJECT - NSFetchedResultsChangeUpdate");
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            NSLog(@"*** controllerDidChangeOBJECT - NSFetchedResultsChangeMove");
           [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** controllerDidChangeSECTION - NSFetchedResultsChangeInsert");
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** controllerDidChangeSECTION - NSFetchedResultsChangeDelete");
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"*** controllerDidChangeContent");
    [self.tableView endUpdates];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - dealloc
- (void)dealloc {
    
    // When we no longer need the FRC we set it to nil so we don't continue
    //   to get results.
    fetchedResultsController.delegate = nil;
}

@end
