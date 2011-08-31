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
- (void)tabBarController:(WLTabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray *)viewControllers;
- (void)tabBarController:(WLTabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed;
- (void)tabBarController:(WLTabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed;

@end


@interface WLTabBarController : WLMultiContentContainerController <WLTabBarDelegate>

@property(nonatomic, weak) id<WLTabBarControllerDelegate> delegate;
@property(nonatomic, strong, readonly) WLTabBar *tabBar;
@property(nonatomic, copy) NSArray *customizableViewControllers;
@property(nonatomic, strong, readonly) UIViewController *secondaryViewController;

- (void)presentSecondaryViewController:(UIViewController *)viewController;
- (void)dismissSecondaryViewController;

@end
