//
//  Location.h
//  MyLocations
//
//  Created by E. Kevin Hall on 12/16/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *locationDescription;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) CLPlacemark *placemark;

@end
