//
//  CCContainerStyle.m
//  CCContainerViewControllerDemo
//
//  Created by Damien Legrand on 15/06/2015.
//  Copyright (c) 2015 Charles-Adrien Fournier. All rights reserved.
//

#import "CCContainerStyle.h"

@implementation CCContainerStyle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sideBarBackground = [UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1];
        _buttonDefaultColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
        _buttonSelectedColor = [UIColor colorWithRed:0.88 green:0.18 blue:0.08 alpha:1];
        _buttonTextDefaultColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
        _buttonTextSelectedColor = [UIColor colorWithRed:0.88 green:0.18 blue:0.08 alpha:1];
        _buttonTextFont = [UIFont systemFontOfSize:10];
        _sideBarWidth = 64.0;
        _buttonSpace = 22.0;
        _detailCornerRadius = 0.0;
        _transitionScale = 0.5;
        _transitionDuration = 0.5;
        _containerSelectionStyle = CCContainerSelectionStyleOverlay;
        _transitionStyle = CCContainerTrasitionAnimationStyleSlide;
        _buttonsTopMargin = 20.0;
    }
    return self;
}

@end
