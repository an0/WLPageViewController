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

- (void)viewDidUnload {
	[self stopObservingTabBarItems:self.viewControllers];
	
	self.navigationItem.titleView = nil;
	_switchBar = nil;
	 
    [super viewDidUnload];
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
		
		[self startObservingTabBarItems:self.viewControllers];
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
			} else if (controller.tabBarItem.title) {
				[_switchBar insertSegmentWithTitle:controller.tabBarItem.title atIndex:0 animated:animated];
			} else {
				[_switchBar insertSegmentWithTitle:@"?" atIndex:0 animated:animated];
			}			
		}
		
		[self startObservingTabBarItems:viewControllers];
	} else {
		// Just leave _switchBar nil and depend on it lazy initialization.
	}
	
	[super setViewControllers:viewControllers animated:animated];
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
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}






@end
