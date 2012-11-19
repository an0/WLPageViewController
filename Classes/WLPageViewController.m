//
//  WLPageViewController.m
//  WLPageViewController
//
//  Created by Ling Wang on 7/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WLPageViewController.h"


#define kPagingAnimationDuration 0.3

@interface WLPageViewController () {
@private
	UITapGestureRecognizer *_tapGestureRecognizer;
	UIViewController *_nextViewController;
	UIViewController *_previousViewController;
	UIView *_frontTitleView;
	UIView *_backTitleView;
}
- (UIViewController *)loadPreviousPage;
- (UIViewController *)loadNextPage;
- (void)unloadInvisiblePages;
- (IBAction)pan:(UIPanGestureRecognizer *)gestureRecognizer;
- (IBAction)turnPage:(UITapGestureRecognizer *)gestureRecognizer;
- (UIView *)setupSubTitleViewWith:(UIViewController *)viewController;
- (void)updateBackTitleViewWith:(UIViewController *)viewController;
- (void)switchTitleViews;
- (void)pagingDidEnd;
@end




@implementation WLPageViewController

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize enableTapPageTurning = _enableTapPageTurning;
@synthesize titleTextAttributes = _titleTextAttributes;


- (id)initWithViewController:(UIViewController *)viewController {
	self = [super init];
	if (self) {
		self.contentController = viewController;
	}
	return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Pan gesture recognizer.
	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
	[self.view addGestureRecognizer:panGestureRecognizer];
	
	// Tap gesture recognizer.
	_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(turnPage:)];
	_tapGestureRecognizer.enabled = _enableTapPageTurning;
	[self.view addGestureRecognizer:_tapGestureRecognizer];	
	
	// Init navigation bar title view.
	self.navigationItem.titleView = [[UIView alloc] init];
	[_frontTitleView removeFromSuperview];
	_frontTitleView = [self setupSubTitleViewWith:_contentController];
	self.navigationItem.titleView.bounds = _frontTitleView.frame;
	[self.navigationItem.titleView addSubview:_frontTitleView];
}

- (void)didReceiveMemoryWarning {
	if (self.isViewLoaded && self.view.window == nil) {
		_frontTitleView = nil;
		_backTitleView = nil;
	}
	[super didReceiveMemoryWarning];
}


#pragma mark - Providing Content

- (void)setContentController:(UIViewController *)contentController {
	if (_contentController == contentController) return;

	if (self.isViewLoaded) {
		[self updateNavigationBarFrom:contentController];
		[self updateToolbarFrom:contentController];
	}

	[self addChildViewController:contentController];
	if (self.isViewLoaded) {
		if (contentController.view.superview != self.view) {
			[self.view addSubview:contentController.view];
		}
		[self unloadInvisiblePages];
	}
	[contentController didMoveToParentViewController:self];	
	
	_contentController = contentController;
}

- (UIViewController *)loadPreviousPage {
	UIViewController *previousViewController = [_dataSource pageViewController:self viewControllerBeforeViewController:_contentController];
	if (previousViewController == nil) return nil;
	
	BOOL isNewlyAdded = ![self.childViewControllers containsObject:previousViewController];
	if (isNewlyAdded) {
		[self addChildViewController:previousViewController];
	}
	CGRect previousFrame = _contentController.view.frame;
	previousFrame.origin.x -= previousFrame.size.width;
	previousViewController.view.frame = previousFrame;
	[self.view addSubview:previousViewController.view];
	if (isNewlyAdded) {
		[previousViewController didMoveToParentViewController:self];
	}
	
	[self updateBackTitleViewWith:previousViewController];
	
	return previousViewController;
}

- (UIViewController *)loadNextPage {
	UIViewController *nextViewController = [_dataSource pageViewController:self viewControllerAfterViewController:_contentController];
	if (nextViewController == nil) return nil;
	
	BOOL isNewlyAdded = ![self.childViewControllers containsObject:nextViewController];
	if (isNewlyAdded) {
		[self addChildViewController:nextViewController];
	}
	CGRect nextFrame = _contentController.view.frame;
	nextFrame.origin.x += nextFrame.size.width;
	nextViewController.view.frame = nextFrame;
	[self.view addSubview:nextViewController.view];
	if (isNewlyAdded) {
		[nextViewController didMoveToParentViewController:self];
	}
	
	[self updateBackTitleViewWith:nextViewController];
	
	return nextViewController;
}

