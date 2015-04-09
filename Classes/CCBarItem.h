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

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) UIImage *image;

@property (nonatomic, copy) NSString *badgeValue;

@property (nonatomic) BOOL enabled;

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image;

@end
