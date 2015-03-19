//  Created by Ling Wang on 7/8/11.
//  Copyright 2011 I Wonder Phone. All rights reserved.

#import "WLPageViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kPagingAnimationDuration 0.4

@interface WLPageViewController () <UIGestureRecognizerDelegate> {
    UIPanGestureRecognizer *_panGR;
	UITapGestureRecognizer *_tapGR;
	UIViewController *_nextViewController;
	UIViewController *_previousViewController;
	UIViewController *_nnextViewController;
	UIViewController *_ppreviousViewController;
	UIView *_titleView;
	UIView *_previousTitleView;
	UIView *_nextTitleView;
	UIView *_ppreviousTitleView;
	UIView *_nnextTitleView;
	BOOL _arePagingAnimationsCancelled;
	NSUInteger _pagingAnimationCount;
}
@end

@implementation WLPageViewController

- (id)initWithViewController:(UIViewController *)viewController {
	return [self initWithViewController:viewController pageSpacing:0];
}

- (id)initWithViewController:(UIViewController *)viewController pageSpacing:(CGFloat)pageSpacing {
    self = [super init];
	if (self) {
		self.contentController = viewController;
        _pageSpacing = pageSpacing;
	}
	return self;
}

- (void)dealloc {
    _panGR.delegate = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Pan gesture recognizer.
	_panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    _panGR.delegate = self;
	[self.view addGestureRecognizer:_panGR];
	
	// Tap gesture recognizer.
	_tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(turnPage:)];
	_tapGR.enabled = _enableTapPageTurning;
	[self.view addGestureRecognizer:_tapGR];	
	
	// Init navigation bar title view.
	self.navigationItem.titleView = [UIView new];
	_titleView = [self setupSubTitleViewWith:_contentController];
	self.navigationItem.titleView.bounds = _titleView.bounds;
	[self.navigationItem.titleView addSubview:_titleView];
}

- (void)didReceiveMemoryWarning {
	[self unloadInvisiblePages];
	[super didReceiveMemoryWarning];
}

#pragma mark - Providing Content

- (void)setContentController:(UIViewController *)contentController {
	if (_contentController == contentController) return;

	[self unregisterKVOForNavigationBar];
	[self unregisterKVOForToolbar];

	[self addChildViewController:contentController];
	if (self.isViewLoaded) {
		if (contentController.view.superview != self.view) {
			[self.view addSubview:contentController.view];
		}
	}
	[contentController didMoveToParentViewController:self];

	_contentController = contentController;
    
    if (self.isViewLoaded) {
        [self updateNavigationBar];
        [self updateToolbar];
    }

	if (self.isViewLoaded) {
		// !!!: Unloading invisible pages is not only for saving memory but is also necessary for scroll-to-top of content scroll view to work because if there are more than one sub scroll views tapping on status bar does not trigger scroll-to-top.
		[self unloadInvisiblePages];
	}
}

- (UIViewController *)loadPreviousPage {
	UIViewController *previousViewController = [_dataSource pageViewController:self viewControllerBeforeViewController:_contentController];
	if (previousViewController == nil) return nil;
	
	BOOL isNewlyAdded = ![self.childViewControllers containsObject:previousViewController];
	if (isNewlyAdded) {
		[self addChildViewController:previousViewController];
	}
	CGRect previousFrame = _contentController.view.frame;
	previousFrame.origin.x -= _pageSpacing + self.view.bounds.size.width;
	previousViewController.view.frame = previousFrame;
	[self.view addSubview:previousViewController.view];
	if (isNewlyAdded) {
		[previousViewController didMoveToParentViewController:self];
	}

	[_previousTitleView removeFromSuperview];
	_previousTitleView = [self setupSubTitleViewWith:previousViewController];
	// Center title view.
	_previousTitleView.center = _titleView.center;
	[self.navigationItem.titleView addSubview:_previousTitleView];

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
	nextFrame.origin.x += _pageSpacing + self.view.bounds.size.width;
	nextViewController.view.frame = nextFrame;
	[self.view addSubview:nextViewController.view];
	if (isNewlyAdded) {
		[nextViewController didMoveToParentViewController:self];
	}
	
	[_nextTitleView removeFromSuperview];
	_nextTitleView = [self setupSubTitleViewWith:nextViewController];
	// Center title view.
	_nextTitleView.center = _titleView.center;
	[self.navigationItem.titleView addSubview:_nextTitleView];

	return nextViewController;
}

- (UIViewController *)loadPPreviousPage {
	UIViewController *ppreviousViewController = [_dataSource pageViewController:self viewControllerBeforeViewController:_previousViewController];
	if (ppreviousViewController == nil) return nil;

	BOOL isNewlyAdded = ![self.childViewControllers containsObject:ppreviousViewController];
	if (isNewlyAdded) {
		[self addChildViewController:ppreviousViewController];
	}
	CGRect previousFrame = _previousViewController.view.frame;
	previousFrame.origin.x -= _pageSpacing + self.view.bounds.size.width;
	ppreviousViewController.view.frame = previousFrame;
	[self.view addSubview:ppreviousViewController.view];
	if (isNewlyAdded) {
		[ppreviousViewController didMoveToParentViewController:self];
	}

	[_ppreviousTitleView removeFromSuperview];
	_ppreviousTitleView = [self setupSubTitleViewWith:ppreviousViewController];
	// Center title view.
	_ppreviousTitleView.center = _titleView.center;
	[self.navigationItem.titleView addSubview:_ppreviousTitleView];

	return ppreviousViewController;
}

