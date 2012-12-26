//
//  LocationsViewController.h
//  MyLocations
//
//  Created by E. Kevin Hall on 12/26/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "LocationCell.h"
#import "LocationDetailsViewController.h"

@interface LocationsViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
