//
//  WLContainerController.h
//  WLContainerController
//
//  Created by Wang Ling on 7/16/10.
//  Copyright I Wonder Phone 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 The WLContainerController class implements a generic container controller that manages a content controller.
 */
@interface WLContainerController : UIViewController {
@protected
	UIViewController *_contentController;
}

@property (nonatomic, retain) UIViewController *contentController; ///< The content controller managed by the container controller.
@property (nonatomic, assign) UIEdgeInsets contentInset; ///< The distance that the content view is inset from the enclosing view.
@property (nonatomic, readonly) UIView *contentView; ///< A shortcut to access the view of the content controller.
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) BOOL inheritsTitle; ///< A Boolean value indicating whether the container controller inherits the title and navigationItem.title properties from the content controller. It has effect only when a new content controller is assigned.
@property (nonatomic, assign) BOOL inheritsTitleView; ///< A Boolean value indicating whether the container controller inherits the navigationItem.titleView property from the content controller. It has effect only when a new content controller is assigned.
@property (nonatomic, assign) BOOL inheritsLeftBarButtonItem; ///< A Boolean value indicating whether the container controller inherits the navigationItem.leftBarButtonItem property from the content controller. It has effect only when a new content controller is assigned.
@property (nonatomic, assign) BOOL inheritsRightBarButtonItem; ///< A Boolean value indicating whether the container controller inherits the navigationItem.rightBarButtonItem property from the content controller. It has effect only when a new content controller is assigned.
@property (nonatomic, assign) BOOL inheritsToolbarItems; ///< A Boolean value indicating whether the container controller inherits the toolbarItems property from the content controller. It has effect only when a new content controller is assigned. Notice: WLContainerController will change navigationBarController.toolbarHidden, so its parent view controller may have to restore navigationBarController.toolbarHidden after poping it.
		   

/**
 Initializes and returns a newly created container controller.
 
 This is a convenience method for initializing the receiver and embed a view controller in it.
 
 @param contentController The view controller that is contained in the container controller.
 
 @return The initialized container controller object or nil if there was a problem initializing the object.
 
 */
- (id)initWithContentController:(UIViewController *)contentController;



#pragma mark -
#pragma mark Protected methods

- (void)updateNavigationBarFrom:(UIViewController *)contentController;
- (void)updateToolbarFrom:(UIViewController *)contentController;

@end