- (UIViewController *)loadNNextPage {
	UIViewController *nnextViewController = [_dataSource pageViewController:self viewControllerAfterViewController:_nextViewController];
	if (nnextViewController == nil) return nil;

	BOOL isNewlyAdded = ![self.childViewControllers containsObject:nnextViewController];
	if (isNewlyAdded) {
		[self addChildViewController:nnextViewController];
	}
	CGRect nextFrame = _nextViewController.view.frame;
	nextFrame.origin.x += _pageSpacing + self.view.bounds.size.width;
	nnextViewController.view.frame = nextFrame;
	[self.view addSubview:nnextViewController.view];
	if (isNewlyAdded) {
		[nnextViewController didMoveToParentViewController:self];
	}

	[_nnextTitleView removeFromSuperview];
	_nnextTitleView = [self setupSubTitleViewWith:nnextViewController];
	// Center title view.
	_nnextTitleView.center = _titleView.center;
	[self.navigationItem.titleView addSubview:_nnextTitleView];

	return nnextViewController;
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
			[_ppreviousTitleView removeFromSuperview];
			_ppreviousTitleView = nil;
		} else if (vc == _nextViewController) {
			_nextViewController = nil;
			[_nextTitleView removeFromSuperview];
			_nextTitleView = nil;
		}

		if (vc == _ppreviousViewController) {
			_ppreviousViewController = nil;
			[_ppreviousTitleView removeFromSuperview];
			_ppreviousTitleView = nil;
		} else if (vc == _nnextViewController) {
			_nnextViewController = nil;
			[_nnextTitleView removeFromSuperview];
			_nnextTitleView = nil;
		}
		UIView *v = vc.view;
		[vc willMoveToParentViewController:nil];
		[v removeFromSuperview];
		[vc removeFromParentViewController];
        // FIXME: workaround for paging happens simultaneously with dismissing of page view controller.
        if (self.parentViewController == nil) {
            [vc viewDidDisappear:NO];
        }
	}
}

- (void)layoutContentView:(UIView *)contentView {
	[super layoutContentView:contentView];
	// Maintain the invariant relationships among previous view, content view and next view.
    CGFloat pageDistance = _pageSpacing + self.view.bounds.size.width;
	if (_previousViewController) {
		_previousViewController.view.frame = CGRectOffset(_contentController.view.frame, -pageDistance, 0.f);
	}
	if (_nextViewController) {
		_nextViewController.view.frame = CGRectOffset(_contentController.view.frame, pageDistance, 0.f);
	}
	if (_ppreviousViewController) {
		_ppreviousViewController.view.frame = CGRectOffset(_previousViewController.view.frame, -pageDistance, 0.f);
	}
	if (_nnextViewController) {
		_nnextViewController.view.frame = CGRectOffset(_nextViewController.view.frame, pageDistance, 0.f);
	}
}

#pragma mark - Configuration

- (void)setEnableTapPageTurning:(BOOL)enableTapPageTurning {
	_enableTapPageTurning = enableTapPageTurning;
	_tapGR.enabled = _enableTapPageTurning;
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
		titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.attributedText = [[NSAttributedString alloc] initWithString:viewController.navigationItem.title attributes:_titleTextAttributes];
		titleLabel.backgroundColor = [UIColor clearColor];
		subTitleView = titleLabel;
	}
	[subTitleView sizeToFit];
    subTitleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	return subTitleView;
}

- (void)setTitleTextAttributes:(NSDictionary *)titleTextAttributes {
    if ([_titleTextAttributes isEqual:titleTextAttributes]) return;
    
    _titleTextAttributes = [titleTextAttributes copy];
    
    if (_titleView != _contentController.navigationItem.titleView && _contentController.navigationItem.title != nil) {
        ((UILabel *)_titleView).attributedText = [[NSAttributedString alloc] initWithString:_contentController.navigationItem.title attributes:_titleTextAttributes];
        [_titleView sizeToFit];
    }
    
    if (_previousTitleView != _previousViewController.navigationItem.titleView && _previousViewController.navigationItem.title != nil) {
        ((UILabel *)_previousTitleView).attributedText = [[NSAttributedString alloc] initWithString:_previousViewController.navigationItem.title attributes:_titleTextAttributes];
        [_previousTitleView sizeToFit];
    }

    if (_nextTitleView != _nextViewController.navigationItem.titleView && _nextViewController.navigationItem.title != nil) {
        ((UILabel *)_nextTitleView).attributedText = [[NSAttributedString alloc] initWithString:_nextViewController.navigationItem.title attributes:_titleTextAttributes];
        [_nextTitleView sizeToFit];
    }
    
    if (_ppreviousTitleView != _ppreviousViewController.navigationItem.titleView && _ppreviousViewController.navigationItem.title != nil) {
        ((UILabel *)_ppreviousTitleView).attributedText = [[NSAttributedString alloc] initWithString:_ppreviousViewController.navigationItem.title attributes:_titleTextAttributes];
        [_ppreviousTitleView sizeToFit];
    }
    
    if (_nnextTitleView != _nnextViewController.navigationItem.titleView && _nnextViewController.navigationItem.title != nil) {
        ((UILabel *)_nnextTitleView).attributedText = [[NSAttributedString alloc] initWithString:_nnextViewController.navigationItem.title attributes:_titleTextAttributes];
        [_nnextTitleView sizeToFit];
    }
    
    self.navigationItem.titleView.bounds = _titleView.bounds;
}

#pragma mark - Paging

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _panGR) {
        CGPoint velocity = [_panGR velocityInView:_panGR.view];
        return fabs(velocity.x) > 2 * fabs(velocity.y);
    } else {
        return YES;
    }
}

