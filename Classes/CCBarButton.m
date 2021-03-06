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
        self.badgeLabel.textColor = [UIColor whiteColor];
        self.badgeLabel.textAlignment = NSTextAlignmentCenter;
        self.badgeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        [self.badgeContainer addSubview:self.badgeLabel];
        
        [self.badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.badgeContainer).insets(UIEdgeInsetsMake(2, 4, 2, 4));
        }];
        
        [self addSubview:self.badgeContainer];
        [self.badgeContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, self.badgePosition.width));
            make.top.equalTo(self).with.insets(UIEdgeInsetsMake(self.badgePosition.height, 0, 0, 0));
            make.width.greaterThanOrEqualTo(self.badgeContainer.mas_height);
        }];
        
//        self.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
//        self.titleEdgeInsets = UIEdgeInsetsMake(40, -30, 0, 0);
//        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.badgeContainer.alpha = 0.0;
        self.titleLabel.numberOfLines = 2;
        
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.badgeContainer.layer.cornerRadius = self.badgeContainer.bounds.size.height/2;
    self.titleLabel.preferredMaxLayoutWidth = self.bounds.size.width;
    [self centerImageAndButton:8 imageOnTop:YES];
    if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) [super layoutSubviews];
}

//https://gist.github.com/phpmaple/9458264
- (void)centerImageAndButton:(CGFloat)gap imageOnTop:(BOOL)imageOnTop {
    NSInteger sign = imageOnTop ? 1 : -1;
    
    CGSize imageSize = self.imageView.frame.size;
    self.titleEdgeInsets = UIEdgeInsetsMake((imageSize.height+gap)*sign, -imageSize.width, 0, 0);
    CGSize titleSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width, MAXFLOAT)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName : self.titleLabel.font} context:nil].size;

    self.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height+gap)*sign, 0, 0, -titleSize.width);
    
}

- (void)setBadgeValue:(NSString *)badgeValue
{    
    _badgeValue = badgeValue;
    
    if ((_badgeValue == nil || [_badgeValue isKindOfClass:[NSNull class]] || [_badgeValue isEqualToString:@""]) && _badgeContainer.alpha > 0) {
        [UIView animateWithDuration:0.15 animations:^{
            _badgeContainer.alpha = 0.0;
        } completion:^(BOOL finished) {
            _badgeLabel.text = nil;
        }];
    } else if (_badgeValue && [_badgeValue isKindOfClass:[NSString class]] && [_badgeValue length] > 0) {
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

- (void)setBadgePosition:(CGSize)badgePosition {
    _badgePosition = badgePosition;
    
    [self.badgeContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, self.badgePosition.width));
        make.top.equalTo(self).with.insets(UIEdgeInsetsMake(self.badgePosition.height, 0, 0, 0));
        make.width.greaterThanOrEqualTo(self.badgeContainer.mas_height);
    }];

}

@end
