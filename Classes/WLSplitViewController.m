//
//  WLSplitViewController.m
//  WLContainerControllers
//
//  Created by Ling Wang on 12/1/10.
//  Copyright 2010 I Wonder Phone. All rights reserved.
//

#import "WLSplitViewController.h"


@interface WLSplitViewController ()

- (void)hideMasterViewController;
- (void)showMasterViewController;
- (void)setBackgroundForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end



@implementation WLSplitViewController

@synthesize
viewControllers = _viewControllers,
splitPosition = _splitPosition,
gutterWidth = _gutterWidth,
showsSplitLine = _showsSplitLine,
hidesMasterViewInPortrait = _hidesMasterViewInPortrait,
delegate = _delegate;


static void init(WLSplitViewController *self) {
	self->_splitPosition = 320.f;
	self->_gutterWidth = 1.f;
	self->_showsSplitLine = YES;
	self->_hidesMasterViewInPortrait = YES;
	
	self->_leftCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_left"]];	
	self->_rightCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_right"]];
	self->_topCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_top"]];
	self->_bottomCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_bottom"]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		init(self);
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		init(self);
	}
	
	return self;
}



#pragma mark - Content View management

- (void)setViewControllers:(NSArray *)viewControllers {
	if ([_viewControllers isEqualToArray:viewControllers]) return;
	if ([viewControllers count] != 2) return;

	UIViewController *oldMasterViewController = _masterViewController;
	UIViewController *oldDetailViewController = _detailViewController;

	_masterViewController = [viewControllers objectAtIndex:0];
	_detailViewController = [viewControllers objectAtIndex:1];

	if (oldMasterViewController.parentViewController) {
		[oldMasterViewController willMoveToParentViewController:nil];
	}
	[self addChildViewController:_masterViewController];
	[oldDetailViewController willMoveToParentViewController:nil];
	[self addChildViewController:_detailViewController];

	[_detailViewController didMoveToParentViewController:self];
	[oldDetailViewController removeFromParentViewController];
	[_masterViewController didMoveToParentViewController:self];
	if (oldMasterViewController.parentViewController) {
		[oldMasterViewController removeFromParentViewController];
	}

	if (self.isViewLoaded) {
		[oldDetailViewController.view removeFromSuperview];
		[self.view addSubview:_detailViewController.view];

		if (!(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && _hidesMasterViewInPortrait)) {
			[oldMasterViewController.view removeFromSuperview];
			[self showMasterViewController];
		} else {
			[self hideMasterViewController];
		}
	}

	[self updateNavigationBarFrom:_masterViewController];
	[self updateToolbarFrom:_masterViewController];

	_viewControllers = [viewControllers copy];
	_contentController = _masterViewController;
}





#pragma mark - View events

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blackColor];
	self.backgroundView = [UIImageView new];

	if (!_viewControllers) return;

	[self.view addSubview:_detailViewController.view];
	if (_hidesMasterViewInPortrait &&
		UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		if (_masterViewController.view.superview == self.view) {
			[self hideMasterViewController];
			[_masterViewController.view removeFromSuperview];
		}
	} else {
		_isMasterViewShown = YES;
	}
}

- (void)didReceiveMemoryWarning {
	if (self.isViewLoaded && self.view.window == nil) {
		_poController = nil;
		_barButtonItem = nil;
	}
	[super didReceiveMemoryWarning];
}




#pragma mark - Rotation support

- (NSUInteger)supportedInterfaceOrientations {
    return (_masterViewController == nil ? UIInterfaceOrientationMaskAll : _masterViewController.supportedInterfaceOrientations) & (_detailViewController == nil ? UIInterfaceOrientationMaskAll : _detailViewController.supportedInterfaceOrientations);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (_hidesMasterViewInPortrait) {
		if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) &&
			UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
			[self showMasterViewController];
			if (_poController.popoverVisible) {
				[_poController dismissPopoverAnimated:NO];
			}
		} else if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) &&
				   UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
			[self hideMasterViewController];
		}
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	if (_hidesMasterViewInPortrait &&
		UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) &&
		UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		double delayInSeconds = 0.f;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[_masterViewController.view removeFromSuperview];
		});
	}
}

