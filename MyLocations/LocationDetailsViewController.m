//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by E. Kevin Hall on 12/10/12.
//  Copyright (c) 2012 E. Kevin Hall. All rights reserved.
//

#import "LocationDetailsViewController.h"

@implementation LocationDetailsViewController

- (IBAction)done:(id)sender {
    [self closeScreen];
}

- (IBAction)cancel:(id)sender {
    [self closeScreen];
}

- (void)closeScreen {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
