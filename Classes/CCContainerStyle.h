//
//  CCContainerStyle.h
//  CCContainerViewControllerDemo
//
//  Created by Damien Legrand on 15/06/2015.
//  Copyright (c) 2015 Charles-Adrien Fournier. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


typedef NS_ENUM(NSInteger, CCContainerSelectionStyle) {
    CCContainerSelectionStyleOverlay = 1,
    CCContainerSelectionStyleTint = 2
};

typedef NS_ENUM(NSInteger, CCContainerTrasitionAnimationStyle) {
    CCContainerTrasitionAnimationStyleNone,
    CCContainerTrasitionAnimationStyleSlide,
    CCContainerTrasitionAnimationStyleSlideAndScale,
    CCContainerTrasitionAnimationStyleFade
};


@interface CCContainerStyle : NSObject

@property (nonatomic) BOOL enabledStatusBarBackground;

@property (nonatomic, strong) UIColor *sideBarBackground;
@property (nonatomic) UIColor *buttonSelectedColor;
@property (nonatomic) UIColor *buttonDefaultColor;
@property (nonatomic) UIColor *buttonTextDefaultColor;
@property (nonatomic) UIColor *buttonTextSelectedColor;
@property (nonatomic) UIFont *buttonTextFont;
@property (nonatomic) CGFloat sideBarWidth;
@property (nonatomic) CGFloat buttonSpace;
@property (nonatomic) CGFloat buttonsTopMargin;
@property (nonatomic) CCContainerTrasitionAnimationStyle transitionStyle;
@property (nonatomic) CGFloat transitionScale; //0 to 1
@property (nonatomic) CGFloat transitionDuration;
@property (nonatomic) CGFloat detailCornerRadius;
@property (nonatomic) BOOL enablePopToNavigationRoot;

@property (nonatomic) CCContainerSelectionStyle containerSelectionStyle;

@property (nonatomic) BOOL  hideMenuInPortrait;

@property (nonatomic, strong) UIImage *leftBarButtonImage;

@end