- (void)pan:(UIPanGestureRecognizer *)gestureRecognizer {
	_isTransitioningContentView = YES;

	const CGRect bounds = self.view.bounds;
	CGPoint translation = [gestureRecognizer translationInView:self.view];
	const CGPoint boundsCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
	CGPoint center = _contentController.view.center;
    CGFloat pageDistance = _pageSpacing + bounds.size.width;

	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[CATransaction setDisableActions:YES];
		if ([_contentController.view.layer animationForKey:@"position.x"]) {
			_contentController.view.layer.position = ((CALayer *)_contentController.view.layer.presentationLayer).position;
			[_contentController.view.layer removeAnimationForKey:@"position.x"];
		}
		if ([_previousViewController.view.layer animationForKey:@"position.x"]) {
			CGPoint position = _contentController.view.layer.position;
			position.x -= pageDistance;
			_previousViewController.view.layer.position = position;
			[_previousViewController.view.layer removeAnimationForKey:@"position.x"];
		}
		if ([_ppreviousViewController.view.layer animationForKey:@"position.x"]) {
			CGPoint position = _contentController.view.layer.position;
			position.x -= 2 * pageDistance;
			_ppreviousViewController.view.layer.position = position;
			[_ppreviousViewController.view.layer removeAnimationForKey:@"position.x"];
		}
		if ([_nextViewController.view.layer animationForKey:@"position.x"]) {
			CGPoint position = _contentController.view.layer.position;
			position.x += pageDistance;
			_nextViewController.view.layer.position = position;
			[_nextViewController.view.layer removeAnimationForKey:@"position.x"];
		}
		if ([_nnextViewController.view.layer animationForKey:@"position.x"]) {
			CGPoint position = _contentController.view.layer.position;
			position.x += 2 * pageDistance;
			_nnextViewController.view.layer.position = position;
			[_nnextViewController.view.layer removeAnimationForKey:@"position.x"];
		}
		if ([_titleView.layer animationForKey:@"opacity"]) {
			_titleView.layer.opacity = ((CALayer *)_titleView.layer.presentationLayer).opacity;
			[_titleView.layer removeAnimationForKey:@"opacity"];
		}
		if ([_previousTitleView.layer animationForKey:@"opacity"]) {
			_previousTitleView.layer.opacity = ((CALayer *)_previousTitleView.layer.presentationLayer).opacity;
			[_previousTitleView.layer removeAnimationForKey:@"opacity"];
		}
		if ([_ppreviousTitleView.layer animationForKey:@"opacity"]) {
			_ppreviousTitleView.layer.opacity = ((CALayer *)_ppreviousTitleView.layer.presentationLayer).opacity;
			[_ppreviousTitleView.layer removeAnimationForKey:@"opacity"];
		}
		if ([_nextTitleView.layer animationForKey:@"opacity"]) {
			_nextTitleView.layer.opacity = ((CALayer *)_nextTitleView.layer.presentationLayer).opacity;
			[_nextTitleView.layer removeAnimationForKey:@"opacity"];
		}
		if ([_nnextTitleView.layer animationForKey:@"opacity"]) {
			_nnextTitleView.layer.opacity = ((CALayer *)_nnextTitleView.layer.presentationLayer).opacity;
			[_nnextTitleView.layer removeAnimationForKey:@"opacity"];
		}
		[CATransaction setDisableActions:NO];
		
		if ([_delegate respondsToSelector:@selector(pageViewController:willBeginPagingViewController:)]) {
			[_delegate pageViewController:self willBeginPagingViewController:_contentController];
		}
	} else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
		if (center.x < boundsCenter.x) {
			if (_nextViewController == nil) {
				// The end. Add some damping.
				translation.x /= 2.f;
			}
		} else if (center.x > boundsCenter.x) {
			if (_previousViewController == nil) {
				// The end. Add some damping.
				translation.x /= 2.f;
			}
		}

		center.x += translation.x;
		const CGFloat pageOffset = center.x - boundsCenter.x;

		if (center.x < boundsCenter.x) {
			if (_nextViewController == nil) {
				_nextViewController = [self loadNextPage];
			}
			// Title transition.
			if (_nextViewController) {
				_titleView.alpha = 1 - fabs(pageOffset) / pageDistance;
				_nextTitleView.alpha = 1 - _titleView.alpha;
			}
		} else if (center.x > boundsCenter.x) {
			if (_previousViewController == nil) {
				_previousViewController = [self loadPreviousPage];
			}
			// Title transition.
			if (_previousViewController) {
				_titleView.alpha = 1 - fabs(pageOffset) / pageDistance;
				_previousTitleView.alpha = 1 - _titleView.alpha;
			}
		}
		
		_contentController.view.center = center;
		CGPoint previousViewCenter = center;
		previousViewCenter.x -= pageDistance;
		_previousViewController.view.center = previousViewCenter;
		CGPoint nextViewCenter = center;
		nextViewCenter.x += pageDistance;
		_nextViewController.view.center = nextViewCenter;

		// Reset translation: I'm use incremental translation not accumulative translation.
		[gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
	} else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
		const CGFloat pageOffset = center.x - boundsCenter.x;
		// Elastic paging and bouncing modeled with damping.
		CGFloat w_0 = 0.7f; // natural frequency
		CGFloat zeta = 0.8f; // damping ratio for under-damping
		CGFloat w_d = w_0 * sqrt(1.f - zeta * zeta); // damped frequency
		CGFloat x_0 = pageOffset;
		
		CGPoint velocity = [gestureRecognizer velocityInView:self.view];
		// Scale velocity down.
		velocity.x /= 20.f;
		velocity.y /= 20.f;
		
		// Use critical damping to calculate the max displacement: x(t) = (A + B * t) * e^(-w_0 * t)
		// Use x(t)' = 0 to get the max x(t) — amplitude.
		// x(t)' = [B - w_0 * (A + B * t)] * e^(-w_0 * t)
		// x(t)' = 0 => t = 1 / w_0 - A / B.
		// x_max = (v_0 / w_0 + x_0) * e^[-v_0 / (v_0 + w_0 * x_0)]
		CGFloat A = x_0;
		CGFloat B = velocity.x + w_0 * x_0;
		CGFloat t_max = 1 / w_0 - A / B;
		CGFloat x_max = pow(M_E, -w_0 * t_max) * (A + B * t_max);
