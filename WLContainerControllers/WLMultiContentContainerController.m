//
//  WLMultiContentContainerController.m
//  WLContainerControllers
//
//  Created by Ling Wang on 8/25/11.
//  Copyright (c) 2011 I Wonder Phone. All rights reserved.
//

#import "WLMultiContentContainerController.h"

@implementation WLMultiContentContainerController {
	NSMutableArray *_viewControllers;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// Initially select the first/last controller if none is pre-selected.
	if (_selectedViewController == nil && _viewControllers.count > 0) {
		self.selectedIndex = _selectsLastByDefault ? _viewControllers.count - 1 : 0;
	}
}

- (BOOL)shouldAutorotate {
	BOOL result = YES;
	for (UIViewController *controller in _viewControllers) {
		if (![controller shouldAutorotate]) {
			return NO;
		}
	}

    return result;
}

- (NSUInteger)supportedInterfaceOrientations {
	NSUInteger mask = UIInterfaceOrientationMaskAll;
	for (UIViewController *controller in _viewControllers) {
		mask &= [controller supportedInterfaceOrientations];
	}

	return mask;
}

#pragma mark - Managing the View Controllers

- (void)setContentController:(UIViewController *)contentController {
	if (_contentController == contentController) return;

	[self unregisterKVOForNavigationBar];
	[self unregisterKVOForToolbar];

	if (self.isViewLoaded) {
		if (_contentController.view.superview == self.view) {
			[_contentController.view removeFromSuperview];
		}
		UIView *contentView = contentController.view;
		// !!!: Update bar items after loading content view since content controller's bar items usually are configured in its viewDidLoad method, but before adding content view because otherwise viewWillLayoutSubviews may be called too early during nav bar & toolbar updating before self.contentView is updated to the new value.
		[self updateNavigationBarFrom:contentController];
		[self updateToolbarFrom:contentController];
		if (contentView.superview != self.view) {
			[self.view addSubview:contentView];
		}
	}
	
	_contentController = contentController;
}

- (void)setViewControllers:(NSArray *)viewControllers {
	[self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
	if ([_viewControllers isEqualToArray:viewControllers]) return;

	for (UIViewController *controller in _viewControllers) {
		[controller willMoveToParentViewController:nil];
		[controller removeFromParentViewController];
	}
	
	for (UIViewController *controller in viewControllers) {
		[self addChildViewController:controller];
		[controller didMoveToParentViewController:self];
	}
	
	// Update the selected view controller.
	UIViewController *controllerToSelect;
	NSUInteger index;
	if (_selectsLastByDefault) {
		index = viewControllers.count - 1;
	} else {
		// Reuse the selectedIndex if possible.
		if (self.selectedIndex < viewControllers.count) {
			index = self.selectedIndex;
		} else {
			index = 0;
		}
	}
	controllerToSelect = viewControllers[index];
	
	// Must update the view controller array before the assignment of selected view controller because of the precondition that the selected view controller must be element of the view contronller array.
	_viewControllers = [viewControllers mutableCopy];
	
	self.selectedViewController = controllerToSelect;
}

- (BOOL)replaceViewControllerAtIndex:(NSUInteger)index withViewController:(UIViewController *)newViewController {
	UIViewController *viewController = _viewControllers[index];
	if (viewController == newViewController) return NO;
	
	[viewController willMoveToParentViewController:nil];
	[viewController removeFromParentViewController];
	
	[self addChildViewController:newViewController];
	[newViewController didMoveToParentViewController:self];
	
	_viewControllers[index] = newViewController;
	
	// Update the selected view controller if viewController is currently selected.
	if (self.selectedViewController == viewController) {
		self.selectedViewController = newViewController;
	}
	
	return YES;
}

- (BOOL)exchangeViewControllerAtIndex:(NSUInteger)index1 withViewControllerAtIndex:(NSUInteger)index2 {
	if (index1 == index2) return NO;
	
	UIViewController *viewController1 = _viewControllers[index1];
	UIViewController *viewController2 = _viewControllers[index2];
	UIViewController *selectedViewController = self.selectedViewController;
	[_viewControllers exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
	if (selectedViewController == viewController1) {
		self.selectedViewController = viewController2;
	} else if (selectedViewController == viewController2) {
		self.selectedViewController = viewController1;
	}
	
	return YES;
}

- (void)addViewController:(UIViewController *)viewController {
	if (!_viewControllers) _viewControllers = [NSMutableArray arrayWithObject:viewController];
	else [_viewControllers addObject:viewController];
}

- (void)removeViewController:(UIViewController *)viewController {
	[_viewControllers removeObject:viewController];
}

#pragma mark - Managing the Selected View Controller

- (void)setSelectedViewController:(UIViewController *)viewController {
	if (_selectedViewController == viewController) return;

	self.contentController = viewController;
	_selectedViewController = viewController;
}

- (NSUInteger)selectedIndex {
	if (_viewControllers) {
		return [_viewControllers indexOfObject:_selectedViewController];
	} else {
		return NSNotFound;
	}
}

- (void)setSelectedIndex:(NSUInteger)index {	
	self.selectedViewController = _viewControllers[index];
}

#pragma mark - State Preservation and Restoration

#define kStateKeyChildViewControllers @"child_view_controllers"
#define kStateKeySelectedIndex @"selected_index"

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
	[super encodeRestorableStateWithCoder:coder];

	[coder encodeObject:self.viewControllers forKey:kStateKeyChildViewControllers];
	[coder encodeInteger:self.selectedIndex forKey:kStateKeySelectedIndex];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
	[super decodeRestorableStateWithCoder:coder];

	self.viewControllers = [coder decodeObjectForKey:kStateKeyChildViewControllers];
	self.selectedIndex = [coder decodeIntegerForKey:kStateKeySelectedIndex];
}

@end
