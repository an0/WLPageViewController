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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view addSubview:self.tabBar];
}

- (void)viewDidUnload
{
    _tabBar = nil;
    [super viewDidUnload];
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
	
	CGRect tabBarFrame = self.view.bounds;
	tabBarFrame.size.height = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? kTabBarHeightPortrait : kTabBarHeightLandscape;
	tabBarFrame.origin.y = CGRectGetMaxY(self.view.bounds) - tabBarFrame.size.height + CGRectGetMaxY(_secondaryViewController.view.frame);
	_tabBar.frame = tabBarFrame;
	_tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

	UIView *contentView = _contentController.view;
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	// Adjust the frame of the content view according to the insets and tab bar size.
	CGRect contentFrame = self.view.bounds;
	contentFrame.origin.y = CGRectGetMaxY(_secondaryViewController.view.frame);
	contentFrame.size.height -= self.tabBar.frame.size.height;
	contentView.frame = UIEdgeInsetsInsetRect(contentFrame, self.contentInset);
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
	[UIView animateWithDuration:0.2 animations:^{
		CGRect offScreenFrame;
		offScreenFrame = self.contentView.frame;
		offScreenFrame.origin.y += self.view.bounds.size.height;
		self.contentView.frame = offScreenFrame;
		offScreenFrame = _tabBar.frame;
		offScreenFrame.origin.y += self.view.bounds.size.height;
		_tabBar.frame = offScreenFrame;
	} completion:^(BOOL finished) {
		_secondaryViewController = viewController;
		[self addChildViewController:_secondaryViewController];
		[self.view addSubview:_secondaryViewController.view];
		[_secondaryViewController didMoveToParentViewController:self];
		[self.contentView removeFromSuperview];
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
		[UIView animateWithDuration:0.2 animations:^{
			CGRect onScreenFrame;
			onScreenFrame = self.contentView.frame;
			onScreenFrame.origin.y -= self.view.bounds.size.height;
			self.contentView.frame = onScreenFrame;
			onScreenFrame = _tabBar.frame;
			onScreenFrame.origin.y -= self.view.bounds.size.height;
			_tabBar.frame = onScreenFrame;			
		}];
	}];
}

@end
