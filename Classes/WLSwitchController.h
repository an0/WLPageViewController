//
//  WLSwitchController.h
//  WLSwitchController
//
//  Created by Wang Ling on 7/14/10.
//  Copyright 2010 I Wonder Phone. All rights reserved.
//

#import "WLMultiContentContainerController.h"

/**
 The WLSwitchController class implements a lightweight container controller that is intended to be used as a top tab bar controller - a UITabBarController with the tab bar on the top instead of bottom. However, the switch control is not a real tab bar as in UITabBarController but a UISegmentedControl, but the segments used as switch items are configured via the tabBarItem property of contained view controllers for convenience.

 It is designed to be used in cases where a tab bar interface is wanted but not suited, e.g., embeded in a navigation controller or another tab bar interface.

 Switch controllers are primarily used in navigation controllers, so the segmented control is embeded in a navigation bar via the navigationItem.titleView property of UIViewController.

 Switch items are configured through their corresponding view controller. To associate a switch item with a view controller, create a new instance of the UITabBarItem class, configure it appropriately for the view controller, and assign it to the view controller’s tabBarItem property. Because a segment can only have an image or a title and can’t have both, the image is used if both image and text are set. If you do not provide a custom tab bar item for your view controller, the view controller creates a default item containing no image and the text from the view controller’s title property.

 View switching should be done through the switch controller interface instead of directly manipulating the segmented control.

 Refer to the class reference of UITabBarController and UISegmentedControl.
 */
@interface WLSwitchController : WLMultiContentContainerController <UIViewControllerRestoration>

@property(nonatomic,strong, readonly) UISegmentedControl *switchBar; ///< The switch bar associated with this controller.

@end
