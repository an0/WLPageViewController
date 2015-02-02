//  Created by Ling Wang on 1/31/15.
//  Copyright (c) 2015 I Wonder Phone. All rights reserved.

#import "WLCompositeController.h"

@implementation WLCompositeController {
    NSMutableArray *_viewControllers;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIViewController *vc in _viewControllers) {
        [self.contentView addSubview:vc.view];
    }
}

- (UIView *)contentView {
    return self.view;
}

- (BOOL)shouldAutorotate {
    for (UIViewController *vc in _viewControllers) {
        if (![vc shouldAutorotate]) {
            return NO;
        }
    }
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    NSUInteger mask;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        mask = UIInterfaceOrientationMaskAll;
    } else {
        mask = UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
    for (UIViewController *vc in _viewControllers) {
        mask &= [vc supportedInterfaceOrientations];
    }
    
    return mask;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutContentView];
}

- (void)layoutContentView {
    
}

#pragma mark - Managing the View Controllers

- (void)setViewControllers:(NSArray *)viewControllers {
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    if ([_viewControllers isEqualToArray:viewControllers]) return;
    
    for (UIViewController *vc in _viewControllers) {
        [vc willMoveToParentViewController:nil];
        if (self.isViewLoaded) {
            [vc.view removeFromSuperview];
        }
        [vc removeFromParentViewController];
    }
    
    for (UIViewController *vc in viewControllers) {
        [self addChildViewController:vc];
        if (self.isViewLoaded) {
            [self.contentView addSubview:vc.view];
        }
        [vc didMoveToParentViewController:self];
    }
    
    _viewControllers = [viewControllers mutableCopy];
}

- (void)replaceViewControllerAtIndex:(NSUInteger)index withViewController:(UIViewController *)viewController {
    UIViewController *vc = _viewControllers[index];
    if (vc == viewController) return;
    
    [self addChildViewController:viewController];
    [vc willMoveToParentViewController:nil];
    if (self.isViewLoaded) {
        [vc.view removeFromSuperview];
        [self.contentView addSubview:viewController.view];
    }
    [viewController didMoveToParentViewController:self];
    [vc removeFromParentViewController];
    
    _viewControllers[index] = viewController;
}

@end
