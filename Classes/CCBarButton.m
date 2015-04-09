//
//  CCBarButton.m
//  CustomControllerContainer
//
//  Created by Charles-Adrien Fournier on 08/04/15.
//  Copyright (c) 2015 Charles-Adrien Fournier. All rights reserved.
//

#import "CCBarButton.h"
#import <Masonry.h>

@interface CCBarButton ()

@property (nonatomic) UILabel *badgeLabel;

@property (nonatomic) UIView *badgeContainer;

@end

@implementation CCBarButton


- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.badgeContainer = [UIView new];
        self.badgeContainer.backgroundColor = [UIColor redColor];
        self.badgeContainer.clipsToBounds = YES;
        self.badgeContainer.layer.cornerRadius = self.badgeContainer.bounds.size.height/2;
        
        self.badgeLabel = [UILabel new];
        [self addObserver:self forKeyPath:@"badgeValue" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        self.badgeLabel.textColor = [UIColor whiteColor];
        self.badgeLabel.textAlignment = NSTextAlignmentCenter;
        self.badgeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        [self.badgeContainer addSubview:self.badgeLabel];
        
        [self.badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.badgeContainer).insets(UIEdgeInsetsMake(2, 4, 2, 4));
        }];
        
        [self addSubview:self.badgeContainer];
        [self.badgeContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.width.greaterThanOrEqualTo(self.badgeContainer.mas_height);
        }];
        
        self.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.titleEdgeInsets = UIEdgeInsetsMake(40, -30, 0, 0);
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.badgeContainer.alpha = 0.0;
    }
    return self;
}

-(void)dealloc {
    [self removeObserver:self forKeyPath:@"badgeValue"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.badgeContainer.layer.cornerRadius = self.badgeContainer.bounds.size.height/2;
}

- (void)setBadgeValue:(NSString *)badgeValue {
    
    _badgeValue = badgeValue;
    
    if (_badgeValue == nil && _badgeContainer.alpha > 0) {
        [UIView animateWithDuration:0.15 animations:^{
            _badgeContainer.alpha = 0.0;
        }];
    } else if (_badgeValue && [_badgeValue length] > 0) {
        _badgeLabel.text = _badgeValue;
        [self layoutIfNeeded];
        if (_badgeContainer.alpha == 0) {
            _badgeContainer.transform = CGAffineTransformMakeScale(0.6, 0.6);
            [UIView animateWithDuration:0.25 animations:^{
                _badgeContainer.alpha = 1.0;
                _badgeContainer.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }];
        }
        
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"badgeValue"] && [object isEqual:self]) {
        self.badgeLabel.text = [NSString stringWithFormat:@"%@", self.badgeValue];
        if ([[change objectForKey:@"new"] isEqualToString:@""]) {
            self.badgeLabel.hidden = YES;
        } else {
            self.badgeLabel.hidden = NO;
        }
    }
}

@end
