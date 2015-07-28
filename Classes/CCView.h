//
//  CCView.h
//  CCContainerViewControllerDemo
//
//  Created by Charles-Adrien Fournier on 28/04/15.
//  Copyright (c) 2015 Charles-Adrien Fournier. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCViewDelegate;

@interface CCView : UIView

/**
 *  THe CCView delegate object
 */
@property (nonatomic, assign) id<CCViewDelegate>delegate;

@end

@protocol CCViewDelegate <NSObject>

@optional

-(void)touchesInView;

@end