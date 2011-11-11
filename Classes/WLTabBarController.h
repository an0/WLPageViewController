//
//  WLTabBarController.h
//  WLContainerControllers
//
//  Created by Ling Wang on 8/25/11.
//  Copyright (c) 2011 I Wonder Phone. All rights reserved.
//

#import "WLMultiContentContainerController.h"
#import "WLTabBar.h"

@class WLTabBarController;

@protocol WLTabBarControllerDelegate <NSObject>

- (BOOL)tabBarController:(WLTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(WLTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(WLTabBarController *)tabBarController willBeginCustomizingViewController:(UIViewController *)viewController;
- (void)tabBarController:(WLTabBarController *)tabBarController willEndCustomizingViewController:(UIViewController *)viewController newViewController:(UIViewController *)newViewController;
- (void)tabBarController:(WLTabBarController *)tabBarController didEndCustomizingViewController:(UIViewController *)viewController newViewController:(UIViewController *)newViewController;

@end


@interface WLTabBarController : WLMultiContentContainerController <WLTabBarDelegate>

@property(nonatomic, weak) id<WLTabBarControllerDelegate> delegate;
@property(nonatomic, strong, readonly) WLTabBar *tabBar;
@property(nonatomic, strong, readonly) UIViewController *secondaryViewController;

- (BOOL)replaceViewControllerAtIndex:(NSUInteger)index withViewController:(UIViewController *)newViewController;
- (BOOL)exchangeViewControllerAtIndex:(NSUInteger)index1 withViewControllerAtIndex:(NSUInteger)index2; // Exchange view controllers, keep selectedIndex not selectedViewController.

- (void)presentSecondaryViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)dismissSecondaryViewControllerAnimated:(BOOL)animated;

@end