- (void)unloadInvisiblePages {
	CGRect bounds = self.view.bounds;
	NSMutableArray *vcToUnload = [NSMutableArray arrayWithCapacity:self.childViewControllers.count];
	for (UIViewController *vc in self.childViewControllers) {
		UIView *v = vc.view;
		if (!CGRectIntersectsRect(bounds, v.frame)) {
			[vcToUnload addObject:vc];
		}
	}
	for (UIViewController *vc in vcToUnload) {
		if (vc == _previousViewController) {
			_previousViewController = nil;
		} else if (vc == _nextViewController) {
			_nextViewController = nil;
		}
		UIView *v = vc.view;
		[vc willMoveToParentViewController:nil];
		[v removeFromSuperview];
		[vc removeFromParentViewController];
	}
}


#pragma mark - Configuration

- (void)setEnableTapPageTurning:(BOOL)enableTapPageTurning {
	_enableTapPageTurning = enableTapPageTurning;
	_tapGestureRecognizer.enabled = _enableTapPageTurning;
}


#pragma mark - Navigation bar and toolbar configuration

- (UIView *)setupSubTitleViewWith:(UIViewController *)viewController {
	UIView *subTitleView = nil;
	CGRect titleViewBounds = self.navigationItem.titleView.bounds;
	if (viewController.navigationItem.titleView) {
		subTitleView = viewController.navigationItem.titleView;
		subTitleView.frame = titleViewBounds;
	} else {
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleViewBounds];
		UIFont *font = [_titleTextAttributes objectForKey:UITextAttributeFont];
		if (!font) font = [UIFont boldSystemFontOfSize:20];
		titleLabel.font = font;
		UIColor *textColor = [_titleTextAttributes objectForKey:UITextAttributeTextColor];
		if (!textColor) textColor = [UIColor whiteColor];
		titleLabel.textColor = textColor;
		UIColor *shadowColor= [_titleTextAttributes objectForKey:UITextAttributeTextShadowColor];
		if (shadowColor) titleLabel.shadowColor = shadowColor;
		NSValue *shadowOffset = [_titleTextAttributes objectForKey:UITextAttributeTextShadowOffset];
		if (shadowOffset) titleLabel.shadowOffset = [shadowOffset CGSizeValue];
		titleLabel.text = viewController.navigationItem.title;
		titleLabel.textAlignment = UITextAlignmentCenter;
		titleLabel.backgroundColor = [UIColor clearColor];
		subTitleView = titleLabel;
	}
	[subTitleView sizeToFit];
	return subTitleView;
}

- (void)updateBackTitleViewWith:(UIViewController *)viewController {
	[_backTitleView removeFromSuperview];
	_backTitleView = [self setupSubTitleViewWith:viewController];
	// Center title view.
	_backTitleView.center = _frontTitleView.center;
	[self.navigationItem.titleView addSubview:_backTitleView];
}

- (void)switchTitleViews {
	UIView *tempTitleView =  _frontTitleView;
	_frontTitleView = _backTitleView;
	_frontTitleView.alpha = 1;
	_backTitleView = tempTitleView;
	_backTitleView.alpha = 0;
	self.navigationItem.titleView.bounds = _frontTitleView.frame;
}



#pragma mark - Paging

- (void)pagingDidEnd
{	
	UIViewController *oldContentController = _contentController;
	CGPoint center = _contentController.view.center;
	CGRect bounds = self.view.bounds;
	if (center.x > CGRectGetMaxX(bounds) && _previousViewController != nil) { // Land in the previous page.
		_nextViewController = _contentController;
		self.contentController = _previousViewController;
		_previousViewController = nil;
		[self switchTitleViews];
	} else if (center.x < CGRectGetMinX(bounds) && _nextViewController != nil) { // Land in the next page.
		_previousViewController = _contentController;
		self.contentController = _nextViewController;
		_nextViewController = nil;
		[self switchTitleViews];
	}

	_isTransitioningContentView = NO;

	if ([_delegate respondsToSelector:@selector(pageViewController:didEndPagingViewController:)]) {
		[_delegate pageViewController:self didEndPagingViewController:oldContentController];
	}
}



#pragma mark Gesture handling

