//
//  UIViewController+WLViewController.h
//  WLContainerControllers
//
//  Created by Ling Wang on 2/15/11.
//  Copyright 2011 I Wonder Phone. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 UIViewController extension to swizzle some methods that are required for content view controllers of WLContainerControllers.
 */


@interface UIViewController (WLViewController)

@property (nonatomic, assign) UIViewController *hostController;

@end
