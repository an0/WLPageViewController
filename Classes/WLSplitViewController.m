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

@end



@implementation WLSplitViewController

@synthesize
viewControllers = _viewControllers,
splitPoint = _splitPoint;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_splitPoint = 0.5;
		
		_leftCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_left"]];	
		_rightCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_right"]];
		_topCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_top"]];
		_bottomCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_bottom"]];
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blackColor];
}

- (void)dealloc {
	[_viewControllers release];
	[_leftCorner release];
	[_rightCorner release];
	[_topCorner release];
	[_bottomCorner release];
	
    [super dealloc];
}




#pragma mark -
#pragma mark Content View management

- (void)setViewControllers:(NSArray *)viewControllers {
	if (_viewControllers != viewControllers) {
		UIViewController *firstViewController = [viewControllers objectAtIndex:0];
		UIViewController *secondViewController = [viewControllers objectAtIndex:1];
		
		if ([self isViewLoaded]) {
			// Update the content views only if the containing view is loaded.	
			// Ensure the content views are loaded before sending view event messages.
			UIView *firstView = firstViewController.view;
			UIView *secondView = secondViewController.view;

			[_firstViewController viewWillDisappear:YES];
			[firstViewController viewWillAppear:YES];
			[_firstViewController.view removeFromSuperview];
			[self.view addSubview:firstView];
			[_firstViewController viewDidDisappear:YES];
			[firstViewController viewDidAppear:YES];
			
			[_secondViewController viewWillDisappear:YES];
			[secondViewController viewWillAppear:YES];
			[_secondViewController.view removeFromSuperview];
			[self.view addSubview:secondView];
			[_secondViewController viewDidDisappear:YES];
			[secondViewController viewDidAppear:YES];			
			
			[self layoutViews:viewControllers];

			[self updateNavigationBarFrom:firstViewController];
			[self updateToolbarFrom:firstViewController];			
		}		
		
		[_viewControllers release];
		_viewControllers = [viewControllers copy];
		_firstViewController = firstViewController;
		_secondViewController = secondViewController;
		// Set self as the parent view controller of content view controller.
		if ([_firstViewController respondsToSelector:@selector(setParentViewController:)]) {
			[_firstViewController setParentViewController:self];
		}
		if ([_secondViewController respondsToSelector:@selector(setParentViewController:)]) {
			[_secondViewController setParentViewController:self];
		}
		
		[_contentController release];
		_contentController = [firstViewController retain];
	}
}





#pragma mark -
#pragma mark View events

- (void)viewWillAppear:(BOOL)animated {	
	if (_viewControllers) {
		// Ensure the content views are loaded before sending view event messages.
		UIView *firstView = _firstViewController.view;
		UIView *secondView = _secondViewController.view;
		// Add the content views in the containing view if necessary.
		if (firstView.superview != self.view || secondView.superview != self.view) { 
			[self.view addSubview:firstView];
			[self.view addSubview:secondView];
			
			[self layoutViews:_viewControllers];

			[self updateNavigationBarFrom:_firstViewController];
			[self updateToolbarFrom:_firstViewController];
		}
		
		[_firstViewController viewWillAppear:animated];
		[_secondViewController viewWillAppear:animated];
	}
	
	// Nullify self.contentController to avoid redundant calls.
	UIViewController *contentController = _contentController;
	_contentController = nil;
	[super viewWillAppear:animated];
	// Restore self.contentController.
	_contentController = contentController;
}

- (void)viewDidAppear:(BOOL)animated {	
	[_firstViewController viewDidAppear:animated];
	[_secondViewController viewDidAppear:animated];
	
	// Nullify self.contentController to avoid redundant calls.
	UIViewController *contentController = _contentController;
	_contentController = nil;
	[super viewDidAppear:animated];
	// Restore self.contentController.
	_contentController = contentController;	
}

- (void)viewWillDisappear:(BOOL)animated {
	[_firstViewController viewWillDisappear:animated];
	[_secondViewController viewWillDisappear:animated];
	
	// Nullify self.contentController to avoid redundant calls.
	UIViewController *contentController = _contentController;
	_contentController = nil;
	[super viewWillDisappear:animated];
	// Restore self.contentController.
	_contentController = contentController;
}

