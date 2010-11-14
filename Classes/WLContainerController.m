//
//  WLContainerController.m
//  WLContainerController
//
//  Created by Wang Ling on 7/16/10.
//  Copyright I Wonder Phone 2010. All rights reserved.
//

#import "WLContainerController.h"


@interface WLContainerController ()

- (void)updateNavigationBarFrom:(UIViewController *)contentController;
- (void)updateToolbarFrom:(UIViewController *)contentController;

@end



@implementation WLContainerController


@synthesize
contentController = _contentController,
contentInset = _contentInset,
inheritsTitleView = _inheritsTitleView,
inheritsLeftBarButtonItem = _inheritsLeftBarButtonItem,
inheritsRightBarButtonItem = _inheritsRightBarButtonItem,
inheritsToolbarItems = _inheritsToolbarItems;


- (id)initWithContentController:(UIViewController *)contentController {
	if ((self = [super init])) {
		self.contentController = contentController;
	}
	return self;
}

- (void)dealloc {
	// Stop the observation.
	[self updateNavigationBarFrom:nil];
	[self updateToolbarFrom:nil];
	
	[_contentController release];
    [super dealloc];
}


#pragma mark -
#pragma mark Content View management

- (void)setContentController:(UIViewController *)contentController {
	if (_contentController != contentController) {
		if ([self isViewLoaded]) {
			// Update the content view only if the containing view is loaded.
			// Ensure the content view is loaded before sending view event messages.
			UIView *contentView = contentController.view;
			contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;			
			// Adjust the frame of the content view according to the insets.
			contentView.frame = UIEdgeInsetsInsetRect(self.view.bounds, self.contentInset);
			[_contentController viewWillDisappear:YES];
			[contentController viewWillAppear:YES];
			[_contentController.view removeFromSuperview];
			[self.view addSubview:contentView];
			[_contentController viewDidDisappear:YES];
			[contentController viewDidAppear:YES];
			
			[self updateNavigationBarFrom:contentController];
			[self updateToolbarFrom:contentController];

			/**
			 FIXME: Logically, parent view controller should be responsible for rotating subview controller, but 1) UINavigationController and UITabBarController don't do it; 2) interfaceOrientation is readonly, so it is impossible to do perfect orientation management currently.
			 I think I should follow the behavior of UINavigationController and UITabBarController, and users should follow http://wangling.me/2010/07/how-to-rock-and-roll-your-apps/ and override interfaceOrientation to return interfaceOrientation of its parent. 
			 In fact, the following code does not work, because contentController.interfaceOrientation never changes and condition clause will have false negatives.
			 */
			
			/** Refer to http://openradar.appspot.com/8365675. */
			
			// Rotate the content view if necessary.
//			if (contentController.interfaceOrientation != self.interfaceOrientation) {
//				UIInterfaceOrientation oldOrientation = contentController.interfaceOrientation;
//				[contentController willRotateToInterfaceOrientation:self.interfaceOrientation duration:0.3];
//				[contentController willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0.3];
//				[contentController didRotateFromInterfaceOrientation:oldOrientation];
//			}
		}		
		
		[_contentController release];
		_contentController = [contentController retain];
	}
}


- (UIView *)contentView {
	return self.contentController.view;
}


#pragma mark -
#pragma mark Update navigation bar and toolbar

- (void)updateNavigationBarFrom:(UIViewController *)contentController {
	// Removing observer throws NSException if it is not a registered observer, but there is no way to query whether it is or not so I have to try removing anyhow.
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
	
	
		
	if (_inheritsTitleView) {
		self.navigationItem.titleView = contentController.navigationItem.titleView;
		[contentController addObserver:self forKeyPath:@"navigationItem.titleView" options:NSKeyValueObservingOptionNew context:nil];
	}
	if (_inheritsLeftBarButtonItem) {
		[self.navigationItem setLeftBarButtonItem:contentController.navigationItem.leftBarButtonItem animated:YES];
		[contentController addObserver:self forKeyPath:@"navigationItem.leftBarButtonItem" options:NSKeyValueObservingOptionNew context:nil];
	}
	if (_inheritsRightBarButtonItem) {
		[self.navigationItem setRightBarButtonItem:contentController.navigationItem.rightBarButtonItem animated:YES];
		[contentController addObserver:self forKeyPath:@"navigationItem.rightBarButtonItem" options:NSKeyValueObservingOptionNew context:nil];
	}	
}

- (void)updateToolbarFrom:(UIViewController *)contentController {
	// Removing observer throws NSRangeException if it is not a registered observer, but there is no way to query whether it is or not so I have to try removing anyhow.
	@try {
		[_contentController removeObserver:self forKeyPath:@"toolbarItems"];
	}
	@catch (NSException * e) {
//		DLog(@"%@: %@", [e class], e);
	}


	if (_inheritsToolbarItems) {
		if ([contentController.toolbarItems count] > 0) {
			self.navigationController.toolbarHidden = NO;
			[self setToolbarItems:contentController.toolbarItems animated:YES];
		} else {
			self.navigationController.toolbarHidden = YES;
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
		
		[self setValue:value forKeyPath:keyPath];
	}	
}


#pragma mark -
#pragma mark View events

- (void)viewWillAppear:(BOOL)animated {	
	if (_contentController) {
		// Ensure the content view is loaded before sending view event messages.
		UIView *contentView = _contentController.view;
		if (contentView.superview != self.view) { 
			// Add the content view in the containing view if necessary.
			// Adjust the frame of the content view according to the insets.
			contentView.frame = UIEdgeInsetsInsetRect(self.view.bounds, self.contentInset);
			contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[self.view addSubview:contentView];
			
			[self updateNavigationBarFrom:_contentController];
			[self updateToolbarFrom:_contentController];
		}
		
		[_contentController viewWillAppear:animated];			 
	}
	
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {	
	if (_contentController) {
		[_contentController viewDidAppear:animated];
	}
	
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (_contentController) {
		[_contentController viewWillDisappear:animated];
	}
	
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	if (_contentController) {
		[_contentController viewDidDisappear:animated];		
	}
	
	[super viewDidDisappear:animated];
}


#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [_contentController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[_contentController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	[_contentController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[_contentController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}



@end