- (IBAction)pan:(UIPanGestureRecognizer *)gestureRecognizer {
	_isTransitioningContentView = YES;

	CGPoint translation = [gestureRecognizer translationInView:self.view];
	CGRect bounds = self.view.bounds;
	CGPoint boundsCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
	CGPoint center = _contentController.view.center;
	center.x += translation.x;
	CGFloat pageWidth = bounds.size.width;
	CGFloat pageOffset = center.x - boundsCenter.x;

	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		if ([_delegate respondsToSelector:@selector(pageViewController:willBeginPagingViewController:)]) {
			[_delegate pageViewController:self willBeginPagingViewController:_contentController];
		}
	} else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
		if (center.x < boundsCenter.x) {
			if (_nextViewController == nil) {
				_nextViewController = [self loadNextPage];
			}
			// Title transition.
			if (_nextViewController) {
				_frontTitleView.alpha = 1 - fabsf(pageOffset) / pageWidth;
				_backTitleView.alpha = 1 - _frontTitleView.alpha;
			}
		} else if (center.x > boundsCenter.x) {
			if (_previousViewController == nil) {
				_previousViewController = [self loadPreviousPage];
			}
			// Title transition.
			if (_previousViewController) {
				_frontTitleView.alpha = 1 - fabsf(pageOffset) / pageWidth;
				_backTitleView.alpha = 1 - _frontTitleView.alpha;
			}
		}
		
		// Move views.
		_contentController.view.center = center;
		CGPoint previousViewCenter = _previousViewController ? _previousViewController.view.center : CGPointZero;
		previousViewCenter.x += translation.x;
		_previousViewController.view.center = previousViewCenter;
		CGPoint nextViewCenter = _nextViewController ? _nextViewController.view.center : CGPointZero;
		nextViewCenter.x += translation.x;
		_nextViewController.view.center = nextViewCenter;

		// Reset translation: I'm use incremental translation not accumulative translation.
		[gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
	} else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
		// Elastic paging and bouncing. Simulate a simple harmonic motion of a spring.
		static const CGFloat k = 3000; // spring constant
		static const CGFloat m = 100; // mass
		CGPoint velocity = [gestureRecognizer velocityInView:self.view];
		/* Law of conservation of energy:
		 * 0.5 k x^2 = 0.5 k x0^2 + 0.5 m v^2
		 */
		CGFloat endPageOffset = copysignf(sqrtf(pageOffset * pageOffset + m / k * velocity.x * velocity.x), pageOffset);
//		NSLog(@"v(%f), x0(%f), x(%f)", velocity.x, pageOffset, endPageOffset);
		static const CGFloat kTimeTuneFactor = 4000;
		
		if (_previousViewController != nil && endPageOffset >= 0.5 * pageWidth) {
			// Turn to previous page.
			CGPoint previousViewCenter = _previousViewController.view.center;
			CGPoint nextViewCenter = _nextViewController ? _nextViewController.view.center : CGPointZero;
			CGPoint pagingTranslation = CGPointMake(boundsCenter.x - previousViewCenter.x, boundsCenter.y - previousViewCenter.y);
			CGPoint newCenter = CGPointMake(center.x + pagingTranslation.x, center.y + pagingTranslation.y);
			CGPoint newNextViewCenter = CGPointMake(nextViewCenter.x + pagingTranslation.x, nextViewCenter.y + pagingTranslation.y);
			[UIView animateWithDuration:kTimeTuneFactor / (fabsf(velocity.x) + kTimeTuneFactor) * kPagingAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionTransitionNone animations:^(void) {
				_contentController.view.center = newCenter;
				_previousViewController.view.center = boundsCenter;
				_nextViewController.view.center = newNextViewCenter;
				_frontTitleView.alpha = 0;
				_backTitleView.alpha = 1;
			} completion:^(BOOL finished) {
				[self pagingDidEnd];
			}];
		} else if (_nextViewController != nil && endPageOffset <= -0.5 * pageWidth) {
			// Turn to next page.
			CGPoint previousViewCenter = _previousViewController ? _previousViewController.view.center : CGPointZero;
			CGPoint nextViewCenter = _nextViewController.view.center;
			CGPoint pagingTranslation = CGPointMake(boundsCenter.x - nextViewCenter.x, boundsCenter.y - nextViewCenter.y);
			CGPoint newCenter = CGPointMake(center.x + pagingTranslation.x, center.y + pagingTranslation.y);
			CGPoint newPreviousViewCenter = CGPointMake(previousViewCenter.x + pagingTranslation.x, previousViewCenter.y + pagingTranslation.y);			
			[UIView animateWithDuration:kTimeTuneFactor / (fabsf(velocity.x) + kTimeTuneFactor) * kPagingAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionTransitionNone animations:^(void) {
				_contentController.view.center = newCenter;
				_previousViewController.view.center = newPreviousViewCenter;
				_nextViewController.view.center = boundsCenter;
				_frontTitleView.alpha = 0;
				_backTitleView.alpha = 1;
			} completion:^(BOOL finished) {
				[self pagingDidEnd];
			}];
		} else {
			// Bounce back to restore current page.
			__block CGPoint previousViewCenter = _previousViewController ?  _previousViewController.view.center : CGPointZero;
			__block CGPoint nextViewCenter = _nextViewController ? _nextViewController.view.center : CGPointZero;
			// Phase 1: continue with deceleration.
			CGFloat restOffset = endPageOffset - pageOffset;
			// Add a damping.
			restOffset /= M_E * M_E;
			endPageOffset = pageOffset + restOffset;
//			NSLog(@"end offset: %f", endPageOffset);
			previousViewCenter.x += restOffset;
			nextViewCenter.x += restOffset;
			center.x += restOffset;
			[UIView animateWithDuration:fabsf(restOffset) / (fabsf(restOffset) + fabsf(endPageOffset)) * kPagingAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionTransitionNone animations:^(void) {
				_contentController.view.center = center;
				_previousViewController.view.center = previousViewCenter;
				_nextViewController.view.center = nextViewCenter;
			} completion:^(BOOL finished) {
				// Phase 2: bounce with acceleration.
				CGPoint bounceTranslation = CGPointMake(boundsCenter.x - center.x, boundsCenter.y - center.y);
				previousViewCenter.x += bounceTranslation.x;
				nextViewCenter.x += bounceTranslation.x;
				[UIView animateWithDuration:fabsf(endPageOffset) / (fabsf(restOffset) + fabsf(endPageOffset)) * kPagingAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone animations:^(void) {
					_contentController.view.center = boundsCenter;
					_previousViewController.view.center = previousViewCenter;
					_nextViewController.view.center = nextViewCenter;
					_frontTitleView.alpha = 1;
					_backTitleView.alpha = 0;
				} completion:^(BOOL finished) {
					[self pagingDidEnd];
				}];	
			}];	
		}
	}
}

