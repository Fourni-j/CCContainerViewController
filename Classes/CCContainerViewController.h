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

/**
 *  THe CCContainerViewController delegate object
 */
@property (nonatomic, assign) id<CCContainerViewControllerDelegate>delegate;

/**
 *  The view controllers to display in container
 */
@property (nonatomic, copy) NSArray *viewControllers;

/**
 *  The selected view controller
 */
@property (nonatomic, assign) UIViewController *selectedViewController;

/**
 *  The index of the selected view controller
 */
@property (nonatomic) NSUInteger selectedIndex;

/**
 *  If Yes the same selected Index will repopulate the detail view controller
 */
@property (nonatomic) BOOL forceSelection;


/**
 *  Initialize the CCContainerViewController object with view controllers
 *
 *  @param controllers The view controllers
 *
 *  @return Initialized CCContainerViewController object
 */
- (instancetype)initWithControllers:(NSArray *)controllers;

/**
 *  Set the view controllers with animation
 *
 *  @param controllers View controllers to display
 *  @param animated    Animation
 */
- (void)setViewControllers:(NSArray *)controllers animated:(BOOL)animated;

/**
 *  Set the selected view controller with animation
 *
 *  @param selectedViewController View controller to select
 *  @param animate                Animation
 */
- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animate;

/**
 *  Set the index of the selected view controller with animation
 *
 *  @param selectedIndex Index of the view controller to display
 *  @param animate       Animation
*/
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animate;

/**
 *  Get the frame of the tab bar item at the index
 *
 *  @param index Index of tab bar item
 *
 *  @return The frame of the tab bar item
 */
- (CGRect)frameForTabBarItemAtIndex:(NSInteger)index;

/**
 *  Get the view of the tab bar item at the index
 *
 *  @param index Index of the tab bar item
 *
 *  @return The view of the tab bar item
 */
- (UIView *)viewForTabAtIndex:(NSUInteger)index;

/**
 *  Describes the style of the container
 */
@property (nonatomic, strong) CCContainerStyle *containerStyle;

@end

@protocol CCContainerViewControllerDelegate <NSObject>
@optional
- (BOOL)customContainerViewController:(CCContainerViewController*)container shouldSelectViewController:(UIViewController *)viewController;
- (void)customContainerViewController:(CCContainerViewController*)container didSelectViewController:(UIViewController *)viewController;
- (UIViewController *)customContainerViewController:(CCContainerViewController *)container needControllerToShowBarButtonItemInViewController:(UIViewController *)controller;

@end

@interface UIViewController (CCContainer)

@property (nonatomic, retain) CCBarItem *barItem;
@property (nonatomic, readonly) CCContainerViewController *containerViewController;

@end