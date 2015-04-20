//
//  ViewController.m
//  CustomControllerContainer
//
//  Created by Charles-Adrien Fournier on 02/04/15.
//  Copyright (c) 2015 Charles-Adrien Fournier. All rights reserved.
//

#import <objc/runtime.h>
#import "CCContainerViewController.h"
#import "CCBarButton.h"

#import <Masonry.h>



@interface CCContainerViewController ()

@property UIViewController  *currentDetailViewController;
@property UIView            *detailView;
@property UIScrollView      *sideBarScrollView;
@property UIView            *sideBarView;
@property NSMutableArray    *buttons;
@property NSMutableArray    *buttonsBadges;
@property BOOL              animated;

@property NSUInteger        expectedIndex;

@end

@implementation CCContainerViewController

@synthesize selectedIndex = _selectedIndex;
@synthesize viewControllers = _viewControllers;
@synthesize sideBarBackground = _sideBarBackground;
@synthesize buttonSelectedColor = _buttonSelectedColor;
@synthesize buttonDefaultColor = _buttonDefaultColor;
@synthesize buttonTextDefaultColor = _buttonTextDefaultColor;
@synthesize buttonTextSelectedColor = _buttonTextSelectedColor;
@synthesize buttonTextFont = _buttonTextFont;


#pragma mark - Initialization

- (instancetype)initWithControllers:(NSArray *)controllers animated:(BOOL)animated{
    self = [super init];
    if (self) {
        self.viewControllers = controllers;
        self.animated = animated;
        [self setSideBarBackground:[UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1]];
        [self setButtonDefaultColor:[UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1]];
        [self setButtonSelectedColor:[UIColor colorWithRed:0.88 green:0.18 blue:0.08 alpha:1]];
        [self setButtonTextDefaultColor:[UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1]];
        [self setButtonTextSelectedColor:[UIColor colorWithRed:0.88 green:0.18 blue:0.08 alpha:1]];
        [self setButtonTextFont:[UIFont systemFontOfSize:10]];
        [self setSideBarWidth:64.0];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setSideBarBackground:[UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1]];
        [self setButtonDefaultColor:[UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1]];
        [self setButtonSelectedColor:[UIColor colorWithRed:0.88 green:0.18 blue:0.08 alpha:1]];
        [self setButtonTextDefaultColor:[UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1]];
        [self setButtonTextSelectedColor:[UIColor colorWithRed:0.88 green:0.18 blue:0.08 alpha:1]];
        [self setButtonTextFont:[UIFont systemFontOfSize:10]];
        [self setSideBarWidth:64.0];
    }
    return self;
}

#pragma mark - Accessor

- (CGRect)frameForTabBarItemAtIndex:(NSInteger)index
{
    UIView *button = self.buttons[index];
    
    CGRect frame = button.bounds;
    UIView *childView = button;
    
    while (childView != self.view)
    {
        frame = [childView convertRect:frame toView:childView.superview];
        childView = childView.superview;
    }
    
    return frame;
}

- (void) setViewControllers:(NSArray *)controllers animated:(BOOL)animated {
    self.viewControllers = controllers;
    self.animated = animated;
}

- (void) setViewControllers:(NSArray *)viewControllers {
    _viewControllers = viewControllers;
    self.animated = YES;
}

- (NSArray *)viewControllers {
    return _viewControllers;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    self.expectedIndex = selectedIndex;
    [self presentDetailViewController:self.viewControllers[selectedIndex]];
    [[self.buttons objectAtIndex:self.selectedIndex] setTintColor:self.buttonDefaultColor];
    [[self.buttons objectAtIndex:self.selectedIndex] setTitleColor:self.buttonTextDefaultColor forState:UIControlStateNormal];
    _selectedIndex = selectedIndex;
    [[self.buttons objectAtIndex:self.selectedIndex] setTintColor:self.buttonSelectedColor];
    [[self.buttons objectAtIndex:self.selectedIndex] setTitleColor:self.buttonTextSelectedColor forState:UIControlStateNormal];
}

- (NSUInteger)selectedIndex {
    return _selectedIndex;
}

- (UIViewController *)selectedViewController {
    return ([self.viewControllers objectAtIndex:self.selectedIndex]);
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    for (int i = 0; i < [self.viewControllers count]; i++) {
        if (selectedViewController == [self.viewControllers objectAtIndex:i]) {
            [self setSelectedIndex:i];
        }
    }
}

- (void)setSideBarBackground:(UIColor *)sideBarBackground {
    _sideBarBackground = sideBarBackground;
    [self.sideBarScrollView setBackgroundColor:sideBarBackground];
}

- (void)setButtonDefaultColor:(UIColor *)buttonDefaultColor {
    _buttonDefaultColor = buttonDefaultColor;
    for (int i = 0; i < [self.buttons count]; i++) {
        [[self.buttons objectAtIndex:i] setBackgroundColor:_buttonDefaultColor];
    }
}

