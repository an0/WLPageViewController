//
//  AppDelegate.m
//  WLContainerControllers
//
//  Created by Wang Ling on 7/16/10.
//  Copyright I Wonder Phone 2010. All rights reserved.
//

#import "AppDelegate.h"
#import "WLSwitchController.h"
#import "WLSplitViewController.h"
#import "WLTabBarController.h"
#import "WLNavigationController.h"
#import "ContentController.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "PageViewController.h"

@implementation AppDelegate {
	MasterViewController *_masterViewController;
	DetailViewController *_detailViewController;
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
	//	ContentController *aViewController = [[ContentController alloc] initWithNibName:@"AViewController" bundle:nil];
	//	aViewController.title = @"Seg A";
	//	ContentController *bViewController = [[ContentController alloc] initWithNibName:@"BViewController" bundle:nil];
	//	bViewController.title = @"Seg B";

	//	WLSwitchController *switchController = [[WLSwitchController alloc] init];
	//	switchController.viewControllers = [NSArray arrayWithObjects:aViewController, bViewController, nil];
	//	[navigationController pushViewController:switchController animated:NO];

	_masterViewController = [[MasterViewController alloc] initWithStyle:UITableViewStylePlain];
	_masterViewController.restorationIdentifier = @"master";
	_detailViewController = [[DetailViewController alloc] init];
	_detailViewController.restorationIdentifier = @"detail";
	WLSplitViewController *rootViewController = [[WLSplitViewController alloc] init];
	rootViewController.restorationIdentifier = @"root";
	rootViewController.showsSplitLine = NO;
	rootViewController.delegate = _detailViewController;
	rootViewController.viewControllers = [NSArray arrayWithObjects:_masterViewController, _detailViewController, nil];

	//	WLTabBarController *tabBarController = [[WLTabBarController alloc] init];
	//	tabBarController.viewControllers = [NSArray arrayWithObjects:aViewController, bViewController, nil];
	//	navigationController.viewControllers = [NSArray arrayWithObject:tabBarController];

	//	WLNavigationController *navController = [[WLNavigationController alloc] initWithRootViewController:aViewController];

	//	PageViewController *papeViewController = [PageViewController new];

	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_window.rootViewController = rootViewController;
	
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[_window makeKeyAndVisible];
	return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
	return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
	return YES;
}

- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
	if ([identifierComponents.lastObject isEqualToString:@"root"]) {
		return _window.rootViewController;
	} else if ([identifierComponents.lastObject isEqualToString:@"master"]) {
		return _masterViewController;
	} else if ([identifierComponents.lastObject isEqualToString:@"detail"]) {
		return _detailViewController;
	} else {
		return nil;
	}
}



#pragma mark -
#pragma mark WLSplitViewControllerDelegate methods

- (void)splitViewController:(WLSplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController {
	DLog(@"popover");
}

- (void)splitViewController:(WLSplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
	DLog(@"willHideViewController");
	barButtonItem.title = @"Master";
	_detailViewController.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(WLSplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button {
	DLog(@"willShowViewController");
	_detailViewController.navigationItem.leftBarButtonItem = nil;	
}

@end