- (IBAction)turnPage:(UITapGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer.state != UIGestureRecognizerStateRecognized) return;

	_isTransitioningContentView = YES;
		
	if ([_delegate respondsToSelector:@selector(pageViewController:willBeginPagingViewController:)]) {
		[_delegate pageViewController:self willBeginPagingViewController:_contentController];
	}

	UIView *view = gestureRecognizer.view;
	CGPoint location = [gestureRecognizer locationInView:view];
	
	static const CGFloat TAP_MARGIN = 40.0;
	
	// Tap on left margin, turn backward.
	if (location.x < CGRectGetMinX(view.bounds) + TAP_MARGIN) {
		_previousViewController = [self loadPreviousPage];
		if (_previousViewController) {
			CGPoint center = _contentController.view.center;
			CGPoint previousViewCenter = _previousViewController.view.center;
			CGPoint translation = CGPointMake(center.x - previousViewCenter.x, center.y - previousViewCenter.y);
			CGPoint newCenter = CGPointMake(center.x + translation.x, center.y + translation.y);
			[UIView animateWithDuration:kPagingAnimationDuration animations:^(void) {
				_contentController.view.center = newCenter;
				_previousViewController.view.center = center;
				_frontTitleView.alpha = 0;
				_backTitleView.alpha = 1;
			} completion:^(BOOL finished) {
				if (finished) {
					[self pagingDidEnd];
				}
			}];
		}
	}
	// Tap on right margin, turn forward.
	else if (location.x > CGRectGetMaxX(view.bounds) - TAP_MARGIN) {
		_nextViewController = [self loadNextPage];;
		if (_nextViewController) {
			CGPoint center = _contentController.view.center;
			CGPoint nextViewCenter = _nextViewController.view.center;
			CGPoint translation = CGPointMake(center.x - nextViewCenter.x, center.y - nextViewCenter.y);
			CGPoint newCenter = CGPointMake(center.x + translation.x, center.y + translation.y);
			[UIView animateWithDuration:kPagingAnimationDuration animations:^(void) {
				_contentController.view.center = newCenter;
				_nextViewController.view.center = center;
				_frontTitleView.alpha = 0;
				_backTitleView.alpha = 1;
			} completion:^(BOOL finished) {
				if (finished) {
					[self pagingDidEnd];
				}
			}];
		}
	}
}


@end
