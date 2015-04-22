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

@property UIView            *selectedOverlay;

@property NSMutableArray    *buttons;
@property (nonatomic) BOOL  builded;
@property (nonatomic, weak) UIView *statusBarBackground;

@property (nonatomic, strong) CAShapeLayer *detailViewMaskLayer;

@property (nonatomic, strong) MASConstraint *selectedOverlayRight;

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

- (instancetype)initWithControllers:(NSArray *)controllers {
    self = [super init];
    if (self) {
        self.viewControllers = controllers;
        [self configureDefaults];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configureDefaults];
    }
    return self;
}

#pragma mark - Defaults

- (void)configureDefaults
{
    _selectedIndex = 0;
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

- (void)setViewControllers:(NSArray *)controllers animated:(BOOL)animated {
    _viewControllers = controllers;
    if(_builded) [self buildButtonsAnimated:animated];
}

- (void)setViewControllers:(NSArray *)viewControllers {
    [self setViewControllers:viewControllers animated:NO];
}

- (NSArray *)viewControllers {
    return _viewControllers;
}


- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animate {
    //self.expectedIndex = selectedIndex;
    
    if(!_builded || self.viewControllers.count == 0)
    {
        _selectedIndex = selectedIndex;
        return;
    }
    
    [self presentDetailViewController:self.viewControllers[selectedIndex] animated:animate];
    
    
    if (_containerSelectionStyle == CCContainerSelectionStyleTint) {
        [[self.buttons objectAtIndex:self.selectedIndex] setTintColor:self.buttonDefaultColor];
        [[self.buttons objectAtIndex:self.selectedIndex] setTitleColor:self.buttonTextDefaultColor forState:UIControlStateNormal];
    }
    _selectedIndex = selectedIndex;
    
    if (_containerSelectionStyle == CCContainerSelectionStyleTint) {
        [[self.buttons objectAtIndex:self.selectedIndex] setTintColor:self.buttonSelectedColor];
        [[self.buttons objectAtIndex:self.selectedIndex] setTitleColor:self.buttonTextSelectedColor forState:UIControlStateNormal];
    }
    
    if (_containerSelectionStyle == CCContainerSelectionStyleOverlay) {
        [self.selectedOverlay mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.buttons[self.selectedIndex]);
            make.height.mas_equalTo(self.buttons[self.selectedIndex]);
            make.left.mas_equalTo(self.sideBarScrollView);
            make.right.mas_equalTo(self.sideBarScrollView);
        }];
        
        [UIView animateWithDuration:0.15 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (NSUInteger)selectedIndex {
    return _selectedIndex;
}

- (UIViewController *)selectedViewController {
    return ([self.viewControllers objectAtIndex:self.selectedIndex]);
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    [self setSelectedViewController:selectedViewController animated:NO];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animate {
    for (int i = 0; i < [self.viewControllers count]; i++) {
        if (selectedViewController == [self.viewControllers objectAtIndex:i]) {
            [self setSelectedIndex:i animated:animate];
        }
    }
}

- (void)setSideBarBackground:(UIColor *)sideBarBackground {
    _sideBarBackground = sideBarBackground;
    [self.sideBarScrollView setBackgroundColor:sideBarBackground];
    [self.view setBackgroundColor:sideBarBackground];
    if(_statusBarBackground) _statusBarBackground.backgroundColor = _sideBarBackground;
}

- (void)setButtonDefaultColor:(UIColor *)buttonDefaultColor {
    _buttonDefaultColor = buttonDefaultColor;
    for (int i = 0; i < [self.buttons count]; i++) {
        [[self.buttons objectAtIndex:i] setBackgroundColor:_buttonDefaultColor];
    }
}

- (void)setButtonSelectedColor:(UIColor *)buttonSelectedColor {
    _buttonSelectedColor = buttonSelectedColor;
    if(self.selectedIndex < self.buttons.count) [[self.buttons objectAtIndex:self.selectedIndex] setBackgroundColor:_buttonSelectedColor];
}

- (void)setButtonTextDefaultColor:(UIColor *)buttonTextDefaultColor {
    _buttonTextDefaultColor = buttonTextDefaultColor;
    for (int i = 0; i < [self.buttons count]; i++) {
        [[self.buttons objectAtIndex:i] setTitleColor:_buttonTextDefaultColor forState:UIControlStateNormal];
    }
}

- (void)setButtonTextSelectedColor:(UIColor *)buttonTextSelectedColor {
    _buttonTextSelectedColor = buttonTextSelectedColor;
    if(self.selectedIndex < self.buttons.count) [[self.buttons objectAtIndex:self.selectedIndex] setTitleColor:_buttonTextSelectedColor forState:UIControlStateNormal];
}

- (void)setButtonTextFont:(UIFont *)buttonTextFont {
    _buttonTextFont = buttonTextFont;
    for (int i = 0; i < [self.buttons count]; i++) {
        [[[self.buttons objectAtIndex:i] titleLabel] setFont:_buttonTextFont];
    }
}

- (UIBezierPath *)detailBezierPath
{
    return [self detailBezierPathWithYOffset:0];
}

- (UIBezierPath *)detailBezierPathWithYOffset:(CGFloat)yOffset
{
    CGRect frame = _detailView.bounds;
    
    if(yOffset != 0.0)
    {
        frame.origin.y = yOffset;
        frame.size.height -= yOffset;
    }
    
    return [UIBezierPath bezierPathWithRoundedRect:frame
                                 byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerBottomLeft)
                                       cornerRadii:CGSizeMake(_detailCornerRadius, _detailCornerRadius)];
}

- (void)updateDetailCorners
{
    _detailViewMaskLayer.frame = _detailView.bounds;
    _detailViewMaskLayer.path = [self detailBezierPathWithYOffset:(_statusBarBackground) ? 20.0 : 0.0].CGPath;
}

#pragma mark - Managing Views

- (void)viewDidLayoutSubviews
{
    [self.view layoutSubviews];
    [super viewDidLayoutSubviews];
    [self updateDetailCorners];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.sideBarScrollView setNeedsLayout];
    [self.sideBarScrollView layoutIfNeeded];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TMP STUFF
    
    self.selectedOverlay = [[UIView alloc] init];
    self.selectedOverlay.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
    
    UIView *tmpRedView = [[UIView alloc] init];
    tmpRedView.backgroundColor = [UIColor redColor];
    [self.selectedOverlay addSubview:tmpRedView];
    
    [tmpRedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.selectedOverlay);
        make.width.mas_equalTo(2);
        make.top.mas_equalTo(self.selectedOverlay);
        make.bottom.mas_equalTo(self.selectedOverlay);
    }];
    
    
    // TMP STUFF
    
    self.detailView = [[UIView alloc] init];
    self.sideBarScrollView = [[UIScrollView alloc] init];
    self.sideBarView = [[UIView alloc] init];
    
    self.detailView.backgroundColor = [UIColor clearColor];
    self.detailView.clipsToBounds = YES;
    
    _detailViewMaskLayer = [[CAShapeLayer alloc] init];
    _detailView.layer.mask = _detailViewMaskLayer;
    
    [self.sideBarScrollView setBackgroundColor:self.sideBarBackground];
    [self.view setBackgroundColor:self.sideBarBackground];
    [self.view addSubview:self.detailView];
    [self.view addSubview:self.sideBarScrollView];
    [self.sideBarScrollView setScrollsToTop:NO];
    [self.sideBarScrollView addSubview:self.sideBarView];
    
    if(_enabledStatusBarBackground)
    {
        UIView *statusBarBackground = [UIView new];
        statusBarBackground.backgroundColor = _sideBarBackground;
        [self.view addSubview:statusBarBackground];
        _statusBarBackground = statusBarBackground;
        
        [_statusBarBackground mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_sideBarView.mas_right);
            make.top.mas_equalTo(self.view);
            make.right.mas_equalTo(self.view);
            make.height.mas_equalTo(@(20));
        }];
    }
    
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
    
    if (_containerSelectionStyle == CCContainerSelectionStyleOverlay)
        [self.sideBarScrollView addSubview:self.selectedOverlay];
    
    [self buildButtonsAnimated:NO];
    _builded = YES;
    
    if (_containerSelectionStyle == CCContainerSelectionStyleOverlay) {
        [self.selectedOverlay mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.buttons[self.selectedIndex]);
            make.height.mas_equalTo(self.buttons[self.selectedIndex]);
            make.left.mas_equalTo(self.sideBarScrollView);
            _selectedOverlayRight = make.right.mas_equalTo(self.sideBarScrollView).insets(UIEdgeInsetsMake(0, 0, 0, -_detailCornerRadius));
        }];
    }
    
    if (self.viewControllers) {
        self.selectedIndex = _selectedIndex;
    }
}