//		NSLog(@"v_0 = %f, x_0 = %f, t_max = %f, x_max = %f", velocity.x, x_0, t_max, x_max);

		BOOL turnToPreviousPage = NO;
		BOOL turnToNextPage = NO;
		if (x_max >= 0.5 * pageDistance || velocity.x > 40.f) {
			if (_previousViewController == nil) {
				_previousViewController = [self loadPreviousPage];
			}
			if (_previousViewController) {
				turnToPreviousPage = YES;
			}
		} else if (x_max <= -0.5 * pageDistance || velocity.x < -40.f) {
			if (_nextViewController == nil) {
				_nextViewController = [self loadNextPage];
			}
			if (_nextViewController) {
				turnToNextPage = YES;
			}
		}

		if (turnToPreviousPage) {
			// Turn to previous page.
			CGPoint previousViewCenter = _previousViewController.view.center;
			CGPoint newPreviousViewCenter = boundsCenter;
			CGPoint newCenter = CGPointMake(newPreviousViewCenter.x + pageDistance, newPreviousViewCenter.y);

			[CATransaction begin];
			[CATransaction setAnimationDuration:kPagingAnimationDuration];

			// Equilibrium postion is different, initial replacement is different.
			x_0 = previousViewCenter.x - newPreviousViewCenter.x;

			BOOL underDamping = NO;

			// Try critical damping first.
			// Limit x_max so that no more than 1 page is scrolled in one direction in one paging.
			// When v_0 is large, x_max can be approximated by (v_0 / w_0 + x_0) / e.
			const CGFloat X_MAX_LIMIT = 0;
			const CGFloat CRITICAL_VELOCITY = w_0 * (X_MAX_LIMIT * M_E - x_0);
			if (velocity.x > CRITICAL_VELOCITY) {
				underDamping = YES;
				velocity.x /= 1.5f;
			}

			if (underDamping) {
//				NSLog(@"Under-damping");
				// Limit x_max so that no more than 1 page is scrolled in one direction in one paging.
				const CGFloat VELOCITY_MAX_LIMIT = 180.f;
				if (velocity.x > VELOCITY_MAX_LIMIT) {
					velocity.x = VELOCITY_MAX_LIMIT;
				}
				A = x_0;
				B = (zeta * x_0 + velocity.x) / w_d;
				CGFloat a = B * w_d - A * zeta * w_0;
				CGFloat b = A * w_d + B * zeta * w_0;
				CGFloat sin_max = sqrt(a * a / (a * a + b * b));
				CGFloat theta_max;
				if (a * b > 0) {
					theta_max = asin(sin_max);
				} else {
					theta_max = M_PI - asin(sin_max);
				}
				t_max = theta_max / w_d;
				if (t_max > 0.f) {
					x_max = pow(M_E, -zeta * w_0 * t_max) * (A * cos(w_d * t_max) + B * sin(w_d * t_max));
//					NSLog(@"v_0 = %f, x_0 = %f, t_max = %f, x_max = %f", velocity.x, x_0, t_max, x_max);
					if (x_max > 0.f) {
						// Part of pre-previous view will be shown temporarily.
						_ppreviousViewController = [self loadPPreviousPage];
					}
				}
			} else {
//				NSLog(@"Critical damping");
				A = x_0;
				B = velocity.x + w_0 * x_0;
			}
			
			// Current view.
			CAKeyframeAnimation *pageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
			pageAnimation.delegate = self;
			pageAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
			NSUInteger steps = 100;
			NSMutableArray *pageAnimationValues = [NSMutableArray arrayWithCapacity:steps];
			CGFloat value;
			for (NSUInteger step = 0; step < steps; ++step) {
				CGFloat t = 0.1f * step;
				if (underDamping) {
					value = pow(M_E, -zeta * w_0 * t) * (A * cos(w_d * t) + B * sin(w_d * t)) + newCenter.x;
				} else {
					value = pow(M_E, -w_0 * t) * (A + B * t) + newCenter.x;
				}
				[pageAnimationValues addObject:@(value)];
			}
			pageAnimation.values = pageAnimationValues;
			[_contentController.view.layer addAnimation:pageAnimation forKey:pageAnimation.keyPath];
			_pagingAnimationCount++;
			[CATransaction setDisableActions:YES];
			_contentController.view.layer.position = newCenter;
			[CATransaction setDisableActions:NO];

			CAKeyframeAnimation *titleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
			titleAnimation.delegate = self;
			titleAnimation.timingFunction = pageAnimation.timingFunction;
			NSMutableArray *titleAnimationValues = [NSMutableArray arrayWithCapacity:steps];
			for (NSUInteger step = 0; step < steps; ++step) {
				value = 1.f - fabs([pageAnimationValues[step] floatValue] - boundsCenter.x) / pageDistance;
				[titleAnimationValues addObject:@(value)];
			}
			titleAnimation.values = titleAnimationValues;
			[_titleView.layer addAnimation:titleAnimation forKey:titleAnimation.keyPath];
			_pagingAnimationCount++;
			[CATransaction setDisableActions:YES];
			_titleView.layer.opacity = 0.f;
			[CATransaction setDisableActions:NO];

			// Previous view.
			[pageAnimationValues removeAllObjects];
			for (NSUInteger step = 0; step < steps; ++step) {
				CGFloat t = 0.1f * step;
				if (underDamping) {
					value = pow(M_E, -zeta * w_0 * t) * (A * cos(w_d * t) + B * sin(w_d * t)) + newPreviousViewCenter.x;
				} else {
					value = pow(M_E, -w_0 * t) * (A + B * t) + newPreviousViewCenter.x;
				}
				[pageAnimationValues addObject:@(value)];
			}
			pageAnimation.values = pageAnimationValues;
			[_previousViewController.view.layer addAnimation:pageAnimation forKey:pageAnimation.keyPath];
			_pagingAnimationCount++;
			[CATransaction setDisableActions:YES];
			_previousViewController.view.layer.position = newPreviousViewCenter;
			[CATransaction setDisableActions:NO];

			[titleAnimationValues removeAllObjects];
			for (NSUInteger step = 0; step < steps; ++step) {
				value = 1.f - fabs([pageAnimationValues[step] floatValue] - boundsCenter.x) / pageDistance;
				[titleAnimationValues addObject:@(value)];
			}
			titleAnimation.values = titleAnimationValues;
			[_previousTitleView.layer addAnimation:titleAnimation forKey:titleAnimation.keyPath];
			_pagingAnimationCount++;
			[CATransaction setDisableActions:YES];
			_previousTitleView.layer.opacity = 1.f;
			[CATransaction setDisableActions:NO];

			if (_ppreviousViewController) {
				CGPoint newPPreviousViewCenter = CGPointMake(newPreviousViewCenter.x - pageDistance, newPreviousViewCenter.y);
				[pageAnimationValues removeAllObjects];
				for (NSUInteger step = 0; step < steps; ++step) {
					CGFloat t = 0.1f * step;
					if (underDamping) {
						value = pow(M_E, -zeta * w_0 * t) * (A * cos(w_d * t) + B * sin(w_d * t)) + newPPreviousViewCenter.x;
					} else {
						value = pow(M_E, -w_0 * t) * (A + B * t) + newPPreviousViewCenter.x;
					}
					[pageAnimationValues addObject:@(value)];
				}
				pageAnimation.values = pageAnimationValues;
				[_ppreviousViewController.view.layer addAnimation:pageAnimation forKey:pageAnimation.keyPath];
				_pagingAnimationCount++;
				[CATransaction setDisableActions:YES];
				_ppreviousViewController.view.layer.position = newPPreviousViewCenter;
				[CATransaction setDisableActions:NO];

				[titleAnimationValues removeAllObjects];
				for (NSUInteger step = 0; step < steps; ++step) {
					value = 1.f - fabs([pageAnimationValues[step] floatValue] - boundsCenter.x) / pageDistance;
					[titleAnimationValues addObject:@(value)];
				}
				titleAnimation.values = titleAnimationValues;
				[_ppreviousTitleView.layer addAnimation:titleAnimation forKey:titleAnimation.keyPath];
				_pagingAnimationCount++;
				[CATransaction setDisableActions:YES];
				_ppreviousTitleView.layer.opacity = 0.f;
				[CATransaction setDisableActions:NO];
			}

			// Next view.
			if (_nextViewController) {
				if (_nextViewController != _ppreviousViewController) {
					CGPoint newNextViewCenter = CGPointMake(newCenter.x + pageDistance, newCenter.y);
					[pageAnimationValues removeAllObjects];
					for (NSUInteger step = 0; step < steps; ++step) {
						CGFloat t = 0.1f * step;
						if (underDamping) {
							value = pow(M_E, -zeta * w_0 * t) * (A * cos(w_d * t) + B * sin(w_d * t)) + newNextViewCenter.x;
						} else {
							value = pow(M_E, -w_0 * t) * (A + B * t) + newNextViewCenter.x;
						}
						[pageAnimationValues addObject:@(value)];
					}
					pageAnimation.values = pageAnimationValues;
					[_nextViewController.view.layer addAnimation:pageAnimation forKey:pageAnimation.keyPath];
					_pagingAnimationCount++;
					[CATransaction setDisableActions:YES];
					_nextViewController.view.layer.position = newNextViewCenter;
					[CATransaction setDisableActions:NO];
				}

				if (_nextTitleView != _ppreviousTitleView) {
					[titleAnimationValues removeAllObjects];
					for (NSUInteger step = 0; step < steps; ++step) {
						value = 1.f - fabs([pageAnimationValues[step] floatValue] - boundsCenter.x) / pageDistance;
						[titleAnimationValues addObject:@(value)];
					}
					titleAnimation.values = titleAnimationValues;
					[_nextTitleView.layer addAnimation:titleAnimation forKey:titleAnimation.keyPath];
					_pagingAnimationCount++;
					[CATransaction setDisableActions:YES];
					_nextTitleView.layer.opacity = 0.f;
					[CATransaction setDisableActions:NO];
				}
			}

			[CATransaction commit];
		} else if (turnToNextPage) {
			// Turn to next page.
			CGPoint nextViewCenter = _nextViewController.view.center;
			CGPoint newNextViewCenter = boundsCenter;
			CGPoint newCenter = CGPointMake(newNextViewCenter.x - pageDistance, newNextViewCenter.y);

			[CATransaction begin];
			[CATransaction setAnimationDuration:kPagingAnimationDuration];

			// Equilibrium postion is different, initial replacement is different.
			x_0 = nextViewCenter.x - newNextViewCenter.x;

			BOOL underDamping = NO;

			// Try critical damping first.
			// Limit x_max so that no more than 1 page is scrolled in one direction in one paging.
			// When v_0 is large, x_max can be approximated by (v_0 / w_0 + x_0) / e.
			const CGFloat X_MIN_LIMIT = 0;
			const CGFloat VELOCITY_MIN_LIMIT = w_0 * (X_MIN_LIMIT * M_E - x_0);
			if (velocity.x < VELOCITY_MIN_LIMIT) {
				underDamping = YES;
				velocity.x /= 1.5f;
			}

			if (underDamping) {
//				NSLog(@"Under-damping");
				// Limit x_max so that no more than 1 page is scrolled in one direction in one paging.
				const CGFloat VELOCITY_MAX_LIMIT = 180.f;
				if (velocity.x < -VELOCITY_MAX_LIMIT) {
					velocity.x = -VELOCITY_MAX_LIMIT;
				}
				A = x_0;
				B = (zeta * x_0 + velocity.x) / w_d;
				CGFloat a = B * w_d - A * zeta * w_0;
				CGFloat b = A * w_d + B * zeta * w_0;
				CGFloat sin_max = sqrt(a * a / (a * a + b * b));
				CGFloat theta_max;
				if (a * b > 0) {
					theta_max = asin(sin_max);
				} else {
					theta_max = M_PI - asin(sin_max);
				}
				t_max = theta_max / w_d;
				if (t_max > 0.f) {
					x_max = pow(M_E, -zeta * w_0 * t_max) * (A * cos(w_d * t_max) + B * sin(w_d * t_max));
//					NSLog(@"v_0 = %f, x_0 = %f, t_max = %f, x_max = %f", velocity.x, x_0, t_max, x_max);
					if (x_max < 0.f) {
						// Part of next-next view will be shown temporarily.
						_nnextViewController = [self loadNNextPage];
					}
				}
			} else {
//				NSLog(@"Critical damping");
				A = x_0;
				B = velocity.x + w_0 * x_0;
			}
			
			// Current view.
			CAKeyframeAnimation *pageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
			pageAnimation.delegate = self;
			pageAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
			NSUInteger steps = 100;
			NSMutableArray *pageAnimationValues = [NSMutableArray arrayWithCapacity:steps];
			CGFloat value;
			for (NSUInteger step = 0; step < steps; ++step) {
				CGFloat t = 0.1f * step;
				if (underDamping) {
					value = pow(M_E, -zeta * w_0 * t) * (A * cos(w_d * t) + B * sin(w_d * t)) + newCenter.x;
				} else {
					value = pow(M_E, -w_0 * t) * (A + B * t) + newCenter.x;
				}
				[pageAnimationValues addObject:@(value)];
			}
			pageAnimation.values = pageAnimationValues;
			[_contentController.view.layer addAnimation:pageAnimation forKey:pageAnimation.keyPath];
			_pagingAnimationCount++;
			[CATransaction setDisableActions:YES];
			_contentController.view.layer.position = newCenter;
			[CATransaction setDisableActions:NO];

			CAKeyframeAnimation *titleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
			titleAnimation.delegate = self;
			titleAnimation.timingFunction = pageAnimation.timingFunction;
			NSMutableArray *titleAnimationValues = [NSMutableArray arrayWithCapacity:steps];
			for (NSUInteger step = 0; step < steps; ++step) {
				value = 1.f - fabs([pageAnimationValues[step] floatValue] - boundsCenter.x) / pageDistance;
				[titleAnimationValues addObject:@(value)];
			}
			titleAnimation.values = titleAnimationValues;
			[_titleView.layer addAnimation:titleAnimation forKey:titleAnimation.keyPath];
			_pagingAnimationCount++;
			[CATransaction setDisableActions:YES];
			_titleView.layer.opacity = 0.f;
			[CATransaction setDisableActions:NO];

			// Previous view.
			if (_previousViewController) {
				if (_previousViewController != _nnextViewController) {
					CGPoint newPreviousViewCenter = CGPointMake(newCenter.x - pageDistance, newCenter.y);
					[pageAnimationValues removeAllObjects];
					for (NSUInteger step = 0; step < steps; ++step) {
						CGFloat t = 0.1f * step;
						if (underDamping) {
							value = pow(M_E, -zeta * w_0 * t) * (A * cos(w_d * t) + B * sin(w_d * t)) + newPreviousViewCenter.x;
						} else {
							value = pow(M_E, -w_0 * t) * (A + B * t) + newPreviousViewCenter.x;
						}
						[pageAnimationValues addObject:@(value)];
					}
					pageAnimation.values = pageAnimationValues;
					[_previousViewController.view.layer addAnimation:pageAnimation forKey:pageAnimation.keyPath];
					_pagingAnimationCount++;
					[CATransaction setDisableActions:YES];
					_previousViewController.view.layer.position = newPreviousViewCenter;
					[CATransaction setDisableActions:NO];
				}

				if (_previousTitleView != _nnextTitleView) {
					[titleAnimationValues removeAllObjects];
					for (NSUInteger step = 0; step < steps; ++step) {
						value = 1.f - fabs([pageAnimationValues[step] floatValue] - boundsCenter.x) / pageDistance;
						[titleAnimationValues addObject:@(value)];
					}
					titleAnimation.values = titleAnimationValues;
					[_previousTitleView.layer addAnimation:titleAnimation forKey:titleAnimation.keyPath];
					_pagingAnimationCount++;
					[CATransaction setDisableActions:YES];
					_previousTitleView.layer.opacity = 0.f;
					[CATransaction setDisableActions:NO];
				}
			}
			
			// Next view.
			[pageAnimationValues removeAllObjects];
			for (NSUInteger step = 0; step < steps; ++step) {
				CGFloat t = 0.1f * step;
				if (underDamping) {
					value = pow(M_E, -zeta * w_0 * t) * (A * cos(w_d * t) + B * sin(w_d * t)) + newNextViewCenter.x;
				} else {
					value = pow(M_E, -w_0 * t) * (A + B * t) + newNextViewCenter.x;
				}
				[pageAnimationValues addObject:@(value)];
			}
			pageAnimation.values = pageAnimationValues;
			[_nextViewController.view.layer addAnimation:pageAnimation forKey:pageAnimation.keyPath];
			_pagingAnimationCount++;
			[CATransaction setDisableActions:YES];
			_nextViewController.view.layer.position = newNextViewCenter;
			[CATransaction setDisableActions:NO];

			[titleAnimationValues removeAllObjects];
			for (NSUInteger step = 0; step < steps; ++step) {
				value = 1.f - fabs([pageAnimationValues[step] floatValue] - boundsCenter.x) / pageDistance;
				[titleAnimationValues addObject:@(value)];
			}
			titleAnimation.values = titleAnimationValues;
			[_nextTitleView.layer addAnimation:titleAnimation forKey:titleAnimation.keyPath];
			_pagingAnimationCount++;
			[CATransaction setDisableActions:YES];
			_nextTitleView.layer.opacity = 1.f;
			[CATransaction setDisableActions:NO];

			if (_nnextViewController) {
				CGPoint newNNextViewCenter = CGPointMake(newNextViewCenter.x + pageDistance, newNextViewCenter.y);
				[pageAnimationValues removeAllObjects];
				for (NSUInteger step = 0; step < steps; ++step) {
					CGFloat t = 0.1f * step;
					if (underDamping) {
						value = pow(M_E, -zeta * w_0 * t) * (A * cos(w_d * t) + B * sin(w_d * t)) + newNNextViewCenter.x;
					} else {
						value = pow(M_E, -w_0 * t) * (A + B * t) + newNNextViewCenter.x;
					}
					[pageAnimationValues addObject:@(value)];
				}
				pageAnimation.values = pageAnimationValues;
				[_nnextViewController.view.layer addAnimation:pageAnimation forKey:pageAnimation.keyPath];
				_pagingAnimationCount++;
				[CATransaction setDisableActions:YES];
				_nnextViewController.view.layer.position = newNNextViewCenter;
				[CATransaction setDisableActions:NO];

				[titleAnimationValues removeAllObjects];
				for (NSUInteger step = 0; step < steps; ++step) {
					value = 1.f - fabs([pageAnimationValues[step] floatValue] - boundsCenter.x) / pageDistance;
					[titleAnimationValues addObject:@(value)];
				}
				titleAnimation.values = titleAnimationValues;
				[_nnextTitleView.layer addAnimation:titleAnimation forKey:titleAnimation.keyPath];
				_pagingAnimationCount++;
				[CATransaction setDisableActions:YES];
				_nnextTitleView.layer.opacity = 0.f;
				[CATransaction setDisableActions:NO];
			}
			
			[CATransaction commit];
		} else {
			// Bounce back to restore current page.
			[CATransaction begin];
			[CATransaction setAnimationDuration:kPagingAnimationDuration];

			if (t_max > 0.f) {
				if (x_max > 0.f) {
					if (_previousViewController == nil) {
						_previousViewController = [self loadPreviousPage];
					}
				} else if (x_max < 0.f) {
					if (_nextViewController == nil) {
						_nextViewController = [self loadNextPage];
					}
				}
			}

			// Current view.
			CAKeyframeAnimation *pageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
			pageAnimation.delegate = self;
			pageAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
			NSUInteger steps = 100;
			NSMutableArray *pageAnimationValues = [NSMutableArray arrayWithCapacity:steps];
			CGFloat value;
			for (NSUInteger step = 0; step < steps; ++step) {
				CGFloat t = 0.1f * step;
				value = pow(M_E, -w_0 * t) * (A + B * t) + boundsCenter.x;
				[pageAnimationValues addObject:@(value)];
			}
			pageAnimation.values = pageAnimationValues;
			[_contentController.view.layer addAnimation:pageAnimation forKey:pageAnimation.keyPath];
			_pagingAnimationCount++;
			[CATransaction setDisableActions:YES];
			_contentController.view.layer.position = boundsCenter;
			[CATransaction setDisableActions:NO];

			CAKeyframeAnimation *titleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
			titleAnimation.delegate = self;
			titleAnimation.timingFunction = pageAnimation.timingFunction;
			NSMutableArray *titleAnimationValues = [NSMutableArray arrayWithCapacity:steps];
			for (NSUInteger step = 0; step < steps; ++step) {
				value = 1.f - fabs([pageAnimationValues[step] floatValue] - boundsCenter.x) / pageDistance;
				[titleAnimationValues addObject:@(value)];
			}
			titleAnimation.values = titleAnimationValues;
			[_titleView.layer addAnimation:titleAnimation forKey:titleAnimation.keyPath];
			_pagingAnimationCount++;
			[CATransaction setDisableActions:YES];
			_titleView.layer.opacity = 1.f;
			[CATransaction setDisableActions:NO];

			// Previous view.
			if (_previousViewController) {
				CGPoint previousViewCenter = CGPointMake(boundsCenter.x - pageDistance, boundsCenter.y);
				[pageAnimationValues removeAllObjects];
				for (NSUInteger step = 0; step < steps; ++step) {
					CGFloat t = 0.1f * step;
					value = pow(M_E, -w_0 * t) * (A + B * t) + previousViewCenter.x;
					[pageAnimationValues addObject:@(value)];
				}
				pageAnimation.values = pageAnimationValues;
				[_previousViewController.view.layer addAnimation:pageAnimation forKey:pageAnimation.keyPath];
				_pagingAnimationCount++;
				[CATransaction setDisableActions:YES];
				_previousViewController.view.layer.position = previousViewCenter;
				[CATransaction setDisableActions:NO];
				
				[titleAnimationValues removeAllObjects];
				for (NSUInteger step = 0; step < steps; ++step) {
					value = 1.f - fabs([pageAnimationValues[step] floatValue] - boundsCenter.x) / pageDistance;
					[titleAnimationValues addObject:@(value)];
				}
				titleAnimation.values = titleAnimationValues;
				[_previousTitleView.layer addAnimation:titleAnimation forKey:titleAnimation.keyPath];
				_pagingAnimationCount++;
				[CATransaction setDisableActions:YES];
				_previousTitleView.layer.opacity = 0.f;
				[CATransaction setDisableActions:NO];
			}

			// Next view.
			if (_nextViewController) {
				CGPoint nextViewCenter = CGPointMake(boundsCenter.x + pageDistance, boundsCenter.y);
				[pageAnimationValues removeAllObjects];
				for (NSUInteger step = 0; step < steps; ++step) {
					CGFloat t = 0.1f * step;
					value = pow(M_E, -w_0 * t) * (A + B * t) + nextViewCenter.x;
					[pageAnimationValues addObject:@(value)];
				}
				pageAnimation.values = pageAnimationValues;
				[_nextViewController.view.layer addAnimation:pageAnimation forKey:pageAnimation.keyPath];
				_pagingAnimationCount++;
				[CATransaction setDisableActions:YES];
				_nextViewController.view.layer.position = nextViewCenter;
				[CATransaction setDisableActions:NO];

				[titleAnimationValues removeAllObjects];
				for (NSUInteger step = 0; step < steps; ++step) {
					value = 1.f - fabs([pageAnimationValues[step] floatValue] - boundsCenter.x) / pageDistance;
					[titleAnimationValues addObject:@(value)];
				}
				titleAnimation.values = titleAnimationValues;
				[_nextTitleView.layer addAnimation:titleAnimation forKey:titleAnimation.keyPath];
				_pagingAnimationCount++;
				[CATransaction setDisableActions:YES];
				_nextTitleView.layer.opacity = 0.f;
				[CATransaction setDisableActions:NO];
			}

			[CATransaction commit];
		}
	}
}