- (void)setButtonSelectedColor:(UIColor *)buttonSelectedColor {
    _buttonSelectedColor = buttonSelectedColor;
    [[self.buttons objectAtIndex:self.selectedIndex] setBackgroundColor:_buttonSelectedColor];
}

- (void)setButtonTextDefaultColor:(UIColor *)buttonTextDefaultColor {
    _buttonTextDefaultColor = buttonTextDefaultColor;
    for (int i = 0; i < [self.buttons count]; i++) {
        [[self.buttons objectAtIndex:i] setTitleColor:_buttonTextDefaultColor forState:UIControlStateNormal];
    }
}

- (void)setButtonTextSelectedColor:(UIColor *)buttonTextSelectedColor {
    _buttonTextSelectedColor = buttonTextSelectedColor;
    [[self.buttons objectAtIndex:self.selectedIndex] setTitleColor:_buttonTextSelectedColor forState:UIControlStateNormal];
}

- (void)setButtonTextFont:(UIFont *)buttonTextFont {
    _buttonTextFont = buttonTextFont;
    for (int i = 0; i < [self.buttons count]; i++) {
        [[[self.buttons objectAtIndex:i] titleLabel] setFont:_buttonTextFont];
    }
}

- (UIColor *)sideBarBackground {
    return _sideBarBackground;
}

- (UIColor *)buttonSelectedColor {
    return _buttonSelectedColor;
}

- (UIColor *)buttonDefaultColor {
    return _buttonDefaultColor;
}

- (UIColor *)buttonTextDefaultColor {
    return _buttonTextDefaultColor;
}

- (UIColor *)buttonTextSelectedColor {
    return _buttonTextSelectedColor;
}

- (UIFont *)buttonTextFont {
    return _buttonTextFont;
}

#pragma mark - Managing Views

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buttons = [[NSMutableArray alloc] init];
    self.buttonsBadges = [[NSMutableArray alloc] init];
    self.detailView = [[UIView alloc] init];
    self.sideBarScrollView = [[UIScrollView alloc] init];
    self.sideBarView = [[UIView alloc] init];
    [self.sideBarScrollView setBackgroundColor:self.sideBarBackground];
    [self.view addSubview:self.detailView];
    [self.view addSubview:self.sideBarScrollView];
    [self.sideBarScrollView setScrollsToTop:NO];
    [self.sideBarScrollView addSubview:self.sideBarView];
    
    [self.sideBarScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top);
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.left.mas_equalTo(self.view.mas_left);
        make.width.mas_equalTo(self.sideBarWidth);
    }];
    
    [self.sideBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sideBarScrollView.mas_top);
        make.bottom.mas_greaterThanOrEqualTo(self.sideBarScrollView.mas_bottom);
        make.left.mas_equalTo(self.sideBarScrollView.mas_left);
        make.right.mas_equalTo(self.sideBarScrollView.mas_right);
        make.width.mas_equalTo(self.sideBarScrollView);
    }];
    
    [self.detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top);
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.right.mas_equalTo(self.view.mas_right);
        make.left.mas_equalTo(self.sideBarScrollView.mas_right);
    }];
    
    self.sideBarScrollView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
    CCBarButton *lastButton = nil;
    
    for (int i = 0; i < self.viewControllers.count; i++) {
        CCBarButton *button = [[CCBarButton alloc] init];
        [[button titleLabel] setFont:self.buttonTextFont];
        [button setTintColor:self.buttonDefaultColor];
        [button setImage:[[self.viewControllers[i] barItem] image] forState:UIControlStateNormal];
        [button setTitle:[[self.viewControllers[i] barItem] title] forState:UIControlStateNormal];
        [button setEnabled:[[self.viewControllers[i] barItem] enabled]];
        [button setBadgeValue:[[self.viewControllers[i] barItem] badgeValue]];
        if ([[self.viewControllers[i] barItem] enabled] == NO) {
            [button setAlpha:0.5];
        }
        
        [[self.viewControllers[i] barItem] addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [[self.viewControllers[i] barItem] addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [[self.viewControllers[i] barItem] addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [[self.viewControllers[i] barItem] addObserver:self forKeyPath:@"badgeValue" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i];
        [self.sideBarView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastButton) {
                make.top.mas_equalTo(lastButton.mas_bottom);
            } else {
                make.top.mas_equalTo(self.sideBarScrollView);
            }
            make.centerX.mas_equalTo(self.sideBarScrollView);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(50);
            if (i == [self.viewControllers count] - 1) {
                make.bottom.mas_equalTo(self.sideBarScrollView);
            }
        }];
        [self.buttons addObject:button];
        lastButton = button;
    }
    if (self.viewControllers) {
        self.selectedIndex = 0;
    }
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![object isKindOfClass:[CCBarItem class]]) {
        return;
    }
    
    NSInteger index = -1;
    for (int i = 0; i < [self.viewControllers count]; i++) {
        if ([self.viewControllers[i] barItem] == object) {
            index = i;
            break;
        }
    }
    
    if (index == -1)
        return;
    
    if ([keyPath isEqualToString:@"enabled"]) {
        [[self.buttons objectAtIndex:index] setEnabled:[[change objectForKey:NSKeyValueChangeNewKey] boolValue]];

        if ([[self.buttons objectAtIndex:index] isEnabled]) {
            [[self.buttons objectAtIndex:index] setAlpha:1.0];
        } else {
            [[self.buttons objectAtIndex:index] setAlpha:0.5];
        }
        
    } else if ([keyPath isEqualToString:@"title"]) {
        [[self.buttons objectAtIndex:index] setTitle:[change objectForKey:NSKeyValueChangeNewKey]];
    } else if ([keyPath isEqualToString:@"image"]) {
        [[self.buttons objectAtIndex:index] setImage:[change objectForKey:NSKeyValueChangeNewKey] forState:UIControlStateNormal];
    } else if ([keyPath isEqualToString:@"badgeValue"]) {
        [[self.buttons objectAtIndex:index] setBadgeValue:[change objectForKey:NSKeyValueChangeNewKey]];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonClicked:(id)sender {
    
    if ((_delegate && (![_delegate respondsToSelector:@selector(customContainerViewController:shouldSelectViewController:)] || ![_delegate customContainerViewController:self shouldSelectViewController:[self.viewControllers objectAtIndex:[sender tag]]])) || self.selectedIndex == [sender tag]) {
        return;
    }
    self.selectedIndex = [sender tag];
}

- (void)presentDetailViewController:(UIViewController *)detailViewController {
    
    [self deactivateButtons];
    
    [self addChildViewController:detailViewController];
    [self.detailView addSubview:detailViewController.view];
    
    if (self.animated) {
        __block MASConstraint *constraint = nil;
        
        [detailViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.detailView);
            make.right.equalTo(self.detailView);
            make.height.equalTo(self.detailView);
            make.width.equalTo(self.detailView);
        }];
        if (self.expectedIndex > self.selectedIndex) {
            [detailViewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
                constraint = make.top.equalTo(self.detailView.mas_bottom);
            }];
        } else {
            [detailViewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
                constraint = make.bottom.equalTo(self.detailView.mas_top);
            }];
        }
        [self.detailView layoutIfNeeded];
        [constraint uninstall];
        [detailViewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.detailView);
        }];
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:2.0 options:0 animations:^{
            [self.detailView layoutIfNeeded];
        }completion:^(BOOL finished) {
            [self removeCurrentDetailViewController];
            self.currentDetailViewController = detailViewController;
            [detailViewController didMoveToParentViewController:self];
            [self activateButtons];
        }];
    } else {
        [self removeCurrentDetailViewController];
        self.currentDetailViewController = detailViewController;
        [detailViewController didMoveToParentViewController:self];
        [detailViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.detailView);
            make.right.equalTo(self.detailView);
            make.height.equalTo(self.detailView);
            make.width.equalTo(self.detailView);
            make.top.equalTo(self.detailView);
        }];
        [self.detailView layoutIfNeeded];
        [self activateButtons];
    }
}

