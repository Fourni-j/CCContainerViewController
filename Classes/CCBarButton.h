//
//  CCBarButton.h
//  CustomControllerContainer
//
//  Created by Charles-Adrien Fournier on 08/04/15.
//  Copyright (c) 2015 Charles-Adrien Fournier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCBarButton : UIButton

@property (nonatomic) NSString *badgeValue;

@property (nonatomic) CGSize badgePosition;

- (instancetype)init;

@end
