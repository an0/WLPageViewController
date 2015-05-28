//  Created by Wang Ling on 7/16/10.
//  Copyright I Wonder Phone 2010. All rights reserved.

#import "WLContainerController.h"

@interface WLContainerController () {
    BOOL _observesTitle;
    BOOL _observesTitleView;
    BOOL _observesLeftButtonItems;
    BOOL _observesRightButtonItems;
    BOOL _observesBackButtonItem;
    BOOL _observesToolbarItems;
    BOOL _observesTabBarItem;
}

@end

@implementation WLContainerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)dealloc {
	[self unregisterKVOForNavigationBar];
	[self unregisterKVOForToolbar];
    [self unregisterKVOForTabBar];
}

- (void)unregisterKVOForNavigationBar {
	if (_observesTitle) {
		[_contentController removeObserver:self forKeyPath:@"title"];
		[_contentController removeObserver:self forKeyPath:@"navigationItem.title"];
		_observesTitle = NO;
	}

	if (_observesTitleView) {
		[_contentController removeObserver:self forKeyPath:@"navigationItem.titleView"];
		_observesTitleView = NO;
	}

	if (_observesLeftButtonItems) {
        [_contentController removeObserver:self forKeyPath:@"navigationItem.leftBarButtonItem"];
		[_contentController removeObserver:self forKeyPath:@"navigationItem.leftBarButtonItems"];
		_observesLeftButtonItems = NO;
	}

	if (_observesRightButtonItems) {
        [_contentController removeObserver:self forKeyPath:@"navigationItem.rightBarButtonItem"];
		[_contentController removeObserver:self forKeyPath:@"navigationItem.rightBarButtonItems"];
		_observesRightButtonItems = NO;
	}

	if (_observesBackButtonItem) {
		[_contentController removeObserver:self forKeyPath:@"navigationItem.backBarButtonItem"];
		_observesBackButtonItem = NO;
	}
}

- (void)unregisterKVOForToolbar {
	if (_observesToolbarItems) {
		[_contentController removeObserver:self forKeyPath:@"toolbarItems"];
		_observesToolbarItems = NO;
	}
}

- (void)unregisterKVOForTabBar {
    if (_observesTabBarItem) {
        [_contentController removeObserver:self forKeyPath:@"tabBarItem.title"];
        [_contentController removeObserver:self forKeyPath:@"tabBarItem.badgeValue"];
        [_contentController removeObserver:self forKeyPath:@"tabBarItem.enabled"];
        _observesTabBarItem = NO;
    }
}

#pragma mark - Content View management

- (void)setContentController:(UIViewController *)contentController {
	if (_contentController == contentController) return;

	[self unregisterKVOForNavigationBar];
	[self unregisterKVOForToolbar];
    [self unregisterKVOForTabBar];

	[_contentController willMoveToParentViewController:nil];
    if (contentController) {
        [self addChildViewController:contentController];
    }
    
	if (self.isViewLoaded) {
		if (_contentController.view.superview == self.view) {
			[_contentController.view removeFromSuperview];
		}
        if (contentController) {
            UIView *contentView = contentController.view;
            if (contentView.superview != self.view) {
                [self.view addSubview:contentView];
            }
        }
	}

    if (contentController) {
        [contentController didMoveToParentViewController:self];
    }
	[_contentController removeFromParentViewController];
	
	_contentController = contentController;
    
    if (self.isViewLoaded && _contentController) {
        // !!!: Update bar items after loading content view since content controller's bar items usually are configured in its viewDidLoad method, but before adding content view because otherwise viewWillLayoutSubviews may be called too early during nav bar & toolbar updating before self.contentView is updated to the new value.
        [self updateNavigationBar];
        [self updateToolbar];
    }
    
    if (_contentController) {
        // Tab bar item should be configured before view is loaded. Otherwise all content view controllers are required to load their views before tab bar can be configured.
        [self updateTabBar];
    }
}

- (UIView *)contentView {
	return self.contentController.view;
}

- (void)layoutContentView:(UIView *)contentView {
	contentView.frame = UIEdgeInsetsInsetRect(self.view.bounds, self.contentInset);
}

- (void)setContentInset:(UIEdgeInsets)insets {
	if (UIEdgeInsetsEqualToEdgeInsets(insets, _contentInset)) return;

	_contentInset = insets;
	[self.view setNeedsLayout];
}

- (void)setBackgroundView:(UIView *)backgroundView {
	if (_backgroundView == backgroundView) return;
	
	[_backgroundView removeFromSuperview];
	_backgroundView = backgroundView;
	if (_backgroundView) {
		_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		if (self.isViewLoaded) {
			_backgroundView.frame = self.view.bounds;
			[self.view insertSubview:_backgroundView atIndex:0];
		}
	}
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	if (!_isTransitioningContentView) {
		[self layoutContentView:self.contentView];
	}
}

#pragma mark - Update navigation bar, toolbar, tab bar

