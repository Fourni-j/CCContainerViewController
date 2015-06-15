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
#import "CCView.h"
#import <Masonry.h>

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)



@interface CCContainerViewController ()

@property UIViewController  *currentDetailViewController;
@property UIView            *detailView;
@property UIScrollView      *sideBarScrollView;
@property UIView            *sideBarView;

@property UIView            *selectedOverlay;

@property CCView            *touchesView;
@property UIScreenEdgePanGestureRecognizer *gesture;

@property NSMutableArray    *buttons;
@property (nonatomic) BOOL  builded;
@property (nonatomic, weak) UIView *statusBarBackground;

@property (nonatomic, strong) CAShapeLayer *detailViewMaskLayer;

@property (nonatomic, strong) MASConstraint *selectedOverlayRight;
@property (nonatomic, strong) MASConstraint *leftDetailView;
@property (nonatomic, strong) MASConstraint *landscapeViewWidth;
@property (nonatomic, strong) MASConstraint *portraitViewWidth;

@end

@implementation CCContainerViewController

@synthesize selectedIndex = _selectedIndex;
@synthesize viewControllers = _viewControllers;


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
    _containerStyle = [CCContainerStyle new];
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
    [self removeCurrentDetailViewController];
    [self removeObserverFromBarItems];
    _viewControllers = controllers;
    if(_builded)
    {
        [self buildButtonsAnimated:animated];
        [self setSelectedIndex:0 animated:animated];
    }
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
    
    
    if (_containerStyle.containerSelectionStyle == CCContainerSelectionStyleTint) {
        [[self.buttons objectAtIndex:self.selectedIndex] setTintColor:self.containerStyle.buttonDefaultColor];
        [[self.buttons objectAtIndex:self.selectedIndex] setTitleColor:self.containerStyle.buttonTextDefaultColor forState:UIControlStateNormal];
    }
    _selectedIndex = selectedIndex;
    
    if (_containerStyle.containerSelectionStyle == CCContainerSelectionStyleTint) {
        [[self.buttons objectAtIndex:self.selectedIndex] setTintColor:self.containerStyle.buttonSelectedColor];
        [[self.buttons objectAtIndex:self.selectedIndex] setTitleColor:self.containerStyle.buttonTextSelectedColor forState:UIControlStateNormal];
    }
    
    if (_containerStyle.containerSelectionStyle == CCContainerSelectionStyleOverlay) {
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

- (void)setContainerStyle:(CCContainerStyle *)containerStyle
{
    if(containerStyle == nil) return;
    
    if(_containerStyle != nil)
    {
        [self removeObserversOnStyle];
    }
    
    _containerStyle = nil;
    _containerStyle = containerStyle;
    
    [self addObserversOnStyle];
}

#pragma mark - Observer

- (void)addObserversOnStyle
{
    [_containerStyle addObserver:self forKeyPath:@"sideBarBackground" options:NSKeyValueObservingOptionNew context:nil];
    [_containerStyle addObserver:self forKeyPath:@"buttonDefaultColor" options:NSKeyValueObservingOptionNew context:nil];
    [_containerStyle addObserver:self forKeyPath:@"buttonSelectedColor" options:NSKeyValueObservingOptionNew context:nil];
    [_containerStyle addObserver:self forKeyPath:@"buttonTextDefaultColor" options:NSKeyValueObservingOptionNew context:nil];
    [_containerStyle addObserver:self forKeyPath:@"buttonTextSelectedColor" options:NSKeyValueObservingOptionNew context:nil];
    [_containerStyle addObserver:self forKeyPath:@"buttonTextFont" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserversOnStyle
{
    [_containerStyle removeObserver:self forKeyPath:@"sideBarBackground" context:nil];
    [_containerStyle removeObserver:self forKeyPath:@"buttonDefaultColor" context:nil];
    [_containerStyle removeObserver:self forKeyPath:@"buttonSelectedColor" context:nil];
    [_containerStyle removeObserver:self forKeyPath:@"buttonTextDefaultColor" context:nil];
    [_containerStyle removeObserver:self forKeyPath:@"buttonTextSelectedColor" context:nil];
    [_containerStyle removeObserver:self forKeyPath:@"buttonTextFont" context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == _containerStyle)
    {
        id value = change[NSKeyValueChangeNewKey];
        
        if([keyPath isEqualToString:@"sideBarBackground"])
        {
            [self.sideBarScrollView setBackgroundColor:value];
            [self.view setBackgroundColor:value];
            if(_statusBarBackground) _statusBarBackground.backgroundColor = value;
        }
        else if([keyPath isEqualToString:@"buttonDefaultColor"])
        {
            for (int i = 0; i < [self.buttons count]; i++) {
                [[self.buttons objectAtIndex:i] setBackgroundColor:value];
            }
        }
        else if([keyPath isEqualToString:@"buttonSelectedColor"])
        {
            if(self.selectedOverlay)
            {
                UIView *line = [self.selectedOverlay viewWithTag:777];
                if(line)
                {
                    line.backgroundColor = value;
                }
            }
            else if(self.selectedIndex < self.buttons.count) [[self.buttons objectAtIndex:self.selectedIndex] setTintColor:value];
        }
        else if([keyPath isEqualToString:@"buttonTextDefaultColor"])
        {
            for (int i = 0; i < [self.buttons count]; i++) {
                [[self.buttons objectAtIndex:i] setTitleColor:value forState:UIControlStateNormal];
            }
        }
        else if([keyPath isEqualToString:@"buttonTextSelectedColor"])
        {
            if(self.selectedIndex < self.buttons.count) [[self.buttons objectAtIndex:self.selectedIndex] setTitleColor:value forState:UIControlStateNormal];
        }
        else if([keyPath isEqualToString:@"buttonTextFont"])
        {
            for (int i = 0; i < [self.buttons count]; i++) {
                [[[self.buttons objectAtIndex:i] titleLabel] setFont:value];
            }
        }
        
        return;
    }
    
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
                                       cornerRadii:CGSizeMake(_containerStyle.detailCornerRadius, _containerStyle.detailCornerRadius)];
}

- (void)updateDetailCorners
{
    _detailViewMaskLayer.frame = _detailView.bounds;
    _detailViewMaskLayer.path = [self detailBezierPathWithYOffset:(_statusBarBackground) ? 20.0 : 0.0].CGPath;
}

#pragma mark - Managing Views

- (void)viewDidLayoutSubviews
{
    if(SYSTEM_VERSION_LESS_THAN(@"8.0")) [self.view layoutSubviews];
    [super viewDidLayoutSubviews];
    [self layoutCurrentViewController];
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
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // TMP STUFF
    
    self.selectedOverlay = [[UIView alloc] init];
    self.selectedOverlay.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
    
    UIView *tmpRedView = [[UIView alloc] init];
    tmpRedView.backgroundColor = _containerStyle.buttonSelectedColor;
    tmpRedView.tag = 777;
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
    
    [self.sideBarScrollView setBackgroundColor:self.containerStyle.sideBarBackground];
    [self.view setBackgroundColor:self.containerStyle.sideBarBackground];
    [self.view addSubview:self.sideBarScrollView];
    [self.view addSubview:self.detailView];
    [self.sideBarScrollView setScrollsToTop:NO];
    [self.sideBarScrollView addSubview:self.sideBarView];
    
    if(_containerStyle.enabledStatusBarBackground)
    {
        UIView *statusBarBackground = [UIView new];
        statusBarBackground.backgroundColor = _containerStyle.sideBarBackground;
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
        make.width.mas_equalTo(self.containerStyle.sideBarWidth);
    }];
    
    [self.sideBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sideBarScrollView.mas_top);
        make.bottom.mas_greaterThanOrEqualTo(self.sideBarScrollView.mas_bottom);
        make.left.mas_equalTo(self.sideBarScrollView.mas_left);
        make.right.mas_equalTo(self.sideBarScrollView.mas_right);
        make.width.mas_equalTo(self.sideBarScrollView);
    }];
    
    [self createDetailView];
    
    
    self.sideBarScrollView.contentInset = UIEdgeInsetsMake(_containerStyle.buttonsTopMargin, 0, 0, 0);
    
    if (_containerStyle.containerSelectionStyle == CCContainerSelectionStyleOverlay)
        [self.sideBarScrollView addSubview:self.selectedOverlay];
    
    [self buildButtonsAnimated:NO];
    _builded = YES;
    
    if (_containerStyle.containerSelectionStyle == CCContainerSelectionStyleOverlay) {
        [self.selectedOverlay mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.buttons[self.selectedIndex]);
            make.height.mas_equalTo(self.buttons[self.selectedIndex]);
            make.left.mas_equalTo(self.sideBarScrollView);
            _selectedOverlayRight = make.right.mas_equalTo(self.sideBarScrollView).insets(UIEdgeInsetsMake(0, 0, 0, -_containerStyle.detailCornerRadius));
        }];
    }
    
    if (self.viewControllers) {
        self.selectedIndex = _selectedIndex;
    }
    
    [self updateInterfaceForOrientation:[[UIDevice currentDevice] orientation]];
}

