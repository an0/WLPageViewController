//
//  WLSwitchController.h
//  WLSwitchController
//
//  Created by Wang Ling on 7/14/10.
//  Copyright 2010 I Wonder Phone. All rights reserved.
//

#import "WLContainerController.h"

/**
 The WLSwitchController class implements a lightweight container controller that is intended to be used as a top tab bar controller - a UITabBarController with the tab bar on the top instead of bottom. However, the switch control is not a real tab bar as in UITabBarController but a UISegmentedControl, but the segments used as switch items are configured via the tabBarItem property of contained view controllers for convenience.

 It is designed to be used in cases where a tab bar interface is wanted but not suited, e.g., embeded in a navigation controller or another tab bar interface.

 Switch controllers are primarily used in navigation controllers, so the segmented control is embeded in a navigation bar via the navigationItem.titleView property of UIViewController.

 Switch items are configured through their corresponding view controller. To associate a switch item with a view controller, create a new instance of the UITabBarItem class, configure it appropriately for the view controller, and assign it to the view controller’s tabBarItem property. Because a segment can only have an image or a title and can’t have both, the image is used if both image and text are set. If you do not provide a custom tab bar item for your view controller, the view controller creates a default item containing no image and the text from the view controller’s title property.

 View switching should be done through the switch controller interface instead of directly manipulating the segmented control.

 Refer to the class reference of UITabBarController and UISegmentedControl.
 */
@interface WLSwitchController : WLContainerController {
@private
	UISegmentedControl *_switchBar;
	NSArray *_viewControllers;
}

@property(nonatomic,readonly) UISegmentedControl *switchBar; ///< The switch bar associated with this controller.
@property(nonatomic, copy) NSArray *viewControllers; ///< An array of the root view controllers displayed by the switch controller.
@property(nonatomic, assign) UIViewController *selectedViewController; ///<The view controller associated with the currently selected switch item.
@property(nonatomic) NSUInteger selectedIndex; ///< The index of the view controller associated with the currently selected switch item.



/**
 Sets the root view controllers of the switch controller.
 
 @param viewControllers The array of custom view controllers to display in the switch controller interface. The order of the view controllers in this array corresponds to the display order in the switch bar, with the controller at index 0 representing the left-most tab, the controller at index 1 the next tab to the right, and so on. It must be non-empty.

 @param animated If YES, the tab bar items for the view controllers are animated into position. If NO, changes to the tab bar items are reflected immediately.
 */
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;



@end
