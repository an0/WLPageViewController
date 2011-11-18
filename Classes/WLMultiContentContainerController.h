//
//  WLMultiContentContainerController.h
//  WLContainerControllers
//
//  Created by Ling Wang on 8/25/11.
//  Copyright (c) 2011 I Wonder Phone. All rights reserved.
//

#import "WLContainerController.h"

@interface WLMultiContentContainerController : WLContainerController

@property(nonatomic, copy) NSArray *viewControllers;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
@property(nonatomic, assign) UIViewController *selectedViewController;
@property(nonatomic) NSUInteger selectedIndex;



/**
 Sets the root view controllers of the switch controller.
 
 @param viewControllers The array of custom view controllers to display in the switch controller interface. The order of the view controllers in this array corresponds to the display order in the switch bar, with the controller at index 0 representing the left-most tab, the controller at index 1 the next tab to the right, and so on. It must be non-empty.
 
 @param animated If YES, the tab bar items for the view controllers are animated into position. If NO, changes to the tab bar items are reflected immediately.
 */
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
- (BOOL)replaceViewControllerAtIndex:(NSUInteger)index withViewController:(UIViewController *)newViewController;
- (BOOL)exchangeViewControllerAtIndex:(NSUInteger)index1 withViewControllerAtIndex:(NSUInteger)index2; // Exchange view controllers, keep selectedIndex not selectedViewController.

// These two methods only do view controller management, no view configuration.
- (void)addViewController:(UIViewController *)viewController;
- (void)removeViewController:(UIViewController *)viewController;

@end
