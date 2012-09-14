//
//  WLNavigationController.m
//  WLContainerControllers
//
//  Created by Ling Wang on 11/16/11.
//  Copyright (c) 2011 I Wonder Phone. All rights reserved.
//

#import "WLNavigationController.h"

@implementation WLNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
	self = [super init];
	if (self) {
		self.inheritsTitle = YES;
		self.inheritsRightBarButtonItem = YES;
		self.inheritsBackBarButtonItem = YES;
		self.inheritsToolbarItems = YES;
		self.viewControllers = [NSArray arrayWithObject:rootViewController];
	}
	return self;
}




#pragma mark - Accessing Items on the Navigation Stack

- (UIViewController *)topViewController {
	return self.viewControllers.lastObject;
}




#pragma mark - Pushing and Popping Stack Items

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[self addChildViewController:viewController];

	UIViewController *topViewController = self.topViewController;

	void (^completion)(BOOL finished) = ^(BOOL finished) {
		[self addViewController:viewController];
		self.selectedViewController = viewController;
		[viewController didMoveToParentViewController:self];
	};
	
	if (self.isViewLoaded && animated) {
		CGRect initViewFrame = UIEdgeInsetsInsetRect(self.view.bounds, self.contentInset); 
		initViewFrame.origin.y += self.view.bounds.size.height;
		viewController.view.frame = initViewFrame;
		[self.view addSubview:viewController.view];
	
		[UIView transitionWithView:self.view duration:0.2 options:0 animations:^{
			[self layoutContentView:viewController.view];
			if (topViewController) {
				CGPoint upperCenter = topViewController.view.center;
				upperCenter.y -= self.view.bounds.size.height;
				topViewController.view.center = upperCenter;
			}
		} completion:completion];
	} else {
		completion(NO);
	}
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
	if (self.viewControllers.count < 2) return nil;
	
	UIViewController *nextViewController = [self.viewControllers objectAtIndex:self.viewControllers.count - 2];
	return [[self popToViewController:nextViewController animated:animated] lastObject];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
	if (self.viewControllers.count < 2) return nil;
	
	UIViewController *rootViewController = [self.viewControllers objectAtIndex:0];
	return [self popToViewController:rootViewController animated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
	NSUInteger indexOfViewController = [self.viewControllers indexOfObject:viewController];
	NSUInteger indexOfTopViewController = self.viewControllers.count - 1;
	
	if (indexOfViewController >= indexOfTopViewController) return nil;
	
	NSArray *popedViewController = [self.viewControllers subarrayWithRange:NSMakeRange(indexOfViewController + 1, indexOfTopViewController - indexOfViewController)];
	
	[popedViewController enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
		[vc willMoveToParentViewController:nil];
	}];

	void (^completion)(BOOL finished) = ^(BOOL finished) {
		self.selectedViewController = viewController;
		[popedViewController enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
			[self removeViewController:vc];
			[vc removeFromParentViewController];
		}];
	};
	
	if (self.isViewLoaded && animated) {
		CGRect initViewFrame = UIEdgeInsetsInsetRect(self.view.bounds, self.contentInset); 
		initViewFrame.origin.y -= self.view.bounds.size.height;
		viewController.view.frame = initViewFrame;
		[self.view addSubview:viewController.view];

		[UIView transitionWithView:self.view duration:0.2 options:0 animations:^{
			[self layoutContentView:viewController.view];
			UIViewController *topViewController = self.topViewController;
			if (topViewController) {
				CGPoint bottomCenter = topViewController.view.center;
				bottomCenter.y += self.view.bounds.size.height;
				topViewController.view.center = bottomCenter;
			}
		} completion:completion];
	} else {
		completion(NO);
	}
	
	return popedViewController;
}



@end
