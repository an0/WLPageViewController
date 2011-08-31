//
//  WLMultiContentContainerController.m
//  WLContainerControllers
//
//  Created by Ling Wang on 8/25/11.
//  Copyright (c) 2011 I Wonder Phone. All rights reserved.
//

#import "WLMultiContentContainerController.h"

@implementation WLMultiContentContainerController

@synthesize viewControllers = _viewControllers;
@synthesize selectedViewController = _selectedViewController;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// Initially select the first controller if none is pre-selected.
	if (_selectedViewController == nil && [_viewControllers count] > 0) {
		self.selectedIndex = 0;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	BOOL result = YES;
	for (UIViewController *controller in _viewControllers) {
		if (![controller shouldAutorotateToInterfaceOrientation:interfaceOrientation]) {
			result = NO;
			break;
		}
	}
	
    return result;
}



#pragma mark - Managing the View Controllers

- (void)setContentController:(UIViewController *)contentController {
	if (_contentController == contentController) return;
	
	if (self.isViewLoaded) {
		[_contentController.view removeFromSuperview];
		[self.view addSubview:contentController.view];
	}
	
	[self updateNavigationBarFrom:contentController];
	[self updateToolbarFrom:contentController];
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
	// Reuse the selectedIndex if possible.
	UIViewController *controllerToSelect;
	NSUInteger index;
	if (self.selectedIndex < [viewControllers count]) {
		index = self.selectedIndex;
	} else {
		index = 0;
	}
	controllerToSelect = [viewControllers objectAtIndex:index];
	
	// Must update the view controller array before the assignment of selected view controller because of the precondition that the selected view controller must be element of the view contronller array.
	_viewControllers = [viewControllers copy];
	
	self.selectedViewController = controllerToSelect;
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
	self.selectedViewController = [_viewControllers objectAtIndex:index];
}

@end
