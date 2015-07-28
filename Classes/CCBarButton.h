//
//  CCBarButton.h
//  CustomControllerContainer
//
//  Created by Charles-Adrien Fournier on 08/04/15.
//  Copyright (c) 2015 Charles-Adrien Fournier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCBarButton : UIButton

/**
 *  The notification badge value
 */
@property (nonatomic) NSString *badgeValue;

/**
 *  The notification badge position
 */
@property (nonatomic) CGSize badgePosition;


/**
 *  Initialize the CCBarButton object
 *
 *  @return The initialized CCBarButton object
 */
- (instancetype)init;

@end
