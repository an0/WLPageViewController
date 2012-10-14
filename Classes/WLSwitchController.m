//
//  WLSwitchController.m
//  WLSwitchController
//
//  Created by Wang Ling on 7/14/10.
//  Copyright 2010 I Wonder Phone. All rights reserved.
//

#import "WLSwitchController.h"
#import "NSString+WLExtension.h"


@interface WLSwitchController ()

// Track the item to update segment in real time.
- (void)startObservingTabBarItem:(UIViewController *)viewController;
- (void)stopObservingTabBarItem:(UIViewController *)viewController;
- (void)startObservingTabBarItems:(NSArray *)viewControllers;
- (void)stopObservingTabBarItems:(NSArray *)viewControllers;

@end


@implementation WLSwitchController

@synthesize switchBar = _switchBar;


static void _init(WLSwitchController *self) {
	self.inheritsRightBarButtonItem = YES;
	self.inheritsToolbarItems = YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		_init(self);
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		_init(self);	
	}
	
	return self;
}

- (void)dealloc {
	[self stopObservingTabBarItems:self.viewControllers];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.titleView = self.switchBar;
}

- (void)didReceiveMemoryWarning {
	if (self.isViewLoaded && self.view.window == nil) {
		[self stopObservingTabBarItems:self.viewControllers];
		self.navigationItem.titleView = nil;
		_switchBar = nil;
	}
	[super didReceiveMemoryWarning];
}





#pragma mark - Switch bar

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
		_switchBar.autoresizingMask = UIViewAutoresizingNone;
	}
	
	return _switchBar;
}

- (void)setInheritsTitleView:(BOOL)flag {
	// Never change title view. It must be the switch bar.
}



#pragma mark - Managing the View Controllers

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
	if ([self.viewControllers isEqualToArray:viewControllers]) return;
	
	[self stopObservingTabBarItems:self.viewControllers];
	
	if (_switchBar) {
		// Update the switch bar.
		[_switchBar removeAllSegments];
		
		// Insert new items in reverse order because the limit of insertion methods.
		for (UIViewController *controller in [viewControllers reverseObjectEnumerator]) {
			if (controller.tabBarItem.image) {
				[_switchBar insertSegmentWithImage:controller.tabBarItem.image atIndex:0 animated:animated];
			} else {
				[_switchBar insertSegmentWithTitle:controller.tabBarItem.title atIndex:0 animated:animated];
			}			
		}		
	} else {
		// Just leave _switchBar nil and depend on it lazy initialization.
	}
	
	[self startObservingTabBarItems:viewControllers];
	
	[super setViewControllers:viewControllers animated:animated];
}

- (BOOL)replaceViewControllerAtIndex:(NSUInteger)index withViewController:(UIViewController *)newViewController {
	UIViewController *viewController = [self.viewControllers objectAtIndex:index];
	if (viewController == newViewController) return NO;
	
	if ([super replaceViewControllerAtIndex:index withViewController:newViewController]) {
		[self stopObservingTabBarItem:viewController];
		if (_switchBar) {
			// Update the switch bar.
			[_switchBar setImage:newViewController.tabBarItem.image forSegmentAtIndex:index];
			[_switchBar setTitle:newViewController.tabBarItem.title forSegmentAtIndex:index];
		}
		[self startObservingTabBarItem:newViewController];
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)exchangeViewControllerAtIndex:(NSUInteger)index1 withViewControllerAtIndex:(NSUInteger)index2 {
	if ([super exchangeViewControllerAtIndex:index1 withViewControllerAtIndex:index2]) {
		UIViewController *newViewController1 = [self.viewControllers objectAtIndex:index1];
		UIViewController *newViewController2 = [self.viewControllers objectAtIndex:index2];
		if (_switchBar) {
			// Update the switch bar.
			[_switchBar setImage:newViewController1.tabBarItem.image forSegmentAtIndex:index1];
			[_switchBar setTitle:newViewController1.tabBarItem.title forSegmentAtIndex:index1];
			[_switchBar setImage:newViewController2.tabBarItem.image forSegmentAtIndex:index2];
			[_switchBar setTitle:newViewController2.tabBarItem.title forSegmentAtIndex:index2];			
		}	
		return YES;
	} else {
		return NO;
	}
}


#pragma mark - View switching

- (void)switchView:(UISegmentedControl *)switchBar {
	self.selectedIndex = switchBar.selectedSegmentIndex;
}

- (void)setSelectedViewController:(UIViewController *)viewController {
	[super setSelectedViewController:viewController];
	// Update the switch.
	self.switchBar.selectedSegmentIndex = self.selectedIndex;
}


#pragma mark - Tab bar item observation

- (void)startObservingTabBarItem:(UIViewController *)viewController {
	[viewController addObserver:self forKeyPath:@"tabBarItem.image" options:NSKeyValueObservingOptionNew context:nil];
	[viewController addObserver:self forKeyPath:@"tabBarItem.title" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)stopObservingTabBarItem:(UIViewController *)viewController {
	// Removing observer throws NSRangeException if it is not a registered observer, but there is no way to query whether it is or not so I have to try removing anyhow.
	@try {
		[viewController removeObserver:self forKeyPath:@"tabBarItem.image"];
	}
	@catch (NSException * e) {
		//		DLog(@"%@: %@", [e class], e);
	}
	
	@try {
		[viewController removeObserver:self forKeyPath:@"tabBarItem.title"];
	}
	@catch (NSException * e) {
		//		DLog(@"%@: %@", [e class], e);
	}
}

- (void)startObservingTabBarItems:(NSArray *)viewControllers {
	for (UIViewController *controller in viewControllers) {
		[self startObservingTabBarItem:controller];
	}	
}

- (void)stopObservingTabBarItems:(NSArray *)viewControllers {
	for (UIViewController *controller in viewControllers) {
		[self stopObservingTabBarItem:controller];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (_switchBar) {
		NSUInteger index = [self.viewControllers indexOfObject:object];
		if (index != NSNotFound) {
			if ([keyPath hasPrefix:@"tabBarItem"]) {
				UIViewController *controller = (UIViewController *)object;
				if (controller.tabBarItem.image) {
					[self.switchBar setImage:controller.tabBarItem.image forSegmentAtIndex:index];
				} else if (controller.tabBarItem.title) {
					[self.switchBar setTitle:controller.tabBarItem.title forSegmentAtIndex:index];
				} else {
					[self.switchBar setTitle:@"?" forSegmentAtIndex:index];
				}
			}
		}
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}






@end
