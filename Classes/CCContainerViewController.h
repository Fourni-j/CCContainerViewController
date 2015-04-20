//
//  ViewController.h
//  CustomControllerContainer
//
//  Created by Charles-Adrien Fournier on 02/04/15.
//  Copyright (c) 2015 Charles-Adrien Fournier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCBarItem.h"
//#import "UIViewController+CCBarItem.h"

@protocol CCContainerViewControllerDelegate;


@interface CCContainerViewController : UIViewController

- (instancetype)initWithControllers:(NSArray *)controllers;

@property (nonatomic, assign) id<CCContainerViewControllerDelegate>delegate;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, assign) UIViewController *selectedViewController;
@property (nonatomic) NSUInteger selectedIndex;


- (void)setViewControllers:(NSArray *)controllers animated:(BOOL)animated;
- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animate;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animate;

- (CGRect)frameForTabBarItemAtIndex:(NSInteger)index;

@property (nonatomic) UIColor *sideBarBackground;
@property (nonatomic) UIColor *buttonSelectedColor;
@property (nonatomic) UIColor *buttonDefaultColor;
@property (nonatomic) UIColor *buttonTextDefaultColor;
@property (nonatomic) UIColor *buttonTextSelectedColor;
@property (nonatomic) UIFont *buttonTextFont;
@property (nonatomic) CGFloat sideBarWidth;
@property (nonatomic) CGFloat buttonSpace;
@property (nonatomic) BOOL shouldAnimateTransitions;
@property (nonatomic) CGFloat detailCornerRadius;

@end

@protocol CCContainerViewControllerDelegate <NSObject>
@optional
- (BOOL)customContainerViewController:(CCContainerViewController*)container shouldSelectViewController:(UIViewController *)viewController;

@end

@interface UIViewController (CCContainer)

@property (nonatomic, retain) CCBarItem *barItem;
@property (nonatomic, readonly) CCContainerViewController *containerViewController;

@end