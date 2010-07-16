//
//  WLContainerController.m
//  WLContainerController
//
//  Created by Wang Ling on 7/16/10.
//  Copyright I Wonder Phone 2010. All rights reserved.
//

#import "WLContainerController.h"


@interface WLContainerController (Private)

- (void)updateNavigationBarFrom:(UIViewController *)contentController;
- (void)updateToolbarFrom:(UIViewController *)contentController;

@end



@implementation WLContainerController


@synthesize
contentController = _contentController,
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


//- (void)viewDidUnload {
//    [super viewDidUnload];	
//}


- (void)dealloc {	
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
			// Adjust the frame of the content view to fit in the containing view.
			contentView.frame = self.view.bounds;
			[_contentController viewWillDisappear:YES];
			[contentController viewWillAppear:YES];
			[_contentController.view removeFromSuperview];
			[self.view addSubview:contentView];
			[_contentController viewDidDisappear:YES];
			[contentController viewDidAppear:YES];
			
			[self updateNavigationBarFrom:contentController];
			[self updateToolbarFrom:contentController];
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
	// FIXME: removing throws exception if it is not an observer
//	[_contentController removeObserver:self forKeyPath:@"navigationItem.titleView"];
//	[_contentController removeObserver:self forKeyPath:@"navigationItem.leftBarButtonItem"];
//	[_contentController removeObserver:self forKeyPath:@"navigationItem.rightBarButtonItem"];
	
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
	// FIXME: removing throws exception if it is not an observer
//	[_contentController removeObserver:self forKeyPath:@"toolbarItems"];

	if (_inheritsToolbarItems) {
		[self setToolbarItems:contentController.toolbarItems animated:YES];
		[contentController addObserver:self forKeyPath:@"toolbarItems" options:NSKeyValueObservingOptionNew context:nil];
	}	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == _contentController) {
		[self setValue:[change objectForKey:NSKeyValueChangeNewKey] forKeyPath:keyPath];
	}
}


#pragma mark -
#pragma mark View events

- (void)viewWillAppear:(BOOL)animated {	
	if (_contentController) {
		// Ensure the content view is loaded before sending view event messages.
		UIView *contentView = _contentController.view;
		contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		if (contentView.superview != self.view) { 
			// Add the content view in the containing view if necessary.
			// Adjust the frame of the content view to fit in the containing view.
			contentView.frame = self.view.bounds;
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
	DLog(@"should rotate to: %d", interfaceOrientation);
    return [_contentController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	DLog(@"will rotate from %d to %d", self.interfaceOrientation, toInterfaceOrientation);
	[_contentController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	DLog(@"willAnimateRotationToInterfaceOrientation %d", interfaceOrientation);
	[_contentController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	DLog(@"did rotate from %d to %d", fromInterfaceOrientation, self.interfaceOrientation);
	[_contentController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}



@end
