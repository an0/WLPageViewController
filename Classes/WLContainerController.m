//
//  WLContainerController.m
//  WLContainerController
//
//  Created by Wang Ling on 7/16/10.
//  Copyright I Wonder Phone 2010. All rights reserved.
//

#import "WLContainerController.h"


@interface WLContainerController ()

- (void)layoutBackgroundForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end



@implementation WLContainerController


@synthesize contentController = _contentController;
@synthesize contentInset = _contentInset;
@synthesize inheritsTitleView = _inheritsTitleView;
@synthesize inheritsLeftBarButtonItem = _inheritsLeftBarButtonItem;
@synthesize inheritsRightBarButtonItem = _inheritsRightBarButtonItem;
@synthesize inheritsToolbarItems = _inheritsToolbarItems;
@synthesize portraitBackgroundImage = _portraitBackgroundImage;
@synthesize landscapeBackgroundImage = _landscapeBackgroundImage;


- (id)init {
	return [self initWithContentController:nil];
}

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
}




#pragma mark - Content View management

- (void)setContentController:(UIViewController *)contentController {
	if (_contentController != contentController) {
		[_contentController willMoveToParentViewController:nil];
		[self addChildViewController:contentController];
		if (self.isViewLoaded) {
			[_contentController.view removeFromSuperview];
			[self.view addSubview:contentController.view];
		}
		[contentController didMoveToParentViewController:self];	
		[_contentController removeFromParentViewController];
		
		[self updateNavigationBarFrom:contentController];
		[self updateToolbarFrom:contentController];
		_contentController = contentController;
	}
}


- (UIView *)contentView {
	return self.contentController.view;
}

- (void)viewWillLayoutSubviews {
	UIView *contentView = _contentController.view;
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;			
	// Adjust the frame of the content view according to the insets.
	contentView.frame = UIEdgeInsetsInsetRect(self.view.bounds, self.contentInset);
}

- (void)setContentInset:(UIEdgeInsets)insets {
	_contentInset = insets;
	[self.view setNeedsLayout];
}


#pragma mark - Update navigation bar and toolbar

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




#pragma mark - View events

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Add background view.
	_backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view insertSubview:_backgroundView atIndex:0];
	// Add content view.
	if (self.contentView) {
		[self.view addSubview:self.contentView];
	}
}


#pragma mark - Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [_contentController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];	
	[self layoutBackgroundForInterfaceOrientation:toInterfaceOrientation];
}



#pragma mark - Background

- (void)layoutBackgroundForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
		_backgroundView.image = _portraitBackgroundImage;
	} else {		
		_backgroundView.image = _landscapeBackgroundImage;
	}	
}



@end
