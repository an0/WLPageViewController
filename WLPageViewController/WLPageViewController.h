//
//  WLPageViewController.h
//  WLPageViewController
//
//  Created by Ling Wang on 7/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WLContainerController.h"

@protocol WLPageViewControllerDataSource;
@protocol WLPageViewControllerDelegate;


@interface WLPageViewController : WLContainerController

#pragma mark Creating Page View Controllers
- (id)initWithViewController:(UIViewController *)viewController;
- (void)turnForward;
- (void)turnBackward;

@property(nonatomic, weak) id <WLPageViewControllerDataSource> dataSource;
@property(nonatomic, weak) id <WLPageViewControllerDelegate> delegate;

#pragma mark Configuration
@property(nonatomic, assign) BOOL enableTapPageTurning;

#pragma mark Customizing Appearance
@property(nonatomic, copy) NSDictionary *titleTextAttributes;

@end


@protocol WLPageViewControllerDataSource <NSObject>

- (UIViewController *)pageViewController:(WLPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;
- (UIViewController *)pageViewController:(WLPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;

@end


@protocol WLPageViewControllerDelegate <NSObject>
@optional
- (void)pageViewController:(WLPageViewController *)pageViewController willBeginPagingViewController:(UIViewController *)viewController;
- (void)pageViewController:(WLPageViewController *)pageViewController didEndPagingViewController:(UIViewController *)viewController;

@end

