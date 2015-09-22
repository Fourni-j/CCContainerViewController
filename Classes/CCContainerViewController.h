//
//  ViewController.h
//  CustomControllerContainer
//
//  Created by Charles-Adrien Fournier on 02/04/15.
//  Copyright (c) 2015 Charles-Adrien Fournier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCBarItem.h"
#import "CCView.h"
#import "CCContainerStyle.h"
//#import "UIViewController+CCBarItem.h"

@protocol CCContainerViewControllerDelegate;


@interface CCContainerViewController : UIViewController <CCViewDelegate>

- (instancetype)initWithControllers:(NSArray *)controllers;

@property (nonatomic, weak) id<CCContainerViewControllerDelegate>delegate;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic) NSUInteger selectedIndex;

/**
 *  If Yes the same selected Index will repopulate the detail view controller
 */
@property (nonatomic) BOOL forceSelection;


- (void)setViewControllers:(NSArray *)controllers animated:(BOOL)animated;
- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animate;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animate;

- (CGRect)frameForTabBarItemAtIndex:(NSInteger)index;
- (UIView *)viewForTabAtIndex:(NSUInteger)index;

@property (nonatomic, strong) CCContainerStyle *containerStyle;

@end

@protocol CCContainerViewControllerDelegate <NSObject>
@optional
- (BOOL)customContainerViewController:(CCContainerViewController*)container shouldSelectViewController:(UIViewController *)viewController;
- (void)customContainerViewController:(CCContainerViewController*)container didSelectViewController:(UIViewController *)viewController;
- (UIViewController *)customContainerViewController:(CCContainerViewController *)container needControllerToShowBarButtonItemInViewController:(UIViewController *)controller;

@end

@interface UIViewController (CCContainer)

@property (nonatomic, strong) CCBarItem *barItem;
@property (nonatomic, readonly) CCContainerViewController *containerViewController;

@end