//  Created by Wang Ling on 7/16/10.
//  Copyright I Wonder Phone 2010. All rights reserved.

#import <UIKit/UIKit.h>

/**
 The WLContainerController class implements a generic container controller that manages a content controller.
 */
@interface WLContainerController : UIViewController {
@protected
	UIViewController *_contentController;
	BOOL _isTransitioningContentView;
}

@property (nonatomic, retain) UIViewController *contentController;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) BOOL inheritsTitle;
@property (nonatomic, assign) BOOL inheritsTitleView;
@property (nonatomic, assign) BOOL inheritsLeftBarButtonItems;
@property (nonatomic, assign) BOOL inheritsRightBarButtonItems;
@property (nonatomic, assign) BOOL inheritsBackBarButtonItem;
@property (nonatomic, assign) BOOL inheritsToolbarItems;
@property (nonatomic, assign) BOOL inheritsTabBarItem;

@property (nonatomic, readonly) BOOL isViewVisible;

#pragma mark - Protected methods

- (void)unregisterKVOForNavigationBar;
- (void)unregisterKVOForToolbar;
- (void)unregisterKVOForTabBar;
- (void)updateNavigationBar;
- (void)updateToolbar;
- (void)updateTabBar;
- (void)layoutContentView:(UIView *)contentView;

@end

