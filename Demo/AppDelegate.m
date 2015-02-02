//
//  AppDelegate.m
//  WLPageViewController
//
//  Created by Ling Wang on 6/7/13.
//  Copyright (c) 2013 Moke. All rights reserved.
//

#import "AppDelegate.h"
#import "PageViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
	self.window.rootViewController = [PageViewController new];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
