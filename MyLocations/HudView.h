//
//  HudView.h
//  MyLocations
//
//  Created by E. Kevin Hall on 12/11/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudView : UIView

+ (HudView *)hudInView:(UIView *)view animated:(BOOL)animated;

@property (nonatomic, strong) NSString *text;

@end