- (void)buildButtonsAnimated:(BOOL)animate
{
    if(self.buttons.count > 0)
    {
        void (^completeRemoving)() = ^{
            [self.buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        };
        
        if(animate)
        {
            [UIView animateWithDuration:0.2 animations:^{
                for (UIView *btn in self.buttons)
                {
                    btn.alpha = 0.0;
                }
            } completion:^(BOOL finished) {
                completeRemoving();
            }];
        }
        else
        {
            completeRemoving();
        }
    }
    
    self.buttons = [[NSMutableArray alloc] init];
    
    CCBarButton *lastButton = nil;
    
    NSMutableIndexSet *disabledIndexes = nil;
    if(animate)
    {
        disabledIndexes = [[NSMutableIndexSet alloc] init];
    }
    
    for (int i = 0; i < self.viewControllers.count; i++) {
        CCBarButton *button = [[CCBarButton alloc] init];
        [[button titleLabel] setFont:self.buttonTextFont];
        [button setTintColor:self.buttonDefaultColor];
        [button setImage:[[self.viewControllers[i] barItem] image] forState:UIControlStateNormal];
        [button setTitle:[[self.viewControllers[i] barItem] title] forState:UIControlStateNormal];
        [button setEnabled:[[self.viewControllers[i] barItem] enabled]];
        [button setBadgeValue:[[self.viewControllers[i] barItem] badgeValue]];
        
        if(animate)
        {
            button.alpha = 0.0;
            if ([[self.viewControllers[i] barItem] enabled] == NO)
            {
                [disabledIndexes addIndex:i];
            }
        }
        else
        {
            if ([[self.viewControllers[i] barItem] enabled] == NO) {
                [button setAlpha:0.5];
            }
        }
        
        [[self.viewControllers[i] barItem] addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [[self.viewControllers[i] barItem] addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [[self.viewControllers[i] barItem] addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [[self.viewControllers[i] barItem] addObserver:self forKeyPath:@"badgeValue" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i];
        
        [self.sideBarScrollView addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastButton) {
                make.top.mas_equalTo(lastButton.mas_bottom).insets(UIEdgeInsetsMake(_buttonSpace, 0, 0, 0));
            } else {
                make.top.mas_equalTo(self.sideBarScrollView);
            }
            make.centerX.mas_equalTo(self.sideBarScrollView);
            make.width.mas_equalTo(self.sideBarScrollView).multipliedBy(0.9);
            make.height.mas_equalTo(button.mas_width);
            if (i == [self.viewControllers count] - 1) {
                make.bottom.mas_equalTo(self.sideBarScrollView);
            }
        }];
        
        [self.buttons addObject:button];
        lastButton = button;
    }
    
    [self.sideBarScrollView setNeedsLayout];
    [self.sideBarScrollView layoutIfNeeded];
    
    if(animate)
    {
        [UIView animateWithDuration:0.2 animations:^{
            for (int i = 0; i < self.buttons.count; i++)
            {
                ((UIView *)self.buttons[i]).alpha = [disabledIndexes containsIndex:i] ? 0.5 : 1.0;
            }
        }];
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
    
    [self setSelectedIndex:[sender tag] animated:_shouldAnimateTransitions];
}

- (void)presentDetailViewController:(UIViewController *)detailViewController
{
    [self presentDetailViewController:detailViewController animated:NO];
}

- (void)presentDetailViewController:(UIViewController *)detailViewController animated:(BOOL)animate {
    
    if(detailViewController == nil) return;
    if(!_builded) return;
    
    [self deactivateButtons];
    
    [self addChildViewController:detailViewController];
    [self.detailView addSubview:detailViewController.view];
    
    if (animate) {
        __block MASConstraint *constraint = nil;
        
        [detailViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.detailView);
            make.right.equalTo(self.detailView);
            make.height.equalTo(self.detailView);
            make.width.equalTo(self.detailView);
        }];
        
        NSInteger currentIndex = [self.viewControllers indexOfObject:_currentDetailViewController];
        NSInteger nextIndex = [self.viewControllers indexOfObject:detailViewController];
        
        if (nextIndex > currentIndex) {
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
        
        if(_animatedTransitionWithScale)
        {
            UIView *scalingView = _currentDetailViewController.view;
            [UIView animateWithDuration:_transitionDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                scalingView.transform = CGAffineTransformMakeScale(_transitionScale, _transitionScale);
                scalingView.alpha = 0.0;
            } completion:^(BOOL finished) {
                scalingView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                scalingView.alpha = 1.0;
            }];
        }
        
        [UIView animateWithDuration:_transitionDuration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:2.0 options:0 animations:^{
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