- (void)turnPage:(UITapGestureRecognizer *)gestureRecognizer
{
	if (_pagingAnimationCount > 0) return;

	if (gestureRecognizer.state != UIGestureRecognizerStateRecognized) return;
		
	if ([_delegate respondsToSelector:@selector(pageViewController:willBeginPagingViewController:)]) {
		[_delegate pageViewController:self willBeginPagingViewController:_contentController];
	}

	UIView *view = gestureRecognizer.view;
	CGPoint location = [gestureRecognizer locationInView:view];
	
	static const CGFloat TAP_MARGIN = 40.0;
	
	// Tap on left margin, turn backward.
	if (location.x < CGRectGetMinX(view.bounds) + TAP_MARGIN) {
		[self turnBackward];
	}
	// Tap on right margin, turn forward.
	else if (location.x > CGRectGetMaxX(view.bounds) - TAP_MARGIN) {
		[self turnForward];
	}
}

- (void)turnForward {
	_isTransitioningContentView = YES;

	if (_nextViewController == nil) {
		_nextViewController = [self loadNextPage];;
	}
	
	if (_nextViewController) {
		CGPoint center = _contentController.view.center;
		CGPoint nextViewCenter = _nextViewController.view.center;
		CGPoint translation = CGPointMake(center.x - nextViewCenter.x, center.y - nextViewCenter.y);
		CGPoint newCenter = CGPointMake(center.x + translation.x, center.y + translation.y);
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		[UIView animateWithDuration:kPagingAnimationDuration animations:^(void) {
			_contentController.view.center = newCenter;
			_nextViewController.view.center = center;
			_titleView.alpha = 0;
			_nextTitleView.alpha = 1;
		} completion:^(BOOL finished) {
			if (finished) {
				[self pagingDidEnd];
			}
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		}];
	}
}

