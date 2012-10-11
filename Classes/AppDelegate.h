//
//  AppDelegate.h
//  WLContainerControllers
//
//  Created by Wang Ling on 7/16/10.
//  Copyright I Wonder Phone 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLSplitViewController.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, WLSplitViewControllerDelegate>

@property (nonatomic, retain) UIWindow *window;

@end

