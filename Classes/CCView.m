//
//  CCView.m
//  CCContainerViewControllerDemo
//
//  Created by Charles-Adrien Fournier on 28/04/15.
//  Copyright (c) 2015 Charles-Adrien Fournier. All rights reserved.
//

#import "CCView.h"

@implementation CCView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_delegate && [_delegate respondsToSelector:@selector(touchesInView)])
        [_delegate touchesInView];
}

@end