- (void)layoutCurrentViewController
{
    if(!_currentDetailViewController || _currentDetailViewController.view.superview == nil)
    {
        return;
    }
    
    _currentDetailViewController.view.frame = _currentDetailViewController.view.superview.bounds;
}

- (void)createDetailView {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGFloat w = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    w = w - self.containerStyle.sideBarWidth;
    
    
    [self.detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top);
        make.bottom.mas_equalTo(self.view.mas_bottom);
        if (!_containerStyle.hideMenuInPortrait)
        {
            make.left.mas_equalTo(self.sideBarScrollView.mas_right);
            make.right.mas_equalTo(self.view);
        }
        else
        {
            if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown)
                self.portraitViewWidth = make.width.mas_equalTo(self.view);
            else if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
                self.landscapeViewWidth = make.width.mas_equalTo(@(w));
            self.leftDetailView = make.left.mas_equalTo(self.view).with.insets(UIEdgeInsetsMake(0, self.containerStyle.sideBarWidth, 0, 0));
        }
    }];
}

- (void)removeObserverFromBarItems
{
    if(_viewControllers.count == 0) return;
    
    for (UIViewController *ctrl in _viewControllers)
    {
        [ctrl.barItem removeObserver:self forKeyPath:@"title" context:nil];
        [ctrl.barItem removeObserver:self forKeyPath:@"image" context:nil];
        [ctrl.barItem removeObserver:self forKeyPath:@"enabled" context:nil];
        [ctrl.barItem removeObserver:self forKeyPath:@"badgeValue" context:nil];
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
        [[button titleLabel] setFont:self.containerStyle.buttonTextFont];
        [button setTintColor:self.containerStyle.buttonDefaultColor];
        [button setImage:[[self.viewControllers[i] barItem] image] forState:UIControlStateNormal];
        [button setTitle:[[self.viewControllers[i] barItem] title] forState:UIControlStateNormal];
        [button setEnabled:[[self.viewControllers[i] barItem] enabled]];
        [button setBadgeValue:[[self.viewControllers[i] barItem] badgeValue]];
        [button setBadgePosition:[[self.viewControllers[i] barItem] badgePosition]];
                
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
                make.top.mas_equalTo(lastButton.mas_bottom).insets(UIEdgeInsetsMake(_containerStyle.buttonSpace, 0, 0, 0));
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
    
    if(_builded)
    {
        for (UIButton *btn in _buttons)
        {
            [btn setNeedsLayout];
            [btn layoutIfNeeded];
        }
    }
    
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

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

    if (orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationFaceUp || !_containerStyle.hideMenuInPortrait)
        return;
    
    [self updateInterfaceForOrientation:orientation];
}

- (void)updateInterfaceForOrientation:(UIDeviceOrientation)orientation {
    if (!_containerStyle.hideMenuInPortrait)
        return;
    if (orientation == UIDeviceOrientationLandscapeRight || orientation == UIDeviceOrientationLandscapeLeft) {
        if (_delegate && [_delegate respondsToSelector:@selector(customContainerViewController:needControllerToShowBarButtonItemInViewController:)]) {
            self.leftDetailView.insets(UIEdgeInsetsMake(0, self.containerStyle.sideBarWidth, 0, 0));
            for (UIViewController *tmp in self.viewControllers) {
               
                UIViewController *ctrl = [_delegate customContainerViewController:self needControllerToShowBarButtonItemInViewController:tmp];
                if (ctrl) {
                    ctrl.navigationItem.leftBarButtonItem = nil;
                }
            }
        }
        if (self.portraitViewWidth)
            [self.portraitViewWidth uninstall];
        if (!self.landscapeViewWidth)
        {
            CGFloat w = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            w = w - self.containerStyle.sideBarWidth;
            [self.detailView mas_updateConstraints:^(MASConstraintMaker *make) {
                self.landscapeViewWidth = make.width.mas_equalTo(@(w));
            }];
        }
            [self.landscapeViewWidth install];
        
        [self.view removeGestureRecognizer:self.gesture];
        [self.touchesView removeFromSuperview];
        self.touchesView = nil;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
    } else if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
        if (_delegate && [_delegate respondsToSelector:@selector(customContainerViewController:needControllerToShowBarButtonItemInViewController:)]) {
            
            self.leftDetailView.insets(UIEdgeInsetsZero);
            for (UIViewController*tmp in self.viewControllers) {
                UIViewController *ctrl = [_delegate customContainerViewController:self needControllerToShowBarButtonItemInViewController:tmp];
                if (ctrl) {
                    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:self.containerStyle.leftBarButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
                    ctrl.navigationItem.leftBarButtonItem = leftButton;
                }
            }
            
            if (self.landscapeViewWidth)
                [self.landscapeViewWidth uninstall];
            if (!self.portraitViewWidth) {
                [self.detailView mas_updateConstraints:^(MASConstraintMaker *make) {
                    self.portraitViewWidth = make.width.mas_equalTo(self.view);
                }];
            }
            [self.portraitViewWidth install];
            
            if (!self.gesture) {
                self.gesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
                self.gesture.edges = UIRectEdgeLeft;
            }
            [self.view addGestureRecognizer:self.gesture];
        }
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)showMenu {
    if (self.touchesView)
        return;
    
    self.touchesView = [[CCView alloc] init];
    self.touchesView.delegate = self;
    [self.view addSubview:self.touchesView];
    [self.touchesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.detailView);
    }];

    
    self.leftDetailView.insets(UIEdgeInsetsMake(0, self.containerStyle.sideBarWidth, 0, 0));
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideMenu {
    [self.touchesView removeFromSuperview];
    self.touchesView = nil;
    self.leftDetailView.insets(UIEdgeInsetsZero);
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonClicked:(id)sender {
    
    if ((_delegate && (![_delegate respondsToSelector:@selector(customContainerViewController:shouldSelectViewController:)] || ![_delegate customContainerViewController:self shouldSelectViewController:[self.viewControllers objectAtIndex:[sender tag]]]))) {
        return;
    }
    
    if(self.selectedIndex == [sender tag])
    {
        if(_containerStyle.enablePopToNavigationRoot)
        {
            if([self.selectedViewController isKindOfClass:[UINavigationController class]])
            {
                [(UINavigationController *)self.selectedViewController popToRootViewControllerAnimated:YES];
            }
        }
        return;
    }
    
    [self setSelectedIndex:[sender tag] animated:(_containerStyle.transitionStyle != CCContainerTrasitionAnimationStyleNone)];
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
        
        if(_containerStyle.transitionStyle == CCContainerTrasitionAnimationStyleSlide || _containerStyle.transitionStyle == CCContainerTrasitionAnimationStyleSlideAndScale)
        {
            CGRect frame = self.detailView.bounds;
            frame.origin.y = frame.size.height;
            
            NSInteger currentIndex = [self.viewControllers indexOfObject:_currentDetailViewController];
            NSInteger nextIndex = [self.viewControllers indexOfObject:detailViewController];
            
            if (nextIndex > currentIndex) {
                frame.origin.y = frame.size.height;
            } else {
                frame.origin.y = -frame.size.height;
            }
            
            detailViewController.view.frame = frame;
            
            [detailViewController.view setNeedsUpdateConstraints];
            [detailViewController.view updateConstraintsIfNeeded];
            
            [detailViewController.view setNeedsLayout];
            [detailViewController.view layoutIfNeeded];
            
            if(_containerStyle.transitionStyle == CCContainerTrasitionAnimationStyleSlideAndScale)
            {
                UIView *scalingView = _currentDetailViewController.view;
                [UIView animateWithDuration:_containerStyle.transitionDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    scalingView.transform = CGAffineTransformMakeScale(_containerStyle.transitionScale, _containerStyle.transitionScale);
                    scalingView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    scalingView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    scalingView.alpha = 1.0;
                }];
            }
            
            [UIView animateWithDuration:_containerStyle.transitionDuration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:2.0 options:0 animations:^{
                detailViewController.view.frame = self.detailView.bounds;
            }completion:^(BOOL finished) {
                [self removeCurrentDetailViewController];
                self.currentDetailViewController = detailViewController;
                [detailViewController didMoveToParentViewController:self];
                [self activateButtons];
            }];
        }
        else
        {
            detailViewController.view.alpha = 0;
            detailViewController.view.frame = self.detailView.bounds;
            
            [detailViewController.view setNeedsUpdateConstraints];
            [detailViewController.view updateConstraintsIfNeeded];
            
            [detailViewController.view setNeedsLayout];
            [detailViewController.view layoutIfNeeded];
            
            [UIView animateWithDuration:_containerStyle.transitionDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                detailViewController.view.alpha = 1;
            } completion:^(BOOL finished) {
                [self removeCurrentDetailViewController];
                self.currentDetailViewController = detailViewController;
                [detailViewController didMoveToParentViewController:self];
                [self activateButtons];
            }];
        }
    } else {
        [self removeCurrentDetailViewController];
        self.currentDetailViewController = detailViewController;
        [detailViewController didMoveToParentViewController:self];
        detailViewController.view.frame = self.detailView.bounds;
        
        [detailViewController.view setNeedsUpdateConstraints];
        [detailViewController.view updateConstraintsIfNeeded];
        
        [detailViewController.view setNeedsLayout];
        [detailViewController.view layoutIfNeeded];
        
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

- (void)touchesInView {
    [self hideMenu];
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

