//
//  CCBarItem.m
//  CustomControllerContainer
//
//  Created by Charles-Adrien Fournier on 07/04/15.
//  Copyright (c) 2015 Charles-Adrien Fournier. All rights reserved.
//

#import "CCBarItem.h"

@implementation CCBarItem

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image {
    self = [super init];
    if (self) {
        self.title = title;
        self.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.badgeValue = @"";
        self.enabled = YES;
    }
    return self;
}

@end
