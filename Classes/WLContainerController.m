//
//  WLContainerController.m
//  WLContainerController
//
//  Created by Wang Ling on 7/16/10.
//  Copyright I Wonder Phone 2010. All rights reserved.
//

#import "WLContainerController.h"

@interface WLContainerController ()
- (void)unregisterKVOForNavigationBar;
- (void)unregisterKVOForToolbar;
@end



@implementation WLContainerController


@synthesize contentController = _contentController;
@synthesize backgroundView = _backgroundView;
@synthesize contentInset = _contentInset;
@synthesize inheritsTitle = _inheritsTitle;
@synthesize inheritsTitleView = _inheritsTitleView;
@synthesize inheritsLeftBarButtonItem = _inheritsLeftBarButtonItem;
@synthesize inheritsRightBarButtonItem = _inheritsRightBarButtonItem;
@synthesize inheritsToolbarItems = _inheritsToolbarItems;
@synthesize secondaryViewController = _secondaryViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		_toolbarHidden = YES;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		_toolbarHidden = YES;
	}
	return self;
}

- (void)dealloc {
	[self unregisterKVOForNavigationBar];
	[self unregisterKVOForToolbar];
}

- (void)unregisterKVOForNavigationBar {
	// Removing observer throws NSException if it is not a registered observer, but there is no way to query whether it is or not so I have to try removing anyhow.
	@try {
		[_contentController removeObserver:self forKeyPath:@"title"];
	}
	@catch (NSException *exception) {
		
	}
	
	@try {
		[_contentController removeObserver:self forKeyPath:@"navigationItem.title"];
	}
	@catch (NSException *exception) {
		
	}
	
	@try {
		[_contentController removeObserver:self forKeyPath:@"navigationItem.titleView"];
	}
	@catch (NSException * e) {
		//		DLog(@"%@: %@", [e class], e);
	}
	
	@try {
		[_contentController removeObserver:self forKeyPath:@"navigationItem.leftBarButtonItem"];
	}
	@catch (NSException * e) {
		//		DLog(@"%@: %@", [e class], e);
	}
	
	@try {
		[_contentController removeObserver:self forKeyPath:@"navigationItem.rightBarButtonItem"];
	}
	@catch (NSException * e) {
		//		DLog(@"%@: %@", [e class], e);
	}
}

- (void)unregisterKVOForToolbar {
	// Removing observer throws NSRangeException if it is not a registered observer, but there is no way to query whether it is or not so I have to try removing anyhow.
	@try {
		[_contentController removeObserver:self forKeyPath:@"toolbarItems"];
	}
	@catch (NSException * e) {
		//		DLog(@"%@: %@", [e class], e);
	}
}


#pragma mark - Content View management

- (void)setContentController:(UIViewController *)contentController {
	if (_contentController == contentController) return;

	[_contentController willMoveToParentViewController:nil];
	[self addChildViewController:contentController];
	if (self.isViewLoaded) {
		if (_contentController.view.superview == self.view) {
			[_contentController.view removeFromSuperview];
		}
		if (contentController.view.superview != self.view) {
			[self.view addSubview:contentController.view];
			[self layoutContentView:contentController.view];
		}
	}
	[contentController didMoveToParentViewController:self];	
	[_contentController removeFromParentViewController];
	
	[self updateNavigationBarFrom:contentController];
	[self updateToolbarFrom:contentController];
	_contentController = contentController;
}


- (UIView *)contentView {
	return self.contentController.view;
}

- (void)layoutContentView:(UIView *)contentView {
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;			
	// Adjust the frame of the content view according to the insets.
	contentView.frame = UIEdgeInsetsInsetRect(self.view.bounds, _contentInset);
	
	// Adjust contentInset and scrollIndicatorInsets for scroll view if container controller is on navigation stack and translucent toolbar is shown.
	UIToolbar *toolbar = self.navigationController.toolbar;
	if (toolbar &&
		!toolbar.hidden &&
		toolbar.translucent &&
		[contentView isKindOfClass:[UIScrollView class]]) {
		CGRect toolbarFrame = [self.view convertRect:toolbar.frame fromView:toolbar.superview];
		CGFloat bottomInset = (toolbarFrame.size.height - self.contentInset.bottom);
		if (bottomInset < 0) bottomInset = 0;
		((UIScrollView *)contentView).scrollIndicatorInsets = ((UIScrollView *)contentView).contentInset = UIEdgeInsetsMake(0, 0, bottomInset, 0);
	}
}

- (void)setContentInset:(UIEdgeInsets)insets {
	_contentInset = insets;
	[self.view setNeedsLayout];
}

- (void)setBackgroundView:(UIView *)backgroundView {
	if (_backgroundView == backgroundView) return;
	
	[_backgroundView removeFromSuperview];
	_backgroundView = backgroundView;
	_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	if (self.isViewLoaded) {
		_backgroundView.frame = self.view.bounds;
		[self.view insertSubview:_backgroundView atIndex:0];
	}
}

#pragma mark - Update navigation bar and toolbar