- (void)turnBackward {
	_isTransitioningContentView = YES;

	if (_previousViewController == nil) {
		_previousViewController = [self loadPreviousPage];
	}
	
	if (_previousViewController) {
		CGPoint center = _contentController.view.center;
		CGPoint previousViewCenter = _previousViewController.view.center;
		CGPoint translation = CGPointMake(center.x - previousViewCenter.x, center.y - previousViewCenter.y);
		CGPoint newCenter = CGPointMake(center.x + translation.x, center.y + translation.y);
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		[UIView animateWithDuration:kPagingAnimationDuration animations:^(void) {
			_contentController.view.center = newCenter;
			_previousViewController.view.center = center;
			_titleView.alpha = 0;
			_previousTitleView.alpha = 1;
		} completion:^(BOOL finished) {
			if (finished) {
				[self pagingDidEnd];
			}
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		}];
	}
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	if (!flag) {
		_arePagingAnimationsCancelled = YES;
	}
	if (--_pagingAnimationCount == 0) {
		[self pagingDidEnd];
	}
}

- (void)pagingDidEnd
{
	UIViewController *oldContentController = _contentController;
	CGPoint center = _contentController.view.center;
	CGRect bounds = self.view.bounds;
	if (center.x > CGRectGetMaxX(bounds) && _previousViewController != nil) {
        // Land in the previous page.
		_nextViewController = _contentController;
		self.contentController = _previousViewController;
		_previousViewController = _ppreviousViewController;
		_ppreviousViewController = nil;

		_nextTitleView = _titleView;
		_titleView = _previousTitleView;
		_previousTitleView = _ppreviousTitleView;
		_ppreviousTitleView = nil;
		self.navigationItem.titleView.bounds = _titleView.bounds;
        _titleView.frame = self.navigationItem.titleView.bounds;
	} else if (center.x < CGRectGetMinX(bounds) && _nextViewController != nil) {
        // Land in the next page.
		_previousViewController = _contentController;
		self.contentController = _nextViewController;
		_nextViewController = _nnextViewController;
		_nnextViewController = nil;

		_previousTitleView = _titleView;
		_titleView = _nextTitleView;
		_nextTitleView = _nnextTitleView;
		_nnextTitleView = nil;
		self.navigationItem.titleView.bounds = _titleView.bounds;
        _titleView.frame = self.navigationItem.titleView.bounds;
	} else {
        // Land in the current page.
        [self unloadInvisiblePages];
    }

	_isTransitioningContentView = NO;
	_arePagingAnimationsCancelled = NO;

	if ([_delegate respondsToSelector:@selector(pageViewController:didEndPagingViewController:)]) {
		[_delegate pageViewController:self didEndPagingViewController:oldContentController];
	}
}

@end
