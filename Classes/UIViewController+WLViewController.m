//
//  UIViewController+WLViewController.m
//  WLContainerControllers
//
//  Created by Ling Wang on 2/15/11.
//  Copyright 2011 I Wonder Phone. All rights reserved.
//

#import "UIViewController+WLViewController.h"
#import "NSObject+WLExtension.h"


@implementation UIViewController (WLViewController)


static CFMutableDictionaryRef theHostTable;


// Host Table management.
- (UIViewController *)hostController {
	return objc_unretainedObject(CFDictionaryGetValue(theHostTable, objc_unretainedPointer(self)));
}

- (void)setHostController:(UIViewController *)hostController {
	CFDictionarySetValue(theHostTable, objc_unretainedPointer(self), objc_unretainedPointer(hostController));
}

- (void)WLDealloc {
	CFDictionaryRemoveValue(theHostTable, objc_unretainedPointer(self));
	[self WLDealloc];
}


// Workaround for the read-only parentViewController property and private setParentViewController method.
- (UIViewController *)WLParentViewController {
	UIViewController *parentController = [self WLParentViewController];
	
	if (!parentController) {
		parentController = self.hostController;
	}
	
	return parentController;
}


// Workaround for the read-only interfaceOrientation property.

- (UIInterfaceOrientation)WLInterfaceOrientation {
	if (self.hostController) {
		return self.hostController.WLInterfaceOrientation;
	} else {
		return self.WLInterfaceOrientation;
	}
}


+ (void)load {
	// Do method swizzling.
	[UIViewController swizzleMethod:@selector(parentViewController) withMethod:@selector(WLParentViewController)];
	[UIViewController swizzleMethod:@selector(interfaceOrientation) withMethod:@selector(WLInterfaceOrientation)];
	[UIViewController swizzleMethod:@selector(dealloc) withMethod:@selector(WLDealloc)];
	// Initialize the Host Table.
	theHostTable = CFDictionaryCreateMutable(NULL, 20, NULL, NULL);
}

@end
