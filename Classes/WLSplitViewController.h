//
//  WLSplitViewController.h
//  WLContainerControllers
//
//  Created by Ling Wang on 12/1/10.
//  Copyright 2010 I Wonder Phone. All rights reserved.
//

#import "WLContainerController.h"


@interface WLSplitViewController : WLContainerController {
	NSArray *_viewControllers;
	UIViewController *_firstViewController;
	UIViewController *_secondViewController;
	UIImageView *_leftCorner;
	UIImageView *_rightCorner;
	UIImageView *_topCorner;
	UIImageView *_bottomCorner;
	double _splitPoint;
}

@property (nonatomic, copy) NSArray *viewControllers; ///< The array of view controllers managed by the receiver. The array in this property must contain exactly two view controllers. The view controllers are presented left-to-right/top-to-bottom in the split view interface when it is in a landscape/portrait orientation. Thus, the view controller at index 0 is displayed on the left/top side and the view controller at index 1 is displayed on the right/bottom side of the interface.

@property (nonatomic, assign) double splitPoint; ///< The split point of the two views. It is a decimal number between 0.0 and 1.0 inclusive.

@end
