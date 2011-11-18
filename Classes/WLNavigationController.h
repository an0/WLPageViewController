//
//  WLNavigationController.h
//  WLContainerControllers
//
//  Created by Ling Wang on 11/16/11.
//  Copyright (c) 2011 I Wonder Phone. All rights reserved.
//

#import "WLMultiContentContainerController.h"

@interface WLNavigationController : WLMultiContentContainerController

@property(nonatomic, readonly, strong) UIViewController *topViewController;

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
