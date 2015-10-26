//  Created by Ling Wang on 8/25/11.
//  Copyright (c) 2011 I Wonder Phone. All rights reserved.

#import "WLContainerController.h"

@interface WLSelectionController : WLContainerController

@property(nonatomic, copy) NSArray<__kindof UIViewController *> *viewControllers;
@property(nonatomic, strong) UIViewController *selectedViewController;
@property(nonatomic, assign) NSUInteger selectedIndex;
@property(nonatomic, assign) BOOL selectsLastByDefault;

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated;
- (BOOL)replaceViewControllerAtIndex:(NSUInteger)index withViewController:(UIViewController *)newViewController;
- (BOOL)exchangeViewControllerAtIndex:(NSUInteger)index1 withViewControllerAtIndex:(NSUInteger)index2; // Exchange view controllers, keep selectedIndex not selectedViewController.

// These two methods only do view controller management, no view configuration.
- (void)addViewController:(UIViewController *)viewController;
- (void)removeViewController:(UIViewController *)viewController;

@end
