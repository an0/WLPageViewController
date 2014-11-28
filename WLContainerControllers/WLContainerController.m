//
//  WLContainerController.m
//  WLContainerController
//
//  Created by Wang Ling on 7/16/10.
//  Copyright I Wonder Phone 2010. All rights reserved.
//

#import "WLContainerController.h"

@interface WLContainerController () {
	BOOL _observesTitle;
	BOOL _observesTitleView;
	BOOL _observesLeftButtonItems;
	BOOL _observesRightButtonItems;
	BOOL _observesBackButtonItem;
	BOOL _observesToolbarItems;
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
		[_contentController removeObserver:self forKeyPath:@"navigationItem.leftBarButtonItems"];
		_observesLeftButtonItems = NO;
	}

	if (_observesRightButtonItems) {
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

#pragma mark - Content View management

- (void)setContentController:(UIViewController *)contentController {
	if (_contentController == contentController) return;
	if (contentController == nil) return;

	[self unregisterKVOForNavigationBar];
	[self unregisterKVOForToolbar];

	[_contentController willMoveToParentViewController:nil];
	[self addChildViewController:contentController];
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

	[contentController didMoveToParentViewController:self];	
	[_contentController removeFromParentViewController];
	
	_contentController = contentController;
}

- (UIView *)contentView {
	return self.contentController.view;
}

- (void)layoutContentView:(UIView *)contentView {
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;			
	// Adjust the frame of the content view according to the insets.
	contentView.frame = UIEdgeInsetsInsetRect(self.view.bounds, _contentInset);
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

#pragma mark - Update navigation bar and toolbar

- (void)updateNavigationBarFrom:(UIViewController *)contentController {
	if (_inheritsTitle) {
		self.title = contentController.title;
		self.navigationItem.title = contentController.navigationItem.title;
        
		if (!_observesTitle) {
            [contentController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
			[contentController addObserver:self forKeyPath:@"navigationItem.title" options:NSKeyValueObservingOptionNew context:nil];
			_observesTitle = YES;
		}
	}
	if (_inheritsTitleView) {
		self.navigationItem.titleView = contentController.navigationItem.titleView;

		if (!_observesTitleView) {
			[contentController addObserver:self forKeyPath:@"navigationItem.titleView" options:NSKeyValueObservingOptionNew context:nil];
			_observesTitleView = YES;
		}
	}
	if (_inheritsLeftBarButtonItems) {
		[self.navigationItem setLeftBarButtonItems:contentController.navigationItem.leftBarButtonItems animated:_animatesNavigationBarChanges];

		if (!_observesLeftButtonItems) {
			[contentController addObserver:self forKeyPath:@"navigationItem.leftBarButtonItems" options:NSKeyValueObservingOptionNew context:nil];
			_observesLeftButtonItems = YES;
		}
	}
	if (_inheritsRightBarButtonItems) {
		[self.navigationItem setRightBarButtonItems:contentController.navigationItem.rightBarButtonItems animated:_animatesNavigationBarChanges];

		if (!_observesRightButtonItems) {
			[contentController addObserver:self forKeyPath:@"navigationItem.rightBarButtonItems" options:NSKeyValueObservingOptionNew context:nil];
			_observesRightButtonItems = YES;
		}
	}
	if (_inheritsBackBarButtonItem) {
		[self.navigationItem setBackBarButtonItem:contentController.navigationItem.backBarButtonItem];

		if (!_observesBackButtonItem) {
			[contentController addObserver:self forKeyPath:@"navigationItem.backBarButtonItem" options:NSKeyValueObservingOptionNew context:nil];
			_observesBackButtonItem = YES;
		}
	}
}

- (void)updateToolbarFrom:(UIViewController *)contentController {
	if (_inheritsToolbarItems) {
		if ([contentController.toolbarItems count] > 0) {
			[self.navigationController setToolbarHidden:NO animated:_animatesToolbarChanges];
			[self setToolbarItems:contentController.toolbarItems animated:_animatesToolbarChanges];
		} else {
			[self.navigationController setToolbarHidden:YES animated:_animatesToolbarChanges];
			[self setToolbarItems:nil];
		}

		if (!_observesToolbarItems) {
			[contentController addObserver:self forKeyPath:@"toolbarItems" options:NSKeyValueObservingOptionNew context:nil];
			_observesToolbarItems = YES;
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == _contentController) {
		id value = change[NSKeyValueChangeNewKey];
		if (value == [NSNull null]) {
			value = nil;
		}
		
		if ([keyPath isEqualToString:@"navigationItem.leftBarButtonItems"]) {
			[self.navigationItem setLeftBarButtonItems:value animated:_animatesNavigationBarChanges];
		} else if ([keyPath isEqualToString:@"navigationItem.rightBarButtonItems"]) {
			[self.navigationItem setRightBarButtonItems:value animated:_animatesNavigationBarChanges];
		} else if ([keyPath isEqualToString:@"navigationItem.backBarButtonItem"]) {
			[self.navigationItem setBackBarButtonItem:value];
		} else {
			if ([keyPath isEqualToString:@"toolbarItems"]) {
				[self.navigationController setToolbarHidden:([(NSArray *)value count] == 0) animated:_animatesToolbarChanges];
			}
			[self setValue:value forKeyPath:keyPath];
		}		
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
		[self updateNavigationBarFrom:_contentController];
		[self updateToolbarFrom:_contentController];
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
	return [_contentController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    if (_contentController) {
        return [_contentController supportedInterfaceOrientations];
    } else {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            return UIInterfaceOrientationMaskAll;
        } else {
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }
    }
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