- (void)removeCurrentDetailViewController {
    if (self.currentDetailViewController) {
        [self.currentDetailViewController willMoveToParentViewController:nil];
        [self.currentDetailViewController.view removeFromSuperview];
        [self.currentDetailViewController removeFromParentViewController];
    }
}

- (void)deactivateButtons {
    for (int i = 0; i < [self.buttons count]; i++) {
        [[self.buttons objectAtIndex:i] setUserInteractionEnabled:NO];
    }
}

- (void)activateButtons {
    for (int i = 0; i < [self.buttons count]; i++) {
        [[self.buttons objectAtIndex:i] setUserInteractionEnabled:YES];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    for (int i = 0; i < [self.viewControllers count]; i++) {
        [[self.viewControllers[i] barItem] removeObserver:self forKeyPath:@"title"];
        [[self.viewControllers[i] barItem] removeObserver:self forKeyPath:@"enabled"];
        [[self.viewControllers[i] barItem] removeObserver:self forKeyPath:@"image"];
        [[self.viewControllers[i] barItem] removeObserver:self forKeyPath:@"badgeValue"];
    }
}

- (BOOL)shouldAutorotate {
    return [[self selectedViewController] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    return [[self selectedViewController] supportedInterfaceOrientations];
}

@end

static char const * const barItemKey = "cccontainerviewcontroller.barItem.key";

@implementation UIViewController (CCContainer)

@dynamic barItem;

- (CCBarItem *)barItem {
    return objc_getAssociatedObject(self, barItemKey);
}

- (void)setBarItem:(CCBarItem *)barItem {
    objc_setAssociatedObject(self, barItemKey, barItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CCContainerViewController *)containerViewController {
    UIViewController *parentController = self.parentViewController;
    if ([parentController isKindOfClass:[CCContainerViewController class]]) {
        return (CCContainerViewController *)parentController;
    }
    while (parentController.parentViewController) {
        parentController = parentController.parentViewController;
        if ([parentController isKindOfClass:[CCContainerViewController class]]) {
            return (CCContainerViewController*)parentController;
        }
    }
    return nil;
}

@end