- (void)updateNavigationBarFrom:(UIViewController *)contentController {
	[self unregisterKVOForNavigationBar];
	
	if (_inheritsTitle) {
		self.title = contentController.title;
		self.navigationItem.title = contentController.navigationItem.title;
		[contentController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
		[contentController addObserver:self forKeyPath:@"navigationItem.title" options:NSKeyValueObservingOptionNew context:nil];
	}		
	if (_inheritsTitleView) {
		self.navigationItem.titleView = contentController.navigationItem.titleView;
		[contentController addObserver:self forKeyPath:@"navigationItem.titleView" options:NSKeyValueObservingOptionNew context:nil];
	}
	if (_inheritsLeftBarButtonItem) {
		[self.navigationItem setLeftBarButtonItem:contentController.navigationItem.leftBarButtonItem animated:_isVisible];
		[contentController addObserver:self forKeyPath:@"navigationItem.leftBarButtonItem" options:NSKeyValueObservingOptionNew context:nil];
	}
	if (_inheritsRightBarButtonItem) {
		[self.navigationItem setRightBarButtonItem:contentController.navigationItem.rightBarButtonItem animated:_isVisible];
		[contentController addObserver:self forKeyPath:@"navigationItem.rightBarButtonItem" options:NSKeyValueObservingOptionNew context:nil];
	}	
}

- (void)updateToolbarFrom:(UIViewController *)contentController {
	[self unregisterKVOForToolbar];

	if (_inheritsToolbarItems) {
		if ([contentController.toolbarItems count] > 0) {
			_toolbarHidden = NO;
			if (_isVisible) {
				[self.navigationController setToolbarHidden:_toolbarHidden animated:_isVisible];
			}
			[self setToolbarItems:contentController.toolbarItems animated:_isVisible];
		} else {
			_toolbarHidden = YES;
			if (_isVisible) {
				[self.navigationController setToolbarHidden:_toolbarHidden animated:_isVisible];
			}
			[self setToolbarItems:nil];
		}

		[contentController addObserver:self forKeyPath:@"toolbarItems" options:NSKeyValueObservingOptionNew context:nil];
	}	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == _contentController) {
		id value = [change objectForKey:NSKeyValueChangeNewKey];
		if (value == [NSNull null]) {
			value = nil;
		}
		
		if ([keyPath isEqualToString:@"navigationItem.leftBarButtonItem"]) {
			[self.navigationItem setLeftBarButtonItem:value animated:_isVisible];
		} else if ([keyPath isEqualToString:@"navigationItem.rightBarButtonItem"]) {
			[self.navigationItem setRightBarButtonItem:value animated:_isVisible];
		} else {
			if ([keyPath isEqualToString:@"toolbarItems"]) {
				_toolbarHidden = ([value count] == 0);
				if (_isVisible) {
					[self.navigationController setToolbarHidden:_toolbarHidden animated:_isVisible];
				}
			}
			[self setValue:value forKeyPath:keyPath];
		}		
	}	
}




#pragma mark - View events

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Addd background view.
	if (_backgroundView) {
		_backgroundView.frame = self.view.bounds;
		[self.view insertSubview:_backgroundView atIndex:0];
	}

	// Add content view.
	if (self.contentView) {
		[self.view addSubview:self.contentView];
		[self layoutContentView:self.contentView];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.navigationController != nil && _toolbarHidden != self.navigationController.toolbarHidden) {
		[self.navigationController setToolbarHidden:_toolbarHidden animated:animated];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	_isVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (self.navigationController != nil && _toolbarHidden != self.navigationController.toolbarHidden) {
		_toolbarHidden = self.navigationController.toolbarHidden;
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	_isVisible = NO;
}



#pragma mark - Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	BOOL result = [_contentController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
	if (_secondaryViewController) {
		result = result && [_secondaryViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
	}
	return result;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self layoutContentView:self.contentView];
}



#pragma mark - Secondary view controller presening/dismissing

- (void)presentSecondaryViewController:(UIViewController *)viewController animated:(BOOL)animated {
	UIToolbar *toolbar = self.navigationController.toolbar;
	
	void (^animations)(void) = ^{
		CGRect offScreenFrame;
		if (toolbar) {
			CGFloat offset = CGRectGetMaxY([self.view convertRect:toolbar.frame fromView:toolbar.superview]);
			offScreenFrame = self.contentView.frame;
			offScreenFrame.origin.y += offset;
			self.contentView.frame = offScreenFrame;
			offScreenFrame = toolbar.frame;
			offScreenFrame.origin.y += offset;
			toolbar.frame = offScreenFrame;
		}
	};
	
	void (^completion)(BOOL finished) = ^(BOOL finished) {
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
		if (animated) {
			[UIView animateWithDuration:(animated ? 0.2 : 0) animations:^{
				_secondaryViewController.view.frame = self.view.bounds;
			}];
		} else {
			_secondaryViewController.view.frame = self.view.bounds;
		}
	};
	
	if (animated) {
		[UIView animateWithDuration:0.2 animations:animations completion:completion];
	} else {
		animations();
		completion(NO);
	}
}

- (void)dismissSecondaryViewControllerAnimated:(BOOL)animated {
	[_secondaryViewController willMoveToParentViewController:nil];
	
	void (^animations)(void) = ^{
		CGRect offScreenFrame = self.view.bounds;
		offScreenFrame.origin.x -= offScreenFrame.size.width;
		_secondaryViewController.view.frame = offScreenFrame;
	};
	
	void (^completion)(BOOL finished) = ^(BOOL finished) {
		[_secondaryViewController.view removeFromSuperview];
		[_secondaryViewController removeFromParentViewController];
		_secondaryViewController = nil;
		[self.view addSubview:self.contentView];
		UIToolbar *toolbar = self.navigationController.toolbar;
		if (animated) {
			[UIView animateWithDuration:(animated ? 0.2 : 0) animations:^{
				if (toolbar) {
					self.navigationController.toolbarHidden = NO;
				}
				[self layoutContentView:self.contentView];
			}];
		} else {
			if (toolbar) {
				self.navigationController.toolbarHidden = NO;
			}
			[self layoutContentView:self.contentView];
		}
	};
	
	if (animated) {
		[UIView animateWithDuration:0.2 animations:animations completion:completion];
	} else {
		animations();
		completion(NO);
	}
}



@end
