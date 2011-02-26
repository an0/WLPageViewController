//
//  WLSplitViewController.m
//  WLContainerControllers
//
//  Created by Ling Wang on 12/1/10.
//  Copyright 2010 I Wonder Phone. All rights reserved.
//

#import "WLSplitViewController.h"


@interface WLSplitViewController ()

- (void)layoutViews:(NSArray *)viewControllers;
- (void)hideMasterViewController;
- (void)showMasterViewController;

@end



@implementation WLSplitViewController

@synthesize
viewControllers = _viewControllers,
splitPosition = _splitPosition,
gutterWidth = _gutterWidth,
showsSplitLine = _showsSplitLine,
hidesMasterViewInPortrait = _hidesMasterViewInPortrait,
delegate = _delegate;


- (void)_init {
	_splitPosition = 320.f;
	_gutterWidth = 1.f;
	_showsSplitLine = YES;
	_hidesMasterViewInPortrait = YES;
	
	_leftCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_left"]];	
	_rightCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_right"]];
	_topCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_top"]];
	_bottomCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_bottom"]];	
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self _init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[self _init];
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidUnload {
	DLog(@"viewDidUnload");
	[_poController release];
	_poController = nil;
	[_barButtonItem release];
	_barButtonItem = nil;
}

- (void)dealloc {
	[_viewControllers release];
	[_leftCorner release];
	[_rightCorner release];
	[_topCorner release];
	[_bottomCorner release];
	[_poController release];
	[_barButtonItem release];
	
    [super dealloc];
}




#pragma mark -
#pragma mark Content View management

- (void)setViewControllers:(NSArray *)viewControllers {
	if (_viewControllers != viewControllers) {
		UIViewController *oldMasterViewController = _masterViewController;
		UIViewController *oldDetailViewController = _detailViewController;

		_masterViewController = [viewControllers objectAtIndex:0];
		_detailViewController = [viewControllers objectAtIndex:1];
		
		if (_isViewDisplayed) {
			// Update the content views only if the containing view is displayed.
			if (!(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && _hidesMasterViewInPortrait)) {
				NSInteger index = [[self.view subviews] indexOfObject:oldMasterViewController.view];
				
				[oldMasterViewController viewWillDisappear:NO];
				[oldMasterViewController.view removeFromSuperview];
				[oldMasterViewController viewDidDisappear:NO];
				
				[_masterViewController viewWillAppear:NO];
				[self.view insertSubview:_masterViewController.view atIndex:index];
				[_masterViewController viewDidAppear:NO];
				
				[self updateNavigationBarFrom:_masterViewController];
				[self updateToolbarFrom:_masterViewController];
			} else {
				[self hideMasterViewController];
				
				if (_poController.popoverVisible) {
					[_poController dismissPopoverAnimated:NO];
				}
				
			}
			
			NSInteger index = [[self.view subviews] indexOfObject:oldDetailViewController.view];
			
			[oldDetailViewController viewWillDisappear:NO];
			[oldDetailViewController.view removeFromSuperview];
			[oldDetailViewController viewDidDisappear:NO];
			
			[_detailViewController viewWillAppear:NO];
			[self.view insertSubview:_detailViewController.view atIndex:index];
			[_detailViewController viewDidAppear:NO];
						
			[self layoutViews:viewControllers];
		}
		
		[_viewControllers release];
		_viewControllers = [viewControllers copy];
		
		// Set self as the parent view controller of content view controller.
//		if ([_masterViewController respondsToSelector:@selector(setParentViewController:)]) {
//			[_masterViewController performSelector:@selector(setParentViewController:) withObject:self];
//		}
//		if ([_detailViewController respondsToSelector:@selector(setParentViewController:)]) {
//			[_detailViewController performSelector:@selector(setParentViewController:) withObject:self];
//		}
		if ([_masterViewController respondsToSelector:@selector(setHostController:)]) {
			[_masterViewController performSelector:@selector(setHostController:) withObject:self];
		}
		if ([_detailViewController respondsToSelector:@selector(setHostController:)]) {
			[_detailViewController performSelector:@selector(setHostController:) withObject:self];
		}
		
		[_contentController release];
		_contentController = [_masterViewController retain];		
	}
}





#pragma mark -
#pragma mark View events

- (void)viewWillAppear:(BOOL)animated {
//	DLog(@"viewWillAppear");
	
	// Ensure the content views are loaded before sending view event messages.
	UIView *masterView = _masterViewController.view;
	UIView *detailView = _detailViewController.view;
	
	if (!(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && _hidesMasterViewInPortrait)) {
		[_masterViewController viewWillAppear:animated];
		if (masterView.superview != self.view) {
			[self.view addSubview:masterView];
			[self updateNavigationBarFrom:_masterViewController];
			[self updateToolbarFrom:_masterViewController];
		}
	} else {
		[self hideMasterViewController];
	}
	
	[_detailViewController viewWillAppear:animated];	
	if (detailView.superview != self.view) {
		[self.view addSubview:detailView];
	}
	
	[self layoutViews:_viewControllers];
	
	// Nullify self.contentController to avoid redundant calls.
	UIViewController *contentController = _contentController;
	_contentController = nil;
	[super viewWillAppear:animated];
	// Restore self.contentController.
	_contentController = contentController;
}

- (void)viewDidAppear:(BOOL)animated {
//	DLog(@"viewDidAppear");
	if (_masterViewController.view.superview == self.view) {
		[_masterViewController viewDidAppear:animated];
	}
	[_detailViewController viewDidAppear:animated];
	
	// Nullify self.contentController to avoid redundant calls.
	UIViewController *contentController = _contentController;
	_contentController = nil;
	[super viewDidAppear:animated];
	// Restore self.contentController.
	_contentController = contentController;	
}

- (void)viewWillDisappear:(BOOL)animated {
//	DLog(@"viewWillDisappear");
	if (_masterViewController.view.superview == self.view) {
		[_masterViewController viewWillDisappear:animated];
	}
	[_detailViewController viewWillDisappear:animated];
	
	// Nullify self.contentController to avoid redundant calls.
	UIViewController *contentController = _contentController;
	_contentController = nil;
	[super viewWillDisappear:animated];
	// Restore self.contentController.
	_contentController = contentController;
}

- (void)viewDidDisappear:(BOOL)animated {
//	DLog(@"viewDidDisappear");
	if (_masterViewController.view.superview == self.view) {
		[_masterViewController viewDidDisappear:animated];
	}
	[_detailViewController viewDidDisappear:animated];
	
	// Nullify self.contentController to avoid redundant calls.
	UIViewController *contentController = _contentController;
	_contentController = nil;
	[super viewDidDisappear:animated];
	// Restore self.contentController.
	_contentController = contentController;
}





#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (_masterViewController == nil ? YES : [_masterViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation]) && (_detailViewController == nil ? YES : [_detailViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation]);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	// Nullify self.contentController to avoid redundant calls.
	UIViewController *contentController = _contentController;
	_contentController = nil;
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	// Restore self.contentController.
	_contentController = contentController;
	
	UIView *masterView = _masterViewController.view;
	if (_hidesMasterViewInPortrait &&
		UIInterfaceOrientationIsLandscape(self.interfaceOrientation) &&
		UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
		// Hide master.
		[self hideMasterViewController];
		[_masterViewController viewWillDisappear:NO];
	}
	
	[_masterViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[_detailViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	if (_hidesMasterViewInPortrait &&
		UIInterfaceOrientationIsPortrait(self.interfaceOrientation) &&
		UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		// Show master.
		[self showMasterViewController];
		[_masterViewController viewWillAppear:NO];
		[self.view addSubview:masterView];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	// Nullify self.contentController to avoid redundant calls.
	UIViewController *contentController = _contentController;
	_contentController = nil;
	[super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
	// Restore self.contentController.
	_contentController = contentController;
	
	
	[_masterViewController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
	[_detailViewController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
	
	if (_poController.popoverVisible) {
		[_poController dismissPopoverAnimated:NO];
	}
	
	[self layoutViews:_viewControllers];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[_masterViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[_detailViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	UIView *masterView = _masterViewController.view;
	if (_hidesMasterViewInPortrait &&
		UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) &&
		UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		// Hide master.
		[masterView removeFromSuperview];
		[_masterViewController viewDidDisappear:NO];
	} else if (_hidesMasterViewInPortrait && 
			   UIInterfaceOrientationIsPortrait(fromInterfaceOrientation) &&
			   UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		// Show master.
		[_masterViewController viewDidAppear:NO];
	}
	
	// Nullify self.contentController to avoid redundant calls.
	UIViewController *contentController = _contentController;
	_contentController = nil;
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	// Restore self.contentController.
	_contentController = contentController;	
}




#pragma mark -
#pragma mark Layout views

- (void)layoutViews:(NSArray *)viewControllers {
	UIViewController *masterViewController = [viewControllers objectAtIndex:0];
	UIViewController *detailViewController = [viewControllers objectAtIndex:1];
	UIView *masterView = masterViewController.view;
	UIView *detailView = detailViewController.view;
	UIView *leadingCorner = nil;
	UIView *trailingCorner = nil;
	
	// Adjust the frame of the content view according to the insets.
	CGRect wholeFrame = UIEdgeInsetsInsetRect(self.view.bounds, self.contentInset);
	
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		[_topCorner removeFromSuperview];
		[_bottomCorner removeFromSuperview];		
		
		if (_hidesMasterViewInPortrait) {
			CGRect masterViewFrame = wholeFrame;
			masterViewFrame.origin.x = -(_splitPosition + _gutterWidth);
			masterViewFrame.size.width = _splitPosition;
			masterView.frame = masterViewFrame;
			masterView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
			
			CGRect detailViewFrame = wholeFrame;
			detailView.frame = detailViewFrame;
			detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;			
		} else {
			CGRect masterViewFrame = wholeFrame;
			masterViewFrame.size.height = _splitPosition;
			masterView.frame = masterViewFrame;
			masterView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
			
			if (_showsSplitLine) {				
				CGRect leftCornerFrame = _leftCorner.frame;
				leftCornerFrame.origin.x = wholeFrame.origin.x;
				leftCornerFrame.origin.y = masterViewFrame.origin.y + masterViewFrame.size.height + _gutterWidth / 2 - leftCornerFrame.size.height / 2;
				_leftCorner.frame = leftCornerFrame;
				_leftCorner.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
				leadingCorner = _leftCorner;
				
				CGRect rightCornerFrame = leftCornerFrame;
				rightCornerFrame.origin.x = wholeFrame.origin.x + wholeFrame.size.width - rightCornerFrame.size.width;
				_rightCorner.frame = rightCornerFrame;
				_rightCorner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
				trailingCorner = _rightCorner;
			}	
			
			CGRect detailViewFrame = wholeFrame;
			detailViewFrame.origin.y = masterViewFrame.origin.y + masterViewFrame.size.height + _gutterWidth;
			detailViewFrame.size.height = wholeFrame.origin.y + wholeFrame.size.height - detailViewFrame.origin.y;
			detailView.frame = detailViewFrame;
			detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;			
		} 		
	} else {
		[_leftCorner removeFromSuperview];
		[_rightCorner removeFromSuperview];
		
		CGRect masterViewFrame = wholeFrame;
		masterViewFrame.size.width = _splitPosition;
		masterView.frame = masterViewFrame;
		masterView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
		
		if (_showsSplitLine) {
			CGRect topCornerFrame = _topCorner.frame;
			topCornerFrame.origin.x = masterViewFrame.origin.x + masterViewFrame.size.width + _gutterWidth / 2 - topCornerFrame.size.width / 2;
			topCornerFrame.origin.y = wholeFrame.origin.y;
			_topCorner.frame = topCornerFrame;
			_topCorner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
			leadingCorner = _topCorner;
			
			CGRect bottomCornerFrame = topCornerFrame;
			bottomCornerFrame.origin.y = wholeFrame.origin.y + wholeFrame.size.height - bottomCornerFrame.size.height;
			_bottomCorner.frame = bottomCornerFrame;
			_bottomCorner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
			trailingCorner = _bottomCorner;
		}
		
		CGRect detailViewFrame = wholeFrame;
		detailViewFrame.origin.x = masterViewFrame.origin.x + masterViewFrame.size.width + _gutterWidth;
		detailViewFrame.size.width = wholeFrame.origin.x + wholeFrame.size.width - detailViewFrame.origin.x;
		detailView.frame = detailViewFrame;				
		detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
	}
	
	[self.view addSubview:leadingCorner];
	[self.view addSubview:trailingCorner];
}



#pragma mark -
#pragma mark Popover handling

- (void)hideMasterViewController {
	if (_poController == nil) {
		_poController = [[UIPopoverController alloc] initWithContentViewController:_masterViewController];
	} else {
		_poController.contentViewController = _masterViewController;
	}

	
	// Create and configure _barButtonItem.
	if (_barButtonItem == nil) {
		_barButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil 
														  style:UIBarButtonItemStyleBordered 
														 target:self 
														 action:@selector(toggleMasterPopover:)];		
	}
	
	// Inform delegate of this state of affairs.
	if (_delegate && [_delegate respondsToSelector:@selector(splitViewController:willHideViewController:withBarButtonItem:forPopoverController:)]) {
		[(id <WLSplitViewControllerDelegate>)_delegate splitViewController:self 
													willHideViewController:_masterViewController 
														 withBarButtonItem:_barButtonItem 
													  forPopoverController:_poController];
	}
}

- (void)showMasterViewController {
	// FIXME: I know this looks strange, but it fixes the bizarre crash. See bug 8816843 for detail.
	if (self.view.window) {
		[_poController presentPopoverFromRect:CGRectZero inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
	}

	if (_poController.popoverVisible) {
		[_poController dismissPopoverAnimated:NO];
	}
	
	// Inform delegate that the _barButtonItem will become invalid.
	if (_delegate && [_delegate respondsToSelector:@selector(splitViewController:willShowViewController:invalidatingBarButtonItem:)]) {
		[(id <WLSplitViewControllerDelegate>)_delegate splitViewController:self 
													willShowViewController:_masterViewController 
												 invalidatingBarButtonItem:_barButtonItem];
	}	
}



- (IBAction)toggleMasterPopover:(id)sender {
	if (_poController.popoverVisible) {
		// Inform delegate.
		if (_delegate && [_delegate respondsToSelector:@selector(splitViewController:popoverController:willDismissViewController:)]) {
			[(id <WLSplitViewControllerDelegate>)_delegate splitViewController:self 
															 popoverController:_poController 
													 willDismissViewController:_masterViewController];
		}		
		// Hide popover.
		[_poController dismissPopoverAnimated:YES];
	} else {
		// Inform delegate.
		if (_delegate && [_delegate respondsToSelector:@selector(splitViewController:popoverController:willPresentViewController:)]) {
			[(id <WLSplitViewControllerDelegate>)_delegate splitViewController:self 
															 popoverController:_poController 
													 willPresentViewController:_masterViewController];
		}
		// Show popover.
		[_poController presentPopoverFromBarButtonItem:_barButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}



@end