- (void)setBackgroundForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
		((UIImageView *)self.backgroundView).image = _portraitBackgroundImage;
	} else {
		((UIImageView *)self.backgroundView).image = _landscapeBackgroundImage;
	}
}


#pragma mark - State Preservation and Restoration

#define kStateKeyChildViewControllers @"child_view_controllers"
#define kStateKeyShowsSplitLine @"shows_split_line"
#define kStateKeySplitPosition @"split_position"
#define kStateKeyGutterWidth @"gutter_width"
#define kStateKeyHidesMasterViewInPortrait @"hides_master_view_in_portrait"

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
	WLSplitViewController *viewController = [[self alloc] init];
	viewController.restorationIdentifier = [identifierComponents lastObject];
	viewController.restorationClass = [self class];
	return viewController;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
	[super encodeRestorableStateWithCoder:coder];

	[coder encodeBool:_showsSplitLine forKey:kStateKeyShowsSplitLine];
	[coder encodeFloat:_splitPosition forKey:kStateKeySplitPosition];
	[coder encodeFloat:_gutterWidth forKey:kStateKeyGutterWidth];
	[coder encodeBool:_hidesMasterViewInPortrait forKey:kStateKeyHidesMasterViewInPortrait];
	[coder encodeObject:self.viewControllers forKey:kStateKeyChildViewControllers];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
	[super decodeRestorableStateWithCoder:coder];

	self.showsSplitLine = [coder decodeBoolForKey:kStateKeyShowsSplitLine];
	self.splitPosition = [coder decodeFloatForKey:kStateKeySplitPosition];
	self.gutterWidth = [coder decodeFloatForKey:kStateKeyGutterWidth];
	self.hidesMasterViewInPortrait = [coder decodeBoolForKey:kStateKeyHidesMasterViewInPortrait];
	self.viewControllers = [coder decodeObjectForKey:kStateKeyChildViewControllers];
}



#pragma mark - Layout views

- (void)viewDidLayoutSubviews {
	UIView *masterView = _masterViewController.view;
	UIView *detailView = _detailViewController.view;
	UIView *leadingCorner = nil;
	UIView *trailingCorner = nil;

	[self setBackgroundForInterfaceOrientation:self.interfaceOrientation];

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



#pragma mark - Popover handling

- (void)hideMasterViewController {
	// Remove _masterViewController from parent before setting it as content view controller of popover controller because the view hierarchy checking will throw exception if content view controller is not root view controller.
	[_masterViewController willMoveToParentViewController:nil];
	[_masterViewController removeFromParentViewController];
	if (_poController == nil) {
		_poController = [[UIPopoverController alloc] initWithContentViewController:_masterViewController];
	} else {
		_poController.contentViewController = _masterViewController;
	}
	// Add it back.
	[self addChildViewController:_masterViewController];
	[_masterViewController didMoveToParentViewController:self];
	
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
	
	_isMasterViewShown = NO;
}

- (void)showMasterViewController {
	// Inform delegate that the _barButtonItem will become invalid.
	if (_delegate && [_delegate respondsToSelector:@selector(splitViewController:willShowViewController:invalidatingBarButtonItem:)]) {
		[(id <WLSplitViewControllerDelegate>)_delegate splitViewController:self
													willShowViewController:_masterViewController
												 invalidatingBarButtonItem:_barButtonItem];
	}

	if (_poController.popoverVisible) {
		[_poController dismissPopoverAnimated:NO];
	}

	if (_masterViewController.view != self.view) {
		[self.view addSubview:_masterViewController.view];
	}

	_isMasterViewShown = YES;
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
