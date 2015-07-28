//
//  CCBarItem.h
//  CustomControllerContainer
//
//  Created by Charles-Adrien Fournier on 07/04/15.
//  Copyright (c) 2015 Charles-Adrien Fournier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCBarItem : NSObject

/**
 *  The title of the bar item
 */
@property (nonatomic, copy) NSString *title;

/**
 *  The icon of the bar item
 */
@property (nonatomic, copy) UIImage *image;

/**
 *  The value of the notification badge
 */
@property (nonatomic, copy) NSString *badgeValue;

/**
 *  The position of the notification badge
 */
@property (nonatomic) CGSize badgePosition;

/**
 *  Describes if the bar item is enabled or not
 */
@property (nonatomic) BOOL enabled;

/**
 *  Initialize the CCBarItem object with corresponding title and icon
 *
 *  @param title The title of the bar item
 *  @param image The icon of the bar item
 *
 *  @return Initialized CCBarItem object
 */
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image;

@end