- (void)updateNavigationBar {
    UIViewController *contentController = self.contentController;
    
	if (_inheritsTitle) {
		if (!_observesTitle) {
            [contentController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
			[contentController addObserver:self forKeyPath:@"navigationItem.title" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
			_observesTitle = YES;
		}
	}
	if (_inheritsTitleView) {
		if (!_observesTitleView) {
			[contentController addObserver:self forKeyPath:@"navigationItem.titleView" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
			_observesTitleView = YES;
		}
	}
	if (_inheritsLeftBarButtonItems) {
		if (!_observesLeftButtonItems) {
            [contentController addObserver:self forKeyPath:@"navigationItem.leftBarButtonItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
			[contentController addObserver:self forKeyPath:@"navigationItem.leftBarButtonItems" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
			_observesLeftButtonItems = YES;
		}
	}
	if (_inheritsRightBarButtonItems) {
		if (!_observesRightButtonItems) {
            [contentController addObserver:self forKeyPath:@"navigationItem.rightBarButtonItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
			[contentController addObserver:self forKeyPath:@"navigationItem.rightBarButtonItems" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
			_observesRightButtonItems = YES;
		}
	}
	if (_inheritsBackBarButtonItem) {
		if (!_observesBackButtonItem) {
			[contentController addObserver:self forKeyPath:@"navigationItem.backBarButtonItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
			_observesBackButtonItem = YES;
		}
	}
}

- (void)updateToolbar {
    UIViewController *contentController = self.contentController;

    if (_inheritsToolbarItems) {
		if (!_observesToolbarItems) {
			[contentController addObserver:self forKeyPath:@"toolbarItems" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
			_observesToolbarItems = YES;
		}
	}
}

- (void)updateTabBar {
    UIViewController *contentController = self.contentController;
    
    if (_inheritsTabBarItem) {
        if (!_observesTabBarItem) {
            [contentController addObserver:self forKeyPath:@"tabBarItem.title" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
            [contentController addObserver:self forKeyPath:@"tabBarItem.badgeValue" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
            [contentController addObserver:self forKeyPath:@"tabBarItem.enabled" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
            _observesTabBarItem = YES;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == _contentController) {
		id value = change[NSKeyValueChangeNewKey];
		if (value == [NSNull null]) {
			value = nil;
		}
		
        [self setValue:value forKeyPath:keyPath];
	}
}

#pragma mark - View events

- (void)viewDidLoad {
	[super viewDidLoad];

	// Add background view.
	if (_backgroundView) {
		_backgroundView.frame = self.view.bounds;
		[self.view insertSubview:_backgroundView atIndex:0];
	}

	// Add content view.
	if (self.contentView) {
		[self.view addSubview:self.contentView];
	}

	// Update bar items after loading content view since content controller's bar items usually are configured in its viewDidLoad method.
	if (_contentController) {
        [self updateNavigationBar];
        [self updateToolbar];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	_isViewVisible = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];	
	_isViewVisible = NO;
}

#pragma mark - Rotation support

- (BOOL)shouldAutorotate {
    BOOL result = YES;
    if (_contentController) {
        result = [_contentController shouldAutorotate];
    }
	return result;
}

- (NSUInteger)supportedInterfaceOrientations {
    NSUInteger mask;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        mask = UIInterfaceOrientationMaskAll;
    } else {
        mask = UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
    if (_contentController) {
        mask &= [_contentController supportedInterfaceOrientations];
    }
    
    return mask;
}

#pragma mark - State Preservation and Restoration

#define kStateKeyTitle @"title"
#define kStateKeyContentViewController @"content_view_controller"
#define kStateKeyContentInset @"content_inset"
#define kStateKeyInheritsTitle @"inherits_title"
#define kStateKeyInheritsTitleView @"inherits_title_view"
#define kStateKeyInheritsLeftBarButtonItems @"inherits_left_bar_button_items"
#define kStateKeyInheritsRightBarButtonItems @"inherits_right_bar_button_items"
#define kStateKeyInheritsBackBarButtonItem @"inherits_back_bar_button_item"
#define kStateKeyInheritsToolbarItems @"inherits_toolbar_items"

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
	[super encodeRestorableStateWithCoder:coder];

	[coder encodeObject:self.title forKey:kStateKeyTitle];
	[coder encodeObject:self.contentController forKey:kStateKeyContentViewController];
	[coder encodeUIEdgeInsets:self.contentInset forKey:kStateKeyContentInset];
	[coder encodeBool:self.inheritsTitle forKey:kStateKeyInheritsTitle];
	[coder encodeBool:self.inheritsTitleView forKey:kStateKeyInheritsTitleView];
	[coder encodeBool:self.inheritsLeftBarButtonItems forKey:kStateKeyInheritsLeftBarButtonItems];
	[coder encodeBool:self.inheritsRightBarButtonItems forKey:kStateKeyInheritsRightBarButtonItems];
	[coder encodeBool:self.inheritsBackBarButtonItem forKey:kStateKeyInheritsBackBarButtonItem];
	[coder encodeBool:self.inheritsToolbarItems forKey:kStateKeyInheritsToolbarItems];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
	[super decodeRestorableStateWithCoder:coder];

	self.inheritsTitle = [coder decodeBoolForKey:kStateKeyInheritsTitle];
	self.inheritsTitleView  = [coder decodeBoolForKey:kStateKeyInheritsTitleView];
	self.inheritsLeftBarButtonItems  = [coder decodeBoolForKey:kStateKeyInheritsLeftBarButtonItems];
	self.inheritsRightBarButtonItems  = [coder decodeBoolForKey:kStateKeyInheritsRightBarButtonItems];
	self.inheritsBackBarButtonItem  = [coder decodeBoolForKey:kStateKeyInheritsBackBarButtonItem];
	self.inheritsToolbarItems  = [coder decodeBoolForKey:kStateKeyInheritsToolbarItems];
	self.contentInset = [coder decodeUIEdgeInsetsForKey:kStateKeyContentInset];
	self.contentController = [coder decodeObjectForKey:kStateKeyContentViewController];
}

@end