- (void)viewDidDisappear:(BOOL)animated {
	[_firstViewController viewDidDisappear:animated];
	[_secondViewController viewDidDisappear:animated];
	
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
    return [_firstViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation] && [_secondViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[_firstViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[_secondViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	[_firstViewController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
	[_secondViewController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
	[self layoutViews:_viewControllers];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[_firstViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[_secondViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}




#pragma mark -
#pragma mark Layout views

- (void)layoutViews:(NSArray *)viewControllers {
	UIViewController *firstViewController = [viewControllers objectAtIndex:0];
	UIViewController *secondViewController = [viewControllers objectAtIndex:1];
	UIView *firstView = firstViewController.view;
	UIView *secondView = secondViewController.view;

	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		[_topCorner removeFromSuperview];
		[_bottomCorner removeFromSuperview];		
		
		// Adjust the frame of the content view according to the insets.
		CGRect wholeFrame = UIEdgeInsetsInsetRect(self.view.bounds, self.contentInset);
		
		CGRect firstViewFrame = wholeFrame;
		firstViewFrame.size.height = round((wholeFrame.size.height * _splitPoint));
		firstView.frame = firstViewFrame;
		firstView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
				
		CGRect leftCornerFrame = _leftCorner.frame;
		leftCornerFrame.origin.x = wholeFrame.origin.x;
		leftCornerFrame.origin.y = firstViewFrame.origin.y + firstViewFrame.size.height + 1.f - leftCornerFrame.size.height / 2;
		_leftCorner.frame = leftCornerFrame;
		_leftCorner.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self.view addSubview:_leftCorner];
		
		CGRect rightCornerFrame = leftCornerFrame;
		rightCornerFrame.origin.x = wholeFrame.origin.x + wholeFrame.size.width - rightCornerFrame.size.width;
		_rightCorner.frame = rightCornerFrame;
		_rightCorner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self.view addSubview:_rightCorner];
		
		CGRect secondViewFrame = wholeFrame;
		secondViewFrame.origin.y = firstViewFrame.origin.y + firstViewFrame.size.height + 1.f;
		secondViewFrame.size.height = wholeFrame.origin.y + wholeFrame.size.height - secondViewFrame.origin.y;
		secondView.frame = secondViewFrame;
		secondView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
	} else {
		[_leftCorner removeFromSuperview];
		[_rightCorner removeFromSuperview];
		
		// Adjust the frame of the content view according to the insets.
		CGRect wholeFrame = UIEdgeInsetsInsetRect(self.view.bounds, self.contentInset);
		
		CGRect firstViewFrame = wholeFrame;
		firstViewFrame.size.width = round((wholeFrame.size.width * _splitPoint));
		firstView.frame = firstViewFrame;
		firstView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;

		CGRect topCornerFrame = _topCorner.frame;
		topCornerFrame.origin.x = firstViewFrame.origin.x + firstViewFrame.size.width + 1.f - topCornerFrame.size.width / 2;
		topCornerFrame.origin.y = wholeFrame.origin.y;
		_topCorner.frame = topCornerFrame;
		_topCorner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self.view addSubview:_topCorner];
		
		CGRect bottomCornerFrame = topCornerFrame;
		bottomCornerFrame.origin.y = wholeFrame.origin.y + wholeFrame.size.height - bottomCornerFrame.size.height;
		_bottomCorner.frame = bottomCornerFrame;
		_bottomCorner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
		[self.view addSubview:_bottomCorner];
		
		CGRect secondViewFrame = wholeFrame;
		secondViewFrame.origin.x = firstViewFrame.origin.x + firstViewFrame.size.width + 1.f;
		secondViewFrame.size.width = wholeFrame.origin.x + wholeFrame.size.width - secondViewFrame.origin.x;
		secondView.frame = secondViewFrame;				
		secondView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
	}
}




@end
