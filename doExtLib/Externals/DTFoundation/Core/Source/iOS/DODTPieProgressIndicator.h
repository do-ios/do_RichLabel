//
//  DTPieProgressIndicator.h
//  DTFoundation
//
//  Created by Oliver Drobnik on 16.05.12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

/**
 A Progress indicator shaped like a pie chart.
 */

@interface DODTPieProgressIndicator : UIView

/**
 The progress in percent
 */
@property (nonatomic, assign) float progressPercent;

/**
 The color of the pie
 */
@property (nonatomic, strong) UIColor *color;

/**
 Creates a pie progress indicator of the correct size
 */
+ (DODTPieProgressIndicator *)pieProgressIndicator;

@end
