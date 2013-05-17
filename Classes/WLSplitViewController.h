//
//  WLSplitViewController.h
//  WLContainerControllers
//
//  Created by Ling Wang on 12/1/10.
//  Copyright 2010 I Wonder Phone. All rights reserved.
//

#import "WLContainerController.h"

@protocol WLSplitViewControllerDelegate;

@interface WLSplitViewController : WLContainerController <UIViewControllerRestoration> {
	NSArray *_viewControllers;
	UIViewController *_masterViewController;
	UIViewController *_detailViewController;
	UIImageView *_leftCorner;
	UIImageView *_rightCorner;
	UIImageView *_topCorner;
	UIImageView *_bottomCorner;
	CGFloat _splitPosition;
    CGFloat _gutterWidth;
	BOOL _showsSplitLine;
	BOOL _hidesMasterViewInPortrait;
	UIPopoverController *_poController;
	UIBarButtonItem *_barButtonItem;
	BOOL _isMasterViewShown;
}

@property (nonatomic, copy) NSArray *viewControllers; ///< The array of view controllers managed by the receiver. The array in this property must contain exactly two view controllers. The view controllers are presented left-to-right/top-to-bottom in the split view interface when it is in a landscape/portrait orientation. Thus, the view controller at index 0 is displayed on the left/top side and the view controller at index 1 is displayed on the right/bottom side of the interface.

@property (nonatomic, assign) CGFloat splitPosition; ///< The split position of the two views.

@property (nonatomic, assign) CGFloat gutterWidth; ///< The width of gutter containing the split line.

@property (nonatomic, assign) BOOL showsSplitLine; ///< The flag indicating whether to show split line. The default is YES.

@property (nonatomic, strong) UIImage *portraitBackgroundImage;
@property (nonatomic, strong) UIImage *landscapeBackgroundImage;

@property (nonatomic, assign) BOOL hidesMasterViewInPortrait; ///< The flag indicating whether to hide master view in portrait. The default is YES.

@property (nonatomic, assign) IBOutlet id <WLSplitViewControllerDelegate> delegate; ///< The delegate you want to receive split view controller messages.



@end




@protocol WLSplitViewControllerDelegate <NSObject>

@optional

- (void)splitViewController:(WLSplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController;

- (void)splitViewController:(WLSplitViewController *)svc popoverController:(UIPopoverController *)pc willDismissViewController:(UIViewController *)aViewController;

- (void)splitViewController:(WLSplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc;

- (void)splitViewController:(WLSplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button;


@end


