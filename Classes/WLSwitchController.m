//
//  WLSwitchController.m
//  WLSwitchController
//
//  Created by Wang Ling on 7/14/10.
//  Copyright 2010 I Wonder Phone. All rights reserved.
//

#import "WLSwitchController.h"
#import "NSString+Extension.h"


@interface WLSwitchController (Private)

// Track the item to update segment in real time.
- (void)startObservingTabBarItems:(NSArray *)viewControllers;
- (void)stopObservingTabBarItems:(NSArray *)viewControllers;

@end


@implementation WLSwitchController

@synthesize
switchBar = _switchBar,
viewControllers = _viewControllers,
selectedViewController = _selectedViewController;



- (id)init {
	if (self = [super init]) {
		self.inheritsRightBarButtonItem = YES;
		self.inheritsToolbarItems = YES;
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.titleView = self.switchBar;
}

- (void)viewDidUnload {
	[self stopObservingTabBarItems:_viewControllers];
	
	[_switchBar release];
	_switchBar = nil;
	 
    [super viewDidUnload];
}


- (void)dealloc {
	[self stopObservingTabBarItems:_viewControllers];
	
	[_switchBar release];
	[_viewControllers release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark View events

- (void)viewWillAppear:(BOOL)animated {	
	// Initially select the first controller is none is pre-selected.
	if (self.selectedViewController == nil && [self.viewControllers count] > 0) {
		self.selectedIndex = 0;
	}
	
	[super viewWillAppear:animated];
}


#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	BOOL result = YES;
	for (UIViewController *controller in self.viewControllers) {
		if (![controller shouldAutorotateToInterfaceOrientation:interfaceOrientation]) {
			result = NO;
			break;
		}
	}
	
    return result;
}




#pragma mark -
#pragma mark Switch bar

- (UISegmentedControl *)switchBar {
	if (_switchBar == nil) {
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:[self.viewControllers count]];
		for (UIViewController *controller in self.viewControllers) {
			if (controller.tabBarItem.image) {
				[items addObject:controller.tabBarItem.image];
			} else if (controller.tabBarItem.title) {
				[items addObject:controller.tabBarItem.title];
			} else {
				[items addObject:@"?"];
			}
		}
		
		_switchBar = [[UISegmentedControl alloc] initWithItems:items];
		_switchBar.segmentedControlStyle = UISegmentedControlStyleBar;
		[_switchBar addTarget:self action:@selector(switchView:) forControlEvents:UIControlEventValueChanged];
		
		[self startObservingTabBarItems:self.viewControllers];
	}
	
	return _switchBar;
}


#pragma mark -
#pragma mark Managing the View Controllers

- (void)setViewControllers:(NSArray *)viewControllers {
	[self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
	if ([_viewControllers isEqualToArray:viewControllers]) {
		return;
	}
	
	[self stopObservingTabBarItems:_viewControllers];
	
	if (_switchBar) {
		// Update the switch bar.
		[self.switchBar removeAllSegments];
		
		// Insert new items in reverse order because the limit of insertion methods.
		for (UIViewController *controller in [viewControllers reverseObjectEnumerator]) {
			if (controller.tabBarItem.image) {
				[self.switchBar insertSegmentWithImage:controller.tabBarItem.image atIndex:0 animated:animated];
			} else if (controller.tabBarItem.title) {
				[self.switchBar insertSegmentWithTitle:controller.tabBarItem.title atIndex:0 animated:animated];
			} else {
				[self.switchBar insertSegmentWithTitle:@"?" atIndex:0 animated:animated];
			}			
		}
		
		[self startObservingTabBarItems:viewControllers];
	} else {
		// Just leave _switchBar nil and depend on it lazy initialization.
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
	
	// Retain the selected view controller to prevent it from being deallocated by releasing the view controller array; then autorelease it because I can not release it when I've lost the reference to it after the assignment.
	[[self.selectedViewController retain] autorelease];
	// Must update the view controller array before the assignment of selected view controller because of the precondition that the selected view controller must be element of the view contronller array.
	[_viewControllers release];
	_viewControllers = [viewControllers copy];

	self.selectedViewController = controllerToSelect;
}



#pragma mark -
#pragma mark View switching

- (void)switchView:(UISegmentedControl *)switchBar {
	self.selectedIndex = switchBar.selectedSegmentIndex;
}

- (void)setSelectedViewController:(UIViewController *)viewController {
	self.contentController = viewController;
	_selectedViewController = viewController;
	// Update the switch.
	self.switchBar.selectedSegmentIndex = self.selectedIndex;
}

- (NSUInteger)selectedIndex {
	if (self.viewControllers) {
		return [self.viewControllers indexOfObject:self.selectedViewController];
	} else {
		return NSNotFound;
	}
}

- (void)setSelectedIndex:(NSUInteger)index {	
	self.selectedViewController = [self.viewControllers objectAtIndex:index];
}


#pragma mark -
#pragma mark Tab bar item observation

- (void)startObservingTabBarItems:(NSArray *)viewControllers {
	for (UIViewController *controller in viewControllers) {
		[controller addObserver:self forKeyPath:@"tabBarItem.image" options:NSKeyValueObservingOptionNew context:nil];
		[controller addObserver:self forKeyPath:@"tabBarItem.title" options:NSKeyValueObservingOptionNew context:nil];
	}	
}

- (void)stopObservingTabBarItems:(NSArray *)viewControllers {
	for (UIViewController *controller in viewControllers) {
		// Removing observer throws NSRangeException if it is not a registered observer, but there is no way to query whether it is or not so I have to try removing anyhow.
		@try {
			[controller removeObserver:self forKeyPath:@"tabBarItem.image"];
		}
		@catch (NSException * e) {
			//		DLog(@"%@: %@", [e class], e);
		}
		
		@try {
			[controller removeObserver:self forKeyPath:@"tabBarItem.title"];
		}
		@catch (NSException * e) {
			//		DLog(@"%@: %@", [e class], e);
		}				
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSUInteger index = [self.viewControllers indexOfObject:object];
	if (index != NSNotFound) {
		if ([keyPath startsWith:@"tabBarItem"]) {
			UIViewController *controller = (UIViewController *)object;
			if (controller.tabBarItem.image) {
				[self.switchBar setImage:controller.tabBarItem.image forSegmentAtIndex:index];
			} else if (controller.tabBarItem.title) {
				[self.switchBar setTitle:controller.tabBarItem.title forSegmentAtIndex:index];
			} else {
				[self.switchBar setTitle:@"?" forSegmentAtIndex:index];
			}
			
			return;
		}
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


@end
