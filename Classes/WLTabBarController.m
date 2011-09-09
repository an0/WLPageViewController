//
//  WLTabBarController.m
//  WLContainerControllers
//
//  Created by Ling Wang on 8/25/11.
//  Copyright (c) 2011 I Wonder Phone. All rights reserved.
//

#import "WLTabBarController.h"

#define kTabBarHeightPortrait 44
#define kTabBarHeightLandscape 34


@implementation WLTabBarController

@synthesize delegate = _delegate;
@synthesize tabBar = _tabBar;
@synthesize customizableViewControllers = _customizableViewControllers;
@synthesize secondaryViewController = _secondaryViewController;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	if (self.navigationController) {
		UIBarButtonItem *tabBar = [[UIBarButtonItem alloc] initWithCustomView:self.tabBar];
		self.toolbarItems = [NSArray arrayWithObject:tabBar];
	} else {
		[self.view addSubview:self.tabBar];
	}
}

- (void)viewDidUnload
{
    _tabBar = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:NO animated:animated];
}



#pragma mark - Accessing the Tab Bar Controller Properties

- (WLTabBar *)tabBar {
	if (_tabBar == nil) {
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:[self.viewControllers count]];
		for (UIViewController *controller in self.viewControllers) {
			[items addObject:controller.tabBarItem];
		}
		
		_tabBar = [[WLTabBar alloc] init];
		_tabBar.delegate = self;
		_tabBar.items = items;
		_tabBar.selectedItem = self.selectedViewController.tabBarItem;
	}
	
	return _tabBar;
}



#pragma mark - Managing the View Controllers

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
	if ([self.viewControllers isEqualToArray:viewControllers]) return;
	
	if (_tabBar) {
		// Update the tab bar.
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:[viewControllers count]];
		for (UIViewController *controller in viewControllers) {
			[items addObject:controller.tabBarItem];
		}

		[_tabBar setItems:items animated:animated];
	} else {
		// Just leave _tabBar nil and depend on it lazy initialization.
	}
	
	[super setViewControllers:viewControllers animated:animated];
}



#pragma mark - Managing the Selected View Controller

- (void)setSelectedViewController:(UIViewController *)viewController {
	if (self.selectedViewController == viewController) return;
	
	_tabBar.selectedItem = viewController.tabBarItem;
	[super setSelectedViewController:viewController];
}



#pragma mark - Managing the Content View

- (void)viewWillLayoutSubviews {
	_secondaryViewController.view.frame = self.view.bounds;
	
	if (self.navigationController.toolbar) {
		CGRect tabBarFrame = self.navigationController.toolbar.bounds;
		_tabBar.frame = tabBarFrame;
		_tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;	
	} else {
		CGRect tabBarFrame = self.view.bounds;
		tabBarFrame.size.height = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? kTabBarHeightPortrait : kTabBarHeightLandscape;
		tabBarFrame.origin.y = CGRectGetMaxY(self.view.bounds) - tabBarFrame.size.height + CGRectGetMaxY(_secondaryViewController.view.frame);
		_tabBar.frame = tabBarFrame;
		_tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;	
	}

	UIView *contentView = _contentController.view;
	if (contentView.superview != self.view) return;
	
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	// Adjust the frame of the content view according to the insets and tab bar size.
	CGRect contentFrame = self.view.bounds;
	contentFrame.origin.y = CGRectGetMaxY(_secondaryViewController.view.frame);
	if (_tabBar.superview == contentView.superview) {
		contentFrame.size.height -= self.tabBar.frame.size.height;
	}
	contentView.frame = UIEdgeInsetsInsetRect(contentFrame, self.contentInset);
	
	// Adjust contentInset and scrollIndicatorInsets for scroll view if container controller is on navigation stack and toolbar is shown.
	if (self.navigationController.toolbar && !self.navigationController.toolbar.hidden && [contentView isKindOfClass:[UIScrollView class]]) {
		CGRect contentFrame = contentView.frame;
		CGRect toolbarFrame = [self.view convertRect:self.navigationController.toolbar.frame fromView:self.navigationController.toolbar.superview];
		CGRect intersection = CGRectIntersection(contentFrame, toolbarFrame);
		((UIScrollView *)contentView).scrollIndicatorInsets = ((UIScrollView *)contentView).contentInset = UIEdgeInsetsMake(0, 0, intersection.size.height, 0);
	}
}



#pragma mark - WLTabBarDelegate

- (void)tabBar:(WLTabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	for (UIViewController *vc in self.viewControllers) {
		if (vc.tabBarItem == item) {
			self.selectedViewController = vc;
		}
	}
}


#pragma mark - Secondary view controller presening/dismissing

- (void)presentSecondaryViewController:(UIViewController *)viewController {
	UIToolbar *toolbar = self.navigationController.toolbar;
	[UIView animateWithDuration:0.2 animations:^{
		CGRect offScreenFrame;
		if (toolbar) {
			offScreenFrame = self.contentView.frame;
			offScreenFrame.origin.y += CGRectGetMaxY(toolbar.frame);
			self.contentView.frame = offScreenFrame;
			offScreenFrame = toolbar.frame;
			offScreenFrame.origin.y += CGRectGetMaxY(toolbar.frame);
			toolbar.frame = offScreenFrame;
		} else {
			offScreenFrame = self.contentView.frame;
			offScreenFrame.origin.y += self.view.bounds.size.height;
			self.contentView.frame = offScreenFrame;
			offScreenFrame = _tabBar.frame;
			offScreenFrame.origin.y += self.view.bounds.size.height;
			_tabBar.frame = offScreenFrame;
		}
	} completion:^(BOOL finished) {
		_secondaryViewController = viewController;
		[self addChildViewController:_secondaryViewController];
		[self.view addSubview:_secondaryViewController.view];
		[_secondaryViewController didMoveToParentViewController:self];
		[self.contentView removeFromSuperview];
		if (toolbar) {
			self.navigationController.toolbarHidden = YES;
		}
		CGRect initFrame = self.view.bounds;
		initFrame.origin.x -= initFrame.size.width;
		_secondaryViewController.view.frame = initFrame;
		[UIView animateWithDuration:0.2 animations:^{
			_secondaryViewController.view.frame = self.view.bounds;
		}];
	}];
}

- (void)dismissSecondaryViewController {
	[_secondaryViewController willMoveToParentViewController:nil];
	[UIView animateWithDuration:0.2 animations:^{
		CGRect offScreenFrame = self.view.bounds;
		offScreenFrame.origin.x -= offScreenFrame.size.width;
		_secondaryViewController.view.frame = offScreenFrame;
	} completion:^(BOOL finished) {
		[_secondaryViewController.view removeFromSuperview];
		[_secondaryViewController removeFromParentViewController];
		_secondaryViewController = nil;
		[self.view addSubview:self.contentView];
		UIToolbar *toolbar = self.navigationController.toolbar;
		[UIView animateWithDuration:0.2 animations:^{
			if (toolbar) {
				self.navigationController.toolbarHidden = NO;
			}
			[self.view layoutIfNeeded]; // Reuse the normal layout algorithm.
		}];
	}];
}

@end
